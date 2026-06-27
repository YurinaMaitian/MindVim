-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local userenv = require("config.userenv")

-- python3_host_prog 已在 init.lua 中通过 userenv 设置
vim.env.CC = userenv.is_windows and "gcc" or "gcc"

-- options.lua 第1行必须是这个
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = false -- 暂时禁用自动 ruff，避免干扰

--缩进
local opt = vim.opt
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.softtabstop = 4
--保持光标行距
opt.scrolloff = 11
opt.smoothscroll = true

--粘贴
opt.clipboard = "unnamedplus"

-- 代理设置已在 init.lua 中通过 userenv.apply_proxy() 应用
-- 如需修改代理地址，请编辑 lua/config/userenv.lua

-- 确保真彩色开启
vim.opt.termguicolors = true
