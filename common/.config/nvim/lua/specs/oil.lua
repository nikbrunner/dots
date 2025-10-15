---@type LazySpec
return {
    "stevearc/oil.nvim",
    lazy = false,
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
        default_file_explorer = false,
        view_options = {
            show_hidden = true,
            skip_confirm_for_simple_edits = true,
            prompt_save_on_select_new_entry = false,
        },
        watch_for_changes = true,
        lsp_file_methods = {
            -- Enable or disable LSP file operations
            enabled = true,
            -- Time to wait for LSP file operations to complete before skipping
            timeout_ms = 1000,
            -- Set to true to autosave buffers that are updated with LSP willRenameFiles
            -- Set to "unmodified" to only save unmodified buffers
            autosave_changes = true,
        },
        win_options = {
            winbar = "%{v:lua.require('oil').get_current_dir()}",
        },
        float = {
            padding = 5,
            max_width = 50,
            max_height = 0.5,
            border = "solid",
            win_options = {
                winblend = 10,
            },
        },
        confirmation = {
            min_width = { 40, 0.35 },
            max_width = 0.65,
            max_height = 0.5,
            min_height = { 5, 0.1 },
            border = "solid",
            win_options = {
                winblend = 10,
                signcolumn = "yes:2",
            },
        },
        keymaps_help = {
            border = "solid",
        },
        keymaps = {
            ["~"] = false,
            ["<C-l>"] = false,
            ["<C-s>"] = false,

            ["q"] = { "actions.close", mode = "n" },
            ["<C-h>"] = { "actions.show_help", mode = "n" },

            ["<localleader>h"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME"))
                end,
                desc = "[H]ome",
            },
            ["<localleader>c"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/.config"))
                end,
                desc = "[C]onfig",
            },
            ["<localleader>r"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos"))
                end,
                desc = "[R]epos",
            },

            ["<localleader>0"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/nikbrunner/dots"))
                end,
                desc = "Dots",
            },
            ["<localleader>1"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/nikbrunner/notes"))
                end,
                desc = "Notes",
            },
            ["<localleader>2"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/nikbrunner/dcd-notes"))
                end,
                desc = "DCD Notes",
            },

            ["<localleader>4"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/black-atom-industries/core"))
                end,
                desc = "BAI Core",
            },

            ["<localleader>7"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/dealercenter-digital/bc-desktop-client"))
                end,
                desc = "DCD Desktop Client",
            },
            ["<localleader>9"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/dealercenter-digital/bc-web-client-poc"))
                end,
                desc = "DCD Web Client",
            },
            ["<C-v>"] = { "actions.select", opts = { vertical = true, close = true } },
            ["<C-t>"] = { "actions.select", opts = { tab = true, close = true } },
        },
    },
    keys = {
        {
            "-",
            function()
                require("oil").open()
            end,
            desc = "[E]xplorer",
        },
        {
            "_",
            function()
                require("oil").open(vim.fn.getcwd())
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
}
