---@type LazyPluginSpec
return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "helix",
        delay = 0, -- Show popup immediately (matching mini.clue behavior)
        win = {
            -- width = { min = 20, max = 0.25 }, -- 25% of columns (matching mini.clue)
            border = "solid",
        },
        -- Manual triggers for builtin keys (which-key won't auto-trigger on existing keymaps)
        triggers = {
            { "<auto>", mode = "nxso" }, -- Auto triggers for non-builtin keys
            { "s", mode = { "n", "v" } }, -- Substitute (builtin)
            { "S", mode = { "n", "v" } }, -- Substitute line (builtin)
            { "g", mode = { "n", "v" } }, -- Various motions (builtin)
            { "z", mode = { "n", "v" } }, -- Folds, spelling (builtin)
            { "y", mode = { "n", "v" } }, -- Yank (builtin)
            { "m", mode = { "n", "v" } }, -- Marks (builtin)
            { "[", mode = { "n", "v" } }, -- Previous (builtin)
            { "]", mode = { "n", "v" } }, -- Next (builtin)
            { "'", mode = { "n", "v" } }, -- Jump to mark (builtin)
            { "`", mode = { "n", "v" } }, -- Jump to mark exact (builtin)
            { '"', mode = { "n", "v" } }, -- Registers (builtin)
        },
    },
    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        -- Register group descriptions (matching mini.clue's manual clues)
        wk.add({
            -- App groups
            { "<leader>a", group = "[A]pp", icon = "󰀻" },
            { "<leader>al", group = "[L]anguages", icon = "󰗊" },
            { "<leader>ah", group = "[H]elp", icon = "󰋖" },
            { "<leader>ap", group = "[P]lugins", icon = "󰏖" },
            { "<leader>as", group = "[S]ettings", icon = "" },
            { "<leader>ag", group = "[G]it", icon = "" },
            { "<leader>ao", group = "[O]ptions", icon = "" },

            -- Workspace groups
            { "<leader>w", group = "[W]orkspace", icon = "󰉋" },
            { "<leader>wg", group = "[G]it", icon = "󰊢" },

            -- Document groups
            { "<leader>d", group = "[D]ocument", icon = "󰈙" },
            { "<leader>dy", group = "[Y]ank", icon = "󰆏" },
            { "<leader>dg", group = "[G]it", icon = "󰊢" },

            -- Operator-pending groups (for s prefix)
            { "sl", group = "[L]og", icon = "󰦪" },
            { "sc", group = "[C]alls", icon = "󰜎" },

            -- Other leader groups
            { "<leader>c", group = "[C]hange", icon = "󰛿" },
            { "<leader>s", group = "[S]ession", icon = "󰐹" },
            { "<leader>h", group = "[H]ttp", icon = "󰖟" },
            { "<leader>n", group = "[N]otes", icon = "󰠮" },
            { "<leader>x", group = "Trouble/Quickfix", icon = "󱖫" },

            -- Individual keymaps (to add icons)
            { "<leader>r", icon = "󰜉" }, -- Restart
            { "<leader>z", icon = "󰬡" }, -- Zed editor
        })
    end,
}
