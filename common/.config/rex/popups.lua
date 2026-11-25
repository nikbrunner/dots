local panes = require("panes")

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

-- One popup per label in each tab, as the action `popup_<label>`: it opens the
-- popup, brings it back with focus when it is minimized or unfocused, and hides
-- it when it has focus. Hiding closes it, or with `keep` minimizes it so its
-- program keeps running. A named action, because Lua function bindings don't
-- fire while a floating layer has focus.
local function popup(label, command, w, h, keep)
	rex.action({
		name = "popup_" .. label:gsub("-", "_"),
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
						flavor = panes.terminal .. ".shell",
						label = label,
						options = {
							command = type(command) == "function" and command(ctx) or command,
							cwd = panes.cwd(ctx.block_id),
						},
					}),
				})
			end
		end,
	})
end

popup("file-picker", function(ctx)
	return { "env", "REX_TARGET_BLOCK=" .. ctx.block_id, "file-picker", "-g" }
end, 0.95, 0.8)
popup("lazygit", { "lazygit" }, 1, 1, true)
popup("review", { "nvim", "iter://review" }, 1, 1, true)
popup("lazyjira", { "lazyjira" }, 1, 1, true)
popup("livery", { "livery", "apply" }, 0.35, 0.25)
popup("lager", { "lager", "tui" }, 1, 1)
popup("glab-tui", { "glab-tui" }, 0.95, 0.8, true)
