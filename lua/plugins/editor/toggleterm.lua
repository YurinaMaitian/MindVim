return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        opts = function(_, opts)
            local userenv = require("config.userenv")

            -- ==========================================
            -- 1. 基础终端配置（REPL体验优化）
            -- ==========================================
            opts.direction = "horizontal" -- 水平分割：终端在下方
            opts.size = 7 -- 终端高度
            opts.open_mapping = [[<c-\>]] -- 【关键】全局快捷键：切换终端显示/隐藏
            opts.hide_numbers = true -- 隐藏终端行号，更清爽
            opts.shade_terminals = true -- 终端背景稍暗，与编辑区视觉区分
            opts.start_in_insert = true -- 打开终端自动进入插入模式（光标在REPL中）
            opts.insert_mappings = true -- 【关键】在终端插入模式下<C-\>依然有效
            opts.persist_size = true -- 记住手动调整后的终端大小
            opts.close_on_exit = false -- Python退出后不自动关窗（方便看报错信息）

            -- 平台自适应 shell
            local shell = userenv.get_shell()
            if shell then
                opts.shell = shell
            end

            local Terminal = require("toggleterm.terminal").Terminal

            -- 缓存Python终端实例：用于跟踪当前是否已开启REPL
            local py_term = nil

            -- ==========================================
            -- 2. 核心功能：REPL模式运行Python
            -- ==========================================
            local function save_and_run_repl()
                -- 强制保存当前文件（无需手动:w）
                vim.cmd("write")

                local file = vim.fn.expand("%:p") -- 获取当前文件的绝对路径
                -- 使用 userenv 自动检测 Python 路径
                local python_exe = userenv.get_python("py310")

                -- 路径标准化（正斜杠）
                local file_clean = userenv.normalize_path(file)

                -- 【REPL核心】-i 参数（interactive）: 脚本执行完毕后进入Python交互模式
                -- 效果：先运行完整文件 → 显示结果 → 保持>>>提示符等待输入
                local cmd = string.format('"%s" -i "%s"', python_exe, file_clean)

                -- ==========================================
                -- 3. 终端生命周期管理策略
                -- ==========================================
                if py_term then
                    -- 如果已有REPL实例在运行（无论是否可见）
                    if py_term:is_open() then
                        py_term:close() -- 关闭旧终端
                    end
                    py_term = nil -- 清除引用，准备创建新实例
                end

                -- 创建全新的Python REPL终端实例
                py_term = Terminal:new({
                    cmd = cmd,
                    direction = "horizontal",
                    close_on_exit = false,
                    auto_scroll = true,

                    -- 终端打开回调：自动聚焦到终端内
                    on_open = function(term)
                        vim.cmd("startinsert!")
                        vim.api.nvim_buf_set_name(term.bufnr, "REPL: " .. vim.fn.expand("%:t"))
                    end,
                })

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
                        buffer = true,
                        silent = true,
                        desc = "Python REPL: 保存并运行",
                    })
                end,
            })

            return opts
        end,
    },
}
