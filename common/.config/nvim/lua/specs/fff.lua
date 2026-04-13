---@type LazyPluginSpec
return {
    "dmtrKovalenko/fff.nvim",
    build = function()
        require("fff.download").download_or_build_binary()
    end,
    lazy = false, -- make fff initialize on startup

    -- fff-snacks.nvim must come after fff.nvim
    dependencies = {
        {
            "nikbrunner/fff-snacks.nvim",
            dir = require("lib.config").get_repo_path("nikbrunner/fff-snacks.nvim"),
            lazy = false, -- loaded by plugin/fff-snacks.lua on UIEnter
            keys = {
                {
                    "<leader><leader>",
                    function()
                        require("fff-snacks").find_files()
                    end,
                    desc = "Pick files",
                },
                {
                    "<leader>wd",
                    function()
                        require("fff-snacks").find_files()
                    end,
                    desc = "Pick files",
                },
                {
                    "<leader>wt",
                    function()
                        require("fff-snacks").live_grep()
                    end,
                    desc = "[T]ext",
                },
                {
                    "<leader>wT",
                    function()
                        require("fff-snacks").live_grep({
                            grep_mode = { "fuzzy", "plain", "regex" },
                        })
                    end,
                    desc = "[T]ext (fuzzy)",
                },
                {
                    mode = "v",
                    "<leader>ww",
                    function()
                        require("fff-snacks").grep_word()
                    end,
                    desc = "[W]ord",
                },
            },
            ---@type fff-snacks.Config
            opts = {},
        },
    },
}
