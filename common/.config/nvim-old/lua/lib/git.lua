local M = {}

---comment
---@return string | nil
function M.get_current_git_branch()
    -- Command to get the current Git branch name
    local cmd = "git rev-parse --abbrev-ref HEAD"

    -- Open the command for reading
    local handle = io.popen(cmd)
    if not handle then
        vim.notify("Failed to execute git command", vim.log.levels.ERROR)
        return nil
    end

    -- Read the command's output (the current branch name)
    local branch_name = handle:read("*a")
    handle:close()

    -- Trim any trailing whitespace from the branch name
    branch_name = string.match(branch_name, "^%s*(.-)%s*$")

    if branch_name == "" then
        vim.notify("Git branch not found or Git not initialized", vim.log.levels.ERROR)
        return nil
    end

    return branch_name
end

---Parses from the provided branch name a issue number and returns it either capitalized or `nil`, if non is found.
---@param branch_name string
---@return string | nil
---Examples:
---```lua
---parse_issue_id_from_branch("feature/dev-123-some-new-feature") -> "DEV-123"
---parse_issue_id_from_branch("dev") -> nil
---```
function M.parse_issue_id_from_branch(branch_name)
    -- Pattern to match the <Three-Letters>-<Number> format
    local pattern = "([a-zA-Z]+%-%d+)"

    -- Search for the pattern in the branch name
    local issue_id = string.match(branch_name, pattern)

    -- If an issue ID is found, return it in uppercase, otherwise return nil
    return issue_id and string.upper(issue_id) or nil
end

---Get all worktrees for a git repository
---@param git_root string Absolute path to the git repository root
---@return {path: string, branch: string, is_main: boolean, display: string}[]
function M.get_worktrees(git_root)
    local cmd = "git -C " .. vim.fn.shellescape(git_root) .. " worktree list --porcelain"
    local output = vim.fn.systemlist(cmd)

    if vim.v.shell_error ~= 0 then
        vim.notify("Failed to list worktrees", vim.log.levels.ERROR)
        return {}
    end

    local worktrees = {}
    local current = nil

    for _, line in ipairs(output) do
        if line == "" then
            if current then
                table.insert(worktrees, current)
                current = nil
            end
        elseif vim.startswith(line, "worktree ") then
            if current then
                table.insert(worktrees, current)
            end
            local path = line:sub(10)
            local is_main = #worktrees == 0
            current = {
                path = path,
                branch = "main",
                is_main = is_main,
            }
        elseif current and vim.startswith(line, "branch ") then
            local ref = line:sub(8)
            local branch_name = ref:match("refs/heads/(.+)") or ref
            current.branch = branch_name
        elseif current and line == "detached" then
            current.branch = "HEAD"
        end
    end

    if current then
        table.insert(worktrees, current)
    end

    for _, wt in ipairs(worktrees) do
        if wt.is_main then
            wt.display = string.format("main [%s]  %s", wt.branch, wt.path)
        else
            local dir_name = vim.fn.fnamemodify(wt.path, ":t")
            wt.display = string.format("%s  (%s)", wt.branch, dir_name)
        end
    end

    return worktrees
end

return M
