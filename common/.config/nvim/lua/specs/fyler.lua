---@type LazyPluginSpec
return {
    "A7Lavinraj/fyler.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    branch = "stable",
    lazy = false,
    opts = {
        hooks = {
            on_rename = function(src, dst)
                Snacks.rename.on_rename_file(src, dst)
            end,
        },
        views = {
            finder = {
                close_on_select = true,
                confirm_simple = false,
                default_explorer = true,
                follow_current_file = true,
                columns = {
                    git = { enabled = true },
                },
                mappings = {
                    ["q"] = "CloseView",
                    ["<CR>"] = "Select",
                    ["<C-t>"] = "SelectTab",
                    ["<C-v>"] = "SelectVSplit",
                    ["<C-s>"] = "SelectSplit",
                    ["-"] = "GotoParent",
                    ["="] = "GotoCwd",
                    ["."] = "GotoNode",
                    ["zM"] = "CollapseAll",
                    ["<BS>"] = "CollapseNode",
                },
                win = {
                    kind = "replace",
                    win_opts = {
                        cursorline = true,
                    },
                },
            },
        },
    },
    keys = {
        { "-", "<cmd>Fyler<cr>", desc = "[E]xplorer" },
        {
            "<leader>we",
            function()
                require("fyler").open({ dir = vim.fn.getcwd() })
            end,
            desc = "[E]xplorer (cwd)",
        },
    },
}
