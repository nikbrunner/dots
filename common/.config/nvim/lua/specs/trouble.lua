---@diagnostic disable: missing-fields
---@type LazyPluginSpec
return {
    "folke/trouble.nvim",
    event = "LspAttach",
    specs = {
        "folke/snacks.nvim",
        opts = function(_, opts)
            return vim.tbl_deep_extend("force", opts or {}, {
                picker = {
                    actions = require("trouble.sources.snacks").actions,
                    win = {
                        input = {
                            keys = {
                                ["<c-q>"] = {
                                    "trouble_open",
                                    mode = { "n", "i" },
                                },
                            },
                        },
                    },
                },
            })
        end,
    },
    ---@type trouble.Config
    opts = {
        focus = true,
        auto_close = true,
        auto_refresh = false,
        indent_guides = false,
        follow = false,

        ---@type trouble.Window.opts
        win = {
            title = "Trouble",
            wo = {
                winbar = "Trouble",
            },
        },

        ---@type table<string, trouble.Mode>
        modes = {
            lsp_document_symbols = {
                ---@type trouble.Window.opts
                win = {
                    type = "split",
                    position = "right",
                    size = { width = 0.33 },
                },
            },

            lsp_defnitions = {
                auto_jump = true, -- auto jump to the item when there's only one
                auto_close = true,
            },

            lsp_references = {
                params = {
                    include_declaration = false,
                },
            },
        },
    },
    keys = {
        { "<leader>dP", "<cmd>Trouble diagnostics toggle  filter.buf=0<cr>", desc = "[P]roblems" },
        { "<leader>wP", "<cmd>Trouble diagnostics toggle<cr>", desc = "[P]roblems" },

        { "sd", "<cmd>Trouble lsp_definitions<cr>", desc = "[R]eferences" },
        { "st", "<cmd>Trouble lsp_type_definitions<cr>", desc = "[R]eferences" },
        { "sr", "<cmd>Trouble lsp_references<cr>", desc = "[R]eferences" },

        { "sci", "<cmd>Trouble lsp_incoming_calls<cr>", desc = "[I]ncoming" },
        { "sco", "<cmd>Trouble lsp_outgoing_calls<cr>", desc = "[O]utgoing" },
        {
            "[q",
            function()
                if require("trouble").is_open() then
                    ---@diagnostic disable-next-line: missing-fields, missing-parameter
                    require("trouble").prev({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cprev)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Previous Trouble/Quickfix Item",
        },
        {
            "]q",
            function()
                if require("trouble").is_open() then
                    ---@diagnostic disable-next-line: missing-fields, missing-parameter
                    require("trouble").next({ skip_groups = true, jump = true })
                else
                    local ok, err = pcall(vim.cmd.cnext)
                    if not ok then
                        vim.notify(err, vim.log.levels.ERROR)
                    end
                end
            end,
            desc = "Next Trouble/Quickfix Item",
        },
    },
}
