---@diagnostic disable: missing-fields
return {
    "A7Lavinraj/fyler.nvim",
    enabled = false,
    ---@type FylerConfig
    opts = {
        hooks = {
            on_rename = function(src_path, dst_path)
                Snacks.rename.rename_file({ from = src_path, to = dst_path })
            end,
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
        },
        close_on_select = true,
        indentscope = {
            enabled = false,
        },
        win = {
            border = "solid",
            win_opts = {
                winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
                wrap = false,
                number = false,
                relativenumber = false,
            },
            kind_presets = {
                float = {
                    height = "0.6rel",
                    width = "0.25rel",
                    top = "0.1rel",
                    left = "0.15rel",
                },
                split_left_most = {
                    width = "0.2rel",
                },
            },
        },
    },
    keys = {
        {
            "-",
            function()
                require("fyler").open({ kind = "float" })
            end,
            desc = "Fyler",
        },
    },
}
