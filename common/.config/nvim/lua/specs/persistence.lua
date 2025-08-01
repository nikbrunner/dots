---@type LazyPluginSpec
return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = function()
        local ps = require("persistence")

        return {
            { "<leader>ss", ps.select, desc = "Select session" },
            { "<leader>sl", ps.load, desc = "Load session" },
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
