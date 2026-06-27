-- lua/plugins/langs/rust.lua
-- Rust 开发环境配置
-- LSP: rust-analyzer
-- F5: cargo run（项目）/ rustc（单文件）

local userenv = require("config.userenv")

-- F5 编译运行
local function save_and_run_rust()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local dir_clean = userenv.normalize_path(dir)

  -- 判断是否在 cargo 项目中
  local is_cargo = vim.fn.filereadable(dir .. "/Cargo.toml") == 1
    or vim.fn.findfile("Cargo.toml", dir .. ";") ~= ""

  local cd_cmd = userenv.cd_command(dir_clean)
  local cmd

  if is_cargo then
    -- Cargo 项目：在项目根目录运行
    local root = vim.fn.fnamemodify(vim.fn.findfile("Cargo.toml", dir .. ";"), ":p:h")
    local root_clean = userenv.normalize_path(root)
    cmd = userenv.cd_command(root_clean) .. " && cargo run"
  else
    -- 单文件：rustc 编译并运行
    local filename_noext = vim.fn.expand("%:t:r")
    local output = dir_clean .. "/" .. filename_noext
    if userenv.is_windows then
      output = output .. ".exe"
    end
    cmd = string.format(
      '%s && rustc "%s" -o "%s" && echo [编译成功，正在运行...] && "%s"',
      cd_cmd,
      userenv.normalize_path(file),
      output,
      output
    )
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
      vim.api.nvim_buf_set_name(term.bufnr, "Rust: " .. vim.fn.expand("%:t"))
    end,
  })
  term:open()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 4

    vim.keymap.set("n", "<F5>", save_and_run_rust, {
      buffer = true,
      silent = true,
      desc = "运行 Rust（cargo run / rustc）",
    })
  end,
})

return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "rust" })
    end,
  },

  -- LSP: rust-analyzer
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
              cargo = { allFeatures = true },
              procMacro = { enable = true },
              inlayHints = {
                bindingModeHints = { enable = true },
                chainingHints = { enable = true },
                closingBraceHints = { enable = true },
                closureReturnTypeHints = { enable = "with_block" },
                lifetimeElisionHints = { enable = "verbose" },
                parameterHints = { enable = true },
                reborrowHints = { enable = "always" },
                typeHints = { enable = true },
              },
            },
          },
        },
      },
    },
  },

  -- Formatter: rustfmt
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = { rust = { "rustfmt" } },
    },
  },
}
