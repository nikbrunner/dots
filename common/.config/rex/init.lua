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
				rex.session.set_layer_state({ session_id = ctx.session_id, layer_id = layer, state = "normal", focus = true })
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

rex.bind("alt+k", "session.previous")
rex.bind("alt+j", "session.next")
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
rex.bind("alt+h", "client.tab.previous")
rex.bind("alt+l", "client.tab.next")
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

-- Popups
package.path = os.getenv("HOME") .. "/repos/black-atom-industries/helm/lua/?.lua;" .. package.path

require("helm").setup({
	popup = false,
	-- side = "cmd+shift+s",
	bin = os.getenv("HOME") .. "/.local/bin/helm-rex",
})
rex.bind("cmd+s", "helm_open")

bind_popup("cmd+p", "file-picker", function(ctx)
	return { "env", "REX_TARGET_BLOCK=" .. ctx.block_id, "file-picker", "-g" }
end, 0.95, 0.8)
bind_popup("cmd+g", "lazygit", { "lazygit" }, 1, 1, true)
bind_popup("cmd+r", "review", { "nvim", "iter://review" }, 1, 1, true)
bind_popup("cmd+j", "lazyjira", { "lazyjira" }, 1, 1, true)
bind_popup("cmd+l", "livery", { "livery", "apply" }, 0.35, 0.25)

-- Bob, the notes session's Claude: the key jumps to its pane, and from there
-- back to the session it came from. A popup can't hold another session's block.
-- Lua here can't list another session's blocks, so bob-pane finds Bob's pane.
-- An action, since rex.client.queue only works inside one.
local home = os.getenv("HOME")
local bob_return
-- bob-pane is the slow part, so its answer is kept until focusing that pane fails.
local bob
local function find_bob()
	local found = rex.exec({ home .. "/.local/bin/bob-pane" })
	local session, block, window = (found and found.stdout or ""):match("(%S+) (%S+) (%S+)")
	bob = session and { session = session, block = block, window = window } or nil
end
rex.action({
	name = "bob_toggle",
	title = "Jump to Bob and back",
	run = function(ctx)
		if not bob then
			find_bob()
		end
		if not bob then
			return
		end
		if ctx.block_id == bob.block then
			if bob_return then
				rex.client.queue("session.select", { session_id = bob_return })
			end
			return
		end
		local function focus()
			return pcall(rex.session.focus_block, { session_id = bob.session, block_id = bob.block })
		end
		if not focus() then
			find_bob()
			if not bob or ctx.block_id == bob.block or not focus() then
				return
			end
		end
		bob_return = ctx.session_id
		rex.client.queue("session.select", { session_id = bob.session, window_id = bob.window })
	end,
})
rex.bind("cmd+b", "bob_toggle")

bind_popup("cmd+alt+g", "glab-tui", { "glab-tui" }, 0.95, 0.8, true)
-- bind_popup("cmd+shift+d", "lazydocker", { "lazydocker" }, 0.8, 0.8)
-- bind_popup("cmd+shift+f", "pick-font", { "pick-font" }, 0.5, 0.5) -- pick-font can't switch Rex's font: the app keeps it in its plist and only reads it on launch.
-- bind_popup("cmd+shift+w", "bm", { "bm" }, 0.5, 0.35)
