-- Install with: npm i -g yaml-language-server
-- https://github.com/redhat-developer/yaml-language-server

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
            schemas = require("schemastore").yaml.schemas(),
        },
    },
}
