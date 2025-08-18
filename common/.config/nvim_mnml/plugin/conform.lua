local formatters = {
    prettier = {
        cmd = "prettierd",
        configs = { ".prettierrc", ".prettierrc.json" },
    },
    deno = {
        cmd = "deno_fmt",
        configs = { "deno.json", "deno.jsonc" },
    },
    -- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome.lua
    biome = {
        cmd = "biome",
        configs = { "biome.json", "biome.jsonc" },
    },
}

vim.g.vin_autoformat_enabled = true

-- Cache formatters per project root to avoid repeated detection
local project_formatters = {}

local function get_project_root(fname)
    local project_root = vim.fs.find({ ".git", "package.json", "deno.json", "deno.jsonc", "biome.json", "biome.jsonc" }, {
        upward = true,
        path = fname,
    })[1]

    if project_root then
        return vim.fs.dirname(project_root)
    else
        return vim.fs.dirname(fname)
    end
end

local function detect_js_formatter(fname, bufnr)
    local conform = require("conform")

    local prettier_config = vim.fs.find(formatters.prettier.configs, { upward = true, path = fname })[1]
    local deno_config = vim.fs.find(formatters.deno.configs, { upward = true, path = fname })[1]
    local biome_config = vim.fs.find(formatters.biome.configs, { upward = true, path = fname })[1]

    local is_prettier_available = conform.get_formatter_info(formatters.prettier.cmd, bufnr).available
    local is_deno_available = conform.get_formatter_info(formatters.deno.cmd, bufnr).available
    local is_biome_available = conform.get_formatter_info(formatters.biome.cmd, bufnr).available

    -- Notify about config findings (only on first detection)
    if prettier_config then
        local msg = is_prettier_available
                and string.format(
                    "Found `prettier` config (%s), and will use `%s` for formatting",
                    prettier_config,
                    formatters.prettier.cmd
                )
            or string.format(
                "There is a `prettier` config (%s), but `%s` is not installed",
                prettier_config,
                formatters.prettier.cmd
            )
        local level = is_prettier_available and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(msg, level, { title = "Conform" })
    end

    if deno_config then
        local msg = is_deno_available and string.format("Using %s for formatting", formatters.deno.cmd)
            or "There is a deno config, but deno is not installed"
        local level = is_deno_available and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(msg, level, { title = "Conform" })
    end

    if biome_config then
        local msg = is_biome_available and string.format("Using %s for formatting", formatters.biome.cmd)
            or "There is a biome config, but biome is not installed"
        local level = is_biome_available and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify(msg, level, { title = "Conform" })
    end

    -- Return formatter in priority order: biome > deno > prettier
    if biome_config and is_biome_available then
        return { "biome-check" }
    elseif deno_config and is_deno_available then
        return { formatters.deno.cmd, stop_after_first = true }
    elseif prettier_config and is_prettier_available then
        return { formatters.prettier.cmd, stop_after_first = true }
    end

    return {}
end

local function select_js_formatter()
    local bufnr = vim.api.nvim_get_current_buf()
    local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))
    local project_root = get_project_root(fname)

    -- Return cached result if available
    if project_formatters[project_root] then
        return project_formatters[project_root]
    end

    -- Detect and cache formatter for this project
    local result = detect_js_formatter(fname, bufnr)
    project_formatters[project_root] = result
    return result
end

local present, conform = pcall(require, "conform")

if not present then
    vim.notify_once("`Conform` module not found!", vim.log.levels.ERROR)
    return
end

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

conform.setup({
    log_level = vim.log.levels.DEBUG,
    format_on_save = function()
        if vim.g.vin_autoformat_enabled then
            return { timeout_ms = 500, lsp_fallback = "fallback" }
        end
    end,
    formatters_by_ft = {
        javascript = select_js_formatter,
        javascriptreact = select_js_formatter,
        markdown = select_js_formatter,
        json = select_js_formatter,
        typescript = select_js_formatter,
        typescriptreact = select_js_formatter,
        css = { formatters.prettier.cmd },
        scss = { formatters.prettier.cmd },
        graphql = { formatters.prettier.cmd },
        html = { formatters.prettier.cmd },
        lua = { "stylua" },
        svelte = { formatters.prettier.cmd },
        yaml = { formatters.prettier.cmd },
        toml = { "taplo" },
        go = { "gofmt" },
        sh = { "shfmt" },
        http = { "kulala-fmt" },
    },
})

vim.keymap.set({ "n", "x" }, "gq", function()
    require("conform").format({
        async = true,
        timeout_ms = 500,
        lsp_fallback = true,
    })
end, { desc = "Format" })

vim.keymap.set("n", "<leader>aof", function()
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
end, { desc = "Toggle Format on Save" })

vim.keymap.set("n", "<leader>ahf", "<cmd>ConformInfo<CR>", { desc = "[F]ormatter" })