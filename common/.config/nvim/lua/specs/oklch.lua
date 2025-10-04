---https://github.com/eero-lehtinen/oklch-color-picker/blob/bd1cc2b2ab1e9416861af6d7329e5399aeba5cc1/src/app.rs#L871
-- let keys = [
--     ("q", "Quit"),
--     ("c", "Copy to clipboard"),
--     ("d", "Done (print result to console)"),
--     ("←/↓/↑/→", "Move focus or control input"),
--     ("h/j/k/l", "Move focus or control input (Vim style)"),
--     ("1/2", "Switch focus to pickers"),
--     ("3/4/5/6", "Switch focus to sliders"),
--     ("Tab/S-Tab", "Cycle focus"),
--     ("Esc/Enter", "Back/Submit"),
-- ];

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
            -- style = "foreground+virtual_left",
            style = "background",
            bold = true,
            italic = false,
            virtual_text = "  ",
        },
    },
}
