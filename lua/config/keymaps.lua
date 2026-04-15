-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "<C-v>", "<C-r><C-o>+", { noremap = true, desc = "粘贴系统剪贴板" })
vim.keymap.set("c", "<C-v>", "<C-r>+", { noremap = true, desc = "命令行粘贴" })

-- 可选：Visual 模式 Ctrl+C 复制（Windows 习惯）
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, desc = "复制到系统剪贴板" })

-- new Windows
vim.keymap.set("n", "<leader>sv", "<C-w>v")
vim.keymap.set("n", "<leader>sh", "<C-w>s")

-- move amonge Windows
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to down window", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to up window", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", silent = true })

-- restart the LSP
vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "重启 LSP" })

-- 终端模式粘贴修复
vim.keymap.set("t", "<C-v>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "终端粘贴" })

-- 强制 Ctrl+\ 使用 toggleterm 而非 cmd
vim.keymap.set({ "n", "i", "t" }, "<C-\\>", function()
    require("toggleterm").toggle()
end, { desc = "切换终端" })
