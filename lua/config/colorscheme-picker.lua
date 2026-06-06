-- lua/config/colorscheme-picker.lua
-- 修复：插件未加载时自动触发 lazy 加载，避免 E185

local scheme_module = require("config.colorschemes")
local schemes = scheme_module.schemes

local cache_file = vim.fn.stdpath("data") .. "/my_colorscheme"
local current_key = "tokyonight-storm"

-- 读取缓存
do
  local f = io.open(cache_file, "r")
  if f then
    local saved = f:read("*l")
    if saved and schemes[saved] then
      current_key = saved
    end
    f:close()
  end
end

-- 核心：应用主题（带自动加载和错误恢复）
function _G.apply_colorscheme(key)
  local s = schemes[key]
  if not s then
    vim.notify("未知主题: " .. tostring(key), vim.log.levels.WARN)
    return
  end

  -- 1. 先执行 setup（这会触发 lazy.nvim 加载插件）
  if s.setup then
    local ok, err = pcall(s.setup)
    if not ok then
      vim.notify("主题 setup 失败: " .. err, vim.log.levels.WARN)
    end
  else
    -- 没有 setup 时，尝试按插件名触发 require 来加载
    local guess = s.plugin:match("/([^/]+)%.nvim$") or s.plugin:match("/([^/]+)$")
    if guess then
      pcall(require, guess)
    end
  end

  -- 2. 应用 colorscheme（失败时自动重试一次）
  local ok, err = pcall(vim.cmd, "colorscheme " .. s.name)
  if not ok then
    -- 延迟 50ms 再试（给 lazy 一点加载时间）
    vim.defer_fn(function()
      ok, err = pcall(vim.cmd, "colorscheme " .. s.name)
      if not ok then
        vim.notify("colorscheme 加载失败: " .. err, vim.log.levels.ERROR)
        return
      end
      vim.o.background = s.background
      sync_transparent(s.transparent)
    end, 100)
    return
  end

  vim.o.background = s.background
  sync_transparent(s.transparent)

  -- 3. 持久化
  current_key = key
  local f = io.open(cache_file, "w")
  if f then
    f:write(key)
    f:close()
  end
end

-- 联动透明插件
function _G.sync_transparent(enabled)
  if enabled then
    pcall(vim.cmd, "TransparentEnable")
  else
    pcall(vim.cmd, "TransparentDisable")
  end
  -- 触发透明修复
  vim.api.nvim_exec_autocmds("ColorScheme", {})
end

-- Telescope 选择器
function _G.pick_colorscheme()
  local ok = pcall(require, "telescope")
  if not ok then
    vim.notify("请先安装 Telescope", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local results = {}
  local keys_sorted = {}
  for k, _ in pairs(schemes) do
    table.insert(keys_sorted, k)
  end
  table.sort(keys_sorted)

  for _, k in ipairs(keys_sorted) do
    local label = k == current_key and (k .. "  ← 当前") or k
    table.insert(results, { key = k, display = label })
  end

  local original_key = current_key

  pickers.new({}, {
    prompt_title = "切换配色方案（28 款）",
    finder = finders.new_table({
      results = results,
      entry_maker = function(entry)
        return {
          value = entry.key,
          display = entry.display,
          ordinal = entry.key,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, _)
      require("telescope.actions.set").shift_selection:enhance({
        post = function()
          local sel = action_state.get_selected_entry()
          if sel then
            apply_colorscheme(sel.value)
          end
        end,
      })

      actions.close:enhance({
        post = function()
          if current_key ~= original_key then
            apply_colorscheme(original_key)
          end
        end,
      })

      actions.select_default:replace(function()
        local sel = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if sel then
          apply_colorscheme(sel.value)
          vim.notify("已切换: " .. sel.value, vim.log.levels.INFO)
        end
      end)

      return true
    end,
  }):find()
end

-- 命令和快捷键
vim.api.nvim_create_user_command("ColorschemePicker", pick_colorscheme, {})
vim.keymap.set("n", "<leader>uC", pick_colorscheme, { desc = "切换配色方案" })

-- 启动时延迟应用（确保 lazy 插件已就绪）
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      apply_colorscheme(current_key)
    end, 200)
  end,
})