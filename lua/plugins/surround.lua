-- lua/plugins/surround.lua
return {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({
            -- 默认键位：
            -- Normal: ys( 加括号, cs( 改括号, ds( 删括号
            -- Visual: S(  加括号（选中后按 S 再按括号）
            -- 不需要手动绑定，setup 自动处理
        })
    end,
}
