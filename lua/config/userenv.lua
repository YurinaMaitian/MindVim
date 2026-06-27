-- lua/config/userenv.lua
-- =============================================================================
-- 用户环境自适应模块
-- 自动检测平台、工具链路径，提供统一接口给其他模块使用。
-- 用户可通过 nvim 配置根目录的 env.lua 覆盖任何设置。
-- =============================================================================

local M = {}

-- =============================================================================
-- 0. 加载用户覆盖配置 (env.lua)
-- =============================================================================
local function load_env()
  local env_path = vim.fn.stdpath("config") .. "/env.lua"
  if vim.fn.filereadable(env_path) == 1 then
    local ok, result = pcall(dofile, env_path)
    if ok and type(result) == "table" then
      return result
    end
  end
  return {}
end

local user_env = load_env()

--- 获取用户覆盖值（env.lua 优先，否则用默认值）
---@param key string
---@param default any
---@return any
function M.get_env(key, default)
  if user_env[key] ~= nil then
    return user_env[key]
  end
  return default
end

-- =============================================================================
-- 1. 平台检测
-- =============================================================================
M.is_windows = vim.fn.has("win32") == 1
M.is_linux = vim.fn.has("linux") == 1
M.is_mac = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
M.is_unix = M.is_linux or M.is_mac

-- =============================================================================
-- 2. 辅助函数
-- =============================================================================

--- 在多个候选路径中查找第一个存在的文件
---@param candidates string[] 候选路径列表
---@return string|nil
function M.find_first_file(candidates)
  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      return path
    end
  end
  return nil
end

--- 在多个候选路径中查找第一个存在的目录
---@param candidates string[] 候选路径列表
---@return string|nil
function M.find_first_dir(candidates)
  for _, path in ipairs(candidates) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end
  return nil
end

--- 查找可执行文件（先在 PATH 中查找，再在候选路径中查找）
---@param name string 可执行文件名（不含扩展名）
---@param extra_candidates string[]|nil 额外的候选路径
---@return string|nil
function M.find_executable(name, extra_candidates)
  -- 优先检查 PATH
  if vim.fn.executable(name) == 1 then
    return name -- 在 PATH 中，直接返回名称即可
  end
  -- 检查额外候选路径
  if extra_candidates then
    for _, dir in ipairs(extra_candidates) do
      local full = dir .. "/" .. name
      if M.is_windows then
        full = dir .. "\\" .. name .. ".exe"
      end
      if vim.fn.executable(full) == 1 then
        return full
      end
    end
  end
  return nil
end

--- 标准化路径（统一使用正斜杠）
---@param p string
---@return string
function M.normalize_path(p)
  return (p:gsub("\\", "/"))
end

-- =============================================================================
-- 3. 代理配置（见 env.lua）
-- =============================================================================
M.proxy = M.get_env("proxy", nil)

-- =============================================================================
-- 4. Python 环境自动检测
-- =============================================================================

--- conda 环境名（在 env.lua 中设置 python_conda_env）
M.conda_env = M.get_env("python_conda_env", "py310")

--- 查找 conda 基础路径
local function detect_conda_base()
  local home = os.getenv("HOME") or os.getenv("USERPROFILE") or vim.fn.expand("~")
  local candidates = {}
  if M.is_windows then
    table.insert(candidates, home .. "\\.conda")
    table.insert(candidates, home .. "\\miniconda3")
    table.insert(candidates, home .. "\\anaconda3")
    table.insert(candidates, "C:\\Miniconda3")
    table.insert(candidates, "C:\\Anaconda3")
  else
    table.insert(candidates, home .. "/miniconda3")
    table.insert(candidates, home .. "/anaconda3")
    table.insert(candidates, home .. "/.conda")
    table.insert(candidates, "/opt/conda")
    table.insert(candidates, "/usr/local/anaconda3")
  end
  return M.find_first_dir(candidates)
end

--- 查找 Python 可执行文件
---@param conda_env string|nil 指定的 conda 环境名
---@return string|nil
function M.detect_python(conda_env)
  -- 1) 检查用户是否在选项中手动指定了 python3_host_prog
  if vim.g.python3_host_prog and vim.g.python3_host_prog ~= "" then
    return vim.g.python3_host_prog
  end

  -- 2) 检查环境变量
  local from_env = os.getenv("NVIM_PYTHON_HOST_PROG") or os.getenv("PYTHON_HOST_PROG")
  if from_env and vim.fn.executable(from_env) == 1 then
    return from_env
  end

  -- 3) Conda 环境
  local conda_base = detect_conda_base()
  if conda_base then
    local envs_dir = M.is_windows and (conda_base .. "\\envs") or (conda_base .. "/envs")
    if conda_env and vim.fn.isdirectory(envs_dir) == 1 then
      local env_python = M.is_windows
          and (envs_dir .. "\\" .. conda_env .. "\\python.exe")
          or (envs_dir .. "/" .. conda_env .. "/bin/python")
      if vim.fn.filereadable(env_python) == 1 then
        return M.normalize_path(env_python)
      end
    end
    -- 使用 conda base 环境
    local base_python = M.is_windows
        and (conda_base .. "\\python.exe")
        or (conda_base .. "/bin/python")
    if vim.fn.filereadable(base_python) == 1 then
      return M.normalize_path(base_python)
    end
  end

  -- 4) 通过 PATH 查找
  if M.is_windows then
    if vim.fn.executable("python.exe") == 1 then return "python.exe" end
    if vim.fn.executable("python3.exe") == 1 then return "python3.exe" end
  else
    if vim.fn.executable("python3") == 1 then return "python3" end
    if vim.fn.executable("python") == 1 then return "python" end
  end

  return nil
end

--- 查找 conda 环境中的脚本
---@param conda_env string conda 环境名
---@param script_name string 脚本名（如 "basedpyright-langserver"）
---@return string|nil
function M.detect_conda_script(conda_env, script_name)
  local conda_base = detect_conda_base()
  if not conda_base then return nil end

  local script_path
  if M.is_windows then
    script_path = conda_base .. "\\envs\\" .. conda_env .. "\\Scripts\\" .. script_name .. ".exe"
  else
    script_path = conda_base .. "/envs/" .. conda_env .. "/bin/" .. script_name
  end

  if vim.fn.filereadable(script_path) == 1 then
    return M.normalize_path(script_path)
  end

  -- 也尝试在 base 环境中查找
  local base_script = M.is_windows
      and (conda_base .. "\\Scripts\\" .. script_name .. ".exe")
      or (conda_base .. "/bin/" .. script_name)
  if vim.fn.filereadable(base_script) == 1 then
    return M.normalize_path(base_script)
  end

  return nil
end

-- 快捷方法：获取当前配置的 Python 路径
---@param conda_env string|nil
---@return string
function M.get_python(conda_env)
  return M.detect_python(conda_env) or (M.is_windows and "python.exe" or "python3")
end

-- =============================================================================
-- 5. Java 环境自动检测
-- =============================================================================

--- 查找 JDK 路径
---@return string|nil
function M.detect_jdk()
  -- 0) 用户手动指定（env.lua）
  local manual = M.get_env("jdk_path", nil)
  if manual and vim.fn.isdirectory(manual) == 1 then
    return M.normalize_path(manual)
  end

  -- 1) JAVA_HOME 环境变量
  local java_home = os.getenv("JAVA_HOME")
  if java_home and vim.fn.isdirectory(java_home) == 1 then
    return M.normalize_path(java_home)
  end

  -- 2) 常见安装路径
  if M.is_windows then
    -- 检查 Program Files 中的 JDK
    local candidates = {}
    local program_files = os.getenv("ProgramFiles") or "C:\\Program Files"
    -- 使用 glob 查找 Microsoft JDK
    local ms_jdk = vim.fn.glob(program_files .. "\\Microsoft\\jdk-*", false, true)
    if ms_jdk and #ms_jdk > 0 then
      table.insert(candidates, ms_jdk[1])
    end
    -- Eclipse Adoptium / Temurin
    local eclipse_jdk = vim.fn.glob(program_files .. "\\Eclipse Adoptium\\jdk-*", false, true)
    if eclipse_jdk and #eclipse_jdk > 0 then
      table.insert(candidates, eclipse_jdk[1])
    end
    -- 普通 Java
    local java_dir = vim.fn.glob(program_files .. "\\Java\\jdk-*", false, true)
    if java_dir and #java_dir > 0 then
      table.insert(candidates, java_dir[1])
    end
    return M.find_first_dir(candidates)
  else
    -- Linux / macOS
    local candidates = {
      "/usr/lib/jvm/default-java",
      "/usr/lib/jvm/java-21-openjdk",
      "/usr/lib/jvm/java-17-openjdk",
      "/usr/lib/jvm/java-11-openjdk",
      "/usr/lib/jvm/default",
    }
    -- glob 查找 /usr/lib/jvm/ 下的 JDK
    local jvm_dirs = vim.fn.glob("/usr/lib/jvm/java-*-openjdk*", false, true)
    if jvm_dirs then
      for _, d in ipairs(jvm_dirs) do
        table.insert(candidates, d)
      end
    end
    -- macOS Homebrew
    if M.is_mac then
      table.insert(candidates, "/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home")
      table.insert(candidates, "/usr/local/opt/openjdk/libexec/openjdk.jdk/Contents/Home")
    end
    return M.find_first_dir(candidates)
  end
end

--- 查找 JDTLS 路径
---@return string|nil
function M.detect_jdtls()
  -- 0) 用户手动指定（env.lua）
  local manual = M.get_env("jdtls_path", nil)
  if manual and vim.fn.isdirectory(manual) == 1 then
    return M.normalize_path(manual)
  end

  -- 1) 检查 Mason 安装的 jdtls
  local mason_jdtls = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
  if vim.fn.isdirectory(mason_jdtls) == 1 then
    return M.normalize_path(mason_jdtls)
  end

  -- 2) 常见手动安装路径
  if M.is_windows then
    local candidates = { "D:\\jdtls", "C:\\jdtls" }
    local home = os.getenv("USERPROFILE") or vim.fn.expand("~")
    table.insert(candidates, home .. "\\jdtls")
    return M.find_first_dir(candidates)
  else
    local home = os.getenv("HOME") or vim.fn.expand("~")
    local candidates = {
      home .. "/jdtls",
      "/opt/jdtls",
      "/usr/local/share/jdtls",
      "/usr/share/jdtls",
    }
    return M.find_first_dir(candidates)
  end
end

--- 获取 JDK 中的 java 可执行文件路径
---@param jdk_path string
---@return string
function M.get_java_bin(jdk_path, exe_name)
  exe_name = exe_name or "java"
  local name = M.is_windows and (exe_name .. ".exe") or exe_name
  return M.normalize_path(jdk_path .. "/bin/" .. name)
end

--- 获取 JDTLS 启动 jar 文件的路径
---@param jdtls_path string
---@return string|nil
function M.get_jdtls_launcher(jdtls_path)
  local pattern = jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"
  local matches = vim.fn.glob(M.normalize_path(pattern), false, true)
  if matches and #matches > 0 then
    return M.normalize_path(matches[1])
  end
  return nil
end

--- 获取 JDTLS 配置目录名（Windows 用 config_win，其他用 config_linux）
---@return string
function M.get_jdtls_config_dir()
  return M.is_windows and "config_win" or "config_linux"
end

-- =============================================================================
-- 6. C/C++ 工具链自动检测
-- =============================================================================

--- 查找 C 编译器
---@return string
function M.detect_c_compiler()
  -- 0) 用户手动指定（env.lua）
  local manual = M.get_env("c_compiler", nil)
  if manual then return manual end

  -- MSYS2 clang（Windows 用户常用）
  if M.is_windows then
    local msys2_clang = "D:/tools/MSYS2/mingw64/bin/clang.exe"
    if vim.fn.filereadable(msys2_clang) == 1 then
      return msys2_clang
    end
  end

  -- PATH 中查找
  if M.is_windows then
    if vim.fn.executable("clang.exe") == 1 then return "clang.exe" end
    if vim.fn.executable("gcc.exe") == 1 then return "gcc.exe" end
  else
    if vim.fn.executable("clang") == 1 then return "clang" end
    if vim.fn.executable("gcc") == 1 then return "gcc" end
  end

  return M.is_windows and "clang.exe" or "gcc"
end

--- 查找 clangd
---@return string
function M.detect_clangd()
  local manual = M.get_env("clangd_path", nil)
  if manual then return manual end
  if M.is_windows then
    -- 优先使用 MSYS2 的 clangd
    local msys2_clangd = "D:/tools/MSYS2/mingw64/bin/clangd.exe"
    if vim.fn.filereadable(msys2_clangd) == 1 then return msys2_clangd end
    if vim.fn.executable("clangd.exe") == 1 then return "clangd.exe" end
  else
    if vim.fn.executable("clangd") == 1 then return "clangd" end
  end
  return M.is_windows and "clangd.exe" or "clangd"
end

--- 查找 clang-format
---@return string
function M.detect_clang_format()
  local manual = M.get_env("clang_format_path", nil)
  if manual then return manual end
  if M.is_windows then
    local msys2_cf = "D:/tools/MSYS2/mingw64/bin/clang-format.exe"
    if vim.fn.filereadable(msys2_cf) == 1 then return msys2_cf end
    if vim.fn.executable("clang-format.exe") == 1 then return "clang-format.exe" end
  else
    if vim.fn.executable("clang-format") == 1 then return "clang-format" end
  end
  return M.is_windows and "clang-format.exe" or "clang-format"
end

--- 获取 C/C++ 的系统头文件路径（用于 clangd fallbackFlags）
---@return string[]
function M.get_c_system_includes()
  if M.is_windows then
    -- MSYS2 MinGW 头文件
    return {
      "D:/tools/MSYS2/mingw64/include",
      "D:/tools/MSYS2/mingw64/x86_64-w64-mingw32/include",
    }
  else
    -- Linux 上 clangd 通常能自动发现，无需手动指定
    -- 如果需要，可以添加：
    -- return { "/usr/include", "/usr/local/include" }
    return {}
  end
end

-- =============================================================================
-- 7. 平台适配命令
-- =============================================================================

--- 获取切换到目录的命令前缀（用于 toggleterm 等）
--- Windows: cd /d（支持切换驱动器）, Linux/macOS: cd
---@param dir string 目录路径
---@return string
function M.cd_command(dir)
  if M.is_windows then
    return string.format('cd /d "%s"', M.normalize_path(dir))
  else
    return string.format('cd "%s"', M.normalize_path(dir))
  end
end

--- 获取在浏览器中打开文件的命令
---@param file string 文件路径
---@return string
function M.open_browser_cmd(file)
  local f = M.normalize_path(file)
  if M.is_windows then
    return string.format('start "" "%s"', f)
  elseif M.is_mac then
    return string.format('open "%s"', f)
  else
    -- Linux: 尝试多种浏览器打开方式
    if vim.fn.executable("xdg-open") == 1 then
      return string.format('xdg-open "%s"', f)
    elseif vim.fn.executable("gnome-open") == 1 then
      return string.format('gnome-open "%s"', f)
    else
      return string.format('xdg-open "%s"', f)
    end
  end
end

--- 获取默认 shell（用于 toggleterm）
--- 可在 env.lua 中设置 shell 覆盖自动检测
---@return string|nil 返回 nil 则使用 Neovim 默认
function M.get_shell()
  -- 0) 用户手动指定（env.lua）
  local manual = M.get_env("shell", nil)
  if manual then return manual end

  if M.is_windows then
    -- Windows: 优先 pwsh (PS 7+)，其次 powershell (5.1)，最后默认
    if vim.fn.executable("pwsh.exe") == 1 then
      return "pwsh.exe"
    end
    if vim.fn.executable("powershell.exe") == 1 then
      return "powershell.exe"
    end
    return nil -- nil = Neovim 默认 (cmd.exe)
  else
    -- Linux/macOS: 优先 $SHELL 环境变量
    local sh = os.getenv("SHELL")
    if sh and vim.fn.executable(sh) == 1 then
      return sh
    end
    -- fallback: 检测常见 shell
    local candidates = { "/bin/bash", "/usr/bin/zsh", "/usr/bin/fish", "/bin/sh" }
    for _, c in ipairs(candidates) do
      if vim.fn.executable(c) == 1 then
        return c
      end
    end
    return nil -- nil = Neovim 默认
  end
end

-- =============================================================================
-- 8. Neovide / GUI 相关
-- =============================================================================

--- 是否在 Neovide 中运行
function M.is_neovide()
  return vim.g.neovide == true
end

--- 默认工作目录（Neovide 无参数启动时使用）
--- 在 env.lua 中设置 default_project_dir
M.default_project_dir = M.get_env("default_project_dir", nil)

--- IME 管理（仅 Windows 需要）
M.ime = {
  enabled = M.is_windows,
  --- im-select.exe 的路径
  ---@return string|nil
  get_path = function()
    local p = vim.fn.stdpath("config") .. "/bin/im-select.exe"
    if vim.fn.filereadable(p) == 1 then
      return p
    end
    return nil
  end,
}

-- =============================================================================
-- 9. 跨盘搜索（Windows 专属）
-- =============================================================================

--- 跨盘搜索根目录（在 env.lua 中设置 cross_search_root）
M.cross_search_root = M.get_env("cross_search_root", nil)

-- =============================================================================
-- 10. 一次性应用代理设置
-- =============================================================================
function M.apply_proxy()
  if not M.proxy then return end
  vim.env.http_proxy = M.proxy
  vim.env.https_proxy = M.proxy
  vim.env.HTTP_PROXY = M.proxy
  vim.env.HTTPS_PROXY = M.proxy
end

-- =============================================================================
-- 导出
-- =============================================================================
return M
