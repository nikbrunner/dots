---@type LazySpec
return {
    "stevearc/oil.nvim",
    enabled = true,
    lazy = false,
    dependencies = {
        { "echasnovski/mini.icons", opts = {} },
    },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
        default_file_explorer = true,
        view_options = {
            show_hidden = true,
            skip_confirm_for_simple_edits = true,
            prompt_save_on_select_new_entry = false,
        },
        keymaps = {
            ["q"] = { "actions.close", mode = "n" },
            ["mh"] = "<cmd>edit $HOME<CR>",
            ["mr"] = "<cmd>edit $HOME/repos/<CR>",
            ["md"] = "<cmd>edit $HOME/repos/nikbrunner/dots<CR>",
            ["mn"] = "<cmd>edit $HOME/repos/nikbrunner/notes<CR>",
            ["<C-h>"] = false,
            ["<C-l>"] = false,
            ["<C-s>"] = false,
            ["<C-v>"] = { "actions.select", opts = { vertical = true } },
            ["<C-t>"] = { "actions.select", opts = { tab = true } },
        },
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
            number = false,
            relativenumber = false,
            winbar = "%{v:lua.require('oil').get_current_dir()}",
        },
        float = {
            padding = 5,
            max_width = 0.35,
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
            "<leader>we",
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
}
