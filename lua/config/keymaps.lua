-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- 粘贴系统剪贴板
vim.keymap.set("i", "<C-v>", "<C-r><C-o>+", { noremap = true, desc = "粘贴系统剪贴板" })
vim.keymap.set("c", "<C-v>", "<C-r>+", { noremap = true, desc = "命令行粘贴" })
vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, desc = "复制到系统剪贴板" })

-- 分屏
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "垂直分屏" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "水平分屏" })

-- 窗口间移动
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "跳到左窗口", silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "跳到下窗口", silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "跳到上窗口", silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "跳到右窗口", silent = true })

-- LSP
vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "重启 LSP" })
vim.keymap.set("n", "<A-CR>", vim.lsp.buf.code_action, { desc = "Code Action" })

-- 终端粘贴
vim.keymap.set("t", "<C-v>", function()
  vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, { desc = "终端粘贴" })

-- 切换终端
vim.keymap.set({ "n", "i", "t" }, "<C-\\>", function()
  require("toggleterm").toggle()
end, { desc = "切换终端" })

-- ==========================================
-- Buffer 切换：Shift+h / Shift+l
-- ==========================================
-- 先反注册 LazyVim 默认的 S-h/S-l（如果有）
pcall(vim.keymap.del, "n", "<S-h>")
pcall(vim.keymap.del, "n", "<S-l>")

vim.keymap.set("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "上一个 Buffer", silent = true })
vim.keymap.set("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "下一个 Buffer", silent = true })

-- ==========================================
-- Visual 模式：Alt+h/l 左右平移选中文本（字符级）
-- 例如 "int main() x" 选中 x 后 Alt-h → "int main(x)"，x 仍被选中
-- ==========================================
vim.keymap.set("v", "<A-h>", 'd<Esc>hP`[v`]', { desc = "选中文本左移", silent = true })
vim.keymap.set("v", "<A-l>", 'd<Esc>lp`[v`]', { desc = "选中文本右移", silent = true })

-- ==========================================
-- Visual 模式：Alt+j/k 上下移动整行
-- ==========================================
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "选中行下移", silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "选中行上移", silent = true })

-- ==========================================
-- 窗口大小调整（Ctrl + 方向键，Neovide 中可按住连续发送）
-- ==========================================
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "窗口增高" })
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "窗口减高" })
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "窗口减宽" })
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "窗口增宽" })
