-- Install with: npm i -g yaml-language-server
-- https://github.com/redhat-developer/yaml-language-server

-- schemastore.nvim is optional; if missing, fall back to an empty schema list
-- so a missing plugin doesn't break the entire vim.lsp.enable() bootstrap.
local ok, schemastore = pcall(require, "schemastore")
local yaml_schemas = ok and schemastore.yaml.schemas() or {}

---@type vim.lsp.Config
return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    settings = {
        yaml = {
            validate = true,
            schemaStore = {
                -- Disable built-in schemaStore; use schemastore.nvim instead
                enable = false,
                url = "",
            },
            schemas = yaml_schemas,
        },
    },
}
