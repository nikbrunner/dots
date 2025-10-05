local M = {}

function M.render()
    -- Get the window ID for this specific winbar (available during statusline evaluation)
    local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    -- Make it relative to cwd if possible
    if filepath ~= "" then
        local cwd = vim.fn.getcwd()
        if filepath:find(cwd, 1, true) == 1 then
            filepath = filepath:sub(#cwd + 2) -- +2 to skip the trailing slash
        else
            filepath = vim.fn.fnamemodify(filepath, ":~")
        end
    else
        filepath = "[No Name]"
    end

    -- Get cursor position for this window
    local cursor = vim.api.nvim_win_get_cursor(winid)
    local row = cursor[1] - 1 -- 0-indexed
    local col = cursor[2]

    -- Get treesitter node at cursor position for this specific buffer
    local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, pos = { row, col } })
    if not ok or not node then
        return "%#Directory#" .. filepath .. "%*"
    end

    local breadcrumbs = {}

    -- Walk up the tree collecting named nodes
    while node do
        for child in node:iter_children() do
            local child_type = child:type()
            -- Look for name/identifier nodes
            if child_type == "name" or child_type == "identifier" or child_type:match("_name$") then
                local ok_text, name = pcall(vim.treesitter.get_node_text, child, bufnr)
                if ok_text and name and name ~= "" then
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
