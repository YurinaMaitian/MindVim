-- lua/plugins/lua.lua
-- Lua 开发环境：F5 直接运行，无需编译
-- 自动检测系统 lua 解释器，支持 Windows / Linux / macOS
-- 自定义路径请编辑 lua/config/userenv.lua

local userenv = require("config.userenv")

-- =============================================================================
-- 平台适配的运行命令生成
-- =============================================================================

--- 检测可用的 Lua 解释器
---@return string
local function detect_lua_interpreter()
    if userenv.is_windows then
        -- 优先检测常见名称
        local candidates = { "lua", "lua54", "lua53", "lua52" }
        for _, cmd in ipairs(candidates) do
            if vim.fn.executable(cmd) == 1 then
                return cmd
            end
        end
        return "lua" -- fallback
    else
        if vim.fn.executable("lua") == 1 then
            return "lua"
        elseif vim.fn.executable("lua5.4") == 1 then
            return "lua5.4"
        elseif vim.fn.executable("lua5.3") == 1 then
            return "lua5.3"
        end
        return "lua"
    end
end

--- 生成运行命令
---@param dir string 项目目录
---@param file string 源文件路径
---@return string
local function run_command(dir, file)
    local interpreter = detect_lua_interpreter()
    local file_clean = userenv.normalize_path(file)

    return string.format(
        '%s && echo [运行 Lua 脚本...] && %s "%s"',
        userenv.cd_command(dir),
        interpreter,
        file_clean
    )
end

-- =============================================================================
-- F5 保存并运行
-- =============================================================================

local lua_term = nil

local function save_and_run_lua()
    vim.cmd("write")
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t")

    local cmd = run_command(dir, file)

    if lua_term and lua_term:is_open() then
        lua_term:close()
        lua_term = nil
    end

    local Terminal = require("toggleterm.terminal").Terminal
    lua_term = Terminal:new({
        cmd = cmd,
        direction = "horizontal",
        size = 10,
        close_on_exit = false,
        auto_scroll = true,
        on_open = function(term)
            vim.cmd("startinsert!")
            -- pcall 避免 E325 ATTENTION 交换文件冲突
            pcall(vim.api.nvim_buf_set_name, term.bufnr, "Lua: " .. filename)
        end,
    })

    lua_term:open()
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
        vim.opt_local.softtabstop = 2
        vim.keymap.set("n", "<F5>", save_and_run_lua, { buffer = true, silent = true, desc = "保存并运行 Lua" })
    end,
})

-- =============================================================================
-- 插件配置
-- =============================================================================

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                                path = vim.split(package.path, ";"),
                            },
                            diagnostics = {
                                globals = { "vim" },
                            },
                            workspace = {
                                library = {
                                    vim.env.VIMRUNTIME,
                                    "${3rd}/luv/library",
                                },
                                checkThirdParty = false,
                            },
                            telemetry = { enable = false },
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },
            },
        },
    },

    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = { lua = { "stylua" } },
            formatters = {
                stylua = {
                    command = (function()
                        if vim.fn.executable("stylua") == 1 then
                            return "stylua"
                        end
                        return "stylua"
                    end)(),
                    args = { "--stdin-filepath", "$FILENAME", "-" },
                    stdin = true,
                },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "lua" })
        end,
    },
}
