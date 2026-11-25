-- Helpers the other modules share.
local M = {}

M.terminal = "com.superlogical.terminal"

-- The foreground process's cwd, which shells and TUIs alike report; `pwd`
-- only holds what a shell announced itself.
function M.cwd(block_id)
	local process = block_id and rex.block.call(M.terminal, "process", { block_id = block_id })
	return process and process.foreground and process.foreground.cwd
end

-- Every pane of every session, in sidebar and tab order. Rex answers only for
-- sessions the calling client is attached to: the app sees them all, `rex do`
-- from a shell sees its own.
function M.all()
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
function M.jump(pane)
	rex.session.focus_block({ session_id = pane.session_id, block_id = pane.block_id })
	rex.client.queue("session.select", { session_id = pane.session_id, window_id = pane.window_id })
end

return M
