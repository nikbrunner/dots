-- Deferred via `Edit.later`: completion only matters in insert mode, which
-- never happens on the first frame. LSP servers take 100s of ms to boot,
-- while vim.schedule runs in <1ms — so the LspAttach autocmd registered
-- here is always in place long before any server attaches. The
-- CompletionItemKind 4-char remap only affects the pum kind column, which
-- is itself gated on this module being loaded.
Edit.later(function()
	local MC = require("mini.completion")

	-- Capture the canonical LSP kind names BEFORE the 4-char remap below
	-- mutates the table. `item.kind` from the LSP response is the numeric
	-- enum value (6 = Class, 3 = Function, ...); looking it up here gives
	-- the canonical name so `LspKind*` highlight groups resolve correctly.
	local lsp_kind_names = vim.deepcopy(vim.lsp.protocol.CompletionItemKind)

	local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
	local process_items = function(items, base)
		-- Pre-set `kind_hlgroup` per item so the popup uses the active
		-- black-atom theme's LspKind* highlight groups. `default_process_items`
		-- preserves any value already on the item (see `or` in mini.completion),
		-- so this overrides the mini.icons lsp category that would otherwise be
		-- applied.
		for _, item in ipairs(items) do
			local kind_name = lsp_kind_names[item.kind]
			if kind_name then
				item.kind_hlgroup = "LspKind" .. kind_name
			end
		end
		return MC.default_process_items(items, base, process_items_opts)
	end

	for _, item in ipairs(vim.fn.complete_info({ "items" }).items) do
		print(item.word, "->", item.kind, "(hl:", item.kind_hlgroup, ")")
	end
	local on_attach = function(args)
		vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
	end
	vim.api.nvim_create_autocmd("LspAttach", { callback = on_attach })

	-- Remap CompletionItemKind to 4-char labels for the native pum kind column
	local item_kinds = vim.lsp.protocol.CompletionItemKind
	for i, name in ipairs(item_kinds) do
		item_kinds[i] = name:sub(1, 4):upper()
	end

	MC.setup({
		delay = { completion = 100, info = 0, signature = 50 },
		window = {
			info = { height = 10, width = 80, border = "solid" },
			signature = { height = 10, width = 80, border = "solid" },
		},
		lsp_completion = {
			process_items = process_items,
		},
	})

	-- Force signature help with <C-k>
	vim.keymap.set("i", "<C-k>", function()
		vim.lsp.buf.signature_help()
	end, { desc = "Signature help" })

	-- CR accepts selected item or inserts newline
	vim.keymap.set("i", "<CR>", function()
		if vim.fn.complete_info()["selected"] ~= -1 then
			return "\25"
		end
		return "\r"
	end, { expr = true })

	-- C-y: pum accept > fallback
	local termcodes = function(keys)
		return vim.api.nvim_replace_termcodes(keys, true, false, true)
	end

	vim.keymap.set("i", "<C-y>", function()
		if vim.fn.pumvisible() == 1 then
			local info = vim.fn.complete_info()
			if info.selected == -1 then
				return termcodes("<C-n><C-y>")
			end
			return termcodes("<C-y>")
		end
		return termcodes("<C-y>")
	end, { expr = true })
end)
