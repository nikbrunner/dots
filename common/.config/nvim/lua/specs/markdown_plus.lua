local date_format = "%Y.%m.%d - %A"

---@type LazyPluginSpec
return {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    enabled = false,
    opts = {
        keymaps = {

            -- List operations (Insert mode)
            -- auto_continue = "<CR>", -- Auto-continue lists or split content
            -- continue_content = "<A-CR>", -- Continue content on next line
            -- indent_list = "<C-t>", -- Indent list item
            -- dedent_list = "<C-d>", -- Dedent list item
            -- smart_backspace = "<BS>", -- Smart backspace

            -- List operations (Insert mode - checkbox)
            -- toggle_checkbox_insert = "<C-CR>", -- Toggle checkbox in insert mode
        },
        list = {
            smart_outdent = true,
            checkbox_completion = {
                enabled = false,
                format = "emoji", -- "emoji" | "comment" | "dataview" | "parenthetical"
                date_format = date_format,
                remove_on_uncheck = true,
                update_existing = true,
            },
        },
    },
}
