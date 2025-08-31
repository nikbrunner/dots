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
            local config = require("config")
            local colorscheme = config["colorscheme_" .. vim.opt.background:get()]
            vim.cmd.colorscheme(colorscheme)
        end,
    },
    {
        "black-atom-industries/radar.nvim",
        dir = require("lib.config").get_repo_path("black-atom-industries/radar.nvim"),
        lazy = false,
        ---@module "radar"
        ---@type Radar.Config
        opts = {
            keys = {
                prefix = "<space>",
                lock = "<space><space>",
            },
        },
    },
}
