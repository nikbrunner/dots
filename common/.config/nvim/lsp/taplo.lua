-- Install with: cargo install --features lsp --locked taplo-cli
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/taplo.lua

---@type vim.lsp.Config
return {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".taplo.toml", "taplo.toml", ".git" },
}
