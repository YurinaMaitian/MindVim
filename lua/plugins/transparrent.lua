-- lua/plugins/transparent.lua
-- 终极版：统一深色卡片 + 编辑区透明 + 暴力遍历所有高亮组

return {
    {
        "xiyaowong/transparent.nvim",
        lazy = false,
        opts = {
            extra_groups = {
                "NormalFloat",
                "FloatBorder",
                "FloatTitle",
                "TelescopeNormal",
                "TelescopeBorder",
                "TelescopePromptNormal",
                "WhichKeyFloat",
                "NoiceCmdlinePopup",
                "NoiceCmdlinePopupBorder",
                "NoiceMini",
            },
            exclude_groups = {},
        },
        config = function(_, opts)
            require("transparent").setup(opts)
            vim.cmd("TransparentEnable")

            -- ==========================================
            -- 统一配色：所有面板共享同一个极深蓝黑
            -- ==========================================
            local CARD_BG = "#080810" -- 比纯黑更柔和，带极微弱蓝调
            local CARD_FG = "#c0c8d8" -- 面板文字：冷灰白
            local EDITOR_FG = "#d8dee9" -- 编辑区文字：纯白
            local DIM_FG = "#4b5568" -- 次要文字：行号、分隔符

            local function fix_transparency()
                -- ==========================================
                -- 1. 编辑区：完全透明，文字高对比
                -- ==========================================
                vim.api.nvim_set_hl(0, "Normal", { fg = EDITOR_FG, bg = "NONE" })
                vim.api.nvim_set_hl(0, "NormalNC", { fg = "#a0a8b8", bg = "NONE" })

                -- 光标行：透明 + 细下划线（绝不加背景，否则破坏玻璃感）
                vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE", underline = true, sp = "#3b4252" })
                vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ffffff", bold = true, bg = "NONE" })

                -- 行号 + 注释
                vim.api.nvim_set_hl(0, "LineNr", { fg = DIM_FG })
                vim.api.nvim_set_hl(0, "Comment", { fg = "#5a6a7d", italic = true })

                -- ==========================================
                -- 2. NeoTree：统一深色卡片（暴力遍历所有 NeoTree* 高亮组）
                -- ==========================================
                local neotree_hls = vim.fn.getcompletion("NeoTree", "highlight")
                for _, name in ipairs(neotree_hls) do
                    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                    if ok and hl and next(hl) ~= nil then
                        -- 保留前景色和特殊样式，只改背景为统一卡片色
                        hl.bg = vim.api.nvim_get_color_by_name(CARD_BG) or CARD_BG
                        -- 如果原来没有前景色，设为统一面板文字色
                        if not hl.fg then
                            hl.fg = vim.api.nvim_get_color_by_name(CARD_FG) or CARD_FG
                        end
                        pcall(vim.api.nvim_set_hl, 0, name, hl)
                    end
                end
                -- 特殊处理：分隔线用更暗的颜色
                vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = "#1a1a2e", bg = CARD_BG })

                -- ==========================================
                -- 3. BufferLine：统一深色卡片（暴力遍历所有 BufferLine*）
                -- ==========================================
                local bufferline_hls = vim.fn.getcompletion("BufferLine", "highlight")
                for _, name in ipairs(bufferline_hls) do
                    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                    if ok and hl and next(hl) ~= nil then
                        hl.bg = vim.api.nvim_get_color_by_name(CARD_BG) or CARD_BG
                        pcall(vim.api.nvim_set_hl, 0, name, hl)
                    end
                end
                -- 选中标签：亮色文字 + 稍微亮一点的背景，形成"凸起"感
                vim.api.nvim_set_hl(0, "BufferLineBufferSelected", {
                    fg = "#ffffff",
                    bg = "#12121c",
                    bold = true,
                    italic = false,
                })
                vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", { fg = "#81a1c1", bg = "#12121c" })

                -- ==========================================
                -- 4. Lualine + 原生状态栏：统一深色卡片
                -- ==========================================
                local lualine_hls = vim.fn.getcompletion("lualine_", "highlight")
                for _, name in ipairs(lualine_hls) do
                    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                    if ok and hl then
                        hl.bg = vim.api.nvim_get_color_by_name(CARD_BG) or CARD_BG
                        -- 非活动状态文字不要太暗
                        if name:find("inactive") then
                            hl.fg = hl.fg or vim.api.nvim_get_color_by_name("#586070")
                        end
                        pcall(vim.api.nvim_set_hl, 0, name, hl)
                    end
                end

                -- 原生 StatusLine 兜底
                vim.api.nvim_set_hl(0, "StatusLine", { fg = CARD_FG, bg = CARD_BG })
                vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#586070", bg = CARD_BG })

                -- ==========================================
                -- 5. 其他面板：WinSeparator、TabLine 等
                -- ==========================================
                vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#1a1a2e", bg = "NONE" })
                vim.api.nvim_set_hl(0, "TabLineFill", { bg = CARD_BG })
                vim.api.nvim_set_hl(0, "TabLine", { fg = CARD_FG, bg = CARD_BG })
                vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#ffffff", bg = "#12121c", bold = true })

                -- ==========================================
                -- 6. 浮动窗口：半透明暗底（不要完全透明，否则弹窗看不清）
                -- ==========================================
                local FLOAT_BG = "#0f0f18"
                vim.api.nvim_set_hl(0, "NormalFloat", { fg = EDITOR_FG, bg = FLOAT_BG })
                vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#3b4252", bg = FLOAT_BG })
                vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { fg = EDITOR_FG, bg = FLOAT_BG })
                vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = "#3b4252", bg = FLOAT_BG })
                vim.api.nvim_set_hl(0, "TelescopeNormal", { fg = EDITOR_FG, bg = FLOAT_BG })
                vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#3b4252", bg = FLOAT_BG })
            end

            -- 切换主题后自动重新应用
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    vim.defer_fn(fix_transparency, 50)
                end,
            })

            fix_transparency()
        end,
    },
}
