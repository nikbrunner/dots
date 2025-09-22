local M = {}

---@type LazyPluginSpec[]
M.specs = {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "master",
        lazy = false,
        opts = {
            highlight = {
                enable = true,
                ---@diagnostic disable-next-line: unused-local
                disable = function(lang, bufnr)
                    return vim.api.nvim_buf_line_count(bufnr) > 5000
                end,
                additional_vim_regex_highlighting = {},
            },
            indent = {
                enable = true,
                disable = { "typescript", "tsx", "javascript", "jsx" },
            },
            auto_install = true,
            ensure_installed = {
                "bash",
                "c",
                "css",
                "go",
                "html",
                "javascript",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "rust",
                "toml",
                "astro",
                "typescript",
                "vim",
                "vimdoc",
                "yaml",
                "http",
            },
            incremental_selection = {
                enable = true,
                disable = { "vim", "qf" },
                keymaps = {
                    init_selection = "vv",
                    node_incremental = "v",
                    node_decremental = "<BS>",
                },
            },
            textobjects = {
                move = {
                    enable = true,
                    set_jumps = true, -- whether to set jumps in the jumplist
                    goto_next_start = {
                        ["]f"] = { query = "@call.outer", desc = "Next function call start" },
                        ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
                        ["]c"] = { query = "@class.outer", desc = "Next class start" },
                        ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
                        ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

                        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                    },
                    goto_next_end = {
                        ["]F"] = { query = "@call.outer", desc = "Next function call end" },
                        ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
                        ["]C"] = { query = "@class.outer", desc = "Next class end" },
                        ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
                        ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
                    },
                    goto_previous_start = {
                        ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
                        ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
                        ["[c"] = { query = "@class.outer", desc = "Prev class start" },
                        ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
                        ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
                    },
                    goto_previous_end = {
                        ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
                        ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
                        ["[C"] = { query = "@class.outer", desc = "Prev class end" },
                        ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
                        ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
                    },
                },
            },
        },
        config = function(_, opts)
            local configs = require("nvim-treesitter.configs")

            configs.setup(opts)
        end,
    },

    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        opts = {},
    },

    {
        "folke/ts-comments.nvim",
        opts = {},
        event = "VeryLazy",
    },

    {
        "aaronik/treewalker.nvim",
        event = "VeryLazy",

        -- The following options are the defaults.
        -- Treewalker aims for sane defaults, so these are each individually optional,
        -- and setup() does not need to be called, so the whole opts block is optional as well.
        opts = {
            -- Whether to briefly highlight the node after jumping to it
            highlight = true,

            -- How long should above highlight last (in ms)
            highlight_duration = 250,

            -- The color of the above highlight. Must be a valid vim highlight group.
            -- (see :h highlight-group for options)
            highlight_group = "CursorLine",

            -- Whether the plugin adds movements to the jumplist -- true | false | 'left'
            --  true: All movements more than 1 line are added to the jumplist. This is the default,
            --        and is meant to cover most use cases. It's modeled on how { and } natively add
            --        to the jumplist.
            --  false: Treewalker does not add to the jumplist at all
            --  "left": Treewalker only adds :Treewalker Left to the jumplist. This is usually the most
            --          likely one to be confusing, so it has its own mode.
            jumplist = true,
        },
        keys = {
            -- { "<C-k>", "<CMD>Treewalker Up<CR>" },
            -- { "<C-j>", "<CMD>Treewalker Down<CR>" },
            -- { "<C-h>", "<CMD>Treewalker Left<CR>" },
            -- { "<C-l>", "<CMD>Treewalker Right<CR>" },
            { "<Up>", "<CMD>Treewalker Up<CR>" },
            { "<Down>", "<CMD>Treewalker Down<CR>" },
            { "<Left>", "<CMD>Treewalker Left<CR>" },
            { "<Right>", "<CMD>Treewalker Right<CR>" },
            -- { "<C-S-k>", "<CMD>Treewalker SwapUp<CR>" },
            -- { "<C-S-j>", "<CMD>Treewalker SwapDown<CR>" },
            -- { "<C-S-h>", "<CMD>Treewalker SwapLeft<CR>" },
            -- { "<C-S-l>", "<CMD>Treewalker SwapRight<CR>" },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        ---@type TSContext.Config
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            line_numbers = true,
            enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
            max_lines = 2, -- How many lines the window should span. Values <= 0 mean no limit.
            multiline_threshold = 20, -- Maximum number of lines to show for a single context
            trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
            zindex = 20, -- The Z-index of the context window
            mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
            on_attach = function(bufnr)
                local disabled_filetypes = { "markdown", "vim" }
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                local should_not_attach = vim.list_contains(disabled_filetypes, vim.bo[bufnr].filetype) or line_count > 5000
                return not should_not_attach
            end,
            patterns = {
                default = {
                    "class",
                    "function",
                    "method",
                    "for", -- These won't appear in the context
                    "while",
                    "if",
                    "switch",
                    "case",
                    "const",
                },
            },
        },
        config = function(_, opts)
            local context = require("treesitter-context")
            context.setup(opts)
        end,
    },
}

return M.specs
