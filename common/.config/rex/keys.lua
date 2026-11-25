-- Keys that decide at press time whether Rex or the focused program gets them,
-- so they stay Lua function bindings: returning false hands the key through.
local terminal = require("panes").terminal

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
