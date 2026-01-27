local M = {}

---@class VinConfig
M.config = {
    ---@type BlackAtom.Theme.Key
    colorscheme = "black-atom-mnml-eink-dark",
    dev_mode = true,
    date_format = "%Y.%m.%d - %A",
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
