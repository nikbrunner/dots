---@type LazyPluginSpec[]
return {
    {
        "black-atom-industries/nvim",
        name = "black-atom",
        dir = require("lib.config").get_repo_path("black-atom-industries/nvim"),
        lazy = false,
        ---@module "black-atom"
        ---@type BlackAtom.Config
        opts = {
            styles = {
                transparency = "none",
                cmp_kind_color_mode = "bg",
                diagnostics = {
                    background = true,
                },
                syntax = {
                    comments = { italic = false },
                    variables = {},
                },
            },
        },
        config = function(_, opts)
            require("black-atom").setup(opts)
            vim.cmd.colorscheme(require("config").colorscheme)
        end,
    },
    {
        "black-atom-industries/radar.nvim",
        -- dir = require("lib.config").get_repo_path("black-atom-industries/radar.nvim"),
        -- lazy = false,
        event = "VimEnter",
        ---@module "radar"
        ---@type Radar.Config
        opts = {
            keys = {
                tabs_toggle = "<leader>t",
            },
            -- radar = {
            --     winblend = 10,
            -- },
        },
    },
    {
        "black-atom-industries/iter.nvim",
        dir = require("lib.config").get_repo_path("black-atom-industries/iter.nvim"),
        cmd = { "Iter" },
        keys = {
            { "gs", "<cmd>Iter<cr>", desc = "Git Status" },
        },
        opts = {
            preview = {
                -- Start diff previews with wrapping disabled.
                wrap = false,

                -- Show old/new line numbers in diff previews.
                show_line_numbers = true,

                -- Show git diff metadata rows such as `diff --git`, `index`, `---`,
                -- and `+++`.
                show_metadata = false,

                -- Diff preview layout: 'stacked', 'split', or 'auto'.
                diff_layout = "auto",

                -- Editor width where 'auto' switches from stacked to split.
                diff_auto_threshold = 120,
            },
        },
    },
}
