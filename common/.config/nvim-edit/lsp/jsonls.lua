-- Install with: npm i -g vscode-langservers-extracted
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jsonls.lua

-- schemastore.nvim is optional; if missing, fall back to an empty schema list
-- so a missing plugin doesn't break the entire vim.lsp.enable() bootstrap.
local ok, schemastore = pcall(require, "schemastore")
local json_schemas = ok and schemastore.json.schemas() or {}

---@type vim.lsp.Config
return {
    cmd = { "vscode-json-language-server", "--stdio" },
    filetypes = { "json", "jsonc" },
    settings = {
        json = {
            validate = { enable = true },
            schemas = json_schemas,
        },
    },
}
