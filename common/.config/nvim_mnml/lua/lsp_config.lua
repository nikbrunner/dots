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

vim.diagnostic.config({
    -- underline = false,
    virtual_text = true,
    virtual_lines = false,
    update_in_insert = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if not client then
            return
        end

        if client:supports_method("textDocument/completion") then
            local chars = {}
            for i = 32, 126 do
                table.insert(chars, string.char(i))
            end
            client.server_capabilities.completionProvider.triggerCharacters = chars

            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end

        -- Only enable if server supports completion
        if client.server_capabilities.completionProvider then
            vim.lsp.completion.enable(true, client.id, bufnr, {
                autotrigger = true,
            })
        end

        vim.keymap.set("i", "<c-space>", function()
            vim.lsp.completion.get()
        end)

        vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
        vim.keymap.set("n", "<leader>ali", "<cmd>checkhealth vim.lsp<cr>", { desc = "[I]nfo" })
        vim.keymap.set("n", "<leader>wp", vim.diagnostic.setqflist, { desc = "[W]orkspace [P]roblems" })
    end,
})
