return {
    "stevearc/aerial.nvim",
    opts = {
        layout = {
            max_width = { 40, 0.3 },
            min_width = 20,
            width = nil,
        },
        -- 显示类层次结构
        show_guides = true,
        guides = {
            mid_item = "├ ",
            last_item = "└ ",
            nested_top = "│ ",
            whitespace = "  ",
        },
        filter_kind = {
            "Class",
            "Constructor",
            "Enum",
            "Function",
            "Interface",
            "Method",
            "Struct",
        },
    },
    keys = {
        { "<leader>co", "<cmd>AerialToggle!<CR>", desc = "代码大纲 (Aerial)" },
        { "{", "<cmd>AerialPrev<CR>", desc = "上一个函数" },
        { "}", "<cmd>AerialNext<CR>", desc = "下一个函数" },
    },
}
