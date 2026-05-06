-- lua/plugins/python.lua
-- Python 开发环境配置：使用本地 Conda 环境的 basedpyright 和 ruff
-- 注意：同时需要检查 lsp-signarue.lua，其中全局禁用了 signatureHelpProvider
--       如果你需要 Python 的函数签名提示，需要调整或移除该全局禁用

local conda_env = "py310"
local conda_base = "C:\\Users\\19241\\.conda\\envs\\" .. conda_env
local python_exe = conda_base .. "\\python.exe"
local basedpyright_exe = conda_base .. "\\Scripts\\basedpyright-langserver.exe"
local ruff_exe = conda_base .. "\\Scripts\\ruff.exe"

return {
    -- 1. 禁用 Mason 对 Python LSP 的自动安装，避免与本地 Conda 版本冲突
    {
        "williamboman/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {},
            automatic_installation = {
                exclude = { "basedpyright", "ruff" },
            },
        },
    },

    -- 2. Python LSP 服务器配置
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- 完全禁用 pyright，避免与 basedpyright 冲突
                pyright = {
                    enabled = false,
                    autostart = false,
                    mason = false,
                },

                -- BasedPyright：使用本地 Conda 版本
                basedpyright = {
                    enabled = true,
                    mason = false,
                    cmd = {
                        basedpyright_exe,
                        "--stdio",
                    },
                    settings = {
                        basedpyright = {
                            analysis = {
                                pythonPath = python_exe,
                                typeCheckingMode = "basic",
                                autoImportCompletions = true,
                                useLibraryCodeForTypes = true,
                                autoSearchPaths = true,
                                extraPaths = {
                                    conda_base .. "\\Lib\\site-packages",
                                },
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

                -- Ruff：使用本地 Conda 版本（LSP server 模式）
                ruff = {
                    enabled = true,
                    mason = false,
                    cmd = {
                        ruff_exe,
                        "server",
                    },
                },
            },
        },
    },

    -- 3. 配置 ruff 作为 linter（nvim-lint）
    {
        "mfussenegger/nvim-lint",
        optional = true,
        opts = {
            linters_by_ft = {
                python = { "ruff" },
            },
            linters = {
                ruff = {
                    cmd = ruff_exe,
                },
            },
        },
    },

    -- 4. 配置 ruff 作为 formatter（conform.nvim）
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                python = { "ruff_format" },
            },
            formatters = {
                ruff_format = {
                    command = ruff_exe,
                    args = { "format", "--stdin-filename", "$FILENAME", "-" },
                    stdin = true,
                },
            },
        },
    },
}
