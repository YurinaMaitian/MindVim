return {
    {
        "folke/noice.nvim",
        opts = {
            lsp = {
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                        trigger = true,
                        luasnip = false,
                    },
                },
                -- 【关键】禁用右下角的 LSP 进度条（Publish Diagnostics/Validate documents）
                progress = {
                    enabled = false,
                },
            },
            views = {
                hover = {
                    size = {
                        max_height = 15,
                        max_width = 60,
                    },
                },
            },
            -- 【备选】如果上面不行，用这个路由过滤掉所有 LSP 进度通知
            routes = {
                {
                    filter = {
                        event = "lsp",
                        kind = "progress",
                    },
                    opts = { skip = true },
                },
            },
        },
    },
}
