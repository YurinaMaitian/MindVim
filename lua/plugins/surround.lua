-- lua/plugins/surround.lua（v4 兼容版）
return {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
        -- 先 setup（不含 keymaps）
        require("nvim-surround").setup({
            -- 可选：其他配置，但 keymaps 必须移除
            surrounds = {
                ["("] = { add = { "(", ")" } },
                [")"] = { add = { "(", ")" } },
            },
        })

        -- 【关键】手动绑定 gS（v4 方式）
        vim.keymap.set("x", "gS", function()
            require("nvim-surround").visual_surround({ line_mode = false })
        end, { desc = "Add surround in visual mode" })
    end,
}
