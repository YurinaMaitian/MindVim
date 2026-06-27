-- lua/plugins/java.lua
-- Java 开发环境：自动检测 JDK 和 JDTLS 路径
-- 手动指定路径请编辑 lua/config/userenv.lua

local userenv = require("config.userenv")

return {
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        dependencies = { "akinsho/toggleterm.nvim" },
        config = function()
            local jdtls = require("jdtls")
            local Terminal = require("toggleterm.terminal").Terminal

            -- 自动检测 JDK 和 JDTLS
            local jdk_path = userenv.detect_jdk()
            local jdtls_path = userenv.detect_jdtls()

            -- 启动时检查必要组件
            if not jdk_path then
                vim.notify(
                    "未找到 JDK，请在 lua/config/userenv.lua 中手动指定 M.java.jdk_path",
                    vim.log.levels.WARN
                )
            end
            if not jdtls_path then
                vim.notify(
                    "未找到 JDTLS，请在 lua/config/userenv.lua 中手动指定 M.java.jdtls_path",
                    vim.log.levels.WARN
                )
            end

            local java_term = nil

            -- F5 编译运行（输出到缓存目录，避免在项目内生成 .class 触发 JDTLS 重新索引）
            local function save_and_run_java()
                local bufnr = vim.api.nvim_get_current_buf()

                -- 用 noautocmd write 保存，绕过 LazyVim 的 format-on-save
                vim.cmd("noautocmd write")

                -- 延迟到写入完成后再开终端，避免焦点切换和 LSP 请求竞争
                vim.schedule(function()
                    local file = vim.api.nvim_buf_get_name(bufnr)
                    local dir = vim.fn.fnamemodify(file, ":p:h")
                    local class = vim.fn.fnamemodify(file, ":t:r")

                    -- 按当前文件所在目录命名输出目录，避免跨项目冲突
                    local project_name = vim.fn.fnamemodify(dir, ":p:h:t")
                    local run_output_dir = userenv.normalize_path(
                        vim.fn.stdpath("cache") .. "/java-run/" .. project_name
                    )

                    if vim.fn.isdirectory(run_output_dir) == 0 then
                        vim.fn.mkdir(run_output_dir, "p")
                    end

                    if not jdk_path then
                        vim.notify("请先配置 JDK 路径", vim.log.levels.ERROR)
                        return
                    end

                    local javac = userenv.get_java_bin(jdk_path, "javac")
                    local java = userenv.get_java_bin(jdk_path, "java")
                    local dir_norm = userenv.normalize_path(dir)
                    local file_norm = userenv.normalize_path(file)

                    -- 使用 userenv 的 cd 命令（平台自适应）
                    local cd_cmd = userenv.cd_command(dir_norm)

                    local cmd = string.format(
                        '%s && "%s" -d "%s" -cp "%s" "%s" && echo [编译成功，正在运行...] && "%s" -cp "%s" "%s"',
                        cd_cmd,
                        javac,
                        run_output_dir,
                        run_output_dir,
                        file_norm,
                        java,
                        run_output_dir,
                        class
                    )

                    if java_term and java_term:is_open() then
                        java_term:close()
                        java_term = nil
                    end

                    java_term = Terminal:new({
                        cmd = cmd,
                        direction = "horizontal",
                        size = 10,
                        close_on_exit = false,
                        auto_scroll = true,
                        on_close = function()
                            java_term = nil
                        end,
                        on_open = function(term)
                            vim.cmd("startinsert!")
                            vim.api.nvim_buf_set_name(term.bufnr, "Java: " .. class)
                        end,
                    })

                    java_term:open()
                end)
            end

            local java_augroup = vim.api.nvim_create_augroup("JavaLspSetup", { clear = true })

            -- 通过 FileType 事件为每个 Java buffer 启动 JDTLS，并绑定 F5
            vim.api.nvim_create_autocmd("FileType", {
                group = java_augroup,
                pattern = "java",
                callback = function(args)
                    -- 避免在 terminal / nofile 等特殊 buffer 上启动 LSP
                    if vim.bo[args.buf].buftype ~= "" then
                        return
                    end

                    -- 禁用 Java 文件的自动格式化
                    vim.b[args.buf].autoformat = false

                    if not jdk_path or not jdtls_path then
                        return
                    end

                    local root_dir = jdtls.setup.find_root({
                        ".git",
                        "mvnw",
                        "gradlew",
                        "pom.xml",
                        "build.gradle",
                        ".project",
                    })
                    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
                    local workspace_dir = userenv.normalize_path(
                        vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
                    )

                    local launcher_jar = userenv.get_jdtls_launcher(jdtls_path)
                    if not launcher_jar then
                        vim.notify("未找到 JDTLS launcher jar，请检查 JDTLS 安装", vim.log.levels.ERROR)
                        return
                    end

                    jdtls.start_or_attach({
                        cmd = {
                            userenv.get_java_bin(jdk_path, "java"),
                            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                            "-Dosgi.bundles.defaultStartLevel=4",
                            "-Declipse.product=org.eclipse.jdt.ls.core.product",
                            "-Dlog.protocol=true",
                            "-Dlog.level=ALL",
                            "-Xmx2g",
                            "-Xms1g",
                            "--add-modules=ALL-SYSTEM",
                            "--add-opens",
                            "java.base/java.util=ALL-UNNAMED",
                            "--add-opens",
                            "java.base/java.lang=ALL-UNNAMED",
                            "-jar",
                            launcher_jar,
                            "-configuration",
                            userenv.normalize_path(jdtls_path .. "/" .. userenv.get_jdtls_config_dir()),
                            "-data",
                            workspace_dir,
                        },
                        root_dir = root_dir,
                        on_attach = function(_, bufnr)
                            vim.notify("JDTLS 已启动", vim.log.levels.INFO)
                            vim.keymap.set("n", "<F5>", save_and_run_java, {
                                buffer = bufnr,
                                silent = true,
                                desc = "保存并运行 Java",
                            })
                            vim.keymap.set("n", "<leader>jo", function()
                                jdtls.organize_imports()
                            end, { buffer = bufnr, desc = "整理 imports" })
                        end,
                        settings = {
                            java = {
                                signatureHelp = { enabled = true },
                                completion = {
                                    favoriteStaticMembers = {
                                        "org.junit.Assert.*",
                                        "org.junit.jupiter.api.Assertions.*",
                                        "java.util.Objects.requireNonNull",
                                    },
                                    filteredTypes = {
                                        "com.sun.*",
                                        "java.awt.*",
                                        "jdk.*",
                                        "sun.*",
                                    },
                                },
                                sources = {
                                    organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
                                },
                                codeGeneration = {
                                    toString = {
                                        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                                    },
                                    useBlocks = true,
                                },
                                configuration = {
                                    runtimes = {
                                        { name = "JavaSE-21", path = jdk_path, default = true },
                                    },
                                },
                                import = {
                                    exclusions = {
                                        "**/node_modules/**",
                                        "**/.git/**",
                                        "**/target/**",
                                        "**/build/**",
                                        "**/bin/**",
                                        "**/.class",
                                    },
                                },
                            },
                        },
                        init_options = { bundles = {} },
                    })
                end,
            })

            -- 手动重启 JDTLS 命令
            vim.api.nvim_create_user_command("JavaLspRestart", function()
                vim.notify("正在关闭 JDTLS...", vim.log.levels.INFO)
                for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
                    vim.lsp.stop_client(client.id, true)
                end
                vim.defer_fn(function()
                    vim.cmd("doautocmd FileType")
                    vim.notify("JDTLS 已重启", vim.log.levels.INFO)
                end, 1000)
            end, {})
        end,
    },
}
