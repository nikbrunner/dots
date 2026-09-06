local M = {}

---@class Worktree
---@field path string Absolute path to the worktree
---@field branch string? Checked-out branch (nil for detached/bare worktrees)
---@field display string Human-readable label used in pickers
---@field is_main boolean True for the repository's main worktree

---List git worktrees of the repository containing git_root
---@param git_root string Absolute path to the repository root
---@return Worktree[]
function M.get_worktrees(git_root)
	local ok, result = pcall(function()
		return vim.system({ "git", "-C", git_root, "worktree", "list", "--porcelain" }, { text = true }):wait()
	end)
	if not ok or result.code ~= 0 then
		return {}
	end

	local worktrees = {}
	local current = nil
	for _, line in ipairs(vim.split(result.stdout or "", "\n")) do
		local path = line:match("^worktree%s(.+)$")
		if path then
			if current then
				table.insert(worktrees, current)
			end
			current = { path = path, is_main = #worktrees == 0 }
		elseif current then
			local branch = line:match("^branch%srefs/heads/(.+)$")
			if branch then
				current.branch = branch
			end
		end
	end
	if current then
		table.insert(worktrees, current)
	end

	for _, wt in ipairs(worktrees) do
		local name = vim.fn.fnamemodify(wt.path, ":t")
		wt.display = wt.branch and (name .. " (" .. wt.branch .. ")") or name
	end
	return worktrees
end

return M
