---@type LazyPluginSpec
return {
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
}
