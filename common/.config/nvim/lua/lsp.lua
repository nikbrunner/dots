local Severity = vim.diagnostic.severity

vim.diagnostic.config({
    underline = false,
    virtual_text = true,
    virtual_lines = false,
    update_in_insert = false,
    float = {
        border = "solid",
    },
    signs = {
        text = {
            [Severity.ERROR] = require("icons").diagnostics.Error,
            [Severity.WARN] = require("icons").diagnostics.Warn,
            [Severity.INFO] = require("icons").diagnostics.Info,
            [Severity.HINT] = require("icons").diagnostics.Hint,
        },
    },
})

-- Set up LSP servers.
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    once = true,
    callback = function()
        local server_configs = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
            :map(function(file)
                return vim.fn.fnamemodify(file, ":t:r")
            end)
            :totable()
        vim.lsp.enable(server_configs)
    end,
})
