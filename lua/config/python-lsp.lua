return {
    -- 禁用 Mason 自动安装，使用本地 Conda 版本
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {},
            automatic_installation = {
                exclude = { "basedpyright", "ruff" },
            },
        },
    },

    -- Python LSP 配置
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- 完全禁用 pyright，避免冲突
                pyright = { enabled = false, mason = false },

                -- BasedPyright 配置（使用本地 Conda 版本）
                basedpyright = {
                    enabled = true,
                    mason = false, -- 关键：禁用 Mason 管理
                    cmd = {
                        "C:\\Users\\19241\\.conda\\envs\\py310\\Scripts\\basedpyright-langserver.exe",
                        "--stdio",
                    },
                    settings = {
                        basedpyright = {
                            analysis = {
                                pythonPath = "C:\\Users\\19241\\.conda\\envs\\py310\\python.exe",
                                typeCheckingMode = "basic",
                                autoImportCompletions = true,
                                useLibraryCodeForTypes = true,
                                autoSearchPaths = true,
                                extraPaths = {
                                    "C:\\Users\\19241\\.conda\\envs\\py310\\Lib\\site-packages",
                                },
                            },
                        },
                    },
                },

                -- Ruff 配置（使用本地 Conda 版本）
                ruff = {
                    enabled = true,
                    mason = false,
                    cmd = {
                        "C:\\Users\\19241\\.conda\\envs\\py310\\Scripts\\ruff.exe",
                        "server",
                    },
                },
            },
        },
    },
}
