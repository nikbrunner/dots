local M = {}

---@class VinConfig
M.config = {
    ---@type BlackAtom.Theme.Key
    colorscheme = "black-atom-terra-fall-night",
    dev_mode = true,
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
