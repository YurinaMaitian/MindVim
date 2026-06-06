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
-- 启动时最大化（比全屏更实用，保留标题栏可拖动）
-- vim.g.neovide_maximized = true

-- 刷新率设置
vim.g.neovide_refresh_rate = 120
vim.g.neovide_refresh_rate_idle = 5 -- 空闲时降低刷新率省电

-- 记住上次窗口位置
vim.g.neovide_remember_window_position = true

-- 使用系统粘贴板（允许 Ctrl+C/V 与系统互通）
vim.g.neovide_input_use_logo = true

-- 关键：让 Neovide 不干预 IME，完全由你手动控制
-- vim.g.neovide_input_ime = false

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

-- 字体大小调整（带非刷屏通知）
local last_font_size = nil

local function adjust_font_size(delta)
    local font = vim.o.guifont
    local name, size = string.match(font, "(.+):h(%d+)$")

    if name and size then
        local new_size = tonumber(size) + delta
        new_size = math.max(6, math.min(30, new_size))
        vim.o.guifont = string.format("%s:h%d", name, new_size)

        -- 【方案2】只用原生 vim.notify，不 require 任何东西
        -- 如果要避免刷屏，用 print 代替（更轻量，不堆积）
        if last_font_size then
            -- 清除上一条 echo 消息（防止刷屏）
            vim.cmd("echo ''")
        end
        vim.api.nvim_echo({ { "字体大小: " .. new_size, "WarningMsg" } }, false, {})
        last_font_size = new_size
    end
end

vim.keymap.set({ "n", "i" }, "<C-=>", function()
    adjust_font_size(1)
end, { desc = "增大字体" })

vim.keymap.set({ "n", "i" }, "<C-->", function()
    adjust_font_size(-1)
end, { desc = "减小字体" })

-- 关键：指定"透明基准色"。Neovide 会把接近这个颜色的区域做透明处理
-- 配合上面的 transparency，实现"背景半透明、文字不透明"的效果
vim.g.neovide_background_color = "#0f1117"

-- ==========================================
-- 3. 浮动窗口毛玻璃（Neovide 独有！）
-- ==========================================
-- Telescope、Noice、诊断弹窗等浮动窗口的模糊程度
vim.g.neovide_floating_blur_amount_x = 8.0
vim.g.neovide_floating_blur_amount_y = 8.0

-- 浮动窗口阴影（增加层次感）
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10

-- ==========================================
-- IME 配置（写代码专用：默认英文，手动切中文）
-- ==========================================
vim.g.neovide_input_ime = true

local im_select = vim.fn.stdpath("config") .. "/bin/im-select.exe"

if vim.fn.executable(im_select) == 1 then
    local ime_group = vim.api.nvim_create_augroup("ImeAuto", { clear = true })

    -- 启动时强制英文（延迟 500ms 确保窗口就绪）
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        group = ime_group,
        callback = function()
            vim.defer_fn(function()
                vim.fn.system({ im_select, "1033" })
            end, 500)
        end,
    })

    -- 退出插入模式：保险切英文
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = ime_group,
        callback = function()
            vim.fn.system({ im_select, "1033" })
        end,
    })

    -- 退出 Neovim：切回中文
    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = ime_group,
        callback = function()
            vim.fn.system({ im_select, "2052" })
        end,
    })
end
