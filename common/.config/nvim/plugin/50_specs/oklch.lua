-- Color picker and inline color highlighting (oklch, hex, css colors).

Edit.later(function()
	vim.pack.add({ "git@github.com:eero-lehtinen/oklch-color-picker.nvim" })

	require("oklch-color-picker").setup({
		highlight = {
			enabled = true,
			---@type 'background'|'foreground'|'virtual_left'|'virtual_eol'|'foreground+virtual_left'|'foreground+virtual_eol'
			style = "foreground+virtual_left",
			bold = true,
			italic = false,
			virtual_text = " ",
			ignore_ft = {
				"markdown.gh",
			},
		},
		patterns = {
			oklch_fn = {
				priority = 5,
				format = "raw_oklch",
				"oklch%(()[%d.,%s]+()%)",
			},
			-- oklch(0.656 0.16 54.87) — space-separated CSS-style, no commas
			-- No explicit format: auto-detected as CSS oklch() which handles space-separated
			oklch_css = {
				priority = 5,
				"()oklch%([^,]-%)()",
			},
		},
	})

	vim.keymap.set("n", "<leader>ac", function()
		require("oklch-color-picker").pick_under_cursor()
	end, { desc = "[C]olor picker" })
end)
