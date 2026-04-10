local prettier_cmd = "prettier"
local prettier_configs = {
    ".prettierrc",
    ".prettierrc.json",
    ".prettierrc.js",
    ".prettierrc.cjs",
    ".prettierrc.mjs",
    "prettier.config.js",
    "prettier.config.cjs",
    "prettier.config.mjs",
    "prettier.config.ts",
}

local deno_cmd = "deno_fmt"
local deno_configs = { "deno.json", "deno.jsonc" }

-- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome.lua
local biome_cmd = "biome"
local biome_configs = { "biome.json", "biome.jsonc" }

---@type LazyPluginSpec
return {
    "stevearc/conform.nvim",
    ---@module "conform"
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    init = function()
        vim.g.vin_autoformat_enabled = true
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

        -- Assign `http` files as `http` files (currently they are interpreted as `conf`)
        vim.filetype.add({
            extension = {
                http = "http",
            },
        })
    end,
    opts = function()
        local conform = require("conform")

        local function handle_shared_formatter(buf)
            -- NOTE: Priority order:
            -- 1. Prettier (explicit formatting config)
            -- 2. Deno (all-in-one tool for Deno projects)
            -- 3. Biome (all-in-one tool, but in some projects only used for linting)
            local buf_fname = vim.uri_to_fname(vim.uri_from_bufnr(buf))

            local is_prettier = conform.get_formatter_info(prettier_cmd, buf).available
            local prettier_config = vim.fs.find(prettier_configs, { upward = true, path = buf_fname })[1]

            if prettier_config ~= nil and not is_prettier then
                vim.notify(
                    string.format("There is a `prettier` config (%s), but `%s` is not installed", prettier_config, prettier_cmd),
                    vim.log.levels.WARN,
                    { title = "Conform" }
                )
            end

            if prettier_config ~= nil and is_prettier then
                return { prettier_cmd, stop_after_first = true }
            end

            local is_deno = conform.get_formatter_info(deno_cmd, buf).available
            local deno_config = vim.fs.find(deno_configs, { upward = true, path = buf_fname })[1]

            if deno_config ~= nil and not is_deno then
                vim.notify("There is a deno config, but deno is not installed", vim.log.levels.WARN, { title = "Conform" })
            end

            if deno_config ~= nil and is_deno then
                return { "deno_fmt", stop_after_first = true }
            end

            -- NOTE: The `biome-check` command combines the `biome` and `biome-organize-imports` commands
            -- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome-check.lua
            -- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome.lua
            -- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome-organize-imports.lua
            local is_biome = conform.get_formatter_info(biome_cmd, buf).available
            local biome_config = vim.fs.find(biome_configs, { upward = true, path = buf_fname })[1]

            if biome_config ~= nil and not is_biome then
                vim.notify("There is a biome config, but biome is not installed", vim.log.levels.WARN, { title = "Conform" })
            end

            if biome_config ~= nil and is_biome then
                -- return { "biome", "biome-organize-imports" }
                return { "biome-check" }
            end

            -- Fallback to prettier with defaults for web-adjacent filetypes
            if is_prettier then
                return { prettier_cmd, stop_after_first = true }
            end

            return {}
        end

        ---@type conform.setupOpts
        return {
            log_level = vim.log.levels.DEBUG,
            format_on_save = function()
                if vim.g.vin_autoformat_enabled then
                    return { timeout_ms = 500, lsp_fallback = "fallback" }
                end
            end,
            formatters_by_ft = {
                astro = handle_shared_formatter,
                javascript = handle_shared_formatter,
                javascriptreact = handle_shared_formatter,
                markdown = handle_shared_formatter,
                json = handle_shared_formatter,
                typescript = handle_shared_formatter,
                typescriptreact = handle_shared_formatter,
                css = handle_shared_formatter,
                scss = handle_shared_formatter,
                graphql = handle_shared_formatter,
                html = handle_shared_formatter,
                lua = { "stylua" },
                svelte = handle_shared_formatter,
                yaml = handle_shared_formatter,
                toml = { "taplo" },
                go = { "gofmt" },
                rust = { "rustfmt" },
                sh = { "shfmt" },
                http = { "kulala-fmt" },
            },
        }
    end,
    keys = {
        {
            "gq",
            mode = { "n", "x" },
            function()
                require("conform").format({
                    async = true,
                    timeout_ms = 500,
                    lsp_fallback = true,
                })
            end,
            desc = "Format",
        },
        {
            "<leader>aof",
            function()
                if vim.g.vin_autoformat_enabled then
                    vim.g.vin_autoformat_enabled = false
                else
                    vim.g.vin_autoformat_enabled = true
                end

                if vim.g.vin_autoformat_enabled then
                    vim.notify("Autoformat enabled", vim.log.levels.INFO, { title = "Conform" })
                else
                    vim.notify("Autoformat disabled", vim.log.levels.INFO, { title = "Conform" })
                end
            end,
            desc = "Toggle Format on Save",
        },
        {
            "<leader>ahf",
            "<cmd>ConformInfo<CR>",
            desc = "[F]ormatter",
        },
    },
}
