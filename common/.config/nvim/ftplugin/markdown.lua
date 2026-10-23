vim.opt_local.wrap = false
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.breakindentopt = "list:-1"
vim.opt_local.textwidth = 0
vim.opt_local.formatexpr = ""
vim.opt_local.conceallevel = 3

local map = vim.keymap.set

map({ "n", "o", "x" }, "0", "g0", { buffer = true })
map({ "n", "o", "x" }, "$", "g$", { buffer = true })
