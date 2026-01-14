return {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
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
}
