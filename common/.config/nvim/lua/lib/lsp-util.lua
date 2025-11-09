---@brief
---
--- LSP utility functions
---

local M = {}

--- Finds the TypeScript server path in node_modules
--- Used by LSPs that need to locate the TypeScript SDK (e.g., astro-ls)
---@param root_dir string The root directory to search from
---@return string The path to the TypeScript lib directory, or empty string if not found
function M.get_typescript_server_path(root_dir)
    local project_roots = vim.fs.find("node_modules", { path = root_dir, upward = true, limit = math.huge })
    for _, project_root in ipairs(project_roots) do
        local typescript_path = project_root .. "/typescript"
        local stat = vim.uv.fs_stat(typescript_path)
        if stat and stat.type == "directory" then
            return typescript_path .. "/lib"
        end
    end
    return ""
end

return M
