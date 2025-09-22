---@type LazyPluginSpec
return {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
        -- The panel is useless.
        panel = { enabled = false },
        suggestion = {
            auto_trigger = true,
            hide_during_completion = false,
            keymap = {
                accept = "<Tab>",
                accept_word = "<S-Tab>",
                -- accept_line = "<M-l>",
                next = "<M-]>",
                prev = "<M-[>",
                dismiss = "<C-e>",
            },
        },
        filetypes = {
            markdown = true,
            yaml = true,
        },
    },
}
