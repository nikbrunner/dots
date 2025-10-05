local Severity = vim.diagnostic.severity

vim.diagnostic.config({
    underline = false,
    virtual_text = true,
    virtual_lines = false,
    update_in_insert = false,
    float = {
        border = "solid",
        focus = false,
        scope = "cursor",
    },
    jump = {
        on_jump = vim.diagnostic.open_float,
    },
    signs = {
        numhl = {
            [Severity.ERROR] = "DiagnosticSignError",
            [Severity.HINT] = "DiagnosticSignHint",
            [Severity.INFO] = "DiagnosticSignInfo",
            [Severity.WARN] = "DiagnosticSignWarn",
        },
        text = {
            [Severity.ERROR] = "",
            [Severity.HINT] = "",
            [Severity.INFO] = "",
            [Severity.WARN] = "",
        },
    },
})

-- Set up LSP servers.
local function enable_lsp()
    local server_configs = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
        :map(function(file)
            return vim.fn.fnamemodify(file, ":t:r")
        end)
        :totable()
    vim.lsp.enable(server_configs)
end

-- Normal startup: enable LSP on first buffer
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    once = true,
    callback = function()
        -- Skip if loading a session (vim sets g:SessionLoad during :source session.vim)
        if vim.g.SessionLoad == 1 then
            return
        end
        enable_lsp()
    end,
})

-- Session load: enable LSP after session finishes loading
vim.api.nvim_create_autocmd("SessionLoadPost", {
    once = true,
    callback = enable_lsp,
})

vim.api.nvim_create_autocmd("LspAttach", {
    nested = true,
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)
        local lib = require("lib.lsp")
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        -- Enable native inline completion
        vim.lsp.inline_completion.enable()

        -- LSP Diagnostics
        vim.keymap.set("n", "sp", function()
            lib.set_diagnostic_virtual_lines()

            vim.api.nvim_create_autocmd("CursorMoved", {
                group = vim.api.nvim_create_augroup("symbol-problems", {}),
                desc = "User(once): Reset diagnostics virtual lines",
                once = true,
                callback = function()
                    lib.set_diagnostic_virtual_text()
                    return true
                end,
            })
        end, { buffer = ev.buf, desc = "[P]roblems (Inline)" })

        vim.keymap.set("n", "si", vim.lsp.buf.hover, { buffer = ev.buf, desc = "[I]nfo" })
        vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature Help" })
        vim.keymap.set("n", "sa", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "[A]ction" })
        vim.keymap.set("n", "sn", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Re[n]ame" })

        vim.keymap.set("n", "sV", lib.goto_split_definition, { buffer = ev.buf, desc = "[D]efinition in Split" })
        vim.keymap.set("n", "sT", lib.goto_tab_definition, { buffer = ev.buf, desc = "[D]efinition in Tab" })

        vim.keymap.set("i", "<Tab>", function()
            if not vim.lsp.inline_completion.get() then
                return "<Tab>"
            end
        end, { expr = true, desc = "Accept the current inline completion" })
    end,
})
