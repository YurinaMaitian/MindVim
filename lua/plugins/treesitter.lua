return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
        -- 关键：使用 git 而非 curl 下载
        prefer_git = true,

        -- 确保 Java 被安装
        ensure_installed = { "java", "c", "cpp" },

        highlight = { enable = true },
    },
}
