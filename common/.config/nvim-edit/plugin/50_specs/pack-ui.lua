-- Minimal package manager UI on top of vim.pack (own "plugin", like winbar).
--
-- <leader>ap — float listing installed plugins:
--   u    update plugin under cursor
--   U    update all plugins
--   q    close
-- <leader>aP — update all plugins directly
--
-- The update view is vim.pack's own confirmation buffer shown inside the
-- float: review changes, `:w` applies, `:q` denies, `gra` offers per-plugin
-- code actions (skip/update/delete), `K` for details, `gx` opens links.

local state = { win = nil }

local function win_valid()
	return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function close()
	if win_valid() then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
end

local function float_config(width, height, title)
	return {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		title = title,
		title_pos = "center",
	}
end

local function show_buf(buf, width, height, title)
	if win_valid() then
		vim.api.nvim_win_set_buf(state.win, buf)
		vim.api.nvim_win_set_config(state.win, float_config(width, height, title))
	else
		state.win = vim.api.nvim_open_win(buf, true, float_config(width, height, title))
	end
	vim.wo[state.win][0].cursorline = true
end

---Run vim.pack.update and show its confirmation buffer inside the float.
---@param names string[]|nil nil updates all plugins
---@param title string
local function run_update(names, title)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"",
		"  ⏳ Downloading updates…",
		"",
		"  If nothing is pending, vim.pack only sends a notification — `q` closes.",
	})
	vim.bo[buf].bufhidden = "wipe"
	vim.keymap.set("n", "q", close, { buffer = buf, silent = true })
	show_buf(buf, 76, 6, title)

	-- Adopt the confirmation buffer into the float: vim.pack opens it via
	-- `:tab sbuffer` and only *afterwards* captures the current window for its
	-- lifecycle hooks (WinClosed = cancel, :w = apply). Focusing the float
	-- from inside BufWinEnter makes vim.pack adopt the float as that window,
	-- so all its hooks work on the float natively.
	vim.api.nvim_create_autocmd("BufWinEnter", {
		pattern = "nvim-pack://confirm*",
		once = true,
		callback = function(ev)
			if not win_valid() then
				return -- float was closed in the meantime; keep default tabpage
			end
			local tab_win = vim.api.nvim_get_current_win()
			local width = math.floor(vim.o.columns * 0.85)
			local height = math.floor(vim.o.lines * 0.85)
			vim.api.nvim_win_set_buf(state.win, ev.buf)
			vim.api.nvim_win_set_config(state.win, float_config(width, height, title))
			vim.api.nvim_set_current_win(state.win)

			-- vim.pack only knows `:quit` as deny — map the `q` key to it
			vim.keymap.set("n", "q", "<Cmd>quit<CR>", { buffer = ev.buf, silent = true, desc = "Deny update" })
			-- Close the now-orphaned tabpage window once vim.pack's setup is done.
			-- Its WinClosed cancel hook watches the float, not this window.
			vim.schedule(function()
				pcall(vim.api.nvim_win_close, tab_win, true)
			end)
		end,
	})

	vim.pack.update(names)
end

local function show_list()
	local plugins = vim.pack.get()
	table.sort(plugins, function(a, b)
		return a.spec.name < b.spec.name
	end)

	local lines, names = {}, {}
	local width = 60
	for i, p in ipairs(plugins) do
		local rev = p.rev and p.rev:sub(1, 7) or "-------"
		local active = p.active and "" or "  (inactive)"
		lines[i] = string.format(" %-32s %s%s", p.spec.name, rev, active)
		names[i] = p.spec.name
		width = math.max(width, #lines[i] + 2)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local height = math.min(#lines, vim.o.lines - 6)
	local title = string.format(" vim.pack — %d plugins · u update · U update all · q close ", #plugins)
	show_buf(buf, width, height, title)

	local function bmap(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = buf, silent = true, desc = desc })
	end

	bmap("q", close, "Close")
	bmap("u", function()
		local name = names[vim.api.nvim_win_get_cursor(state.win)[1]]
		if name then
			run_update({ name }, string.format(" vim.pack — update %s ", name))
		end
	end, "Update plugin under cursor")
	bmap("U", function()
		run_update(nil, " vim.pack — update all ")
	end, "Update all plugins")
end

vim.keymap.set("n", "<leader>ap", show_list, { desc = "[P]lugins (installed)" })
vim.keymap.set("n", "<leader>aP", function()
	run_update(nil, " vim.pack — update all ")
end, { desc = "[P]lugins (update all)" })
