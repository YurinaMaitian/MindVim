return {
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "VeryLazy",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            local rainbow = require("rainbow-delimiters")
            
            vim.g.rainbow_delimiters = {
                strategy = {
                    [""] = rainbow.strategy["global"],
                    vim = rainbow.strategy["local"],
                },
                query = {
                    [""] = "rainbow-delimiters",
                    lua = "rainbow-blocks",
                },
                highlight = {
                    "RainbowDelimiterRed",
                    "RainbowDelimiterYellow", 
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterCyan",
                },
            }
        end,
    },
}