return {
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            -- 配置所有 LSP 客户端
            opts.servers = opts.servers or {}

            -- 全局禁用自动签名帮助
            opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
                settings = {
                    Lua = {
                        -- 禁用某些很烦人的提示
                        signatureHelp = { enabled = false }, -- 关闭自动签名提示
                        -- 或者保留但延迟触发（下面这行是延迟，上面是关闭）
                        -- signatureHelp = { enabled = true, autoActive = false },
                    },
                },
            })

            -- 方法 B：在 LSP attach 时配置（更彻底，对所有 LSP 生效）
            local on_attach_original = opts.on_attach
            opts.on_attach = function(client, bufnr)
                -- 先执行原来的 on_attach
                if on_attach_original then
                    on_attach_original(client, bufnr)
                end

                -- 禁用签名帮助自动触发
                client.server_capabilities.signatureHelpProvider = false
            end

            return opts
        end,
    },
}
