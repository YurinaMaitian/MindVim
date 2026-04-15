return {
    {
        "folke/snacks.nvim",
        opts = {
            dashboard = {
                preset = {
                    header = [[
__   __         _             _____           _      
\ \ / /        (_)           /  __ \         | |     
 \ V /   _ _ __ _ _ __   __ _| /  \/ ___   __| | ___ 
  \ / | | | '__| | '_ \ / _` | |    / _ \ / _` |/ _ \
  | | |_| | |  | | | | | (_| | \__/\ (_) | (_| |  __/
  \_/\__,_|_|  |_|_| |_|\__,_|\____/\___/ \__,_|\___|
                ]],
                },
            },
        },
        config = function(_, opts)
            require("snacks").setup(opts)

            -- 霓虹灯效果：青色 -> 紫色 -> 粉色渐变
            vim.api.nvim_set_hl(0, "SnacksDashboardHeader", {
                fg = "#4b4cb8", -- 青色霓虹-
                bold = true,
                italic = true,
            })

            -- 如果支持 GUI，可以添加下划线发光效果
            vim.api.nvim_set_hl(0, "SnacksDashboardHeader", {
                fg = "#ebcfc0", -- 品红
                bg = "NONE",
                bold = true,
                -- sp = "#00ffff", -- 下划线颜色（如果终端支持）
                -- underline = true,
            })
        end,
    },
}
