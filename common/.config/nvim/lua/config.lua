local M = {}

---@class VinConfig
M.config = {
    dev_mode = true,

    background = "dark",

    ---@type BlackAtom.Theme.Key
    colorscheme_light = "black-atom-stations-research",

    ---@type BlackAtom.Theme.Key
    colorscheme_dark = "black-atom-mnml-mono-dark",

    open_previous_files_on_startup = false,
    open_neotree_on_startup = false,
    pathes = {
        repos = vim.fn.expand("~/repos"),
        config = {
            nvim = vim.fn.expand("$XDG_CONFIG_HOME") .. "/nvim/lua/config.lua",
            wezterm = vim.fn.expand("$XDG_CONFIG_HOME") .. "/wezterm",
            ghostty = vim.fn.expand("$XDG_CONFIG_HOME") .. "/ghostty",
        },
        notes = {
            personal = vim.fn.expand("~/repos") .. "/nikbrunner/notes",
            the_black_atom = vim.fn.expand("~/repos") .. "/nikbrunner/the-black-atom",
            work = {
                dcd = vim.fn.expand("~/repos") .. "/nikbrunner/dcd-notes",
            },
        },
    },
}

return M.config
