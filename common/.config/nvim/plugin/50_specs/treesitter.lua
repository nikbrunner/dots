-- Treesitter support.
-- Parser management via arborist: parsers auto-install when a file is opened,
-- queries for ~330 languages are bundled. (nvim-treesitter was archived 2026-04.)
-- Run `:checkhealth arborist` to verify setup; requires the `tree-sitter` CLI.

Edit.now_if_args(function()
	vim.pack.add({ "git@github.com:arborist-ts/arborist.nvim" })

	-- Register the mdx filetype and parse it with the markdown parser
	vim.filetype.add({ extension = { mdx = "mdx" } })
	vim.treesitter.language.register("markdown", "mdx")

	require("arborist").setup({
		-- bob nightlies are not built with ENABLE_WASMTIME — skip the WASM
		-- attempt (and its startup warning) and compile natively right away.
		prefer_wasm = false,
		-- The popular set already covers the rest of the old ensure_installed
		-- list (incl. tsx); these two would only install on demand otherwise.
		ensure_installed = { "astro", "http" },
	})

	-- Fix: Stale node range race condition when async parse completes after
	-- buffer has been modified. nvim_buf_get_text throws "Index out of bounds"
	-- when a node's range exceeds the buffer's current line count.
	--
	-- Affects:
	--   1. Built-in treesitter fold (#trim! directive in folds query)
	--   2. render-markdown.nvim (Node.new calling get_node_text on stale capture)
	--
	-- Returns empty string on stale ranges instead of crashing.
	-- The stale state is temporary — next edit/parse cycle resolves it.
	local orig_get_node_text = vim.treesitter.get_node_text
	vim.treesitter.get_node_text = function(node, source, opts)
		if type(source) ~= "number" then
			return orig_get_node_text(node, source, opts)
		end
		local ok, result = pcall(orig_get_node_text, node, source, opts)
		if ok then
			return result
		end
		return ""
	end
end)
