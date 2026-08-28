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

	local function convert_to_black_atom_oklch()
		local color = require("oklch-color-picker").color_under_cursor()
		if not color or not color.color:match("^#%x%x%x%x%x%x$") then
			vim.notify("No 6-digit hex color under cursor", vim.log.levels.INFO)
			return
		end

		local oklch = require("mini.colors").convert(color.color, "oklch", {
			adjust_lightness = false,
		})
		local replacement = string.format("oklch(%.3f, %.4f, %.1f)", oklch.l / 100, oklch.c / 100, oklch.h or 0)
		local row = vim.api.nvim_win_get_cursor(0)[1]

		vim.api.nvim_buf_set_text(0, row - 1, color.pos[1] - 1, row - 1, color.pos[2] - 1, { replacement })
	end

	vim.keymap.set("n", "<leader>aC", function()
		require("oklch-color-picker").pick_under_cursor()
	end, { desc = "[C]olor picker" })

	vim.keymap.set("n", "<leader>ac", convert_to_black_atom_oklch, {
		desc = "Convert to Black Atom OKLCH",
	})
end)
