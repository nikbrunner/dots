-- Snippet management and expansion. Expand with <C-j> (default).
-- Snippet sources:
-- - 'snippets/global.lua' — global snippets incl. dynamic date snippets
--   (lua file returning a table; functions are re-evaluated on each expand)
-- - 'snippets/<lang>.json' via from_lang loader (e.g. markdown.json)

Edit.later(function()
	local snippets = require("mini.snippets")
	local config_path = vim.fn.stdpath("config")

	snippets.setup({
		snippets = {
			snippets.gen_loader.from_file(config_path .. "/snippets/global.lua"),
			snippets.gen_loader.from_lang({
				lang_patterns = {
					-- Recognize special injected language of markdown tree-sitter parser
					markdown_inline = { "markdown.json" },
				},
			}),
		},
	})

	-- Show snippets at cursor as candidates in the mini.completion menu
	-- (requires this dedicated in-process LSP server).
	MiniSnippets.start_lsp_server()
end)
