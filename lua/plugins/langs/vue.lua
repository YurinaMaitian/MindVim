-- lua/plugins/langs/vue.lua
-- Vue3 开发环境配置
-- LSP: volar (Vue Language Server)
-- F5: 提示用户运行 npm run dev（Vue 项目无法直接"运行"单个文件）

local userenv = require("config.userenv")

-- F5: Vue 项目启动开发服务器或打开组件预览
local function vue_f5_action()
  vim.cmd("write")
  local dir = vim.fn.expand("%:p:h")

  -- 查找 package.json 中的 scripts
  local pkg = vim.fn.findfile("package.json", dir .. ";")
  if pkg == "" then
    vim.notify("未找到 package.json，无法启动 Vue 项目", vim.log.levels.WARN)
    return
  end

  -- 尝试读取 scripts 判断用哪个命令
  local pkg_path = pkg
  if vim.fn.filereadable(pkg_path) == 1 then
    local content = table.concat(vim.fn.readfile(pkg_path), "\n")
    local script = "dev"
    if content:find('"dev:vue"') or content:find('"dev:web"') then
      -- 多种 dev 脚本
    end

    local root = vim.fn.fnamemodify(pkg_path, ":p:h")
    local root_clean = userenv.normalize_path(root)
    local cmd = userenv.cd_command(root_clean) .. " && npm run dev"

    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new({
      cmd = cmd,
      direction = "horizontal",
      size = 14,
      close_on_exit = false,
      auto_scroll = true,
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_name(term.bufnr, "Vue Dev: " .. vim.fn.fnamemodify(root, ":t"))
      end,
    })
    term:open()
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "vue",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 2

    vim.keymap.set("n", "<F5>", vue_f5_action, {
      buffer = true,
      silent = true,
      desc = "启动 Vue 开发服务器",
    })
  end,
})

return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "vue" })
    end,
  },

  -- LSP: Volar
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        volar = {
          filetypes = { "vue" },
          init_options = {
            vue = { hybridMode = false },
          },
          settings = {
            volar = {
              takeoverMode = { enabled = false },
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
      formatters_by_ft = { vue = { "prettier" } },
    },
  },
}
