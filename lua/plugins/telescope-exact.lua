return {
    {
        "nvim-telescope/telescope.nvim",
        opts = {
            defaults = {
                -- 显示完整路径，方便你知道文件在哪个盘哪个文件夹
                path_display = { "absolute" },
                -- 或者只显示文件名+父目录：path_display = { "smart" },

                -- 忽略这些目录，减少垃圾结果
                file_ignore_patterns = {
                    "node_modules",
                    ".git/",
                    "__pycache__/",
                    "%.pyc$",
                    "target/", -- Rust
                    "build/", -- 构建目录
                },
            },
            pickers = {
                find_files = {
                    -- 关键设置：禁用乱序模糊匹配
                    -- 现在必须连续输入 "test.py" 才能匹配到，不会匹配 t...e...s...t...
                    fuzzy = false,

                    -- 如果你想保留一点模糊能力但不要太离谱，可以用这个：
                    -- sorter = require('telescope.sorters').get_fuzzy_file({ fuzzy = false }),
                },

                -- 同样设置 live_grep（内容搜索）
                live_grep = {
                    fuzzy = false,
                },
            },
        },
    },
}
