return {
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    enabled = false,
    event = "VeryLazy",
    keys = {
        {
            "-",
            function()
                require("yazi").yazi()
            end,
            desc = "[E]xplorer",
        },
        {
            "_",
            function()
                require("yazi").yazi(nil, vim.fn.getcwd())
            end,
            desc = "[E]xplorer (Root)",
        },
    },

    ---@type YaziConfig
    opts = {
        yazi_floating_window_winblend = 10,
        floating_window_scaling_factor = {
            height = vim.o.lines,
            width = vim.o.columns,
        },
        yazi_floating_window_border = "solid",
    },
}
