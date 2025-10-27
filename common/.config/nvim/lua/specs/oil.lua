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
            ["<C-h>"] = false,

            ["q"] = { "actions.close", mode = "n" },

            ["<C-v>"] = { "actions.select", opts = { vertical = true, close = true } },
            ["<C-t>"] = { "actions.select", opts = { tab = true, close = true } },
            ["<C-s>"] = { "actions.select", opts = { horizontal = true, close = true } },

            ["<leader><leader>"] = {
                function()
                    require("snacks.picker").files({
                        cwd = require("oil").get_current_dir(),
                    })
                end,
                mode = "n",
                nowait = true,
                desc = "Find files in the current directory",
            },

            ["<localleader><localleader>"] = {
                function()
                    require("oil.actions").cd.callback()
                end,
                desc = "CD to current directory",
            },
            ["<localleader>h"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME"))
                end,
                desc = "Home",
            },
            ["<localleader>c"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/.config"))
                end,
                desc = "Config",
            },
            ["<localleader>r"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos"))
                end,
                desc = "Repos",
            },
            ["<localleader>l"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/.local/share/nvim/lazy"))
                end,
                desc = "Lazy Packages",
            },
            ["<localleader>0"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/nikbrunner/dots"))
                end,
                desc = "nbr - dots",
            },
            ["<localleader>1"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/nikbrunner/notes"))
                end,
                desc = "nbr - notes",
            },
            ["<localleader>2"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/nikbrunner/dcd-notes"))
                end,
                desc = "DCD - Notes",
            },

            ["<localleader>4"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/black-atom-industries/core"))
                end,
                desc = "Black Atom - core",
            },

            ["<localleader>5"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/black-atom-industries/nvim"))
                end,
                desc = "Black Atom - nvim",
            },

            ["<localleader>6"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/black-atom-industries/radar.nvim"))
                end,
                desc = "Black Atom - radar.nvim",
            },

            ["<localleader>7"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/dealercenter-digital/bc-desktop-client"))
                end,
                desc = "DCD - BC Desktop Client",
            },
            ["<localleader>8"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/dealercenter-digital/bc-desktop-tools"))
                end,
                desc = "DCD - BC Desktop Tools",
            },
            ["<localleader>9"] = {
                function()
                    require("oil").open(vim.fn.expand("$HOME/repos/dealercenter-digital/bc-web-client-poc"))
                end,
                desc = "DCD - BC Web Client",
            },

            -- Yank file paths
            ["yn"] = {
                function()
                    local entry = require("oil").get_cursor_entry()
                    if entry then
                        local name = entry.name
                        vim.fn.setreg("+", name)
                        vim.notify("Copied filename: " .. name, vim.log.levels.INFO)
                    end
                end,
                desc = "Yank filename",
            },
            ["yr"] = {
                function()
                    local oil = require("oil")
                    local entry = oil.get_cursor_entry()
                    if entry then
                        local dir = oil.get_current_dir()
                        local full_path = dir .. entry.name
                        local relative_path = vim.fn.fnamemodify(full_path, ":~:.")
                        vim.fn.setreg("+", relative_path)
                        vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
                    end
                end,
                desc = "Yank relative path",
            },
            ["yh"] = {
                function()
                    local oil = require("oil")
                    local entry = oil.get_cursor_entry()
                    if entry then
                        local dir = oil.get_current_dir()
                        local full_path = dir .. entry.name
                        local path_from_home = vim.fn.fnamemodify(full_path, ":~")
                        vim.fn.setreg("+", path_from_home)
                        vim.notify("Copied path from home: " .. path_from_home, vim.log.levels.INFO)
                    end
                end,
                desc = "Yank path from home",
            },
            ["ya"] = {
                function()
                    local oil = require("oil")
                    local entry = oil.get_cursor_entry()
                    if entry then
                        local dir = oil.get_current_dir()
                        local full_path = dir .. entry.name
                        vim.fn.setreg("+", full_path)
                        vim.notify("Copied absolute path: " .. full_path, vim.log.levels.INFO)
                    end
                end,
                desc = "Yank absolute path",
            },
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
