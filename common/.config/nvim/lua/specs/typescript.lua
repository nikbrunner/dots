return {
    {
        "dmmulroy/tsc.nvim",
        event = "LspAttach",
        cmd = { "TSC" },
        opts = {
            use_trouble_qflist = true,
        },
    },
    {
        "dmmulroy/ts-error-translator.nvim",
        event = "LspAttach",
        opts = {},
    },
}
