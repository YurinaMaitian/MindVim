-- lua/plugins/c.lua（完全切换 Clang）
-- C/C++ F5 编译运行配置（toggleterm 基础配置在 toggleterm.lua 中）
-- 已经把clang添加进环境变量，如果更换设备记得指定clang路径或者加至环境变量

local c_term = nil

local function save_and_run_c()
    vim.cmd("write")
    local file = vim.fn.expand("%:p")
    local dir = vim.fn.expand("%:p:h")
    local filename_noext = vim.fn.expand("%:t:r")
    local dir_clean = dir:gsub("\\", "/")
    local file_clean = file:gsub("\\", "/")
    local output = string.format("%s/%s.exe", dir_clean, filename_noext)

    local cmd
    local build_script = dir .. "/build.bat"
    local has_build_script = vim.fn.filereadable(build_script) == 1

    if has_build_script then
        cmd = string.format('cd /d "%s" && build.bat', dir)
    else
        local compiler = "clang.exe"
        cmd = string.format(
            'cd /d "%s" && "%s" --target=x86_64-w64-mingw32 -isystem D:/mingw64/x86_64-w64-mingw32/include -LD:/mingw64/x86_64-w64-mingw32/lib -Wall -Wextra -g -std=c11 -o "%s" "%s" && echo [编译成功，正在运行...] && "%s"',
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

return {
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
                        "--compile_args_from=filesystem",
                    },
                    init_options = {
                        fallbackFlags = {
                            "--target=x86_64-w64-mingw32",
                            "-isystem",
                            "D:/mingw64/x86_64-w64-mingw32/include",
                            "-isystem",
                            "D:/mingw64/include",
                            "-std=c11",
                        },
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
                    command = "D:/llvm/bin/clang-format.exe",
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
