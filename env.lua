-- env.lua — 用户环境配置
-- =============================================================================
-- 这是你需要编辑的配置文件，位于 nvim 配置根目录，一目了然。
-- 大部分设置会自动检测（PATH → 常见路径），只需修改检测失败的部分。
-- 修改后重启 nvim 生效。
-- =============================================================================

return {
    -- ============================================
    -- 1. 代理设置（留空 = 不使用代理）
    -- ============================================
    proxy = nil,
    -- proxy = "http://127.0.0.1:7890",  -- Clash 默认端口
    -- proxy = "http://127.0.0.1:10809", -- v2rayN 默认端口

    -- ============================================
    -- 2. Python 环境
    -- ============================================
    python_conda_env = "py310", -- conda 环境名（非 conda 用户忽略）

    -- ============================================
    -- 3. 默认项目目录（Neovide/GUI 无参数启动时）
    -- ============================================
    default_project_dir = nil,
    -- default_project_dir = "~/Projects",

    -- ============================================
    -- 4. Java 开发环境（留空自动检测）
    -- ============================================
    jdk_path = nil,
    -- jdk_path = "C:\\Program Files\\Microsoft\\jdk-21.0.11.10-hotspot",   -- Windows
    -- jdk_path = "/usr/lib/jvm/java-21-openjdk",                            -- Linux

    jdtls_path = nil,
    -- jdtls_path = "D:\\jdtls",    -- Windows
    -- jdtls_path = "/opt/jdtls",   -- Linux

    -- ============================================
    -- 5. C/C++ 工具链（留空自动检测）
    -- ============================================
    c_compiler = nil,
    -- c_compiler = "D:/tools/MSYS2/mingw64/bin/clang.exe",  -- Windows MSYS2
    -- c_compiler = "clang",                                   -- Linux

    clangd_path = nil,
    clang_format_path = nil,

    -- ============================================
    -- 6. 跨盘搜索（仅 Windows 有意义）
    -- ============================================
    cross_search_root = nil,
    -- cross_search_root = "D:/",    -- Windows
    -- cross_search_root = "/home",  -- Linux

    -- ============================================
    -- 7. 外观
    -- ============================================
    -- 默认配色方案（启动时自动应用）
    default_colorscheme = "tokyonight-storm",

    -- ============================================
    -- 8. 终端 Shell（留空自动检测）
    -- ============================================
    shell = nil,
    -- shell = "pwsh.exe",          -- Windows (PowerShell 7)
    -- shell = "powershell.exe",    -- Windows (PowerShell 5)
    -- shell = "/usr/bin/zsh",      -- Linux (zsh)
    -- shell = "/usr/bin/fish",     -- Linux (fish)
}
