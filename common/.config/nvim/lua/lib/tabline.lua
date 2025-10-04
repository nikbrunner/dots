local M = {}

function M.render()
    local current_tab = vim.fn.tabpagenr()
    local current_win = vim.fn.tabpagewinnr(current_tab)
    local parts = { "%#TabLine# " .. current_tab .. ":" .. vim.fn.tabpagenr("$") .. " %#TabLineFill#   " }

    for i, bufnr in ipairs(vim.fn.tabpagebuflist(current_tab)) do
        local bufname = vim.fn.bufname(bufnr)
        local buftype = vim.fn.getbufvar(bufnr, "&buftype")
        local filetype = vim.fn.getbufvar(bufnr, "&filetype")

        -- Only include normal files, unnamed buffers, or help files
        if buftype == "" or filetype == "help" then
            -- Highlight and separator
            local hl = i == current_win and "%#TabLineSel#" or "%#TabLine#"
            table.insert(parts, " " .. hl .. " ")

            -- Get filename
            local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:.") or "[No Name]"
            if bufname ~= "" and string.match(filename, "^/") then
                filename = vim.fn.fnamemodify(bufname, ":t")
            end

            -- Add modified indicator
            local modified = vim.fn.getbufvar(bufnr, "&modified") == 1 and "●" or ""
            table.insert(parts, filename .. modified .. " ")
        end
    end

    return table.concat(parts) .. "%#TabLineFill#"
end

return M
