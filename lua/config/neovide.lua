-- lua/config/neovide.lua
-- vim:ft=lua sw=4 et ai
if not vim.g.neovide then
    return
end

-- ========== 外观与性能配置 ==========

-- 字体设置
vim.o.guifont = "Consolas:h23"

-- 全屏启动
vim.g.neovide_fullscreen = true

-- 刷新率设置
vim.g.neovide_refresh_rate = 120
vim.g.neovide_refresh_rate_idle = 5 -- 空闲时降低刷新率省电

-- 记住上次窗口位置
vim.g.neovide_remember_window_position = true

-- 使用系统粘贴板（允许 Ctrl+C/V 与系统互通）
vim.g.neovide_input_use_logo = true

-- 关键：让 Neovide 不干预 IME，完全由你手动控制
vim.g.neovide_input_ime = false

-- ========== 光标效果 ==========
vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_trail_size = 0.4
vim.g.neovide_cursor_vfx_mode = "ripple"

-- ========== 默认工作目录设置 ==========
-- 当直接打开 Neovide（不带文件参数）时，自动切换到指定目录
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        -- 检查是否有命令行参数（比如双击文件打开，或命令行指定了目录）
        if vim.fn.argc() == 0 then
            -- 设置你的默认目录（使用正斜杠或双反斜杠）
            local default_dir = "D:/Projects"
            -- 或者使用相对 home 的路径：vim.fn.expand("~/code")

            -- 检查目录是否存在
            if vim.fn.isdirectory(default_dir) == 1 then
                vim.api.nvim_set_current_dir(default_dir)
                vim.notify("已切换到工作目录: " .. default_dir, vim.log.levels.INFO)
            else
                vim.notify("警告: 默认目录不存在 " .. default_dir, vim.log.levels.WARN)
            end
        end
    end,
})

-- ========== 快捷键配置 ==========

-- Ctrl+S 保存（所有模式通用）
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Cmd>w<CR>", { desc = "保存文件 (Ctrl+S)" })

-- 字体大小调整
local function adjust_font_size(delta)
    local font = vim.o.guifont
    local name, size = string.match(font, "(.+):h(%d+)$")

    if name and size then
        local new_size = tonumber(size) + delta
        new_size = math.max(6, math.min(30, new_size))
        vim.o.guifont = string.format("%s:h%d", name, new_size)
        vim.notify("字体大小: " .. new_size)
    end
end

vim.keymap.set({ "n", "i" }, "<C-=>", function()
    adjust_font_size(1)
end, { desc = "增大字体" })
vim.keymap.set({ "n", "i" }, "<C-->", function()
    adjust_font_size(-1)
end, { desc = "减小字体" })
