---Open canola at git root, filtered to show only changed and untracked files.
---Uses the canola-git status cache (CanolaReadPost) to decide what to show:
---clean tracked files are hidden. Restores when the canola buffer is unloaded.
---@param opts? {float?: boolean}
local function canola_git_changes(opts)
    opts = opts or {}
    local git_root = Snacks.git.get_root()
    if not git_root then
        Snacks.notify("Not in a git repository", { level = "warn", title = "Canola Git" })
        return
    end

    local config = require("canola.config")
    local canola = require("canola")

    local orig_enabled = config.hidden.enabled
    local orig_is_hidden = config._is_hidden_file
    local did_restore = false

    local function restore()
        if did_restore then
            return
        end
        did_restore = true
        config.hidden.enabled = orig_enabled
        config._is_hidden_file = orig_is_hidden
    end

    config.hidden.enabled = true

    canola.set_is_hidden_file(function(name, bufnr)
        if name == ".." then
            return false
        end
        local dir = canola.get_current_dir(bufnr)
        if not dir then
            return false
        end
        local ok, canola_git = pcall(require, "canola-git")
        if not ok then
            return false
        end
        local cache = canola_git._cache[dir]
        if not cache or cache == false then
            return false
        end
        if cache.status[name] then
            return false
        end
        if not cache.tracked[name] then
            return false
        end
        return true
    end)

    local open_fn = opts.float and canola.open_float or canola.open
    open_fn(git_root)

    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype == "canola" then
        local group = vim.api.nvim_create_augroup("_canola_git_changes", { clear = true })
        for _, event in ipairs({ "BufUnload", "BufDelete", "BufWipeout" }) do
            vim.api.nvim_create_autocmd(event, {
                group = group,
                buffer = bufnr,
                once = true,
                callback = restore,
            })
        end
    end
end

return {
    {
        "barrettruth/canola.nvim",
        branch = "canola",
        lazy = false,
        ---@module "canola"
        init = function()
            vim.g.canola = {
                columns = { "git_status", "icon" },
                watch = true,
                hidden = { enabled = false }, -- show hidden files (inverted from oil's show_hidden = true)
                confirm = false, -- skip_confirm_for_simple_edits = true
                save = false, -- prompt_save_on_select_new_entry = false
                lsp = {
                    enabled = true,
                    timeout_ms = 1000,
                    autosave = true,
                },
                win = {
                    winbar = "%{v:lua.require('canola').get_current_dir()}",
                },
                float = {
                    padding = 5,
                    max_width = 50,
                    max_height = 0.5,
                    border = "solid",
                    win = { winblend = 10 },
                },
                confirmation = {
                    min_width = { 40, 0.35 },
                    max_width = 0.65,
                    max_height = 0.5,
                    min_height = { 5, 0.1 },
                    border = "solid",
                    win = { winblend = 10, signcolumn = "yes:2" },
                },
                keymaps = {
                    ["~"] = false,
                    ["<C-l>"] = false,
                    ["<C-h>"] = false,

                    ["q"] = { callback = "actions.close", mode = "n" },

                    ["<localleader><localleader>"] = {
                        callback = function()
                            require("canola.actions").cd.callback()
                        end,
                        desc = "CD to current directory",
                    },
                    ["<localleader>h"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME"))
                        end,
                        desc = "Home",
                    },
                    ["<localleader>c"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/.config"))
                        end,
                        desc = "Config",
                    },
                    ["<localleader>r"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos"))
                        end,
                        desc = "Repos",
                    },
                    ["<localleader>l"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/.local/share/nvim/lazy"))
                        end,
                        desc = "Lazy Packages",
                    },
                    ["<localleader>0"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/nikbrunner/dots"))
                        end,
                        desc = "nbr - dots",
                    },
                    ["<localleader>1"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/nikbrunner/notes"))
                        end,
                        desc = "nbr - notes",
                    },
                    ["<localleader>2"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/nikbrunner/dcd-notes"))
                        end,
                        desc = "DCD - Notes",
                    },
                    ["<localleader>4"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/black-atom-industries/core"))
                        end,
                        desc = "Black Atom - core",
                    },
                    ["<localleader>5"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/black-atom-industries/nvim"))
                        end,
                        desc = "Black Atom - nvim",
                    },
                    ["<localleader>6"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/black-atom-industries/radar.nvim"))
                        end,
                        desc = "Black Atom - radar.nvim",
                    },
                    ["<localleader>7"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/nikbrunner/nbr.haus"))
                        end,
                        desc = "nikbrunner - nbr.haus",
                    },
                    ["<localleader>8"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/nikbrunner/koyo"))
                        end,
                        desc = "nikbrunner - koyo",
                    },
                    ["<localleader>9"] = {
                        callback = function()
                            require("canola").open(vim.fn.expand("$HOME/repos/dealercenter-digital/bc-desktop-client"))
                        end,
                        desc = "DCD - BC Desktop Client",
                    },

                    -- Yank file paths
                    ["<leader>yn"] = {
                        callback = function()
                            local entry = require("canola").get_cursor_entry()
                            if entry then
                                local name = entry.name
                                vim.fn.setreg("+", name)
                                vim.notify("Copied filename: " .. name, vim.log.levels.INFO)
                            end
                        end,
                        desc = "Yank filename",
                    },
                    ["<leader>yr"] = {
                        callback = function()
                            local oil = require("canola")
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
                    ["<leader>yh"] = {
                        callback = function()
                            local oil = require("canola")
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
                    ["<leader>ya"] = {
                        callback = function()
                            local oil = require("canola")
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
            }
        end,
        keys = {
            {
                "-",
                function()
                    require("canola").open()
                end,
                desc = "[E]xplorer",
            },
            {
                "_",
                function()
                    require("canola").open(vim.fn.getcwd())
                end,
                desc = "[E]xplorer",
            },
            {
                "<leader>wM",
                canola_git_changes,
                desc = "Git Changes Explorer",
            },
        },
        config = function()
            vim.api.nvim_create_autocmd("User", {
                pattern = "CanolaActionsPost",
                callback = function(event)
                    for _, action in ipairs(event.data.actions) do
                        if action.type == "move" then
                            Snacks.rename.on_rename_file(action.src_url, action.dest_url)
                        end
                    end
                end,
            })

            -- Ensure MiniClue triggers in canola buffers (non-listed buftype)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "canola",
                callback = function(args)
                    vim.schedule(function()
                        if not vim.api.nvim_buf_is_valid(args.buf) then
                            return
                        end
                        pcall(require, "mini.clue")
                        if MiniClue then
                            MiniClue.ensure_buf_triggers(args.buf)
                        end
                    end)
                end,
            })
        end,
    },
    {
        "barrettruth/canola-collection",
        lazy = false,
        init = function()
            vim.g.canola_git = {
                show = { untracked = true, ignored = false },
                format = "compact",
            }
        end,
    },
}
