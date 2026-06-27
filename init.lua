-- =============================================================================
-- Neovim 配置入口
-- 如需修改环境配置，请编辑 nvim 配置根目录下的 env.lua 文件
-- =============================================================================

-- 环境自适应模块：自动检测平台和工具链路径
local userenv = require("config.userenv")

-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.lazyvim_python_lsp = "basedpyright"
-- 设置 Python 宿主程序（由 userenv 自动检测，conda 环境名见 env.lua）
vim.g.python3_host_prog = userenv.get_python(userenv.conda_env)
-- 应用代理设置（见 env.lua）
userenv.apply_proxy()

require("config.lazy")
require("config.neovide")
require("config.colorscheme-picker")
