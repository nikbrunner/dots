-- NOTE: Image Preview does not work: https://yazi-rs.github.io/docs/image-preview/#neovim

---@type LazySpec
return {
    {
        "stevearc/oil.nvim",
        enabled = false,
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            view_options = {
                show_hidden = true,
                skip_confirm_for_simple_edits = true,
                prompt_save_on_select_new_entry = false,
            },
            keymaps = {
                ["<C-v>"] = { "actions.select", opts = { vertical = true } },
                ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
                ["<C-t>"] = { "actions.select", opts = { tab = true } },
                ["<C-p>"] = "actions.preview",
            },
        },
        -- Optional dependencies
        dependencies = { { "echasnovski/mini.icons", opts = {} } },
        -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        -- lazy = false,
        keys = {
            {
                "-",
                function()
                    require("oil").open()
                end,
                desc = "[E]xplorer",
            },
        },
        config = function(_, opts)
            require("oil").setup(opts)

            vim.api.nvim_create_autocmd("User", {
                pattern = "OilActionsPost",
                callback = function(event)
                    if event.data.actions.type == "move" then
                        Snacks.rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
                    end
                end,
            })
        end,
    },

    {
        "mikavilpas/yazi.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        enabled = false,
        event = "VeryLazy",
        keys = {
            {
                "<leader>f",
                function()
                    require("yazi").yazi()
                end,
                desc = "[E]xplorer",
            },
            {
                "<leader>F",
                function()
                    require("yazi").yazi(nil, vim.fn.getcwd())
                end,
                desc = "[E]xplorer (Root)",
            },
        },

        ---@type YaziConfig
        opts = {
            yazi_floating_window_winblend = 10,
            floating_window_scaling_factor = {
                height = 0.8,
                width = 0.9,
            },
            yazi_floating_window_border = "solid",
        },
    },

    {
        "A7Lavinraj/fyler.nvim",
        dependencies = {},
        enabled = true,
        event = "VeryLazy",
        branch = "main",
        keys = {
            { "<M-[>", "<cmd>Fyler kind=split_left_most<CR>", desc = "Fyler" },
            { "<leader>we", "<cmd>Fyler<CR>", desc = "Fyler" },
        },
        opts = {
            hooks = {
                on_rename = function(src_path, dst_path)
                    Snacks.rename.on_rename_file(src_path, dst_path)
                end,
            },
            -- Changes icon provider
            icon_provider = "mini-icons",
            -- Changes mappings for associated view
            mappings = {
                explorer = {
                    ["q"] = "CloseView",
                    ["<CR>"] = "Select",
                    ["<C-t>"] = "SelectTab",
                    ["<C-v>"] = "SelectVSplit",
                    ["<C-s>"] = "SelectSplit",
                    ["-"] = "GotoParent",
                    ["~"] = "GotoCwd",
                    ["."] = "GotoNode",
                },
            },
            views = {
                confirm = {
                    win = {
                        border = "solid",
                        -- Changes window kind
                        kind = "float",
                        -- Changes window kind preset
                        kind_presets = {
                            float = {
                                -- height = "0.15rel",
                                -- width = "0.35rel",
                                -- top = "0.75rel",
                                -- left = "0.25rel",

                                height = "0.15rel",
                                width = "0.35rel",
                                top = "0.25rel",
                                left = "0.5rel",
                            },
                        },
                        -- Changes window options
                        win_opts = {
                            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
                        },
                    },
                },
                explorer = {
                    -- Changes explorer closing behaviour when a file get selected
                    close_on_select = true,
                    -- Changes explorer behaviour to auto confirm simple edits
                    confirm_simple = false,
                    -- Changes explorer behaviour to hijack NETRW
                    default_explorer = true,
                    -- Changes git statuses visibility
                    git_status = true,
                    -- Changes Indentation marker properties
                    indentscope = {
                        enabled = false,
                    },
                    win = {
                        -- Changes window border
                        border = "solid",
                        -- Changes window kind preset
                        kind_presets = {
                            float = {
                                height = "0.65rel",
                                -- width = "0.35rel",
                                width = "0.2rel",
                                -- top = "0.15rel",
                                -- left = "0.15rel",
                                -- top = "0rel",
                                left = "0.15rel",
                            },
                            split_left_most = {
                                width = "0.2rel",
                            },
                        },
                        -- Changes window options
                        win_opts = {
                            number = false,
                            relativenumber = false,
                            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,FloatTitle:FloatTitle",
                        },
                    },
                },
            },
        },
    },
}
