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
