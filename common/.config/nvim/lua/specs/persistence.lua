---@type LazyPluginSpec
return {
    "folke/persistence.nvim",
    lazy = false,
    opts = {},
    keys = function()
        local ps = require("persistence")

        return {
            {
                "<leader>ss",
                function()
                    ps.save()
                    ps.select()
                end,
                desc = "Select session",
            },
            {
                "<leader>sl",
                function()
                    ps.load()
                end,
                desc = "Load session",
            },
            {
                "<leader>sr",
                function()
                    ps.load({ last = true })
                end,
                desc = "Restore session",
            },
        }
    end,
}
