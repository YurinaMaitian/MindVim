-- lua/plugins/langs/latex.lua
-- LaTeX 开发环境配置
-- LSP: texlab
-- F5: latexmk 编译 → 用浏览器打开 PDF

local userenv = require("config.userenv")

-- 查找 latexmk 命令
local function get_latexmk()
  if vim.fn.executable("latexmk") == 1 then
    return "latexmk"
  end
  return nil
end

-- F5 编译 LaTeX 并打开 PDF
local function save_compile_open_pdf()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local filename_noext = vim.fn.expand("%:t:r")
  local dir_clean = userenv.normalize_path(dir)
  local file_clean = userenv.normalize_path(file)
  local pdf_file = dir_clean .. "/" .. filename_noext .. ".pdf"

  local latexmk = get_latexmk()
  if not latexmk then
    vim.notify(
      "未找到 latexmk，请安装 TeX Live 或 MikTeX。\n"
        .. (userenv.is_windows and "https://miktex.org/download" or "sudo apt install texlive-full"),
      vim.log.levels.ERROR
    )
    return
  end

  -- latexmk -pdf 编译，编译成功后打开 PDF
  -- -interaction=nonstopmode 避免交互式错误提示
  -- -synctex=1 启用正反向搜索
  local compile_cmd = string.format(
    'cd "%s" && %s -pdf -interaction=nonstopmode -synctex=1 "%s"',
    dir_clean,
    latexmk,
    file_clean
  )

  -- 编译完成后打开 PDF
  local open_cmd
  if vim.fn.filereadable(pdf_file) == 1 then
    open_cmd = " && " .. userenv.open_browser_cmd(pdf_file)
  else
    open_cmd = " && echo [请检查编译错误]"
  end

  local cmd = compile_cmd .. open_cmd

  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new({
    cmd = cmd,
    direction = "horizontal",
    size = 12,
    close_on_exit = false,
    auto_scroll = true,
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_name(term.bufnr, "LaTeX: " .. filename_noext)
    end,
  })
  term:open()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex", "bib" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.conceallevel = 1
    vim.opt_local.textwidth = 80

    vim.keymap.set("n", "<F5>", save_compile_open_pdf, {
      buffer = true,
      silent = true,
      desc = "编译 LaTeX 并打开 PDF",
    })
  end,
})

return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "latex" })
    end,
  },

  -- LSP: texlab
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          settings = {
            texlab = {
              build = {
                executable = "latexmk",
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                onSave = false,
              },
              chktex = {
                onEdit = true,
                onOpenAndSave = true,
              },
              forwardSearch = {
                executable = userenv.is_windows and "SumatraPDF" or nil,
                args = {},
              },
              -- 支持 bibtex/biblatex
              bibtexFormatter = "texlab",
            },
          },
        },
      },
    },
  },
}
