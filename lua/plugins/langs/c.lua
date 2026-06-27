-- lua/plugins/c.lua
-- C/C++ 开发环境：跨平台自动检测工具链
-- Windows: 自动检测 MSYS2，否则使用 PATH 中的 clang/gcc
-- Linux/macOS: 使用系统 gcc/clang
-- 自定义路径请编辑 lua/config/userenv.lua

local userenv = require("config.userenv")

-- =============================================================================
-- 平台适配的构建命令生成
-- =============================================================================

--- 检测项目中的构建脚本
---@param dir string 项目目录
---@return string|nil
local function find_build_script(dir)
  -- Windows: build.bat, Linux/macOS: build.sh / Makefile / CMakeLists.txt
  local scripts = userenv.is_windows
      and { "build.bat" }
      or { "build.sh", "Makefile", "makefile", "CMakeLists.txt" }

  for _, script in ipairs(scripts) do
    local full = dir .. "/" .. script
    if vim.fn.filereadable(full) == 1 then
      return script
    end
  end
  return nil
end

--- 生成单文件编译命令
---@param dir string 项目目录
---@param file string 源文件路径
---@param output string 输出文件路径
---@return string
local function compile_command(dir, file, output)
  local compiler = userenv.detect_c_compiler()

  if userenv.is_windows then
    -- Windows: 使用 --target=x86_64-w64-mingw32 以使用 MinGW 运行时
    return string.format(
      '%s && "%s" --target=x86_64-w64-mingw32 -Wall -Wextra -g -std=c23 -o "%s" "%s" && echo [编译成功，正在运行...] && "%s"',
      userenv.cd_command(dir),
      compiler,
      output,
      userenv.normalize_path(file),
      output
    )
  else
    -- Linux/macOS: 标准编译
    return string.format(
      '%s && %s -Wall -Wextra -g -std=c11 -o "%s" "%s" && echo [编译成功，正在运行...] && "%s"',
      userenv.cd_command(dir),
      compiler,
      output,
      userenv.normalize_path(file),
      output
    )
  end
end

-- =============================================================================
-- F5 编译运行
-- =============================================================================

local c_term = nil

local function save_and_run_c()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local dir = vim.fn.expand("%:p:h")
  local filename_noext = vim.fn.expand("%:t:r")
  local dir_clean = userenv.normalize_path(dir)
  local file_clean = userenv.normalize_path(file)
  local ext = userenv.is_windows and ".exe" or ""
  local output = dir_clean .. "/" .. filename_noext .. ext

  local cmd
  local build_script = find_build_script(dir)

  if build_script then
    -- 有构建脚本，使用它
    if build_script == "Makefile" or build_script == "makefile" then
      cmd = userenv.cd_command(dir) .. " && make && echo [编译成功] && ./" .. filename_noext .. ext
    elseif build_script == "CMakeLists.txt" then
      -- 简单的 cmake 构建
      local build_dir = dir_clean .. "/build"
      cmd = userenv.cd_command(dir)
        .. " && mkdir -p build && cd build && cmake .. && make && echo [编译成功] && ./"
        .. filename_noext .. ext
    else
      -- build.sh / build.bat
      cmd = userenv.cd_command(dir) .. " && ./" .. build_script
      if userenv.is_windows then
        cmd = userenv.cd_command(dir) .. " && " .. build_script
      end
    end
  else
    cmd = compile_command(dir, file_clean, output)
  end

  if c_term and c_term:is_open() then
    c_term:close()
    c_term = nil
  end

  local Terminal = require("toggleterm.terminal").Terminal
  c_term = Terminal:new({
    cmd = cmd,
    direction = "horizontal",
    size = 10,
    close_on_exit = false,
    auto_scroll = true,
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_name(term.bufnr, "C: " .. filename_noext)
    end,
  })

  c_term:open()
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.softtabstop = 4
    vim.keymap.set(
      "n",
      "<F5>",
      save_and_run_c,
      { buffer = true, silent = true, desc = "保存并编译运行 C/C++" }
    )
  end,
})

-- =============================================================================
-- 插件配置
-- =============================================================================

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            userenv.detect_clangd(),
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=bundled",
            "--pch-storage=memory",
            "--compile_args_from=filesystem",
          },
          init_options = {
            fallbackFlags = (function()
              local flags = {}
              if userenv.is_windows then
                table.insert(flags, "--target=x86_64-w64-mingw32")
              end
              -- C23 原生支持 true/false/bool 关键字，无需 #include <stdbool.h>
              -- 如果编译器较老不支持 C23，改回 -std=c11 并手动 #include <stdbool.h>
              table.insert(flags, "-std=c23")
              -- 平台特定的系统头文件路径
              local includes = userenv.get_c_system_includes()
              for _, inc in ipairs(includes) do
                table.insert(flags, "-isystem")
                table.insert(flags, inc)
              end
              return flags
            end)(),
          },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = { c = { "clang_format" }, cpp = { "clang_format" } },
      formatters = {
        clang_format = {
          command = userenv.detect_clang_format(),
          args = function()
            return {
              "-assume-filename",
              "$FILENAME",
              "--style",
              "{BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never, AllowShortFunctionsOnASingleLine: Empty, BinPackArguments: false, BinPackParameters: false}",
            }
          end,
          stdin = true,
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "c", "cpp" })
    end,
  },
}
