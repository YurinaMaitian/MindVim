return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- 双重保险禁用 pyright
                pyright = {
                    enabled = false,
                    autostart = false,
                    mason_install = false,
                },

                -- 强制启用 basedpyright
                basedpyright = {
                    enabled = true,
                    cmd = {
                        "C:\\Users\\19241\\.conda\\envs\\py310\\Scripts\\basedpyright-langserver.exe",
                        "--stdio",
                    },
                    settings = {
                        basedpyright = {
                            analysis = {
                                -- 关键：指定 Python 解释器
                                pythonPath = "C:\\Users\\19241\\.conda\\envs\\py310\\python.exe",
                                typeCheckingMode = "basic",
                                autoImportCompletions = true,
                                useLibraryCodeForTypes = true,
                                autoSearchPaths = true,
                                -- 单文件模式下手动加库路径
                                extraPaths = {
                                    "C:\\Users\\19241\\.conda\\envs\\py310\\Lib\\site-packages",
                                },
                                -- 如果还是报红，把错误变警告（先让能工作）
                                diagnosticSeverityOverrides = {
                                    reportOptionalMemberAccess = "none",
                                    reportAttributeAccessIssue = "warning",
                                    reportMissingModuleSource = "warning",
                                    reportMissingImports = "warning",
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}
