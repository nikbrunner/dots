local MD = require("mini.diff")

MD.setup({
	view = {
		style = "sign",
		signs = {
			add = "▎",
			change = "▎",
			delete = "▎",
		},
	},
	mappings = {
		-- Disable defaults, using custom keymaps below
		apply = "",
		reset = "",
		textobject = "gh", -- Keep textobject for use with custom mappings
		goto_first = "",
		goto_prev = "",
		goto_next = "",
		goto_last = "",
	},
})

local map = vim.keymap.set

-- Navigation with centering (matching gitsigns [c / ]c)
map("n", "]c", function()
	MD.goto_hunk("next")
	vim.cmd("norm zz")
end, { desc = "Next Hunk" })

map("n", "[c", function()
	MD.goto_hunk("prev")
	vim.cmd("norm zz")
end, { desc = "Prev Hunk" })

-- Hunk operations - normal mode uses operator + textobject
map("n", "<leader>cs", function()
	return MD.operator("apply") .. "gh"
end, { expr = true, remap = true, desc = "Stage Hunk" })

map("n", "<leader>cr", function()
	return MD.operator("reset") .. "gh"
end, { expr = true, remap = true, desc = "Reset Hunk" })

-- Hunk operations - visual mode uses do_hunks with selection
map("v", "<leader>cs", function()
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	MD.do_hunks(0, "apply", { line_start = start_line, line_end = end_line })
end, { desc = "Stage Hunk" })

map("v", "<leader>cr", function()
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	MD.do_hunks(0, "reset", { line_start = start_line, line_end = end_line })
end, { desc = "Reset Hunk" })

-- Preview/overlay toggle
map({ "n", "v" }, "<leader>cg", function()
	MD.toggle_overlay(0)
end, { desc = "[G]it (Hunk Preview)" })

-- Buffer-level operations
map("n", "<leader>dgr", function()
	MD.do_hunks(0, "reset")
end, { desc = "[R]evert changes" })

map("n", "<leader>dgs", function()
	MD.do_hunks(0, "apply")
end, { desc = "[S]tage document" })
