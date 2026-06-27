-- lua/plugins/cross-drive-search.lua
-- 跨盘搜索：Windows 上搜索其他驱动器，Linux 上搜索文件系统根目录
-- 如需自定义搜索根目录，编辑 lua/config/userenv.lua 中的 M.cross_search_root

local userenv = require("config.userenv")

return {
    {
        "nvim-telescope/telescope.nvim",
        keys = {
            {
                "<leader>fd",
                function()
                    -- 使用 userenv 中配置的搜索根目录
                    -- Windows: 默认为 nil（如需启用，在 userenv 中设置 cross_search_root）
                    -- Linux: 默认为 nil（如需启用，可设为 "/" 或 "~"）
                    local root = userenv.cross_search_root
                    if not root then
                        -- 如果没有配置跨盘搜索，使用 home 目录
                        root = vim.fn.expand("~")
                    end

                    local title = userenv.is_windows and "跨盘搜索" or "搜索文件"

                    require("telescope.builtin").find_files({
                        cwd = root,
                        prompt_title = title,
                    })
                end,
                desc = userenv.is_windows and "搜索 D 盘文件" or "搜索文件",
            },
        },
    },
}
