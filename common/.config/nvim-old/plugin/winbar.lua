local function setup_highlights()
    local function get_attr(group, attr)
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        local val = hl[attr]
        return val and string.format("#%06x", val) or nil
    end

    local git_bg = get_attr("Normal", "bg")
    local lsp_bg = get_attr("Normal", "bg")
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

    local normal_fg = get_attr("Normal", "fg")
    local normal_bg = get_attr("Normal", "bg")

    vim.api.nvim_set_hl(0, "WinBarFilename", { fg = normal_fg, bg = normal_bg, bold = true })
    vim.api.nvim_set_hl(0, "WinBarPath", { fg = muted, bg = normal_bg })
    vim.api.nvim_set_hl(0, "WinBarSeparator", { fg = muted, bg = normal_bg })
end

local function truncate_path(parts, max_len)
    if #parts == 0 then
        return parts
    end

    -- Always keep filename (last part); try to fit as many leading dirs as possible
    local filename = parts[#parts]
    local ellipsis = "..."

    -- Build from the right: filename, then parent, then grandparent, etc.
    local keep = { filename }
    local current_len = #filename

    for i = #parts - 1, 1, -1 do
        local part = parts[i]
        local added_len = #part + 1 -- +1 for the separator that will precede it
        if current_len + added_len > max_len then
            break
        end
        table.insert(keep, 1, part)
        current_len = current_len + added_len
    end

    -- If we dropped any leading dirs, prepend ellipsis
    if #keep < #parts then
        table.insert(keep, 1, ellipsis)
    end

    return keep
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

    -- Estimate max path length: try 40 chars, or half the window width if smaller
    local max_len = math.min(40, math.floor(vim.api.nvim_win_get_width(0) / 2.5))
    max_len = math.max(max_len, 20) -- absolute floor so it's never unusable

    if #table.concat(parts, "/") > max_len then
        parts = truncate_path(parts, max_len)
    end

    local highlighted_parts = {}
    for i, part in ipairs(parts) do
        if i == #parts then
            table.insert(highlighted_parts, "%#WinBarFilename#" .. part .. "%*")
        else
            table.insert(highlighted_parts, "%#WinBarPath#" .. part .. "%*")
        end
    end
    return table.concat(highlighted_parts, "%#WinBarSeparator#/%*")
end

local function get_ft_icon(bufnr)
    local bufname = vim.fn.bufname(bufnr)
    local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or ""
    if filename == "" then
        return ""
    end
    return ""  -- icon disabled
end

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
            table.insert(sections, "%#WinBarGitLabel# [GIT:" .. table.concat(tokens, "") .. "%#WinBarGitLabel#]%*")
        end
    end

    -- LSP section: use built-in vim.diagnostic.status()
    local lsp_status = vim.diagnostic.status(bufnr)
    if lsp_status ~= "" then
        table.insert(sections, "%#WinBarLspLabel# [LSP: " .. lsp_status .. "%#WinBarLspLabel#]%*")
    end

    if #sections == 0 then
        return ""
    end
    return table.concat(sections, "") .. " "
end

local clear_winbar_filetypes = {
    "minifiles",
    "help",
    "lazy",
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

    -- Clear winbar for non-file buffers and filetypes that shouldn't show the custom winbar
    -- Skip oil: it manages its own winbar via config
    if bt ~= "" or vim.tbl_contains(clear_winbar_filetypes, ft) then
        if ft ~= "oil" and ft ~= "canola" then
            vim.api.nvim_set_option_value("winbar", "", { win = winnr })
        end
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
end

local augroup = vim.api.nvim_create_augroup("WinBar", { clear = true })

setup_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = setup_highlights,
    desc = "Rebuild winbar highlight groups on theme change",
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
