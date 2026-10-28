-- https://www.superlogical.com/rex/docs/reference/lua

local terminal = "com.superlogical.terminal"

-- The foreground process's cwd, which shells and TUIs alike report; `pwd`
-- only holds what a shell announced itself.
local function cwd(block_id)
	local process = block_id and rex.block.call(terminal, "process", { block_id = block_id })
	return process and process.foreground and process.foreground.cwd
end

local function popup(command, w, h)
	return function(ctx)
		rex.session.new_layer({
			session_id = ctx.session_id,
			bounds = { (1 - w) / 2, (1 - h) / 2, w, h },
			focus = true,
			layout = rex.layout.block({
				flavor = terminal .. ".shell",
				options = {
					command = type(command) == "function" and command(ctx) or command,
					cwd = cwd(ctx.block_id),
				},
			}),
		})
		return true
	end
end

rex.bind("cmd+shift+l", popup({ "livery", "apply" }, 0.5, 0.4))
-- pick-font can't switch Rex's font: the app keeps it in its plist and only
-- reads it on launch.
-- rex.bind("alt+shift+f", popup({ "pick-font" }, 0.5, 0.5))
rex.bind("alt+shift+w", popup({ "bm" }, 0.5, 0.35))
rex.bind(
	"alt+shift+p",
	popup(function(ctx)
		return { "env", "REX_TARGET_BLOCK=" .. ctx.block_id, "file-picker", "-g" }
	end, 0.95, 0.8)
)
rex.bind("alt+g", popup({ "lazygit" }, 1, 1))
rex.bind("alt+shift+g", popup({ "glab-tui" }, 0.95, 0.8))
rex.bind("alt+ctrl+g", popup({ os.getenv("HOME") .. "/repos/nikbrunner/glab-tui/target/release/glab-tui" }, 0.95, 0.8))
rex.bind("alt+shift+d", popup({ "lazydocker" }, 0.8, 0.8))
rex.bind("alt+shift+j", popup({ "lazyjira" }, 1, 1))

rex.bind("alt+r", popup({ "nvim", "iter://review" }, 1, 1))
