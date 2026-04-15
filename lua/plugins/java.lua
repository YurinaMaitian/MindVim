return {
    {
        "mfussenegger/nvim-jdtls",
        ft = "java",
        dependencies = { "akinsho/toggleterm.nvim" },
        config = function()
            local jdtls = require("jdtls")
            local Terminal = require("toggleterm.terminal").Terminal

            -- ==================== 路径配置（根据你的实际路径修改） ====================
            local jdk_path = "C:\\Program Files\\Microsoft\\jdk-21.0.7.6-hotspot"
            local jdtls_path = "D:\\jdtls"
            local workspace_dir = vim.fn.stdpath("data")
                .. "\\jdtls-workspace\\"
                .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

            -- ==================== JDTLS 启动配置 ====================
            local config = {
                cmd = {
                    jdk_path .. "\\bin\\java.exe",
                    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                    "-Dosgi.bundles.defaultStartLevel=4",
                    "-Declipse.product=org.eclipse.jdt.ls.core.product",
                    "-Dlog.protocol=true",
                    "-Dlog.level=ALL",
                    "-Xmx1g",
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
                    client.server_capabilities.progress = nil
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
                                {
                                    name = "JavaSE-21",
                                    path = jdk_path,
                                    default = true,
                                },
                            },
                        },
                    },
                },

                -- 初始化选项（调试相关，可选）
                init_options = {
                    bundles = {},
                },
            }

            -- 启动 LSP
            jdtls.start_or_attach(config)

            -- ==================== F5 编译运行（使用 Toggleterm） ====================
            local java_term = nil

            local function save_and_run_java()
                -- 强制保存
                vim.cmd("write")

                local file = vim.fn.expand("%:p") -- 完整路径：D:\Project\Main.java
                local dir = vim.fn.expand("%:p:h") -- 目录：D:\Project
                local class = vim.fn.expand("%:t:r") -- 类名：Main

                -- Windows 命令：编译并运行（处理空格路径）
                local cmd = string.format(
                    'cd /d "%s" && javac "%s" && echo [编译成功，正在运行...] && java "%s"',
                    dir,
                    file,
                    class
                )

                -- 关闭旧终端
                if java_term and java_term:is_open() then
                    java_term:close()
                    java_term = nil
                end

                -- 创建新终端（与 Python 共用 toggleterm 配置）
                java_term = Terminal:new({
                    cmd = cmd,
                    direction = "horizontal",
                    size = 10, -- 终端高度
                    close_on_exit = false, -- 编译错误时保留窗口查看
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

            -- 绑定 F5（仅当前 Java 文件）
            vim.keymap.set("n", "<F5>", save_and_run_java, {
                buffer = 0,
                silent = true,
                desc = "保存并运行 Java (javac + java)",
            })

            -- 额外的 Java 快捷键（可选）
            vim.keymap.set("n", "<leader>jo", function()
                jdtls.organize_imports()
            end, {
                buffer = 0,
                desc = "整理 imports",
            })
        end,
    },
}
