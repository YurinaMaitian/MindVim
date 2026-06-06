return {
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            --搜索D
            {
                "<leader>fd",
                function()
                    require("telescope.builtin").find_files({
                        cwd = "D:/",
                        prompt_title = "Find Files (D:)",
                    })
                end,
                desc = "Find Files in D Drive",
            },
        },
    },
}
