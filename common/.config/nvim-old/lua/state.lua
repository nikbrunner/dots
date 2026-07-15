local M = {}

---@class State
---@field is_deno_project boolean
---@field gh_current_pr number|nil
---@field gh_current_repo string|nil
M.state = {
    is_deno_project = false,
    gh_current_pr = nil,
    gh_current_repo = nil,
}

---@alias StateKey "is_deno_project" | "gh_current_pr" | "gh_current_repo"

-- Getter and setter functions
---@param key StateKey
function M:get(key)
    return self.state[key]
end

---@param key StateKey
---@param value any
function M:set(key, value)
    self.state[key] = value
    return self.state[key]
end

-- Toggle function
---@param key StateKey
function M:toggle(key)
    self.state[key] = not self.state[key]
    return self.state[key]
end

-- Get GitHub context (PR number and repo)
---@return {pr: number|nil, repo: string|nil}
function M:get_gh_context()
    return {
        pr = self.state.gh_current_pr,
        repo = self.state.gh_current_repo,
    }
end

-- Check if GitHub context is available
---@return boolean
function M:has_gh_context()
    return self.state.gh_current_pr ~= nil and self.state.gh_current_repo ~= nil
end

return M
