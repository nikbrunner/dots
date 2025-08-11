---@type LazyPluginSpec
return {
    "OliverChao/bufmsg.nvim",
    lazy = false,
    keys = {
        {
            "<leader>am",
            "<CMD>Bufmsgss<CR>",
            desc = "[M]essages",
        },
    },
    opts = {},
}
