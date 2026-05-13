local function setup_highlights()
    local function get_attr(group, attr)
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        local val = hl[attr]
        return val and string.format("#%06x", val) or nil
    end

    local git_bg = get_attr("DiffChange", "bg")
    local lsp_bg = get_attr("DiagnosticVirtualTextHint", "bg")
    local muted = get_attr("Comment", "fg")

    vim.api.nvim_set_hl(0, "WinBarGitLabel", { fg = muted, bg = git_bg })
    vim.api.nvim_set_hl(0, "WinBarGitAdd", { fg = get_attr("MiniDiffSignAdd", "fg"), bg = git_bg })
    vim.api.nvim_set_hl(0, "WinBarGitChange", { fg = get_attr("MiniDiffSignChange", "fg"), bg = git_bg })
    vim.api.nvim_set_hl(0, "WinBarGitDelete", { fg = get_attr("MiniDiffSignDelete", "fg"), bg = git_bg })

    vim.api.nvim_set_hl(0, "WinBarLspLabel", { fg = muted, bg = lsp_bg })
    vim.api.nvim_set_hl(0, "WinBarLspError", { fg = get_attr("DiagnosticSignError", "fg"), bg = lsp_bg })
    vim.api.nvim_set_hl(0, "WinBarLspWarn", { fg = get_attr("DiagnosticSignWarn", "fg"), bg = lsp_bg })
    vim.api.nvim_set_hl(0, "WinBarLspInfo", { fg = get_attr("DiagnosticSignInfo", "fg"), bg = lsp_bg })
    vim.api.nvim_set_hl(0, "WinBarLspHint", { fg = get_attr("DiagnosticSignHint", "fg"), bg = lsp_bg })
end

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
    if filename == "" then
        return ""
    end
    local ok, icon, hl = pcall(require("mini.icons").get, "file", filename)
    if ok and icon then
        return "%#" .. hl .. "#" .. icon .. "%*  "
    end
    return ""
end

-- { severity, DiagnosticSign group, icon, WinBarLsp group }
local diagnostic_signs = {
    { "ERROR", "DiagnosticSignError", "", "WinBarLspError" },
    { "WARN", "DiagnosticSignWarn", "", "WinBarLspWarn" },
    { "INFO", "DiagnosticSignInfo", "", "WinBarLspInfo" },
    { "HINT", "DiagnosticSignHint", "", "WinBarLspHint" },
}

local function build_right(bufnr)
    local sections = {}

    -- GIT section: label + counts share git_bg
    local summary = vim.b[bufnr].minidiff_summary
    if summary then
        local tokens = {}
        if (summary.add or 0) > 0 then
            table.insert(tokens, "%#WinBarGitAdd# +" .. summary.add)
        end
        if (summary.change or 0) > 0 then
            table.insert(tokens, "%#WinBarGitChange# ~" .. summary.change)
        end
        if (summary.delete or 0) > 0 then
            table.insert(tokens, "%#WinBarGitDelete# -" .. summary.delete)
        end
        if #tokens > 0 then
            table.insert(sections, "%#WinBarGitLabel# [GIT]" .. table.concat(tokens, "") .. "%#WinBarGitLabel# %*")
        end
    end

    -- LSP section: label + counts share lsp_bg
    local diag_tokens = {}
    for _, sv in ipairs(diagnostic_signs) do
        local n = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity[sv[1]] })
        if n > 0 then
            table.insert(diag_tokens, "%#" .. sv[4] .. "# " .. sv[3] .. " " .. n)
        end
    end
    if #diag_tokens > 0 then
        table.insert(sections, "%#WinBarLspLabel# [LSP]" .. table.concat(diag_tokens, "") .. "%#WinBarLspLabel# %*")
    end

    if #sections == 0 then
        return ""
    end
    return table.concat(sections, "  ") .. " "
end

local function request_lsp_symbols(bufnr, winnr, left_base, right)
    local uri = vim.lsp.util.make_text_document_params(bufnr)["uri"]
    if not uri then
        return
    end

    local ok, pos = pcall(vim.api.nvim_win_get_cursor, winnr)
    if not ok then
        return
    end
    local cursor_line = pos[1] - 1
    local cursor_char = pos[2]

    vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", {
        textDocument = { uri = uri },
    }, function(err, symbols)
        if not vim.api.nvim_win_is_valid(winnr) then
            return
        end
        if vim.api.nvim_win_get_buf(winnr) ~= bufnr then
            return
        end
        if err or not symbols or #symbols == 0 then
            return
        end

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

    vim.api.nvim_set_option_value("winbar", left_base .. "%=" .. right, { win = winnr })

    local win_width = vim.api.nvim_win_get_width(winnr)
    if win_width < 120 then
        return
    end

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if client.server_capabilities.documentSymbolProvider then
            request_lsp_symbols(bufnr, winnr, left_base, right)
            break
        end
    end
end

local augroup = vim.api.nvim_create_augroup("WinBar", { clear = true })

setup_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = setup_highlights,
    desc = "Rebuild winbar highlight groups on theme change",
})

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
