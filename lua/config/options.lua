-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.python3_host_prog = "C:/Users/19241/.conda/envs/py310/python.exe"

local opt = vim.opt
vim.env.CC = "gcc"

-- options.lua 第1行必须是这个
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = false -- 暂时禁用自动 ruff，避免干扰

-- 你原来的其他配置...
--缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.softtabstop = 4
--保持光标行距
opt.scrolloff = 11
opt.smoothscroll = true

--粘贴
opt.clipboard = "unnamedplus"

-- 设置代理环境变量（让 Neovim 内的 curl/git 都走代理）
local proxy = "http://127.0.0.1:7890" -- 根据你的代理软件修改（Clash 默认 7890，v2rayN 默认 10809）
vim.env.http_proxy = proxy
vim.env.https_proxy = proxy
vim.env.HTTP_PROXY = proxy
vim.env.HTTPS_PROXY = proxy

-- 确保真彩色开启（Windows Terminal 原生支持）
vim.opt.termguicolors = true
