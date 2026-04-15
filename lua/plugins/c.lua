-- lua/plugins/c.lua
-- C/C++ 完整配置：LSP (clangd) + 格式化 (clang-format) + 编译运行

return {
    -- ==================== 1. LSP (clangd) ====================
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=bundled",
                        "--pch-storage=memory",
                        "--query-driver=D:/mingw64/bin/gcc.exe",
                    },
                    init_options = {
                        fallbackFlags = {
                            "-ID:/mingw64/lib/gcc/x86_64-w64-mingw32/15.2.0/include",
                            "-ID:/mingw64/include",
                            "-ID:/mingw64/x86_64-w64-mingw32/include",
                            "-ID:/mingw64/lib/gcc/x86_64-w64-mingw32/15.2.0/include-fixed",
                        },
                    },
                },
            },
        },
    },

    -- ==================== 2. 格式化 (clang-format) ====================
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
            },
            formatters = {
                clang_format = {
                    -- 使用你手动安装的 LLVM clang-format
                    command = "D:/llvm/bin/clang-format.exe",
                    args = {
                        "-assume-filename",
                        "$FILENAME",
                        "-style={BasedOnStyle: LLVM, IndentWidth: 4, TabWidth: 4, UseTab: Never}",
                    },
                    stdin = true,
                },
            },
        },
    },

    -- ==================== 3. 编译运行 (F5) ====================
    {
        "akinsho/toggleterm.nvim",
        optional = true,
        config = function(_, opts)
            require("toggleterm").setup(opts)
            local Terminal = require("toggleterm.terminal").Terminal
            local c_term = nil

            local function save_and_run_c()
                vim.cmd("write")
                local file = vim.fn.expand("%:p")
                local dir = vim.fn.expand("%:p:h")
                local filename_noext = vim.fn.expand("%:t:r")
                local ext = vim.fn.expand("%:e")
                local dir_clean = dir:gsub("\\", "/")
                local file_clean = file:gsub("\\", "/")
                local output = string.format("%s/%s.exe", dir_clean, filename_noext)

                local cmd
                local build_script = dir .. "/build.sh"
                local has_build_script = vim.fn.filereadable(build_script) == 1

                if has_build_script then
                    cmd = string.format('cd /d "%s" && bash build.sh', dir)
                else
                    local compiler = (ext == "cpp" or ext == "cc" or ext == "cxx") and "g++" or "gcc"
                    cmd = string.format(
                        'cd /d "%s" && %s -Wall -Wextra -g -std=c11 -o "%s" "%s" && echo [编译成功，正在运行...] && "%s"',
                        dir,
                        compiler,
                        filename_noext,
                        file_clean,
                        output
                    )
                end

                if c_term and c_term:is_open() then
                    c_term:close()
                    c_term = nil
                end

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

                    vim.keymap.set("n", "<F5>", save_and_run_c, {
                        buffer = true,
                        silent = true,
                        desc = "保存并编译运行 C/C++",
                    })
                end,
            })
        end,
    },

    -- ==================== 4. Treesitter ====================
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "c", "cpp" })
        end,
    },
}
