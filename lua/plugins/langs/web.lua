-- lua/plugins/web.lua
-- HTML/CSS/Vue 前端配置
-- 前置：fd 和 rg 已加入系统 PATH
-- 前置：treesitter 的 html/css/vue/js/ts parser 已安装

local userenv = require("config.userenv")

local function save_and_open_browser()
    vim.cmd("write")
    local file = vim.fn.expand("%:p")
    local ext = vim.fn.expand("%:e")

    if ext == "html" or ext == "htm" then
        -- 平台自适应的浏览器打开命令
        local cmd = userenv.open_browser_cmd(file)
        vim.fn.jobstart(cmd, { detach = true })
        print("已用浏览器打开: " .. vim.fn.expand("%:t"))
    elseif ext == "vue" then
        print("Vue 文件请运行 npm run dev")
    else
        print("当前文件类型不支持直接浏览器打开")
    end
end

-- 前端文件统一缩进（所有前端类型）
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "css", "vue", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
        vim.opt_local.softtabstop = 2
    end,
})

-- F5 仅对 HTML 文件：浏览器打开（JS/TS/Vue 有各自的 F5 处理器）
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "htm" },
    callback = function()
        vim.keymap.set("n", "<F5>", save_and_open_browser, {
            buffer = true,
            silent = true,
            desc = "保存并用浏览器打开 HTML",
        })
    end,
})

return {
    -- 1. 标签自动闭合 + 回车展开（核心）
    {
        "windwp/nvim-ts-autotag",
        event = "VeryLazy",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = true,
                },
                per_filetype = {
                    html = { enable_close = true },
                    vue = { enable_close = true },
                    javascript = { enable_close = true },
                    typescript = { enable_close = true },
                    xml = { enable_close = true },
                },
            })
        end,
    },

    -- 2. 自动配对（增强回车行为，避免和 autotag 冲突）
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                ts_config = {
                    html = { "string", "attribute_value" },
                    vue = { "string", "attribute_value" },
                    javascript = { "string", "template_string" },
                    typescript = { "string", "template_string" },
                },
            })
        end,
    },

    -- 3. Treesitter：语言 + 缩进（必须合并在一个 opts 函数里）
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.indent = opts.indent or {}
            opts.indent.enable = true

            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, {
                "html",
                "css",
                "vue",
                "javascript",
                "typescript",
            })

            opts.highlight = opts.highlight or {}
            opts.highlight.enable = true
        end,
    },

    -- 4. LSP
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                html = {
                    settings = {
                        html = {
                            format = { templating = true, wrapLineLength = 120 },
                            hover = { documentation = true, references = true },
                            validate = { scripts = true, styles = true },
                        },
                    },
                },
                cssls = {
                    settings = {
                        css = { validate = true, lint = { unknownAtRules = "ignore" } },
                        scss = { validate = true, lint = { unknownAtRules = "ignore" } },
                        less = { validate = true, lint = { unknownAtRules = "ignore" } },
                    },
                },
                volar = {
                    filetypes = { "vue" },
                    init_options = {
                        vue = { hybridMode = false },
                    },
                },
            },
        },
    },

    -- 5. 格式化
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                html = { "prettier" },
                css = { "prettier" },
                vue = { "prettier" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                json = { "prettier" },
            },
        },
    },
}
