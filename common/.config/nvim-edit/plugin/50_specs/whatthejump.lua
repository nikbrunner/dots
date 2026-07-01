-- Show jumplist neighbors in a float while navigating with <C-o> / <C-i>.
-- We have custom <C-o>/<C-i> maps in 20_keymaps.lua, so the plugin's
-- auto-wiring is skipped — wire show_jumps explicitly (see README).

Edit.later(function()
	vim.pack.add({ "git@github.com:lewis6991/whatthejump.nvim" })

	local map = vim.keymap.set
	map("n", "<C-o>", function()
		require("whatthejump").show_jumps(false)
		return "<C-o>zz"
	end, { expr = true, desc = "Jump back" })
	map("n", "<C-i>", function()
		require("whatthejump").show_jumps(true)
		return "<C-i>zz"
	end, { expr = true, desc = "Jump forward" })
end)
