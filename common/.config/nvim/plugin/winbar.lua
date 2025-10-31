local function range_contains_pos(range, line, char)
    local start = range.start
    local stop = range["end"]

    if line < start.line or line > stop.line then
        return false
    end

    if line == start.line and char < start.character then
        return false
    end

    if line == stop.line and char > stop.character then
        return false
    end

    return true
end

local function find_symbol_path(symbol_list, line, char, path)
    if not symbol_list or #symbol_list == 0 then
        return false
    end

    for _, symbol in ipairs(symbol_list) do
        if symbol.range and range_contains_pos(symbol.range, line, char) then
            table.insert(path, symbol.name)
            find_symbol_path(symbol.children, line, char, path)
            return true
        end
    end
    return false
end

local function get_relative_path(bufnr)
    local file_path = vim.fn.bufname(bufnr)
    if not file_path or file_path == "" then
        return "[No Name]"
    end

    local relative_path
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients > 0 and clients[1].root_dir then
        -- Get path relative to LSP root
        local root_dir = clients[1].root_dir
        relative_path = vim.fn.fnamemodify(file_path, ":~:.")
        -- If the file is under the root_dir, make it relative to that
        if vim.startswith(file_path, root_dir) then
            relative_path = file_path:sub(#root_dir + 2) -- +2 to skip the trailing slash
        end
    else
        -- Fallback to path relative to cwd
        relative_path = vim.fn.fnamemodify(file_path, ":~:.")
    end

    local parts = vim.split(relative_path, "/", { plain = true })
    local highlighted_parts = {}

    for i, part in ipairs(parts) do
        if i == #parts then
            -- Highlight the filename
            table.insert(highlighted_parts, "%#WinBarFilename#" .. part .. "%*")
        else
            -- Highlight directory parts
            table.insert(highlighted_parts, "%#WinBarPath#" .. part .. "%*")
        end
    end

    return table.concat(highlighted_parts, " %#WinBarSeparator#/%* ")
end

local function lsp_callback(err, symbols, ctx)
    if err or not symbols then
        vim.wo.winbar = get_relative_path(ctx.bufnr)
        return
    end

    local pos = vim.api.nvim_win_get_cursor(0)
    local cursor_line = pos[1] - 1
    local cursor_char = pos[2]

    local path_part = get_relative_path(ctx.bufnr)
    local symbol_breadcrumbs = {}

    find_symbol_path(symbols, cursor_line, cursor_char, symbol_breadcrumbs)

    -- Build the winbar with different separators
    local winbar_parts = { path_part }

    if #symbol_breadcrumbs > 0 then
        -- Add highlighted symbols with different separator
        for _, symbol in ipairs(symbol_breadcrumbs) do
            table.insert(winbar_parts, "%#WinBarSymbol#" .. symbol .. "%*")
        end
        local breadcrumb_string = winbar_parts[1]
            .. " %#WinBarSeparator##%* "
            .. table.concat(vim.list_slice(winbar_parts, 2), " %#WinBarSeparator##%* ")
        vim.wo.winbar = breadcrumb_string
    else
        vim.wo.winbar = path_part
    end
end

local function breadcrumbs_set()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Skip Oil buffers (they have their own winbar)
    if vim.bo[bufnr].filetype == "oil" then
        return
    end

    -- Skip unnamed buffers
    local file_path = vim.fn.bufname(bufnr)
    if not file_path or file_path == "" then
        vim.wo.winbar = ""
        return
    end

    -- Check if window is wide enough for LSP symbols
    local win_width = vim.api.nvim_win_get_width(0)
    if win_width < 150 then
        -- Just show the relative path for narrow windows
        vim.wo.winbar = get_relative_path(bufnr)
        return
    end

    -- Check if any LSP client supports document symbols
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    local has_document_symbol = false

    for _, client in ipairs(clients) do
        if client.server_capabilities.documentSymbolProvider then
            has_document_symbol = true
            break
        end
    end

    -- If no document symbol support, just show the relative path
    if not has_document_symbol then
        vim.wo.winbar = get_relative_path(bufnr)
        return
    end

    local uri = vim.lsp.util.make_text_document_params(bufnr)["uri"]
    if not uri then
        vim.wo.winbar = get_relative_path(bufnr)
        return
    end

    local params = {
        textDocument = {
            uri = uri,
        },
    }
    vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, lsp_callback)
end

local breadcrumbs_augroup = vim.api.nvim_create_augroup("Breadcrumbs", { clear = true })

vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    group = breadcrumbs_augroup,
    callback = function()
        vim.schedule(breadcrumbs_set)
    end,
    desc = "Set breadcrumbs.",
})
