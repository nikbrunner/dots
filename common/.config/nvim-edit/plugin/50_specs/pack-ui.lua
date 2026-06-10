-- Minimal package manager UI on top of vim.pack (own "plugin", like winbar).
--
-- <leader>ap — float listing installed plugins:
--   u    update plugin under cursor
--   U    update all plugins
--   r    re-check for available updates
--   q    close
-- <leader>aP — update all plugins directly
--
-- A background check runs shortly after startup (headless child process, so
-- the fetches never block the UI) and flags plugins with pending updates.
--
-- The update view is vim.pack's own confirmation buffer shown inside the
-- float: review changes, `:w` applies, `q`/`:q` denies, `gra` offers
-- per-plugin code actions (skip/update/delete), `K` details, `gx` links.

local ns = vim.api.nvim_create_namespace("pack-ui")

local state = { win = nil, mode = nil }

---@type table<string, boolean>|nil names with pending updates; nil until first check
local pending = nil
local checking = false

local function win_valid()
	return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

local function close()
	if win_valid() then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
	state.mode = nil
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

local show_list -- forward declaration (check completion refreshes an open list)

---Check for pending updates in a headless child process.
---`vim.pack.get(nil, { offline = false })` fetches from all sources, so it
---must not run in this instance — the child inherits NVIM_APPNAME and sees
---the same plugins. Pending update = `rev` and `rev_to` differ (:h vim.pack.get()).
local function check_updates()
	if checking then
		return
	end
	checking = true

	local code = table.concat({
		"local ok, plugs = pcall(vim.pack.get, nil, { offline = false })",
		"local out = {}",
		"if ok then",
		"  for _, p in ipairs(plugs) do",
		"    if p.rev and p.rev_to and p.rev ~= p.rev_to then out[#out + 1] = p.spec.name end",
		"  end",
		"end",
		"io.write('##PACKUI##' .. table.concat(out, ',') .. '##END##')",
	}, "\n")

	vim.system(
		{ "nvim", "--clean", "--headless", "+lua " .. code, "+qa!" },
		{ text = true },
		vim.schedule_wrap(function(out)
			checking = false
			local names = (out.stdout or ""):match("##PACKUI##(.-)##END##")
			if not names then
				return
			end
			pending = {}
			local count = 0
			for name in names:gmatch("[^,]+") do
				pending[name] = true
				count = count + 1
			end
			if count > 0 then
				local plural = count == 1 and "" or "s"
				vim.notify(
					string.format("%d update%s available", count, plural),
					vim.log.levels.INFO,
					{ title = "vim.pack" }
				)
			end
			if win_valid() and state.mode == "list" then
				show_list()
			end
		end)
	)
end

---Run vim.pack.update and show its confirmation buffer inside the float.
---@param names string[]|nil nil updates all plugins
---@param title string
local function run_update(names, title)
	state.mode = "update"

	-- The background check already ran `git fetch` for every plugin (shared
	-- plugin dirs, fetches persist on disk) — reuse that data instead of
	-- downloading again. Without a completed check, download as usual.
	local offline = pending ~= nil

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
		"",
		offline and "  ⏳ Preparing update (using already fetched data)…" or "  ⏳ Downloading updates…",
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

			-- Once the confirmation buffer is gone (update applied or denied),
			-- return to the plugin list and refresh the pending-updates info.
			-- Polled via timer instead of BufUnload: vim.pack closes its window
			-- itself and with the adopted float that cleanup can partially fail
			-- (silent pcall) leaving an empty float — polling the buffer is
			-- robust against every cleanup ordering.
			local conf_buf = ev.buf
			local timer = vim.uv.new_timer()
			timer:start(
				400,
				400,
				vim.schedule_wrap(function()
					if vim.api.nvim_buf_is_loaded(conf_buf) then
						return
					end
					timer:stop()
					timer:close()
					-- Skip if the user explicitly closed the UI (close() resets mode)
					if state.mode == "update" then
						show_list()
						vim.defer_fn(check_updates, 2000)
					end
				end)
			)

			-- Close the now-orphaned tabpage window once vim.pack's setup is done.
			-- Its WinClosed cancel hook watches the float, not this window.
			vim.schedule(function()
				pcall(vim.api.nvim_win_close, tab_win, true)
			end)
		end,
	})

	vim.pack.update(names, { offline = offline })
end

show_list = function()
	-- info=false reads revisions from the lockfile instead of shelling out to
	-- git per plugin (~465ms for 32 plugins vs ~0.2ms) — we don't need
	-- branches/tags here, and update info comes from the background check.
	local plugins = vim.pack.get(nil, { info = false })
	table.sort(plugins, function(a, b)
		return a.spec.name < b.spec.name
	end)

	-- Preserve cursor position when re-rendering an already open list
	local prev_row = (win_valid() and state.mode == "list") and vim.api.nvim_win_get_cursor(state.win)[1] or 1

	local lines, names, flagged = {}, {}, {}
	local width = 80
	local update_count = 0
	for i, p in ipairs(plugins) do
		local rev = p.rev and p.rev:sub(1, 7) or "-------"
		local active = p.active and "" or "  (inactive)"
		lines[i] = string.format(" %-32s %s%s", p.spec.name, rev, active)
		names[i] = p.spec.name
		if pending and pending[p.spec.name] then
			flagged[i] = true
			update_count = update_count + 1
		end
		width = math.max(width, #lines[i] + 16)
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	for i in pairs(flagged) do
		vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
			virt_text = { { "● update available ", "DiagnosticInfo" } },
			virt_text_pos = "right_align",
		})
	end
	vim.bo[buf].modifiable = false
	vim.bo[buf].bufhidden = "wipe"

	local status
	if checking then
		status = "checking updates…"
	elseif pending == nil then
		status = "updates not checked yet (r)"
	elseif update_count == 0 then
		status = "up to date"
	else
		status = update_count .. " update" .. (update_count == 1 and "" or "s")
	end

	local height = math.min(#lines, vim.o.lines - 6)
	local title = string.format(" vim.pack — %d plugins · %s · u/U update · q close ", #plugins, status)
	show_buf(buf, width, height, title)
	state.mode = "list"
	vim.api.nvim_win_set_cursor(state.win, { math.min(prev_row, #lines), 0 })

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
	bmap("r", function()
		check_updates()
		show_list()
	end, "Re-check for updates")
end

vim.keymap.set("n", "<leader>ap", show_list, { desc = "[P]lugins (installed)" })
vim.keymap.set("n", "<leader>aP", function()
	run_update(nil, " vim.pack — update all ")
end, { desc = "[P]lugins (update all)" })

-- Background update check on startup. The check itself runs in a child
-- process (vim.system is async), so VimEnter only spawns it — no UI blocking.
if vim.v.vim_did_enter == 1 then
	check_updates()
else
	vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = check_updates })
end
