return {
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        dependencies = { "akinsho/toggleterm.nvim" },
        config = function()
            local jdtls = require("jdtls")
            local Terminal = require("toggleterm.terminal").Terminal

            -- 【确认】改成你实际安装的 JDK 路径
            local jdk_path = "C:\\Program Files\\Microsoft\\jdk-21.0.11.10-hotspot"
            local jdtls_path = "D:\\jdtls"

            local java_term = nil

            -- F5 编译运行（输出到缓存目录，避免在项目内生成 .class 触发 JDTLS 重新索引）
            local function save_and_run_java()
                local bufnr = vim.api.nvim_get_current_buf()

                -- 用 noautocmd write 保存，绕过 LazyVim 的 format-on-save。
                -- JDTLS 初始化/繁忙时格式化容易 timeout，应用部分编辑后还可能损坏文件。
                vim.cmd("noautocmd write")

                -- 延迟到写入完成后再开终端，避免焦点切换和 LSP 请求竞争
                vim.schedule(function()
                    local file = vim.api.nvim_buf_get_name(bufnr)
                    local dir = vim.fn.fnamemodify(file, ":p:h")
                    local class = vim.fn.fnamemodify(file, ":t:r")

                    -- 按当前文件所在目录命名输出目录，避免跨项目冲突
                    local project_name = vim.fn.fnamemodify(dir, ":p:h:t")
                    local run_output_dir = vim.fn.stdpath("cache")
                        .. "\\java-run\\"
                        .. project_name

                    if vim.fn.isdirectory(run_output_dir) == 0 then
                        vim.fn.mkdir(run_output_dir, "p")
                    end

                    local cmd = string.format(
                        'cd /d "%s" && "%s" -d "%s" -cp "%s" "%s" && echo [编译成功，正在运行...] && "%s" -cp "%s" "%s"',
                        dir,
                        jdk_path .. "\\bin\\javac.exe",
                        run_output_dir,
                        run_output_dir,
                        file,
                        jdk_path .. "\\bin\\java.exe",
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

                    -- 禁用 Java 文件的自动格式化。JDTLS 在初始化阶段响应格式化很慢，
                    -- 容易 timeout，甚至崩溃；需要格式化时可用 <leader>cf 手动触发。
                    vim.b[args.buf].autoformat = false

                    local root_dir = jdtls.setup.find_root({
                        ".git",
                        "mvnw",
                        "gradlew",
                        "pom.xml",
                        "build.gradle",
                        ".project",
                    })
                    local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
                    local workspace_dir = vim.fn.stdpath("data")
                        .. "\\jdtls-workspace\\"
                        .. project_name

                    jdtls.start_or_attach({
                        cmd = {
                            jdk_path .. "\\bin\\java.exe",
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
                            vim.fn.glob(jdtls_path .. "\\plugins\\org.eclipse.equinox.launcher_*.jar"),
                            "-configuration",
                            jdtls_path .. "\\config_win",
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
                                -- 把常见编译输出目录排除在 import 扫描之外，
                                -- 避免 JDTLS 因为 .class 文件触发不必要的刷新
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

            -- 【关键】手动重启 JDTLS 命令（不走 nvim-lspconfig 的默认配置）
            vim.api.nvim_create_user_command("JavaLspRestart", function()
                vim.notify("正在关闭 JDTLS...", vim.log.levels.INFO)
                for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
                    vim.lsp.stop_client(client.id, true)
                end
                vim.defer_fn(function()
                    -- 重新触发当前 buffer 的 FileType 事件即可启动
                    vim.cmd("doautocmd FileType")
                    vim.notify("JDTLS 已重启", vim.log.levels.INFO)
                end, 1000)
            end, {})
        end,
    },
}
