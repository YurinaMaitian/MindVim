-- lua/plugins/telescope-exact.lua
-- Telescope 配置：精确搜索 + 跨平台 fd/rg 检测
-- 前置依赖：已将 fd 和 rg 加入系统环境变量 PATH

local userenv = require("config.userenv")

return {
    {
        "nvim-telescope/telescope.nvim",
        opts = function(_, opts)
            opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
                path_display = { "absolute" },
                file_ignore_patterns = {
                    "node_modules",
                    ".git/",
                    "__pycache__/",
                    "%.pyc$",
                    "target/",
                    "build/",
                },

                layout_config = {
                    prompt_position = "bottom",
                },
            })

            opts.pickers = opts.pickers or {}
            opts.pickers.find_files = vim.tbl_deep_extend("force", opts.pickers.find_files or {}, {
                fuzzy = false,
            })
            opts.pickers.live_grep = vim.tbl_deep_extend("force", opts.pickers.live_grep or {}, {
                fuzzy = false,
            })

            -- 跨平台检测 fd/rg（所有平台都需要）
            if vim.fn.executable("fd") == 0 and vim.fn.executable("fdfind") == 0 then
                vim.notify(
                    "未检测到 fd，Telescope 可能无法搜索文件。请安装："
                        .. (userenv.is_windows and "scoop install fd" or "sudo apt install fd-find"),
                    vim.log.levels.WARN
                )
            end
            if vim.fn.executable("rg") == 0 then
                vim.notify(
                    "未检测到 ripgrep，live_grep 可能无法使用。请安装："
                        .. (userenv.is_windows and "scoop install ripgrep" or "sudo apt install ripgrep"),
                    vim.log.levels.WARN
                )
            end

            return opts
        end,
    },
}
