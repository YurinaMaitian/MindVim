-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- 确保 Python 文件自动启动 LSP

-- 智能 scrolloff 补全：保持光标居中，但避免无限追加空行
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    pattern = "*",
    callback = function()
        -- ==========================================
        -- 1. 基础保护：只处理可修改的普通文件
        -- ==========================================
        if not vim.bo.modifiable then
            return
        end
        if vim.bo.readonly then
            return
        end

        -- 排除特殊 buffer 类型（terminal、help、prompt 等）
        local bt = vim.bo.buftype
        if bt == "terminal" or bt == "help" or bt == "prompt" or bt == "nofile" then
            return
        end

        -- 大文件保护：超过10000行不处理，避免性能问题
        local last_line = vim.fn.line("$")
        if last_line > 10000 then
            return
        end

        local line = vim.fn.line(".")
        local scrolloff = vim.opt.scrolloff:get()

        -- ==========================================
        -- 2. 计算逻辑：是否需要补行？
        -- ==========================================

        -- 计算光标当前位置到文件末尾的距离（行数差）
        -- 例如：文件100行，光标在98行，距离为2
        local distance_to_end = last_line - line

        -- 如果距离已经足够（>= scrolloff），无需处理，直接返回
        -- 这是第一道防线，避免不必要的计算
        if distance_to_end >= scrolloff then
            return
        end

        -- 计算理论上需要补充多少行，才能达到 scrolloff 的缓冲效果
        -- 例如：scrolloff=5，距离=2，还需要 3 行
        local needed = scrolloff - distance_to_end

        -- ==========================================
        -- 3. 核心改进：检测末尾已存在的空行数量
        -- ==========================================

        -- 局部函数：统计文件末尾连续空行的数量
        -- 参数 max_check：最多检查多少行（优化性能，我们只需要知道是否 >= needed）
        local function count_trailing_blank_lines(max_check)
            -- 优化：只获取最后 max_check 行进行检查，而不是遍历整个文件
            local start_idx = math.max(0, last_line - max_check)
            local lines = vim.api.nvim_buf_get_lines(0, start_idx, last_line, false)

            local count = 0
            -- 倒序遍历：从文件最后一行向前数
            for i = #lines, 1, -1 do
                if lines[i] == "" then
                    count = count + 1
                else
                    -- 遇到非空行立即停止，说明连续空行中断
                    break
                end
                -- 如果已经数够 needed 个，提前退出（小优化）
                if count >= max_check then
                    break
                end
            end
            return count
        end

        -- 检查末尾已有的空行数量（最多检查 needed 个，因为我们只需要知道够不够）
        local existing_blank = count_trailing_blank_lines(needed)

        -- ==========================================
        -- 4. 智能补全：只添加"确实需要"的行数
        -- ==========================================

        -- 计算实际需要添加的行数
        -- 例如：needed=3，已有2个空行，就只需添加1个
        local lines_to_add = needed - existing_blank

        -- 如果已有空行足够（lines_to_add <= 0），直接返回，不执行任何操作
        -- 这就是防止无限追加空行的关键逻辑！
        if lines_to_add <= 0 then
            return
        end

        -- 创建需要添加的空行表
        local new_lines = {}
        for i = 1, lines_to_add do
            table.insert(new_lines, "")
        end

        -- 在文件末尾追加空行（last_line 位置之后插入）
        vim.api.nvim_buf_set_lines(0, last_line, last_line, false, new_lines)
    end,
})
