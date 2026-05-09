local icons = {
    diagnostics = "",
    git = "",
}

---@type LazyPluginSpec
return {
    "b0o/incline.nvim",
    event = "VeryLazy",

    config = function()
        require("incline").setup({
            window = {
                placement = {
                    vertical = "top",
                    horizontal = "right",
                },
                margin = { horizontal = 0, vertical = 0 },
                padding = 0,
            },
            render = function(props)
                local bufname = vim.api.nvim_buf_get_name(props.buf)
                local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"
                local relpath = bufname ~= "" and vim.fn.fnamemodify(bufname, ":.") or ""
                -- Show path relative to git root if inside a repo, otherwise relative to cwd
                local git_root = vim.b[props.buf].minigit_summary and vim.b[props.buf].minigit_summary.root
                if git_root and bufname:find(git_root, 1, true) == 1 then
                    relpath = bufname:sub(#git_root + 2)
                end
                local display = relpath ~= "" and relpath or filename
                local ft_icon, ft_hl = require("mini.icons").get("file", filename, { default = true })

                local function get_git_diff()
                    local summary = vim.b[props.buf].minidiff_summary
                    local labels = {}
                    if summary == nil then
                        return labels
                    end
                    if summary.add > 0 then
                        table.insert(labels, { summary.add .. " ", group = "MiniDiffSignAdd" })
                    end
                    if summary.change > 0 then
                        table.insert(labels, { summary.change .. " ", group = "MiniDiffSignChange" })
                    end
                    if summary.delete > 0 then
                        table.insert(labels, { summary.delete .. " ", group = "MiniDiffSignDelete" })
                    end
                    if #labels > 0 then
                        table.insert(labels, 1, { icons.git .. " " })
                        table.insert(labels, { ": " })
                    end
                    return labels
                end

                local function get_diagnostic_label()
                    local label = {}
                    local severities = { "error", "warn", "info", "hint" }

                    for _, severity in ipairs(severities) do
                        local n =
                            #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
                        if n > 0 then
                            table.insert(label, { n .. " ", group = "DiagnosticSign" .. severity })
                        end
                    end
                    if #label > 0 then
                        table.insert(label, 1, { icons.diagnostics .. " " })
                        table.insert(label, { ": " })
                    end
                    return label
                end

                return {
                    { get_diagnostic_label() },
                    { get_git_diff() },
                    { (ft_icon or "") .. " ", group = ft_hl },
                    { display .. " ", gui = vim.bo[props.buf].modified and "bold,italic" or "bold" },
                }
            end,
        })
    end,
}
