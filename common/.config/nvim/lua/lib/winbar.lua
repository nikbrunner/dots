local M = {}

function M.render()
    local filepath = vim.fn.expand("%:.")
    if filepath == "" then
        filepath = "[No Name]"
    end

    -- Get treesitter node at cursor
    local ok, node = pcall(vim.treesitter.get_node)
    if not ok or not node then
        return filepath
    end

    local breadcrumbs = {}

    -- Walk up the tree collecting named nodes
    while node do
        for child in node:iter_children() do
            local child_type = child:type()
            -- Look for name/identifier nodes
            if child_type == "name" or child_type == "identifier" or child_type:match("_name$") then
                local name = vim.treesitter.get_node_text(child, 0)
                if name and name ~= "" then
                    table.insert(breadcrumbs, 1, name)
                    break
                end
            end
        end

        node = node:parent()
    end

    if #breadcrumbs > 0 then
        local separator = "%#Comment# / %*"
        local breadcrumb_path = "%#Function#" .. table.concat(breadcrumbs, "%#Comment# / %#Function#") .. "%*"
        return "%#Directory#" .. filepath .. "%*" .. separator .. breadcrumb_path
    end

    return "%#Directory#" .. filepath .. "%*"
end

return M
