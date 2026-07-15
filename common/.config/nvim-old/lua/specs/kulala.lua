---@type LazyPluginSpec
return {
    "mistweaverco/kulala.nvim",
    ft = "http",
    ---@doc: [Setup Options | Kulala.nvim](https://kulala.mwco.app/docs/getting-started/setup-options/)
    opts = {
        default_env = "local",
        kulala_keymaps_prefix = ".",
    },
    keys = {
        { "[h", function() require("kulala").jump_prev() end, desc = "Previous request" },
        { "]h", function() require("kulala").jump_next() end, desc = "Next request" },
        { "<leader>he", function() require("kulala").set_selected_env() end, desc = "Select env" },
        { "<leader>hr", function() require("kulala").run() end, desc = "Run request" },
        { "<leader>hs", function() require("kulala").search() end, desc = "Search" },
        { "<leader>hc", function() require("kulala").copy() end, desc = "Copy request" },
    },
}
