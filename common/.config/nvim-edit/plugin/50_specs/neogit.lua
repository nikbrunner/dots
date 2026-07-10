-- Magit-style git interface for Neovim.
--
-- Dependencies: all optional. This config reuses plugins already in the
-- stack — no new installs:
--   - codediff.nvim  → diff viewer (replaces iter's diffs.nvim previews)
--   - snacks.nvim    → fuzzy finder backend
--
-- Replaces the `gs` (Git Status) mapping that black_atom/iter.nvim owned
-- (iter.lua is disabled as iter.lua.disabled).

Edit.later(function()
	vim.pack.add({ "https://github.com/neogitorg/neogit" })

	local neogit = require("neogit")

	neogit.setup({
		-- Force codediff as the diff viewer (diffview is not installed).
		diff_viewer = "codediff",

		integrations = {
			codediff = true,
			snacks = true,
		},

		-- Open the status buffer in a new tab (Magit-like full-screen flow).
		kind = "split_below",

		-- Treesitter highlighting for diff hunks + word-level diff.
		treesitter_diff_highlight = true,
		word_diff_highlight = true,

		-- Refresh the status buffer on .git filesystem events.
		filewatcher = { enabled = true, interval = 1000 },

		-- Unicode branch graph in log/history (ascii default looks sparse).
		-- "kitty" needs Kitty terminal glyphs; "unicode" works everywhere.
		graph_style = "unicode",

		-- Spinning indicator while git commands run — nice on big repos / slow logs.
		process_spinner = true,

		-- Relative dates in the log/history views.
		commit_date_format = nil,
		log_date_format = nil,

		-- git_services defaults cover github.com / bitbucket.org / gitlab.com.
		-- Bitbucket Server (work) permalinks stay on gitlinker.nvim (`<leader>dyg`).

		-- Keep neogit's own keymaps; customizations go here later if needed.
		use_default_keymaps = true,

		-- Nicer fold glyphs than the default ">" / "v".
		-- ▸ collapsed, ▾ expanded — render in any font, no Nerd Font needed.
		signs = {
			hunk = { "", "" },
			item = { "▸", "▾" },
			section = { "▸", "▾" },
		},
	})

	-- Status buffer. Three entry points for muscle memory:
	--   `gs`           — primary (reclaims iter.nvim's old mapping)
	--   `<leader>ag`   — was lazygit, now neogit
	--   `<leader>wgs`  — was lazygit, now neogit
	local open_status = function()
		neogit.open()
	end
	vim.keymap.set("n", "gs", open_status, { desc = "Git Status (Neogit)" })
	vim.keymap.set("n", "<leader>ag", open_status, { desc = "[G]it (Neogit)" })
	vim.keymap.set("n", "<leader>wgs", open_status, { desc = "[S]tatus (Neogit)" })

	-- History (replaced lazygit log / file log).
	--   `<leader>wgH` — repo-wide log for the current branch (direct buffer, no popup).
	--   `<leader>dgH` — log of changes to the current file (`:NeogitLogCurrent`).
	--                 With a visual range it traces that line span via `-L`.
	vim.keymap.set("n", "<leader>wgH", neogit.action("log", "log_current"), { desc = "[H]istory (Neogit log)" })
	vim.keymap.set("n", "<leader>dgH", "<Cmd>NeogitLogCurrent<CR>", { desc = "[H]istory: current file (Neogit)" })
	vim.keymap.set("v", "<leader>dgH", ":NeogitLogCurrent<CR>", { desc = "[H]istory: line range (Neogit -L)" })
end)
