return {
    {
        "esmuellert/codediff.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = "CodeDiff",
        event = "VeryLazy",
        keys = {
            -- Workspace level
            { "<leader>wgd", "<cmd>CodeDiff<cr>", desc = "Workspace [D]iff to `master` (CodeDiff)" },
            { "<leader>wgD", "<cmd>CodeDiff master<cr>", desc = "Workspace [D]iff (CodeDiff)" },

            -- Document level
            { "<leader>dgd", "<cmd>CodeDiff file HEAD<cr>", desc = "Document [D]iff (CodeDiff)" },
            { "<leader>dgD", "<cmd>CodeDiff file master<cr>", desc = "Document [D]iff (CodeDiff)" },

            {
                "<leader>wgb",
                function()
                    vim.ui.input({ prompt = "Compare against branch: " }, function(branch)
                        if branch and branch ~= "" then
                            vim.cmd("CodeDiff " .. branch)
                        end
                    end)
                end,
                desc = "Compare [B]ranch (CodeDiff)",
            },

            { "<leader>wgpm", "<cmd>CodeDiff merge<cr>", desc = "[M]erge conflicts (CodeDiff)" },
        },
        opts = {
            char_brightness = 1, -- disable auto-adjustment
            explorer = {
                view_mode = "tree",
            },
        },
    },
    {
        "nikbrunner/review.nvim",
        enabled = false,
        dir = require("lib.config").get_repo_path("nikbrunner/review.nvim"),
        dependencies = {
            "esmuellert/codediff.nvim",
            "MunifTanjim/nui.nvim",
        },
        event = "VeryLazy",
        cmd = "Review",
        keys = {
            { "<leader>wgpr", "<cmd>Review<cr>", desc = "[R]eview diff (review.nvim)" },
        },
        opts = {},
    },
}
