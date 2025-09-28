vim.g.mapleader = ","

vim.opt.autoread = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 1
vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "popup", "preview" }
vim.opt.autocompletedelay = 150
vim.opt.cursorline = true
vim.opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " " }
vim.opt.foldcolumn = "1"
vim.opt.foldenable = true
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldmethod = "indent"
vim.opt.foldtext = ""
vim.opt.ignorecase = true
vim.opt.inccommand = "split" -- preview for substitution
vim.opt.jumpoptions = "stack"
vim.opt.number = true
vim.opt.pumblend = 10
vim.opt.pumheight = 30
vim.opt.relativenumber = true
vim.opt.scrolloff = 4
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.statuscolumn = "%s %l %C "
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undofile = true
vim.opt.winborder = "solid"
vim.opt.winbar = "%f"
vim.opt.wrap = false

-- Assign `http` files as `http` files (currently they are interpreted as `conf`)
vim.filetype.add({
    extension = {
        http = "http",
    },
})
