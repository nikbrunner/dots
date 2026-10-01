-- Show jumplist neighbors in a float while navigating with <C-o> / <C-i>.
-- We have custom <C-o>/<C-i> maps in 20_keymaps.lua, so the plugin's
-- auto-wiring is skipped — wire show_jumps explicitly (see README).

Edit.later(function()
	vim.pack.add({ "git@github.com:lewis6991/whatthejump.nvim" })

	-- The plugin hardcodes the float to the top-right and exposes no config.
	-- show_jumps opens it in a vim.schedule callback, so a callback scheduled
	-- after it runs once the float exists and can move it.
	local function show_jumps(forward)
		require("whatthejump").show_jumps(forward)
		vim.schedule(function()
			local win = vim.api.nvim_get_current_win()
			for _, w in ipairs(vim.api.nvim_list_wins()) do
				local cfg = vim.api.nvim_win_get_config(w)
				if cfg.relative ~= "" and cfg.zindex == 200 and vim.wo[w].winblend == 15 then
					vim.api.nvim_win_set_config(w, {
						relative = "win",
						win = win,
						anchor = "SE",
						row = vim.api.nvim_win_get_height(win),
						col = vim.api.nvim_win_get_width(win),
					})
				end
			end
		end)
	end

	local map = vim.keymap.set
	map("n", "<C-o>", function()
		show_jumps(false)
		return "<C-o>zz"
	end, { expr = true, desc = "Jump back" })
	map("n", "<C-i>", function()
		show_jumps(true)
		return "<C-i>zz"
	end, { expr = true, desc = "Jump forward" })
end)
