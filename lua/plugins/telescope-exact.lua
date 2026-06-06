-- lua/plugins/telescope.lua
-- 前置依赖：已将 fd 和 rg 加入系统环境变量 PATH
-- fd: D:\tools\fd-v10.4.2-x86_64-pc-windows-msvc\
-- rg: D:\tools\ripgrep-15.1.0-x86_64-pc-windows-msvc\
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

            -- Windows 自动检测 fd/rg（依赖 PATH）
            if vim.fn.has("win32") == 1 then
                if vim.fn.executable("fd") == 0 and vim.fn.executable("fdfind") == 0 then
                    vim.notify("未检测到 fd，Telescope 可能无法搜索文件", vim.log.levels.WARN)
                end
                if vim.fn.executable("rg") == 0 then
                    vim.notify("未检测到 ripgrep，live_grep 可能无法使用", vim.log.levels.WARN)
                end
            end

            return opts
        end,
    },
}
