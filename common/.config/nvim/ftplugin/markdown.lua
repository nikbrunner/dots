vim.opt_local.wrap = false
vim.opt_local.linebreak = true
vim.opt_local.textwidth = 80

vim.opt_local.formatoptions:append("t") -- Auto-wrap text using textwidth
vim.opt_local.formatoptions:remove("l") -- Allow wrapping of long lines in insert mode

local map = vim.keymap.set

map({ "n", "o", "x" }, "j", "gj", { buffer = true })
map({ "n", "o", "x" }, "k", "gk", { buffer = true })
map({ "n", "o", "x" }, "0", "g0", { buffer = true })
map({ "n", "o", "x" }, "$", "g$", { buffer = true })
