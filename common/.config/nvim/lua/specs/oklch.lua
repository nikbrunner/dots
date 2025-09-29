return {
    "eero-lehtinen/oklch-color-picker.nvim",
    event = "VeryLazy",
    version = "*",
    keys = {
        {
            "<leader>ac",
            function()
                require("oklch-color-picker").pick_under_cursor()
            end,
            desc = "Color pick under cursor",
        },
    },
    ---@type oklch.Opts
    opts = {
        highlight = {
            enabled = true,
            ---@type 'background'|'foreground'|'virtual_left'|'virtual_eol'|'foreground+virtual_left'|'foreground+virtual_eol'
            style = "foreground+virtual_left",
            bold = true,
            italic = false,
            virtual_text = "  ",
        },
    },
}
