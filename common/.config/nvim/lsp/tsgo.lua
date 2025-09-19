-- Install with: npm i -g @typescript/native-preview

---@type vim.lsp.Config
return {
    cmd = { "tsgo", "--lsp", "--stdio" },
    -- filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    filetypes = {}, -- Disabled and use vtsls until this also handles code actions
    root_dir = function(bufnr, cb)
        local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

        local deno_configs = { "deno.json", "deno.jsonc" }
        local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]
        -- If there is a Deno config, we don't start the vtsls server.
        if deno_config then
            return
        end

        -- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
        local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]
        if git_root then
            cb(vim.fn.fnamemodify(git_root, ":h"))
        end

        local ts_configs = { "tsconfig.json", "tsconfig.jsonc" }
        local ts_config = vim.fs.find(ts_configs, { upward = true, path = fname })[1]
        if ts_config then
            cb(vim.fn.fnamemodify(ts_config, ":h"))
        end
    end,
}
