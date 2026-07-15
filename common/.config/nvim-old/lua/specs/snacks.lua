---@diagnostic disable: assign-type-mismatch, missing-fields

---@type LazyPluginSpec
return {
    "folke/snacks.nvim",
    lazy = false,

    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- stylua: ignore start
                Snacks.toggle.line_number():map("<leader>aol")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>aoL")
                Snacks.toggle.inlay_hints():map("<leader>aoh")
                Snacks.toggle.treesitter():map("<leader>aoT")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 1 and vim.o.conceallevel or 3 }):map("<leader>aoc")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>aob")
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>aos")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>aow")
                -- stylua: ignore end
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "SnacksTerminalClose",
            callback = function()
                vim.defer_fn(function()
                    local ok, gitsigns = pcall(require, "gitsigns")
                    if ok then
                        gitsigns.refresh()
                    end
                end, 100)
            end,
        })
    end,

    dependencies = {},

    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        statuscolumn = { enabled = true },
        debug = { enabled = true },
        toggle = { enabled = true },
        gitbrowse = { enabled = true },
        input = { enabled = false },
        scroll = { enabled = false },
        notifier = {
            enabled = false,
            margin = { top = 0, right = 0, bottom = 1, left = 1 },
            style = "compact",
        },
        words = { debounce = 100 },
        terminal = {
            win = {
                border = "solid",
                wo = {
                    winbar = "",
                },
            },
        },
        lazygit = {
            configure = false,
            win = {
                backdrop = true,
                border = "solid",
                width = 0,
                height = 0,
            },
        },
        styles = {
            notification_history = {
                border = "solid",
            },
            notification = {
                border = "single",
                wo = {
                    winblend = 0,
                    winhighlight = "Normal:SnacksNotifierHistory",
                },
            },
        },
    },

    keys = {
        -- stylua: ignore start
        { "<leader>ag",  function() Snacks.lazygit() end,          desc = "[G]it" },
        { "<leader>an",  function() Snacks.notifier.show_history() end, desc = "[N]otifications" },
        { "<leader>wgH", function() Snacks.lazygit.log() end,      desc = "[H]istory (Lazygit)" },
        { "<leader>wgr", function() Snacks.gitbrowse() end,        desc = "[R]emote (GitHub)" },
        { "<leader>wgs", function() Snacks.lazygit() end,          desc = "[S]tatus (Lazygit)" },
        { "<leader>dgH", function() Snacks.lazygit.log_file() end, desc = "[H]istory (Lazygit)" },
        { "sgb", function() Snacks.git.blame_line() end,   desc = "[B]lame" },
        -- stylua: ignore end
    },
}
