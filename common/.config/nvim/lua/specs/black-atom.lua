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
            },
        },
        config = function(_, opts)
            require("black-atom").setup(opts)
            vim.cmd.colorscheme(require("config").colorscheme)
        end,
    },
    {
        "black-atom-industries/radar.nvim",
        dir = require("lib.config").get_repo_path("black-atom-industries/radar.nvim"),
        -- lazy = false,
        event = "VimEnter",
        ---@module "radar"
        ---@type Radar.Config
        opts = {
            radar = {
                winblend = 10,
                border = "double",
                grid_size = { width = math.floor(vim.o.columns * 0.8), height = math.floor(vim.o.lines * 0.3) },
            },
        },
    },
}
