---@brief
---
--- https://github.com/withastro/language-tools/tree/main/packages/language-server
--- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/astro.lua
---
--- `astro-ls` can be installed via `npm`:
--- ```sh
--- npm install -g @astrojs/language-server
--- ```

local lsp_util = require("lib.lsp-util")

---@type vim.lsp.Config
return {
    cmd = { "astro-ls", "--stdio" },
    filetypes = { "astro" },
    root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
    init_options = {
        typescript = {},
    },
    before_init = function(_, config)
        if config.init_options and config.init_options.typescript and not config.init_options.typescript.tsdk then
            config.init_options.typescript.tsdk = lsp_util.get_typescript_server_path(config.root_dir)
        end
    end,
}
