---@type LazyPluginSpec
return {
    "nikbrunner/mdn.nvim",
    -- dir = require("lib.config").get_repo_path("nikbrunner/mdn.nvim"),
    ft = { "markdown" },
    ---@type Mdn.Config
    opts = {
        auto_continue = true,
    },
}
