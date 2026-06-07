vim.g.mapleader = ","
vim.g.maplocalleader = "."

vim.opt.mouse = "a"

vim.cmd.colorscheme("miniwinter")

-- Load project-specific .nvim.lua files (run `:trust` to allow execution)
vim.o.exrc = true

vim.opt.clipboard = "unnamedplus"

vim.opt.spelllang = "en_us,de_de"

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.opt.cursorline = true
vim.opt.cursorcolumn = false

-- preview for substitution
vim.opt.inccommand = "split"

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.o.winborder = "solid"

vim.o.conceallevel = 0

vim.opt.jumpoptions = "stack"

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.opt.foldcolumn = "0"

vim.opt.jumpoptions = "stack"

vim.opt.pumborder = "solid"
vim.opt.pumblend = 0
vim.opt.pumheight = 10
vim.opt.pummaxwidth = 60
-- vim.o.shortmess = vim.o.shortmess .. "uc"
vim.opt.scrolloffpad = 99

vim.o.complete = ".,w,b,kspell" -- Use less sources
vim.o.completeopt = "menuone,noselect,fuzzy,nosort"
vim.o.completetimeout = 100     -- Limit sources delay

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autoread = true
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.writebackup = false
vim.opt.undofile = true
vim.opt.updatetime = 500

vim.opt.cmdheight = 1

vim.opt.showmode = false
vim.opt.laststatus = 3

vim.opt.wrap = false

vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.termguicolors = true

vim.opt.guifont = { "JetBrainsMono Nerd Font", ":h16" }

vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20"

vim.opt.scrolloff = 4

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.o.showtabline = 0

-- Disabled because its somehow interfering with mini.completion info window
-- pcall(function()
--     require("vim._core.ui2").enable({
--         msg = {
--             targets = {
--                 default = "msg",
--                 progress = "msg",
--                 pager = "pager",
--             },
--             msg = {
--                 timeout = 3000,
--                 height = 0.5,
--             },
--         },
--     })
-- end)
