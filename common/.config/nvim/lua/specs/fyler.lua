---@diagnostic disable: missing-fields
return {
    "A7Lavinraj/fyler.nvim",
    dependencies = { "echasnovski/mini.icons" },
    enabled = false,
    ---@type FylerConfig
    opts = {
        hooks = {
            on_rename = function(src_path, dst_path)
                Snacks.rename.rename_file({ from = src_path, to = dst_path })
            end,
        },
        mappings = {
            explorer = {
                ["q"] = "CloseView",
                ["<CR>"] = "Select",
                ["<C-t>"] = "SelectTab",
                ["<C-v>"] = "SelectVSplit",
                ["<C-s>"] = "SelectSplit",
                ["-"] = "GotoParent",
                ["="] = "GotoCwd",
                ["."] = "GotoNode",
            },
            confirm = {
                ["y"] = "Confirm",
                ["n"] = "Discard",
            },
        },
        views = {
            confirm = {
                border = "solid",
                win_opts = {
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
                    wrap = false,
                },
            },
            explorer = {
                close_on_select = true,
                win = {
                    border = "solid",
                    win_opts = {
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
                        wrap = false,
                    },
                    kind_presets = {
                        float = {
                            height = "0.6rel",
                            width = "0.2rel",
                            top = "0.1rel",
                            left = "0.1rel",
                        },
                        split_left_most = {
                            width = "0.2rel",
                        },
                    },
                },
            },
        },
    },
    keys = {
        {
            "-",
            function()
                require("fyler").open()
            end,
            desc = "Fyler",
        },
    },
}
