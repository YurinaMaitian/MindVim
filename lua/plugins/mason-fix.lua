return {
    -- 禁用 Mason 自动安装 basedpyright
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {},
            automatic_installation = {
                exclude = { "basedpyright", "ruff" },
            },
        },
    },

    -- 手动配置 basedpyright
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                pyright = { enabled = false, mason = false },
                basedpyright = {
                    enabled = true,
                    mason = false,
                    cmd = {
                        "C:\\Users\\19241\\.conda\\envs\\py310\\Scripts\\basedpyright-langserver.exe",
                        "--stdio",
                    },
                    -- 【删除】root_dir 这行！让 lspconfig 自动处理
                    -- 或者如果需要，用这个安全版本：
                    -- root_dir = require("lspconfig.util").find_git_ancestor,

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
