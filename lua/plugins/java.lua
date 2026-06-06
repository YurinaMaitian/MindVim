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
            local workspace_dir = vim.fn.stdpath("data")
                .. "\\jdtls-workspace\\"
                .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

            local java_term = nil

            -- F5 编译运行（bin 目录隔离 .class）
            local function save_and_run_java()
                vim.cmd("write")
                local file = vim.fn.expand("%:p")
                local dir = vim.fn.expand("%:p:h")
                local class = vim.fn.expand("%:t:r")
                local bin_dir = dir .. "\\bin"

                if vim.fn.isdirectory(bin_dir) == 0 then
                    vim.fn.mkdir(bin_dir, "p")
                end

                local cmd = string.format(
                    'cd /d "%s" && "%s" -d "%s" -cp "%s" "%s" && echo [编译成功，正在运行...] && "%s" -cp "%s" "%s"',
                    dir,
                    jdk_path .. "\\bin\\javac.exe",
                    bin_dir,
                    bin_dir,
                    file,
                    jdk_path .. "\\bin\\java.exe",
                    bin_dir,
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
            end

            -- FileType 绑定 F5（不依赖 on_attach）
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function(args)
                    vim.keymap.set("n", "<F5>", save_and_run_java, {
                        buffer = args.buf,
                        silent = true,
                        desc = "保存并运行 Java",
                    })
                    vim.keymap.set("n", "<leader>jo", function()
                        jdtls.organize_imports()
                    end, { buffer = args.buf, desc = "整理 imports" })
                end,
            })

            -- JDTLS 配置
            local config = {
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
                root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }),
                on_attach = function(client, bufnr)
                    vim.notify("JDTLS 已启动", vim.log.levels.INFO)
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
                    },
                },
                init_options = { bundles = {} },
            }

            -- 【关键】手动重启 JDTLS 命令（不走 nvim-lspconfig 的默认配置）
            vim.api.nvim_create_user_command("JavaLspRestart", function()
                vim.notify("正在关闭 JDTLS...", vim.log.levels.INFO)
                for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
                    vim.lsp.stop_client(client.id, true)
                end
                vim.defer_fn(function()
                    jdtls.start_or_attach(config)
                    vim.notify("JDTLS 已重启", vim.log.levels.INFO)
                end, 1000)
            end, {})

            -- 启动 JDTLS
            jdtls.start_or_attach(config)
        end,
    },
}
