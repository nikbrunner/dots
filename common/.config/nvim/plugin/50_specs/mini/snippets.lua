-- Snippet management and expansion. Expand with <C-j> (default).
-- Snippet sources:
-- - 'snippets/global.lua' — global snippets incl. dynamic date snippets
--   (lua file returning a table; functions are re-evaluated on each expand)
-- - 'snippets/<lang>.json' via from_lang loader (e.g. markdown.json)

Edit.later(function()
	-- Community snippet collection, picked up by the from_lang loader below
	vim.pack.add({ "git@github.com:rafamadriz/friendly-snippets" })

	local snippets = require("mini.snippets")
	local config_path = vim.fn.stdpath("config")

	snippets.setup({
		snippets = {
			snippets.gen_loader.from_file(config_path .. "/snippets/global.lua"),
			snippets.gen_loader.from_lang(),
		},
		mappings = {
			expand = "<C-j>",
			jump_next = "<C-l>",
			jump_prev = "<C-h>",
		},
	})

	-- No start_lsp_server() — blink.cmp uses mini.snippets directly via
	-- the "mini_snippets" preset (see plugin/50_specs/blink.lua).
end)
