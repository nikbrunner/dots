return {
    "folke/sidekick.nvim",
    ---@type sidekick.Config
    opts = {
        cli = {
            mux = {
                backend = "tmux",
                enabled = true,
            },
        },
        nes = {
            enabled = true,
        },
    },
    keys = {
        {
            "<tab>",
            function()
                -- if there is a next edit, jump to it, otherwise apply it if any
                if not require("sidekick").nes_jump_or_apply() then
                    return "<Tab>" -- fallback to normal tab
                end
            end,
            expr = true,
            desc = "Goto/Apply Next Edit Suggestion",
        },
        {
            "<c-.>",
            function()
                require("sidekick.cli").focus()
            end,
            mode = { "n", "x", "i", "t" },
            desc = "Sidekick Switch Focus",
        },
        {
            "<leader>ait",
            function()
                require("sidekick.cli").toggle({ focus = true })
            end,
            desc = "Sidekick Toggle CLI",
            mode = { "n", "v" },
        },
        {
            "<leader>aic",
            function()
                require("sidekick.cli").toggle({ name = "claude", focus = true })
            end,
            desc = "Sidekick Claude Toggle",
            mode = { "n", "v" },
        },
        {
            "<leader>aip",
            function()
                require("sidekick.cli").select_prompt()
            end,
            desc = "Sidekick Ask Prompt",
            mode = { "n", "v" },
        },
    },
}
