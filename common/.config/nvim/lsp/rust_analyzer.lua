-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/rust_analyzer.lua

---@type vim.lsp.Config
return {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json" },
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
        },
    },
}
