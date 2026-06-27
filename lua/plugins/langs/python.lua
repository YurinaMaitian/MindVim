-- lua/plugins/python.lua
-- Python 开发环境配置：自动检测 Python 路径
-- 可通过编辑 lua/config/userenv.lua 手动指定路径
-- 注意：同时需要检查 lsp-signature.lua，其中全局禁用了 signatureHelpProvider
--       如果你需要 Python 的函数签名提示，需要调整或移除该全局禁用

local userenv = require("config.userenv")
local conda_env = "py310" -- 你的 conda 环境名（可修改）

-- 自动检测 Python
local python_exe = userenv.detect_python(conda_env) or "python3"
-- 自动检测 basedpyright 和 ruff（优先从 conda 环境获取，否则依赖 PATH/Mason）
local basedpyright_exe = userenv.detect_conda_script(conda_env, "basedpyright-langserver")
local ruff_exe = userenv.detect_conda_script(conda_env, "ruff")

-- 构建 LSP cmd
local basedpyright_cmd = basedpyright_exe and { basedpyright_exe, "--stdio" } or nil
local ruff_cmd = ruff_exe and { ruff_exe, "server" } or nil

-- 构建 extraPaths
local function get_extra_paths()
    local paths = {}
    -- 如果检测到 conda，添加 site-packages
    if basedpyright_exe then
        local conda_base = vim.fn.fnamemodify(basedpyright_exe, ":h:h:h")
        if userenv.is_windows then
            table.insert(paths, conda_base .. "/Lib/site-packages")
        else
            -- Linux conda: <env>/lib/python3.x/site-packages/
            local py_ver = vim.fn
                .system({ python_exe, "-c", "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" })
                :gsub("%s+", "")
            if py_ver and py_ver ~= "" then
                table.insert(paths, conda_base .. "/lib/python" .. py_ver .. "/site-packages")
            end
        end
    end
    return paths
end

return {
    -- 1. 禁用 Mason 对 Python LSP 的自动安装，避免与本地版本冲突
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

                -- BasedPyright：优先使用本地版本，否则由 Mason 管理
                basedpyright = {
                    enabled = true,
                    mason = basedpyright_cmd == nil, -- 如未找到本地版本则允许 Mason 安装
                    cmd = basedpyright_cmd,
                    settings = {
                        basedpyright = {
                            analysis = {
                                pythonPath = python_exe,
                                typeCheckingMode = "basic",
                                autoImportCompletions = true,
                                useLibraryCodeForTypes = true,
                                autoSearchPaths = true,
                                extraPaths = get_extra_paths(),
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

                -- Ruff：优先使用本地版本，否则由 Mason 管理
                ruff = {
                    enabled = true,
                    mason = ruff_cmd == nil, -- 如未找到本地版本则允许 Mason 安装
                    cmd = ruff_cmd,
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
                    cmd = ruff_exe or "ruff",
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
                    command = ruff_exe or "ruff",
                    args = { "format", "--stdin-filename", "$FILENAME", "-" },
                    stdin = true,
                },
            },
        },
    },
}
