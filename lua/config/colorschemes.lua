-- lua/config/colorschemes.lua
-- 28 款主题库：高对比 + 透明友好优先

local M = {}

M.schemes = {
  -- ========== 高对比首选（复杂壁纸也清晰）==========
  ["tokyonight-storm"] = {
    plugin = "folke/tokyonight.nvim",
    name = "tokyonight",
    background = "dark",
    transparent = false,
    setup = function()
      require("tokyonight").setup({ style = "storm" })
    end,
  },
  ["tokyonight-moon"] = {
    plugin = "folke/tokyonight.nvim",
    name = "tokyonight",
    background = "dark",
    transparent = true,
    setup = function()
      require("tokyonight").setup({ style = "moon", styles = { comments = { italic = true }, keywords = { italic = false } } })
    end,
  },
  ["tokyonight-day"] = {
    plugin = "folke/tokyonight.nvim",
    name = "tokyonight",
    background = "light",
    transparent = false,
    setup = function()
      require("tokyonight").setup({ style = "day" })
    end,
  },

  -- ========== Catppuccin（现代高饱和，透明极美）==========
  ["catppuccin-mocha"] = {
    plugin = "catppuccin/nvim",
    name = "catppuccin",
    background = "dark",
    transparent = true,
    setup = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
        styles = { comments = { "italic" }, conditionals = { "italic" } },
      })
    end,
  },
  ["catppuccin-macchiato"] = {
    plugin = "catppuccin/nvim",
    name = "catppuccin",
    background = "dark",
    transparent = true,
    setup = function()
      require("catppuccin").setup({ flavour = "macchiato", transparent_background = true })
    end,
  },
  ["catppuccin-frappe"] = {
    plugin = "catppuccin/nvim",
    name = "catppuccin",
    background = "dark",
    transparent = false,
    setup = function()
      require("catppuccin").setup({ flavour = "frappe", transparent_background = false })
    end,
  },

  -- ========== Kanagawa（和风，dragon 对比度最高）==========
  ["kanagawa-wave"] = {
    plugin = "rebelot/kanagawa.nvim",
    name = "kanagawa-wave",
    background = "dark",
    transparent = true,
    setup = function()
      require("kanagawa").setup({ transparent = true })
    end,
  },
  ["kanagawa-dragon"] = {
    plugin = "rebelot/kanagawa.nvim",
    name = "kanagawa-dragon",
    background = "dark",
    transparent = true,
    setup = function()
      require("kanagawa").setup({ transparent = true })
    end,
  },
  ["kanagawa-lotus"] = {
    plugin = "rebelot/kanagawa.nvim",
    name = "kanagawa-lotus",
    background = "light",
    transparent = false,
    setup = function()
      require("kanagawa").setup({ transparent = false })
    end,
  },

  -- ========== Gruvbox（复古硬对比）==========
  ["gruvbox-dark"] = {
    plugin = "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    background = "dark",
    transparent = true,
    setup = function()
      require("gruvbox").setup({
        italic = { strings = true, operators = false, comments = true },
        contrast = "hard",
        transparent_mode = true,
      })
    end,
  },
  ["gruvbox-light"] = {
    plugin = "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    background = "light",
    transparent = false,
    setup = function()
      require("gruvbox").setup({ contrast = "hard", transparent_mode = false })
    end,
  },

  -- ========== OneDark（经典高对比蓝底）==========
  ["onedark-dark"] = {
    plugin = "navarasu/onedark.nvim",
    name = "onedark",
    background = "dark",
    transparent = true,
    setup = function()
      require("onedark").setup({ style = "dark", transparent = true })
    end,
  },
  ["onedark-darker"] = {
    plugin = "navarasu/onedark.nvim",
    name = "onedark",
    background = "dark",
    transparent = true,
    setup = function()
      require("onedark").setup({ style = "darker", transparent = true })
    end,
  },
  ["onedark-cool"] = {
    plugin = "navarasu/onedark.nvim",
    name = "onedark",
    background = "dark",
    transparent = true,
    setup = function()
      require("onedark").setup({ style = "cool", transparent = true })
    end,
  },

  -- ========== Dracula（紫粉高对比，极清晰）==========
  dracula = {
    plugin = "Mofiqul/dracula.nvim",
    name = "dracula",
    background = "dark",
    transparent = true,
    setup = function()
      require("dracula").setup({ transparent_bg = true })
    end,
  },

  -- ========== Everforest（暗绿护眼，但对比度够）==========
  ["everforest-dark"] = {
    plugin = "sainnhe/everforest",
    name = "everforest",
    background = "dark",
    transparent = true,
  },

  -- ========== Rose Pine（暗紫美学）==========
  ["rose-pine-moon"] = {
    plugin = "rose-pine/neovim",
    name = "rose-pine",
    background = "dark",
    transparent = true,
    setup = function()
      require("rose-pine").setup({ variant = "moon", styles = { transparency = true } })
    end,
  },
  ["rose-pine-main"] = {
    plugin = "rose-pine/neovim",
    name = "rose-pine",
    background = "dark",
    transparent = true,
    setup = function()
      require("rose-pine").setup({ variant = "main", styles = { transparency = true } })
    end,
  },

  -- ========== Nightfox 系列（蓝调科技）==========
  nightfox = {
    plugin = "EdenEast/nightfox.nvim",
    name = "nightfox",
    background = "dark",
    transparent = true,
    setup = function()
      require("nightfox").setup({ options = { transparent = true } })
    end,
  },
  ["nightfox-carbon"] = {
    plugin = "EdenEast/nightfox.nvim",
    name = "carbonfox",
    background = "dark",
    transparent = true,
    setup = function()
      require("nightfox").setup({ options = { transparent = true } })
    end,
  },
  ["nightfox-dusk"] = {
    plugin = "EdenEast/nightfox.nvim",
    name = "duskfox",
    background = "dark",
    transparent = true,
    setup = function()
      require("nightfox").setup({ options = { transparent = true } })
    end,
  },

  -- ========== Cyberdream（赛博霓虹）==========
  ["cyberdream-dark"] = {
    plugin = "scottmckendry/cyberdream.nvim",
    name = "cyberdream",
    background = "dark",
    transparent = true,
    setup = function()
      require("cyberdream").setup({ variant = "dark", transparent = true })
    end,
  },
  ["cyberdream-light"] = {
    plugin = "scottmckendry/cyberdream.nvim",
    name = "cyberdream",
    background = "light",
    transparent = false,
    setup = function()
      require("cyberdream").setup({ variant = "light", transparent = false })
    end,
  },

  -- ========== Material（多种材质风格）==========
  ["material-deep-ocean"] = {
    plugin = "marko-cerovac/material.nvim",
    name = "material",
    background = "dark",
    transparent = true,
    setup = function()
      vim.g.material_style = "deep ocean"
      require("material").setup({ transparent = true })
    end,
  },
  ["material-darker"] = {
    plugin = "marko-cerovac/material.nvim",
    name = "material",
    background = "dark",
    transparent = true,
    setup = function()
      vim.g.material_style = "darker"
      require("material").setup({ transparent = true })
    end,
  },

  -- ========== Poimandres（现代暗蓝，高对比）==========
  poimandres = {
    plugin = "olivercederborg/poimandres.nvim",
    name = "poimandres",
    background = "dark",
    transparent = true,
    setup = function()
      require("poimandres").setup({ transparent = true })
    end,
  },

  -- ========== GitHub Dark（干净高对比）==========
  ["github-dark"] = {
    plugin = "projekt0n/github-nvim-theme",
    name = "github_dark",
    background = "dark",
    transparent = true,
    setup = function()
      require("github-theme").setup({ options = { transparent = true } })
    end,
  },

  -- ========== Monet（莫奈油画）==========
  ["monet-dark"] = {
    plugin = "fynnfluegge/monet.nvim",
    name = "monet",
    background = "dark",
    transparent = true,
    setup = function()
      local palette = require("monet.palette")
      setmetatable(palette, { __index = palette.defaults })
    end,
  },
}

function M.get_plugins()
  local seen = {}
  local plugins = {}
  for _, cfg in pairs(M.schemes) do
    if not seen[cfg.plugin] then
      seen[cfg.plugin] = true
      table.insert(plugins, { cfg.plugin, lazy = true })
    end
  end
  return plugins
end

return M