local M = {}

---@type LazyPluginSpec[]
M.specs = {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "master",
        commit = "42fc28ba918343ebfd5565147a42a26580579482",
        lazy = false,
        opts = {
            highlight = {
                enable = true,
                ---@diagnostic disable-next-line: unused-local
                disable = function(lang, bufnr)
                    return vim.api.nvim_buf_line_count(bufnr) > 5000
                end,
                additional_vim_regex_highlighting = false,
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
                "kulala_http",
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
        },
        config = function(_, opts)
            local configs = require("nvim-treesitter.configs")

            -- Register the mdx filetype
            vim.filetype.add({ extension = { mdx = "mdx" } })

            -- Configure treesitter to use the markdown parser for mdx files
            vim.treesitter.language.register("markdown", "mdx")

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
            { mode = { "n", "v" }, "<Up>", "<CMD>Treewalker Up<CR>" },
            { mode = { "n", "v" }, "<Down>", "<CMD>Treewalker Down<CR>" },
            { mode = { "n", "v" }, "<Left>", "<CMD>Treewalker Left<CR>" },
            { mode = { "n", "v" }, "<Right>", "<CMD>Treewalker Right<CR>" },

            -- { mode = { "n", "v" }, "<S-Up>", "<CMD>Treewalker SwapUp<CR>" },
            -- { mode = { "n", "v" }, "<S-Down>", "<CMD>Treewalker SwapDown<CR>" },
            -- { mode = { "n", "v" }, "<S-Left>", "<CMD>Treewalker SwapLeft<CR>" },
            -- { mode = { "n", "v" }, "<S-Right>", "<CMD>Treewalker SwapRight<CR>" },
        },
    },
}

return M.specs
