return {
    "jim-at-jibba/nvim-stride",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter", -- optional, smart context
        "folke/snacks.nvim", -- optional, animated notifications
    },
    event = "InsertEnter",
    opts = {
        mode = "refactor", -- "completion", "refactor", or "both"
    },
}
