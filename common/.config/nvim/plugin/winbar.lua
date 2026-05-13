local function range_contains_pos(range, line, char)
    local start = range.start
    local stop = range["end"]
    if line < start.line or line > stop.line then return false end
    if line == start.line and char < start.character then return false end
    if line == stop.line and char > stop.character then return false end
    return true
end

local function find_symbol_path(symbol_list, line, char, path)
    if not symbol_list or #symbol_list == 0 then return false end
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
    if not file_path or file_path == "" then return "[No Name]" end

    local relative_path
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients > 0 and clients[1].root_dir then
        local root_dir = clients[1].root_dir
        relative_path = vim.fn.fnamemodify(file_path, ":~:.")
        if vim.startswith(file_path, root_dir) then
            relative_path = file_path:sub(#root_dir + 2)
        end
    else
        relative_path = vim.fn.fnamemodify(file_path, ":~:.")
    end

    local parts = vim.split(relative_path, "/", { plain = true })
    local highlighted_parts = {}
    for i, part in ipairs(parts) do
        if i == #parts then
            table.insert(highlighted_parts, "%#WinBarFilename#" .. part .. "%*")
        else
            table.insert(highlighted_parts, "%#WinBarPath#" .. part .. "%*")
        end
    end
    return table.concat(highlighted_parts, " %#WinBarSeparator#/%* ")
end

local function get_ft_icon(bufnr)
    local bufname = vim.fn.bufname(bufnr)
    local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or ""
    if filename == "" then return "" end
    local ok, icon, hl = pcall(require("mini.icons").get, "file", filename)
    if ok and icon then
        return "%#" .. hl .. "#" .. icon .. "%*  "
    end
    return ""
end

local function get_git_diff(bufnr)
    local summary = vim.b[bufnr].minidiff_summary
    if not summary then return "" end
    local parts = {}
    if (summary.add or 0) > 0 then
        table.insert(parts, "%#MiniDiffSignAdd#+" .. summary.add .. "%*")
    end
    if (summary.change or 0) > 0 then
        table.insert(parts, "%#MiniDiffSignChange#~" .. summary.change .. "%*")
    end
    if (summary.delete or 0) > 0 then
        table.insert(parts, "%#MiniDiffSignDelete#-" .. summary.delete .. "%*")
    end
    if #parts == 0 then return "" end
    return table.concat(parts, " ")
end

local function get_diagnostics(bufnr)
    local parts = {}
    local severities = {
        { "error", "DiagnosticSignError" },
        { "warn", "DiagnosticSignWarn" },
        { "info", "DiagnosticSignInfo" },
        { "hint", "DiagnosticSignHint" },
    }
    for _, sv in ipairs(severities) do
        local n = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity[string.upper(sv[1])] })
        if n > 0 then
            table.insert(parts, "%#" .. sv[2] .. "#" .. n .. "%*")
        end
    end
    if #parts == 0 then return "" end
    return table.concat(parts, " ")
end

local function build_right(bufnr)
    local parts = {}
    local git = get_git_diff(bufnr)
    local diag = get_diagnostics(bufnr)
    if git ~= "" then table.insert(parts, git) end
    if diag ~= "" then table.insert(parts, diag) end
    if #parts == 0 then return "" end
    return table.concat(parts, "  ") .. " "
end

local function request_lsp_symbols(bufnr, winnr, left_base, right)
    local uri = vim.lsp.util.make_text_document_params(bufnr)["uri"]
    if not uri then return end

    local ok, pos = pcall(vim.api.nvim_win_get_cursor, winnr)
    if not ok then return end
    local cursor_line = pos[1] - 1
    local cursor_char = pos[2]

    vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
        textDocument = { uri = uri },
    }, function(err, symbols)
        if not vim.api.nvim_win_is_valid(winnr) then return end
        if vim.api.nvim_win_get_buf(winnr) ~= bufnr then return end
        if err or not symbols or #symbols == 0 then return end

        local symbol_breadcrumbs = {}
        find_symbol_path(symbols, cursor_line, cursor_char, symbol_breadcrumbs)

        if #symbol_breadcrumbs > 0 then
            local symbol_str = table.concat(
                vim.tbl_map(function(s)
                    return "%#WinBarSymbol#" .. s .. "%*"
                end, symbol_breadcrumbs),
                " %#WinBarSeparator##%* "
            )
            local left = left_base .. " %#WinBarSeparator##%* " .. symbol_str
            vim.api.nvim_set_option_value("winbar", left .. "%=" .. right, { win = winnr })
        end
    end)
end

local ignore_filetypes = {
    "minifiles",
    "oil",
    "help",
    "lazy",
    "mason",
    "trouble",
    "TelescopePrompt",
    "noice",
    "radar",
}

local function winbar_set()
    local bufnr = vim.api.nvim_get_current_buf()
    local winnr = vim.api.nvim_get_current_win()
    local ft = vim.bo[bufnr].filetype
    local bt = vim.bo[bufnr].buftype

    if bt ~= "" or vim.tbl_contains(ignore_filetypes, ft) then
        vim.api.nvim_set_option_value("winbar", "", { win = winnr })
        return
    end

    local file_path = vim.fn.bufname(bufnr)
    if not file_path or file_path == "" then
        vim.api.nvim_set_option_value("winbar", "", { win = winnr })
        return
    end

    local left_base = get_ft_icon(bufnr) .. get_relative_path(bufnr)
    local right = build_right(bufnr)

    -- Render sync state immediately (non-blocking)
    vim.api.nvim_set_option_value("winbar", left_base .. "%=" .. right, { win = winnr })

    -- Kick off async LSP symbol enrichment if window is wide enough
    local win_width = vim.api.nvim_win_get_width(winnr)
    if win_width < 120 then return end

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client.server_capabilities.documentSymbolProvider then
            request_lsp_symbols(bufnr, winnr, left_base, right)
            break
        end
    end
end

local augroup = vim.api.nvim_create_augroup("WinBar", { clear = true })

vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    group = augroup,
    callback = function()
        vim.schedule(winbar_set)
    end,
    desc = "Refresh winbar LSP symbols on cursor move",
})

vim.api.nvim_create_autocmd({ "BufEnter", "DiagnosticChanged" }, {
    group = augroup,
    callback = function()
        vim.schedule(winbar_set)
    end,
    desc = "Refresh winbar on buffer enter or diagnostic change",
})

vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "MiniDiffUpdated",
    callback = function()
        vim.schedule(winbar_set)
    end,
    desc = "Refresh winbar on mini.diff update",
})
