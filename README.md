# Neovim 快捷键速查表

-> 环境：LazyVim + Neovide (Windows)  
-> Leader 键：`Space`

---

## 一、窗口与 Buffer 导航

- `Ctrl+h` — 跳到左窗口
- `Ctrl+j` — 跳到下窗口
- `Ctrl+k` — 跳到上窗口
- `Ctrl+l` — 跳到右窗口
- `Alt+h` — 上一个 Buffer
- `Alt+l` — 下一个 Buffer
- `Alt+Shift+h` — Buffer 向左移动
- `Alt+Shift+l` — Buffer 向右移动
- `Space sv` — 垂直分屏
- `Space sh` — 水平分屏
- `Space wm` — 最大化当前窗口
- `Space w=` — 所有窗口等分
- `Space wd` — 关闭当前窗口

---

## 二、窗口大小调整（按住连续生效）

- `Ctrl+Up` — 窗口增高
- `Ctrl+Down` — 窗口减高
- `Ctrl+Left` — 窗口减宽
- `Ctrl+Right` — 窗口增宽
- `Ctrl+w` 然后 `+` — 增高 1 行（可前缀数字，如 `5 Ctrl+w +`）
- `Ctrl+w` 然后 `-` — 减高 1 行
- `Ctrl+w` 然后 `&gt;` — 增宽 1 列
- `Ctrl+w` 然后 `&lt;` — 减宽 1 列
- `Ctrl+w` 然后 `_` — 高度最大化
- `Ctrl+w` 然后 `|` — 宽度最大化

---

## 三、文本对象（精准选择代码块）

### 原生文本对象（所有文件通用）

- `viw` — 选中当前单词
- `vi"` / `va"` — 选中引号内 / 含引号
- `vi(` / `va(` — 选中括号内 / 含括号
- `vi{` / `va{` — 选中花括号内 / 含花括号
- `vip` / `vap` — 选中当前段落（空行分隔）
- `vit` / `vat` — 选中 HTML/XML 标签内 / 含标签

&gt; **记忆**：`i` = inner（内部），`a` = around（含边界）

### Treesitter 文本对象（代码专用）

- `vaf` — 选中整个函数（含函数名和参数）
- `vif` — 选中函数内部（不含函数名和花括号）
- `vac` — 选中整个类
- `vic` — 选中类内部
- `vaa` — 选中参数（含逗号）
- `via` — 选中参数值（不含逗号）

&gt; 配合操作：`d` 删除、`y` 复制、`&gt;` 缩进

---

## 四、代码导航与 LSP

- `gd` — 跳转到定义
- `gD` — 跳转到声明
- `gr` — 查找引用（Telescope 列表）
- `gI` — 跳转到实现
- `K` — 悬停文档（Hover）
- `Space rn` — 重命名符号（LSP）
- `Space cr` — 重命名符号（备选）
- `Space ca` — Code Action（意图动作/修复）
- `Alt+Enter` — Code Action（备选）
- `[d` — 上一个诊断错误
- `]d` — 下一个诊断错误
- `Space cd` — 显示当前行诊断详情
- `Space lr` — 重启 LSP

---

## 五、跳转与位置恢复

- `Ctrl+o` — 跳到上一个跳转位置（Older）
- `Ctrl+i` — 跳到下一个跳转位置（Newer）
- `gi` — 跳到上次插入模式的位置
- `g;` — 跳到上次修改的位置
- `g,` — 反向跳修改位置（`g;` 之后用）
- `` ` `` — 跳到上次修改的精确位置
- `''` — 跳到上次跳转前的位置

---

## 六、搜索与批量替换

- `*` — 向下搜索光标下单词，并高亮所有匹配
- `#` — 向上搜索光标下单词
- `n` — 下一个匹配
- `N` — 上一个匹配
- `cgn` — 修改下一个匹配（配合 `n` 批量改）
- `.` — 重复上一次修改（`cgn` 后按 `n` + `.` 神技）
- `:%s/old/new/g` — 全局替换
- `:%s/old/new/gc` — 全局替换（带确认）

&gt; **批量改名神技**：`*` → `N`（回到原位）→ `cgn` 改第一个 → `Esc` → `n` 跳到下一个 → `.` 重复

---

## 七、注释与格式化

- `gcc` — 注释/取消注释当前行（Normal）
- `gc` — 注释选区（Visual）
- `gcip` — 注释当前段落
- `&gt;&gt;` / `&lt;&lt;` — 当前行增/减缩进
- `&gt;ap` / `&lt;ap` — 整个段落增/减缩进
- `=ap` — 自动格式化段落
- `gg=G` — 全文件自动缩进
- `Space cf` — LSP 格式化代码
- `Space cF` — 格式化并保存

---

## 八、列编辑（Visual Block）

- `Ctrl+v` → `j/k` → `I` → 输入 → `Esc` — 在选区前方插入（多行加前缀）
- `Ctrl+v` → `j/k` → `A` → 输入 → `Esc` — 在选区后方追加（多行加后缀）
- `Ctrl+v` → `j/k` → `c` → 输入 → `Esc` — 删除选区并替换（改列内容）
- `Ctrl+v` → `j/k` → `C` → 输入 → `Esc` — 删除选区到行尾并替换
- `Ctrl+v` → `j/k` → `r{char}` — 用单个字符替换选区（立即生效）

&gt; **注意**：`I`/`A`/`c`/`C` 输入时只显示第一行变化，按 `Esc` 后同步到所有行。

---

## 九、括号与结构跳转

- `%` — 跳转到匹配括号（`()`、`{}`、`[]`）
- `[(` / `])` — 上一个 / 下一个未匹配的 `(`
- `[{` / `]}` — 上一个 / 下一个未匹配的 `{`
- `[m` / `]m` — 上一个 / 下一个函数开头
- `[M` / `]M` — 上一个 / 下一个函数结尾

---

## 十、文件与搜索（Telescope）

- `Space ff` — 查找文件（当前项目）
- `Space fg` — 全局文本搜索（live grep）
- `Space fb` — 查找已打开的 Buffer
- `Space fr` — 最近文件
- `Space ss` — 当前文件符号（函数/变量列表）
- `Space sS` — 工作区符号
- `Space fd` — 查找 D 盘文件（自定义）
- `Space cd` — 切换工作目录

---

## 十一、Git

- `Space gg` — 打开 LazyGit
- `Space gh` — 查看当前 hunk
- `Space gH` — 预览 hunk
- `Space gb` — Git blame 当前行
- `Space gB` — Git blame 整个文件

---

## 十二、终端与运行

- `Ctrl+\` — 切换 ToggleTerm 终端
- `F5` — 运行当前文件（C/Java/Python）
- `Space ft` — 打开浮动终端

---

## 十三、其他实用

- `Ctrl+a` / `Ctrl+x` — 光标下数字增 / 减
- `ys` / `cs` / `ds` — 添加 / 修改 / 删除 surround（引号/括号）
- `Ctrl+s` — 保存文件
- `Ctrl+=` / `Ctrl+-` — 增大 / 减小字体（Neovide）
- `Space un` — 查看通知历史（Noice）
- `Space ul` — 打开 Lazy 插件管理
- `Space cm` — 打开 Mason（LSP 管理）
- `Space uC` — 切换配色方案
- `q` — 关闭浮窗（help、Telescope、诊断等）

---

## 十四、命令行与历史

- `:` — 进入 Ex 命令行
- `/` / `?` — 向下 / 向上搜索
- `Ctrl+f`（在 `:` 模式下）— 打开命令历史窗口
- `Ctrl+f`（在 `/` 模式下）— 打开搜索历史窗口
- `Ctrl+c` — 关闭命令行窗口

---

## 记忆优先级（建议先熟记）

1. **窗口**：`Ctrl+hjkl` + `Alt+hl` + `Ctrl+方向键`
2. **选择**：`viw` / `vi"` / `vaf` / `vif`
3. **跳转**：`gd` + `Ctrl+o` / `gi` / `g;`
4. **搜索替换**：`*` + `cgn` + `.`
5. **注释**：`gcc` / `gc`
6. **列编辑**：`Ctrl+v` + `I` / `c`