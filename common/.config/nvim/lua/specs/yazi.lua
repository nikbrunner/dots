return {
    "mikavilpas/yazi.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    enabled = true,
    event = "VeryLazy",
    keys = {
        {
            "<leader>we",
            function()
                require("yazi").yazi()
            end,
            desc = "[E]xplorer",
        },
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
        yazi_floating_window_winblend = 0,
        floating_window_scaling_factor = {
            height = 0.8,
            width = 0.8,
        },
        yazi_floating_window_border = "solid",
    },
}
