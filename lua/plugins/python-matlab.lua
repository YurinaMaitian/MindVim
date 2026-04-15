return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = function(_, opts)
            -- ==========================================
            -- 1. 基础终端配置（REPL体验优化）
            -- ==========================================
            opts.direction = "horizontal" -- 水平分割：终端在下方
            opts.size = 7 -- 终端高度15行
            opts.open_mapping = [[<c-\>]] -- 【关键】全局快捷键：切换终端显示/隐藏
            opts.hide_numbers = true -- 隐藏终端行号，更清爽
            opts.shade_terminals = true -- 终端背景稍暗，与编辑区视觉区分
            opts.start_in_insert = true -- 打开终端自动进入插入模式（光标在REPL中）
            opts.insert_mappings = true -- 【关键】在终端插入模式下<C-\>依然有效（REPL输入时也能切回代码）
            opts.persist_size = true -- 记住手动调整后的终端大小
            opts.close_on_exit = false -- Python退出后不自动关窗（方便看报错信息）
            -- shell保持默认，Win11通常自动识别cmd或PowerShell

            local Terminal = require("toggleterm.terminal").Terminal

            -- 缓存Python终端实例：用于跟踪当前是否已开启REPL
            local py_term = nil

            -- ==========================================
            -- 2. 核心功能：REPL模式运行Python
            -- ==========================================
            local function save_and_run_repl()
                -- 强制保存当前文件（无需手动:w）
                vim.cmd("write")

                local file = vim.fn.expand("%:p") -- 获取当前文件的绝对路径（Win11格式）
                local python_exe = "C:/Users/19241/.conda/envs/py310/python.exe"

                -- Win11路径处理：将反斜杠转为正斜杠，避免Lua转义问题和命令行解析错误
                local file_clean = file:gsub("\\", "/")

                -- 【REPL核心】-i 参数（interactive）: 脚本执行完毕后进入Python交互模式
                -- 效果：先运行完整文件 → 显示结果 → 保持>>>提示符等待输入
                local cmd = string.format('"%s" -i "%s"', python_exe, file_clean)

                -- ==========================================
                -- 3. 终端生命周期管理策略
                -- ==========================================
                if py_term then
                    -- 如果已有REPL实例在运行（无论是否可见）
                    if py_term:is_open() then
                        py_term:close() -- 关闭旧终端（为了重新加载最新代码，确保变量状态全新）
                    end
                    py_term = nil -- 清除引用，准备创建新实例
                end

                -- 创建全新的Python REPL终端实例
                py_term = Terminal:new({
                    cmd = cmd, -- 执行命令：Python解释器 + 脚本 + 交互模式
                    direction = "horizontal", -- 保持水平布局
                    close_on_exit = false, -- 按Ctrl+D退出Python后，终端窗口保留（可查看历史输出）
                    auto_scroll = true, -- 自动滚动到最新输出（追踪print结果）

                    -- 终端打开回调：自动聚焦到终端内，立即可以交互输入
                    on_open = function(term)
                        vim.cmd("startinsert!") -- 强制进入插入模式，光标在REPL命令行
                        -- 可选：设置缓冲区名称，在bufferline中显示为"Python REPL"
                        vim.api.nvim_buf_set_name(term.bufnr, "REPL: " .. vim.fn.expand("%:t"))
                    end,
                })

                -- 显示终端并执行命令
                py_term:open()
            end

            -- ==========================================
            -- 4. Python文件专用快捷键绑定
            -- ==========================================
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "python",
                callback = function()
                    -- F5：保存文件并以REPL模式运行
                    vim.keymap.set("n", "<F5>", save_and_run_repl, {
                        buffer = true, -- 仅当前Python文件有效
                        silent = true,
                        desc = "Python REPL: 保存并运行 (Conda MM环境)",
                    })

                    -- 【额外建议】F6：直接发送当前行到REPL（不重启，保持变量状态）
                    -- 如需此功能，取消下面注释：
                    --[[
          vim.keymap.set("n", "<F6>", function()
            if py_term and py_term:is_open() then
              local line = vim.api.nvim_get_current_line()
              py_term:send(line, true)  -- true表示添加回车执行
            else
              vim.notify("请先按F5启动REPL", vim.log.levels.WARN)
            end
          end, { buffer = true, silent = true, desc = "发送当前行到REPL" })
          --]]
                end,
            })

            return opts
        end,
    },
}
