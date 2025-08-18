local present, treesitter = pcall(require, "nvim-treesitter.configs")

if not present then
    vim.notify_once("`Treesitter` module not found!", vim.log.levels.ERROR)
    return
end

treesitter.setup({
    highlight = {
        enable = true,
        disable = function(_, bufnr)
            return vim.api.nvim_buf_line_count(bufnr) > 5000
        end,
    },
    auto_install = true,
    ensure_installed = {
        "bash",
        "c",
        "css",
        "go",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "rust",
        "toml",
        "astro",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
        "http",
    },
    incremental_selection = {
        enable = true,
        disable = { "vim", "qf" },
        keymaps = {
            init_selection = "vv",
            node_incremental = "v",
            node_decremental = "<BS>",
        },
    },
})