local panes = require("panes")

-- An agent is a pane whose program reports a status, or runs under one of these
-- names. Pi and OpenCode report no status while idle, so they need the name.
local agent_programs = { claude = true, codex = true, opencode = true, pi = true }

local function is_agent(pane)
	local at = { session_id = pane.session_id, block_id = pane.block_id }
	local status = rex.block.call(panes.terminal, "program_status", at)
	if status and status.records and status.records[1] then
		return true
	end
	local process = rex.block.call(panes.terminal, "process", at)
	local argv0 = process and process.foreground and process.foreground.argv0
	return argv0 and agent_programs[argv0:match("[^/]*$")]
end

-- agent_next and agent_previous walk the agents across all sessions and wrap;
-- from any other pane they go to the nearest agent in that order.
for _, step in ipairs({ 1, -1 }) do
	rex.action({
		name = step > 0 and "agent_next" or "agent_previous",
		title = step > 0 and "Next Agent" or "Previous Agent",
		run = function(ctx)
			local agents, before, on = {}, 0, false
			for _, pane in ipairs(panes.all()) do
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
			panes.jump(agents[(step > 0 and before + (on and 1 or 0) or before - 1) % #agents + 1])
		end,
	})
end

-- Bob, the notes session's Claude: bob_toggle jumps to its pane, and from there
-- back to the session it came from. A popup can't hold another session's block.
-- An action, since rex.client.queue only works inside one.
local bob_return
rex.action({
	name = "bob_toggle",
	title = "Jump to Bob and back",
	run = function(ctx)
		local bob
		for _, pane in ipairs(panes.all()) do
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
		panes.jump(bob)
	end,
})
