return {
    {
        "esmuellert/codediff.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = "CodeDiff",
        event = "VeryLazy",
        keys = {
            -- Workspace level
            { "<leader>wvD", "<cmd>CodeDiff<cr>", desc = "Workspace [D]iff (CodeDiff)" },
            {
                "<leader>wvB",
                function()
                    vim.ui.input({ prompt = "Compare against branch: " }, function(branch)
                        if branch and branch ~= "" then
                            vim.cmd("CodeDiff " .. branch)
                        end
                    end)
                end,
                desc = "Compare [B]ranch (CodeDiff)",
            },
            { "<leader>wvM", "<cmd>CodeDiff merge<cr>", desc = "[M]erge conflicts (CodeDiff)" },

            -- Document level
            { "<leader>dvD", "<cmd>CodeDiff file HEAD<cr>", desc = "Document [D]iff (CodeDiff)" },
        },
        opts = {},
    },
    {
        "georgeguimaraes/review.nvim",
        dependencies = {
            "esmuellert/codediff.nvim",
            "MunifTanjim/nui.nvim",
        },
        event = "VeryLazy",
        cmd = "Review",
        keys = {
            { "<leader>wvr", "<cmd>Review<cr>", desc = "[R]eview diff (review.nvim)" },
            { "<leader>wvR", "<cmd>Review commits<cr>", desc = "[R]eview commits (review.nvim)" },
        },
        opts = {},
    },
}
