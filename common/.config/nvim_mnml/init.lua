require("config.options")
require("config.keymaps")
require("config.auto")
require("config.lsp")

local black_atom = require("specs.black_atom")
local treesitter = require("specs.treesitter")
local mini = require("specs.mini")
local gitsigns = require("specs.gitsigns")
local navigator = require("specs.navigator")
local mason = require("specs.mason")
local sleuth = require("specs.sleuth")
local conform = require("specs.conform")
local supermaven = require("specs.supermaven")

vim.pack.add({
    black_atom.spec,
    gitsigns.spec,
    mini.spec,
    navigator.spec,
    treesitter.spec,
    mason.spec,
    sleuth.spec,
    conform.spec,
    supermaven.spec,
})

black_atom.init()
gitsigns.init()
mini.init()
navigator.init()
treesitter.init()
mason.init()
conform.init()
supermaven.init()
