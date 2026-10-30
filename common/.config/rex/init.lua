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
		for _, layer in ipairs(window.layers or {}) do
			for _, block in ipairs(layer.blocks or {}) do
				if block.label == label then
					return block.block_id, layer.layer_id
				end
			end
		end
	end
end

-- One popup per label: the key opens it, focuses it when it is open
-- elsewhere, and closes it when it has focus.
local function popup(label, command, w, h)
	return function(ctx)
		local block, layer = find_popup(ctx.session_id, label)
		if block == ctx.block_id then
			rex.session.close_layer({ session_id = ctx.session_id, layer_id = layer })
		elseif block then
			rex.session.focus_block({ session_id = ctx.session_id, block_id = block })
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
		return true
	end
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
	popup = "cmd+s",
	-- side = "cmd+shift+s",
	bin = os.getenv("HOME") .. "/.local/bin/helm-rex",
})

rex.bind(
	"cmd+p",
	popup("file-picker", function(ctx)
		return { "env", "REX_TARGET_BLOCK=" .. ctx.block_id, "file-picker", "-g" }
	end, 0.95, 0.8)
)
rex.bind("cmd+g", popup("lazygit", { "lazygit" }, 1, 1))
rex.bind("cmd+r", popup("review", { "nvim", "iter://review" }, 1, 1))
rex.bind("cmd+j", popup("lazyjira", { "lazyjira" }, 1, 1))
rex.bind("cmd+l", popup("livery", { "livery", "apply" }, 0.15, 0.25))

-- Bob, the notes session's Claude: the key jumps to its pane, and from there
-- back to the session it came from. A popup can't hold another session's block.
-- Lua here only reaches its own session, so bob-pane and the rex CLI do the
-- cross-session work. An action, since rex.client.queue only works inside one.
local home = os.getenv("HOME")
local rex_cli = home
	.. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
local bob_return
rex.action({
	name = "bob_toggle",
	title = "Jump to Bob and back",
	run = function(ctx)
		local found = rex.exec({ home .. "/.local/bin/bob-pane" })
		local session, block, window = (found and found.stdout or ""):match("(%S+) (%S+) (%S+)")
		if not session then
			return
		end
		if ctx.block_id == block then
			if bob_return then
				rex.client.queue("session.select", { session_id = bob_return })
			end
			return
		end
		bob_return = ctx.session_id
		rex.exec({ rex_cli, "focus", "-s", session, block })
		rex.client.queue("session.select", { session_id = session, window_id = window })
	end,
})
rex.bind("cmd+b", "bob_toggle")

-- rex.bind("cmd+shift+g", popup("glab-tui", { "glab-tui" }, 0.95, 0.8))
-- rex.bind("cmd+shift+d", popup("lazydocker", { "lazydocker" }, 0.8, 0.8))
-- rex.bind("cmd+shift+f", popup("pick-font", { "pick-font" }, 0.5, 0.5)) -- pick-font can't switch Rex's font: the app keeps it in its plist and only reads it on launch.
-- rex.bind("cmd+shift+w", popup("bm", { "bm" }, 0.5, 0.35))
