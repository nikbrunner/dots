local M = {}

---Get session name for a given path (defaults to cwd)
---@param path? string Absolute path to derive session name from
---@return string
function M.get_session_name(path)
    local dir = path or vim.fn.getcwd()
    local home = vim.fn.expand("~")

    -- Strip home directory to make portable across macOS/Linux
    local name = dir
    if vim.startswith(dir, home) then
        name = string.sub(dir, #home + 2) -- +2 to skip the trailing slash
    end

    -- Replace remaining slashes with underscores
    name = string.gsub(name, "/", "_")

    local result = vim.fn.system("git -C " .. vim.fn.shellescape(dir) .. " branch --show-current")
    local branch = vim.trim(result)
    branch = string.gsub(branch, "/", "_")

    if vim.v.shell_error == 0 and branch ~= "" then
        return name .. "_" .. branch
    else
        return name
    end
end

-- Directories that should auto-create sessions
M.auto_create_session_dirs = {
    vim.fn.expand("~/repos/"),
}

return M
