-- lua/plugins/langs/typescript.lua
-- TypeScript/JavaScript 开发环境配置
-- LSP: vtsls (推荐) / typescript-language-server
-- F5: node 直接运行 JS/TS 文件

local userenv = require("config.userenv")

-- F5 运行 JS/TS
local function save_and_run_js()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local file_clean = userenv.normalize_path(file)
  local ext = vim.fn.expand("%:e")

  local cmd
  if ext == "ts" or ext == "tsx" then
    -- 优先级: bun (原生 TS) > tsx > ts-node > npx
    if vim.fn.executable("bun") == 1 then
      cmd = string.format('bun run "%s"', file_clean)
    elseif vim.fn.executable("tsx") == 1 then
      cmd = string.format('tsx "%s"', file_clean)
    elseif vim.fn.executable("ts-node") == 1 then
      cmd = string.format('ts-node "%s"', file_clean)
    else
      cmd = string.format('npx ts-node "%s"', file_clean)
    end
  else
    -- JS: bun / node
    if vim.fn.executable("bun") == 1 then
      cmd = string.format('bun run "%s"', file_clean)
    else
      cmd = string.format('node "%s"', file_clean)
    end
  end

  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({
    cmd = cmd,
    direction = "horizontal",
    size = 12,
    close_on_exit = false,
    auto_scroll = true,
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_name(term.bufnr, "Node: " .. vim.fn.expand("%:t"))
    end,
  })
  term:open()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2

    vim.keymap.set("n", "<F5>", save_and_run_js, {
      buffer = true,
      silent = true,
      desc = "运行 JS/TS 文件",
    })
  end,
})

return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "javascript",
        "typescript",
        "tsx",
      })
    end,
  },

  -- LSP: vtsls (TypeScript/JavaScript)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              suggest = { completeFunctionCalls = true },
              inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
            javascript = {
              suggest = { completeFunctionCalls = true },
              inlayHints = {
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
          },
        },
      },
    },
  },

  -- Formatter: prettier
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },
    },
  },
}
