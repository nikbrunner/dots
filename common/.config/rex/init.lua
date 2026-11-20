-- https://www.superlogical.com/rex/docs/reference/lua

local terminal = "com.superlogical.terminal"

-- The foreground process's cwd, which shells and TUIs alike report; `pwd`
-- only holds what a shell announced itself.
local function cwd(block_id)
	local process = block_id and rex.block.call(terminal, "process", { block_id = block_id })
	return process and process.foreground and process.foreground.cwd
end

local function find_popup(session_id, label)
	local view = rex.session.view({ session_id = session_id }) or {}
	for _, window in ipairs(view.windows or {}) do
		if window.window_id == view.active_window_id then
			for _, layer in ipairs(window.layers or {}) do
				for _, block in ipairs(layer.blocks or {}) do
					if block.label == label then
						return block.block_id, layer.layer_id, window.focused_block_id
					end
				end
			end
		end
	end
end

-- One popup per label in each tab: the key opens it, brings it back with focus
-- when it is minimized or unfocused, and hides it when it has focus. Hiding closes
-- it, or with `keep` minimizes it so its program keeps running. Bound through a
-- named action, because Lua function bindings don't fire while a floating layer
-- has focus.
local function bind_popup(key, label, command, w, h, keep)
	local name = "popup_" .. label:gsub("-", "_")
	rex.action({
		name = name,
		title = "Popup: " .. label,
		run = function(ctx)
			local block, layer, focused = find_popup(ctx.session_id, label)
			if block and block == focused then
				if keep then
					rex.session.set_layer_state({ session_id = ctx.session_id, layer_id = layer, state = "minimized" })
				else
					rex.session.close_layer({ session_id = ctx.session_id, layer_id = layer })
				end
			elseif block then
				rex.session.set_layer_state({
					session_id = ctx.session_id,
					layer_id = layer,
					state = "normal",
					focus = true,
				})
			else
				rex.session.new_layer({
					session_id = ctx.session_id,
					bounds = { (1 - w) / 2, (1 - h) / 2, w, h },
					focus = true,
					layout = rex.layout.block({
						flavor = terminal .. ".shell",
						label = label,
						options = {
							command = type(command) == "function" and command(ctx) or command,
							cwd = cwd(ctx.block_id),
						},
					}),
				})
			end
		end,
	})
	rex.bind(key, name)
end

-- App

rex.bind("cmd+;", "client.palette.toggle")
rex.bind("cmd+shift+r", "client.config.reload")

-- Sessions

rex.bind("alt+shift+k", "session.previous")
rex.bind("alt+shift+j", "session.next")

rex.bind("alt+shift+t", "session.new")
rex.bind("alt+shift+n", "session.rename")
rex.bind("alt+shift+q", "session.close")

-- Tabs

for i = 1, 9 do
	rex.bind("alt+" .. i, "client.tab.goto", { index = i })
end
rex.bind("alt+t", "client.tab.new")
rex.bind("alt+n", "client.tab.rename")
rex.bind("alt+q", "client.tab.close")
rex.bind("alt+k", "client.tab.previous")
rex.bind("alt+j", "client.tab.next")
rex.bind("alt+shift+h", "client.tab.move.backward")
rex.bind("alt+shift+l", "client.tab.move.forward")

-- Panes

-- Ctrl+hjkl moves between panes, except in Neovim, which gets the key and
-- crosses back into Rex at its split edges (see nvim's navigator.lua).
for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
	rex.bind("ctrl+" .. key, function(ctx)
		local process = ctx.block_id and rex.block.call(terminal, "process", { block_id = ctx.block_id })
		if process and process.foreground and process.foreground.name == "nvim" then
			return false
		end
		rex.session.focus_direction({ session_id = ctx.session_id, direction = direction })
		return true
	end)
end

for _, direction in ipairs({ "left", "down", "up", "right" }) do
	rex.bind("alt+shift+" .. direction, "pane.resize", { direction = direction })
	rex.bind("ctrl+shift+" .. direction, "pane.move", { direction = direction })
end
rex.bind("alt+=", "pane.balance")
rex.bind("alt+z", "pane.zoom")

-- Clears screen and scrollback in a shell; a TUI keeps the key, since a reset
-- would wipe its screen.
rex.bind("alt+c", function(ctx)
	local process = ctx.block_id and rex.block.call(terminal, "process", { block_id = ctx.block_id })
	local name = process and process.foreground and process.foreground.name
	if name ~= "zsh" and name ~= "bash" and name ~= "fish" then
		return false
	end
	rex.block.call(terminal, "reset", { block_id = ctx.block_id })
	rex.block.call(terminal, "write", { block_id = ctx.block_id, data = "\f" })
	return true
end)

-- Agents

-- Every pane of every session, in sidebar and tab order. Rex answers only for
-- sessions the calling client is attached to: the app sees them all, `rex do`
-- from a shell sees its own.
local function panes()
	local found = {}
	local sessions = rex.call("session.list") or {}
	for _, session in ipairs(sessions.sessions or {}) do
		local view = rex.session.view({ session_id = session.session_id }) or {}
		for _, window in ipairs(view.windows or {}) do
			for _, layer in ipairs(window.layers or {}) do
				for _, block in ipairs(layer.blocks or {}) do
					found[#found + 1] = {
						session_id = session.session_id,
						window_id = window.window_id,
						block_id = block.block_id,
						label = block.label,
					}
				end
			end
		end
	end
	return found
end

-- Works from an action only, like the rex.client.queue it calls.
local function jump(pane)
	rex.session.focus_block({ session_id = pane.session_id, block_id = pane.block_id })
	rex.client.queue("session.select", { session_id = pane.session_id, window_id = pane.window_id })
end

-- An agent is a pane whose program reports a status, or runs under one of these
-- names. Pi and OpenCode report no status while idle, so they need the name.
local agent_programs = { claude = true, codex = true, opencode = true, pi = true }

local function is_agent(pane)
	local at = { session_id = pane.session_id, block_id = pane.block_id }
	local status = rex.block.call(terminal, "program_status", at)
	if status and status.records and status.records[1] then
		return true
	end
	local process = rex.block.call(terminal, "process", at)
	local argv0 = process and process.foreground and process.foreground.argv0
	return argv0 and agent_programs[argv0:match("[^/]*$")]
end

-- The keys walk the agents across all sessions and wrap; from any other pane
-- they go to the nearest agent in that order.
for key, step in pairs({ j = 1, k = -1 }) do
	local name = step > 0 and "agent_next" or "agent_previous"
	rex.action({
		name = name,
		title = step > 0 and "Next Agent" or "Previous Agent",
		run = function(ctx)
			local agents, before, on = {}, 0, false
			for _, pane in ipairs(panes()) do
				local here = pane.block_id == ctx.block_id
				if here then
					before = #agents
				end
				if is_agent(pane) then
					agents[#agents + 1] = pane
					on = on or here
				end
			end
			if #agents == 0 then
				return
			end
			jump(agents[(step > 0 and before + (on and 1 or 0) or before - 1) % #agents + 1])
		end,
	})
	rex.bind("alt+ctrl+" .. key, name)
end

-- Popups
package.path = os.getenv("HOME") .. "/repos/black-atom-industries/helm/lua/?.lua;" .. package.path

require("helm").setup({
	popup = false,
	-- side = "cmd+shift+s",
	bin = os.getenv("HOME") .. "/.local/bin/helm-rex",
	bounds = { 0.25, 0.175, 0.6, 0.55 },
	detail_bounds = { 0.15, 0.055, 0.9, 0.55 },
})
rex.bind("alt+s", "helm_open")
rex.bind("alt+o", "helm_jump_back")

bind_popup("cmd+i", "file-picker", function(ctx)
	return { "env", "REX_TARGET_BLOCK=" .. ctx.block_id, "file-picker", "-g" }
end, 0.95, 0.8)
bind_popup("cmd+g", "lazygit", { "lazygit" }, 1, 1, true)
bind_popup("cmd+r", "review", { "nvim", "iter://review" }, 1, 1, true)
bind_popup("cmd+j", "lazyjira", { "lazyjira" }, 1, 1, true)
bind_popup("cmd+t", "livery", { "livery", "apply" }, 0.35, 0.25)
bind_popup("cmd+l", "lager", { "lager", "tui" }, 0.75, 0.65)

-- Bob, the notes session's Claude: the key jumps to its pane, and from there
-- back to the session it came from. A popup can't hold another session's block.
-- An action, since rex.client.queue only works inside one.
local home = os.getenv("HOME")
local bob_return
rex.action({
	name = "bob_toggle",
	title = "Jump to Bob and back",
	run = function(ctx)
		local bob
		for _, pane in ipairs(panes()) do
			if (pane.label or ""):lower() == "bob" then
				bob = pane
				break
			end
		end
		if not bob then
			return
		end
		if ctx.block_id == bob.block_id then
			if bob_return and rex.session.view({ session_id = bob_return }) then
				rex.client.queue("session.select", { session_id = bob_return })
			end
			return
		end
		bob_return = ctx.session_id
		jump(bob)
	end,
})
rex.bind("cmd+b", "bob_toggle")
dofile(home .. "/.config/rex/bob_ask.lua")

bind_popup("cmd+alt+g", "glab-tui", { "glab-tui" }, 0.95, 0.8, true)
bind_popup("cmd+alt+f", "pick-font", { "pick-font" }, 0.5, 0.5)
