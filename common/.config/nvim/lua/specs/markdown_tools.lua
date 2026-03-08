local date_format = "%Y.%m.%d - %A"

---@type LazyPluginSpec
return {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {
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
