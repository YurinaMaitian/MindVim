<p align="center">
  <img src="https://raw.githubusercontent.com/LazyVim/LazyVim/main/lazyvim-logo.png" width="180" alt="LazyVim Logo" />
</p>

<h1 align="center">🌙 MindVim</h1>

<p align="center">
  <b>一套配置走天下的 Neovim 开发环境</b><br>
  基于 LazyVim · 28 款主题 · 多语言开箱即用 · 跨平台自适应
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Neovim-0.10%2B-blue?logo=neovim" />
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey" />
  <img src="https://img.shields.io/badge/LazyVim-powered-8a2be2" />
  <img src="https://img.shields.io/badge/License-Apache%202.0-green" />
</p>

---

## ✨ 亮点

- **一套配置走天下** — Windows / Linux / macOS 无需分别配置，工具链路径自动检测
- **只需改一个文件** — 根目录的 `env.lua` 是唯一需要手动编辑的配置
- **F5 一键运行** — C/C++、Python、Java、JS/TS、Rust、LaTeX、Vue3 按下即编译运行
- **28 款内置主题** — 一键切换，支持透明/磨砂效果
- **调试即用** — nvim-dap 预配 Python / C++ / JS / Java / Rust 调试器
- **LazyVim 生态** — 继承 LazyVim 全部功能，按需扩展

---

## 🚀 快速上手

### 前置要求

- Neovim ≥ 0.10
- 可选：[Nerd Font](https://www.nerdfonts.com/)（图标显示）
- 可选：`fd`、`ripgrep`（Telescope 搜索）

```bash
# Linux / macOS
sudo apt install fd-find ripgrep   # Debian/Ubuntu
brew install fd ripgrep             # macOS

# Windows
scoop install fd ripgrep
```

### 安装

```bash
# 备份旧配置（如果有）
mv ~/.config/nvim ~/.config/nvim.bak

# Clone 配置
git clone https://github.com/YurinaMaitian/MyNeovim.git ~/.config/nvim

# Windows 用户 clone 到：
# git clone https://github.com/YurinaMaitian/MyNeovim.git %LOCALAPPDATA%\nvim
```

首次启动时会自动安装 lazy.nvim 和所有插件，等待片刻即可。

### 配置（可选）

打开配置根目录下的 **`env.lua`**，按需修改：

```lua
return {
  proxy             = nil,                              -- 代理地址
  python_conda_env  = "py310",                          -- conda 环境名
  default_project_dir = "~/Projects",                   -- 启动时的默认目录
  jdk_path          = "/usr/lib/jvm/java-21-openjdk",   -- JDK 路径（留空自动检测）
  default_colorscheme = "tokyonight-storm",             -- 默认主题
}
```

> 大多数设置留空即可自动检测。只有检测不到时才需要手动填。

---

## 🗺️ 支持的语言

| 语言 | LSP | 格式化 | F5 运行 |
|------|-----|--------|---------|
| **Python** | basedpyright + ruff | ruff | `python -i`（REPL 模式）|
| **C / C++** | clangd | clang-format | 编译器编译 + 运行 |
| **Java** | jdtls | — | javac 编译 + java 运行 |
| **TypeScript / JS** | vtsls | prettier | node / tsx 运行 |
| **Rust** | rust-analyzer | rustfmt | cargo run / rustc |
| **Vue3** | volar | prettier | npm run dev |
| **HTML / CSS** | html + cssls | prettier | 浏览器打开 |
| **LaTeX** | texlab | — | latexmk 编译 → 浏览器查看 PDF |

---

## ⌨️ 快捷键

> Leader 键：<kbd>Space</kbd>

### 窗口与 Buffer

| 按键 | 功能 |
|------|------|
| <kbd>Ctrl</kbd>+<kbd>h</kbd> / <kbd>j</kbd> / <kbd>k</kbd> / <kbd>l</kbd> | 窗口间移动 |
| <kbd>Alt</kbd>+<kbd>h</kbd> / <kbd>l</kbd> | 上一个 / 下一个 Buffer |
| <kbd>Ctrl</kbd>+<kbd>↑ ↓ ← →</kbd> | 调整窗口大小 |
| <kbd>Space</kbd> `sv` / `sh` | 垂直 / 水平分屏 |

### LSP / 代码导航

| 按键 | 功能 |
|------|------|
| `gd` | 跳转到定义 |
| `gr` | 查找引用 |
| `K` | 悬停文档 |
| <kbd>Space</kbd> `rn` | 重命名符号 |
| <kbd>Space</kbd> `ca` | Code Action |
| <kbd>Space</kbd> `lr` | 重启 LSP |
| `[d` / `]d` | 上一个 / 下一个诊断 |

### 搜索（Telescope）

| 按键 | 功能 |
|------|------|
| <kbd>Space</kbd> `ff` | 查找文件 |
| <kbd>Space</kbd> `fg` | 全局文本搜索 |
| <kbd>Space</kbd> `fb` | 已打开的 Buffer |
| <kbd>Space</kbd> `fr` | 最近文件 |
| <kbd>Space</kbd> `ss` | 当前文件大纲 |

### Git

| 按键 | 功能 |
|------|------|
| <kbd>Space</kbd> `gg` | LazyGit |
| <kbd>Space</kbd> `gf` | 当前文件 Git 历史 |
| <kbd>Space</kbd> `gb` | Git Blame |

### 终端 / 运行

| 按键 | 功能 |
|------|------|
| <kbd>Ctrl</kbd>+<kbd>\\</kbd> | 切换终端 |
| <kbd>F5</kbd> | 编译运行当前文件 |
| <kbd>Ctrl</kbd>+<kbd>s</kbd> | 保存文件 |

### 调试（DAP）

| 按键 | 功能 |
|------|------|
| <kbd>F9</kbd> | 切换断点 |
| <kbd>F10</kbd> | 单步跳过 |
| <kbd>F11</kbd> | 单步进入 |
| <kbd>Shift</kbd>+<kbd>F11</kbd> | 单步跳出 |
| <kbd>Space</kbd> `dc` | 继续 |
| <kbd>Space</kbd> `du` | 切换调试面板 |

### 文本对象（Treesitter）

| 按键 | 选中范围 |
|------|---------|
| `vaf` / `vif` | 整个函数 / 函数内部 |
| `vac` / `vic` | 整个类 / 类内部 |
| `vaa` / `via` | 参数（含逗号）/ 参数值 |

### 其他

| 按键 | 功能 |
|------|------|
| `gcc` | 注释/取消注释当前行 |
| <kbd>Space</kbd> `cf` | LSP 格式化代码 |
| <kbd>Space</kbd> `uC` | 切换配色方案 |
| <kbd>Space</kbd> `ul` | Lazy 插件管理 |
| <kbd>Space</kbd> `co` | 代码大纲（Aerial）|
| `ys` / `cs` / `ds` | Surround 添加/修改/删除 |

---

## 📦 插件精选

基于 [LazyVim](https://www.lazyvim.org/) 生态，额外整合：

| 类别 | 插件 |
|------|------|
| **编辑** | nvim-surround, rainbow-delimiters, nvim-ts-autotag, nvim-autopairs |
| **UI** | snacks.nvim, noice.nvim, aerial.nvim, neo-tree.nvim |
| **终端** | toggleterm.nvim（F5 运行各语言 + REPL） |
| **调试** | nvim-dap + nvim-dap-ui + nvim-dap-virtual-text |
| **Git** | lazygit.nvim |
| **透明** | transparent.nvim（多主题透明适配） |

---

## 🎨 内置主题

tokyonight (3) · catppuccin (3) · kanagawa (3) · onedark (3) · nightfox (3)  
gruvbox (2) · cyberdream (2) · material (2) · rose-pine (2) · dracula  
everforest · poimandres · github-dark · monet

<kbd>Space</kbd> `uC` 打开主题选择器，实时预览切换。

---

## 📁 目录结构

```
~/.config/nvim/
├── env.lua                 ← 你唯一需要编辑的文件
├── init.lua                ← 入口
├── lua/
│   ├── config/             ← 核心配置
│   │   └── userenv.lua     ← 环境自适应引擎
│   └── plugins/
│       ├── editor/         ← 编辑器体验
│       ├── langs/          ← 语言支持（每语言一个文件）
│       └── tools/          ← 外部工具集成
```

---

## 🔧 常见问题

<details>
<summary><b>某语言的 LSP 没有启动？</b></summary>

检查 Mason 是否已安装对应的 LSP：<kbd>Space</kbd> `cm` 打开 Mason，按 `2` 进入 LSP 列表，手动安装。

也可在终端检查：`which clangd` / `which rust-analyzer` 等。
</details>

<details>
<summary><b>F5 运行报错？</b></summary>

确保编译器/运行时在 PATH 中：
- Python：`python3 --version`
- C/C++：`gcc --version` 或 `clang --version`
- Java：`javac --version` 和 `java --version`
- JS/TS：`node --version`
- Rust：`cargo --version`
- LaTeX：`latexmk --version`
</details>

<details>
<summary><b>如何迁移到另一台电脑？</b></summary>

1. Clone 仓库
2. 根据新电脑环境编辑 `env.lua`
3. 启动 nvim，插件会自动安装
</details>

<details>
<summary><b>如何更新插件？</b></summary>

<kbd>Space</kbd> `ul` → `S`（Sync），或 `U`（Update all）。
</details>

---

## 📄 License

Apache 2.0 © [YurinaMaitian](https://github.com/YurinaMaitian)
