return {
    {
        "dmmulroy/tsc.nvim",
        event = "LspAttach",
        cmd = { "Compile" },
        opts = {
            use_trouble_qflist = true,
            flags = {
                skipLibCheck = true,
            },
        },
        keys = {
            -- { "<leader>wP", "<cmd>TSC<CR>", desc = "[P]roblems" },
        },
    },
    {
        "dmmulroy/ts-error-translator.nvim",
        event = "LspAttach",
        opts = {},
    },
}
