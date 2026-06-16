-- stylua: ignore start
-- This file is aligned manually for easier reading — stylua is disabled
-- for the whole file.

-- General ====================================================================
vim.g.mapleader       = ',' -- Use `,` as <Leader> key

vim.o.mouse           = 'a'            -- Enable mouse
vim.o.mousescroll     = 'ver:25,hor:6' -- Customize mouse scroll
vim.o.switchbuf       = 'usetab'       -- Use already opened buffers when switching
vim.o.undofile        = true           -- Enable persistent undo
vim.o.swapfile        = false          -- Don't create swap files
vim.o.updatetime      = 500            -- Faster CursorHold (used by checktime etc.)
vim.o.clipboard       = 'unnamedplus'  -- Sync yank/paste with system clipboard
vim.o.jumpoptions     = 'stack'        -- Make jumplist behave like a stack

vim.o.shada           = "'100,<50,s10,:1000,/100,@100,h" -- Limit ShaDa file (for startup)

vim.o.sessionoptions  = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- NOTE: 'exrc' is set in 'init.lua' — the `.nvim.lua` search happens right
-- after init.lua is sourced, before plugin/ files. Setting it here is too late.

-- Enable all filetype plugins and syntax (if not enabled, for better startup)
vim.cmd('filetype plugin indent on')
if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end

-- UI =========================================================================
vim.o.breakindent     = true                -- Indent wrapped lines to match line start
vim.o.breakindentopt  = 'list:-1'           -- Add padding for lists (if 'wrap' is set)
vim.o.colorcolumn     = '+1'                -- Draw column on the right of maximum width
vim.o.cursorline      = true                -- Enable current line highlighting
vim.o.inccommand      = 'split'             -- Preview :substitute results in a split
vim.o.laststatus      = 3                   -- Single global statusline
vim.o.linebreak       = true                -- Wrap lines at 'breakat' (if 'wrap' is set)
vim.o.list            = true                -- Show helpful text indicators
vim.o.number          = true                -- Show line numbers
vim.o.relativenumber  = true                -- Show relative line numbers
vim.o.pumborder       = 'solid'             -- Use padded border in popup menu
vim.o.pumheight       = 10                  -- Make popup menu smaller
vim.o.pummaxwidth     = 60                  -- Make popup menu not too wide
vim.o.ruler           = false               -- Don't show cursor coordinates
vim.o.scrolloff       = 4                   -- Keep lines visible around cursor
vim.o.scrolloffpad    = 99                  -- Keep 'scrolloff' padding even at end of file
vim.o.shortmess       = 'CFOSWaco'          -- Disable some built-in completion messages
vim.o.showmode        = false               -- Don't show mode in command line
vim.o.signcolumn      = 'yes'               -- Always show signcolumn (less flicker)
vim.o.splitbelow      = true                -- Horizontal splits will be below
vim.o.splitkeep       = 'screen'            -- Reduce scroll during window split
vim.o.splitright      = true                -- Vertical splits will be to the right
vim.o.winborder       = 'solid'             -- Use padded border in floating windows
vim.o.wrap            = false               -- Don't visually wrap lines

vim.o.cursorlineopt   = 'screenline,number' -- Show cursor line per screen line

vim.o.guicursor       = 'n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20' -- Mode-dependent cursor shape
vim.o.guifont         = 'JetBrainsMono Nerd Font:h16'            -- Only used by GUI clients

-- Special UI symbols. More is set via 'mini.basics' later.
vim.o.fillchars       = 'eob: ,fold:╌'
-- vim.o.listchars       = 'extends:…,nbsp:␣,precedes:…,tab:> '

-- Folds (see `:h fold-commands`, `:h zM`, `:h zR`, `:h zA`, `:h zj`)
vim.o.foldlevel       = 99     -- Start with all folds open
vim.o.foldmethod      = 'expr' -- Fold based on treesitter
vim.o.foldnestmax     = 10     -- Limit number of fold levels
vim.o.foldtext        = ''     -- Show text under fold with its highlighting

vim.o.foldexpr        = 'v:lua.vim.treesitter.foldexpr()'

-- Editing ====================================================================
vim.o.autoindent      = true     -- Use auto indent
vim.o.expandtab       = true     -- Convert tabs to spaces
vim.o.formatoptions   = 'rqnl1j' -- Improve comment editing
vim.o.ignorecase      = true     -- Ignore case during search
vim.o.incsearch       = true     -- Show search matches while typing
vim.o.infercase       = true     -- Infer case in built-in completion
vim.o.shiftwidth      = 2        -- Use this number of spaces for indentation
vim.o.smartcase       = true     -- Respect case if search pattern has upper case
vim.o.smartindent     = true     -- Make indenting smart
vim.o.spelloptions    = 'camel'  -- Treat camelCase word parts as separate words
vim.o.tabstop         = 2        -- Show tab as this number of spaces
vim.o.virtualedit     = 'block'  -- Allow going past end of line in blockwise mode

vim.o.spelllang       = 'en_us,de_de' -- Spellcheck English and German

vim.o.iskeyword       = '@,48-57,_,192-255,-' -- Treat dash as `word` textobject part

-- Pattern for a start of numbered list (used in `gw`). This reads as
-- "Start of list item is: at least one special character (digit, -, +, *)
-- possibly followed by punctuation (. or `)`) followed by at least one space".
vim.o.formatlistpat   = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]

-- Built-in completion
vim.o.complete        = '.,w,b,kspell'                  -- Use less sources
vim.o.completeopt     = 'menuone,noselect,fuzzy,nosort' -- Use custom behavior
vim.o.completetimeout = 100                             -- Limit sources delay

-- Filetypes ==================================================================
vim.filetype.add({ extension = { http = 'http' } })

-- Autocommands ===============================================================

-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.
local f = function() vim.cmd('setlocal formatoptions-=c formatoptions-=o') end
Edit.new_autocmd('FileType', nil, f, "Proper 'formatoptions'")

-- Diagnostics are configured in 'plugin/10_options/lsp.lua'.
-- stylua: ignore end

require("vim._core.ui2").enable({
	enable = true, -- Whether to enable or disable the UI.
	msg = { -- Options related to the message module.
		---@type string|table<string, 'cmd'|'msg'|'pager'> Default message target
		---or table mapping |ui-messages| kinds, triggers and IDs to a target.
		---Table keys are are matched as a Lua pattern to the message ID. 'default'
		---mapping applies to any omitted kind: { default = 'cmd', progress = 'msg' }.
		targets = "cmd",
		cmd = { -- Options related to messages in the cmdline window.
			-- Maximum height (rows if >=1, or % of 'lines' if <1) of messages expanded
			-- beyond 'cmdheight'; 0.999 for full height.
			height = 0.5,
		},
		dialog = { -- Options related to dialog window.
			height = 0.5, -- Maximum height.
		},
		msg = { -- Options related to msg window.
			height = 0.5, -- Maximum height.
			timeout = 4000, -- Time a message is visible in the message window.
		},
		pager = { -- Options related to message window.
			height = 0.999, -- Maximum height.
		},
	},
})
