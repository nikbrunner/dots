-- QMK keymap.c formatting for my koyo keyboards.
-- Re-runs setup() per keyboard since each has a different physical layout.

Edit.later(function()
	vim.pack.add({ "git@github.com:codethread/qmk.nvim" })

	local shared_opts = {
		comment_preview = {
			position = "inside",
			keymap_overrides = {
				KC_TRANSPARENT = " ",
				["SS_TILD_SLSH"] = "~/",
				["SS_FATARROW"] = "=>",
				["SS_VIM_WA"] = ":wa",
				["SS_TODO"] = "TODO",
				["SS_BCD"] = "BCD-",
			},
		},
	}

	local setup = function(opts)
		require("qmk").setup(vim.tbl_deep_extend("force", shared_opts, opts or {}))
	end

	local group = vim.api.nvim_create_augroup("nvim-edit-qmk", {})

	vim.api.nvim_create_autocmd("BufEnter", {
		desc = "Format CRKBD/Chocofi koyo keymap",
		group = group,
		pattern = {
			"*nikbrunner/koyo/qmk/crkbd/src/keymap.c",
			"*nikbrunner/koyo/qmk/chocofi/src/keymap.c",
		},
		callback = function()
			setup({
				name = "LAYOUT_split_3x5_3",
				layout = {
					"x x x x x _ x x x x x",
					"x x x x x _ x x x x x",
					"x x x x x _ x x x x x",
					"_ _ x x x _ x x x _ _",
				},
			})
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		desc = "Format Moonlander koyo keymap",
		group = group,
		pattern = "*nikbrunner/koyo/qmk/moonlander/src/keymap.c",
		callback = function()
			setup({
				name = "LAYOUT_moonlander",
				layout = {
					"x x x x x x x _ x x x x x x x",
					"x x x x x x x _ x x x x x x x",
					"x x x x x x x _ x x x x x x x",
					"x x x x x x _ _ _ x x x x x x",
					"x x x x x x _ _ _ x x x x x x",
					"_ _ _ _ x x x _ x x x _ _ _ _",
				},
			})
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		desc = "Format Voyager koyo keymap",
		group = group,
		pattern = "*nikbrunner/koyo/qmk/voyager/src/keymap.c",
		callback = function()
			setup({
				name = "LAYOUT_voyager",
				layout = {
					"x x x x x x _ x x x x x x",
					"x x x x x x _ x x x x x x",
					"x x x x x x _ x x x x x x",
					"x x x x x x _ x x x x x x",
					"_ _ _ _ x x _ x x _ _ _ _",
				},
			})
		end,
	})
end)
