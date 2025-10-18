---@diagnostic disable: assign-type-mismatch, missing-fields
local M = {}

function EditLineFromLazygit(file_path, line)
    local path = vim.fn.expand("%:p")
    if path == file_path then
        vim.cmd(tostring(line))
    else
        vim.cmd("e " .. file_path)
        vim.cmd(tostring(line))
    end
end

function EditFromLazygit(file_path)
    local path = vim.fn.expand("%:p")
    if path == file_path then
        return
    else
        vim.cmd("e " .. file_path)
    end
end

function M.file_surfer()
    Snacks.picker.zoxide({
        confirm = function(picker, item)
            local cwd = item._path

            picker:close()
            vim.fn.chdir(cwd)

            if item then
                vim.schedule(function()
                    Snacks.picker.files({
                        filter = {
                            cwd = cwd,
                        },
                    })
                end)
            end
        end,
    })
end

function M.find_associated_files()
    local current_filename = vim.fn.expand("%:t:r")
    -- Extract base name before any suffixes like .stories, .test, .data, etc.
    local base_name = current_filename:match("^([^.]+)") or current_filename
    local relative_filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") -- Get path relative to cwd

    Snacks.picker.files({
        pattern = base_name,
        exclude = {
            ".git",
            relative_filepath,
        },
    })
end

---@type snacks.picker.layout.Config
M.shared_layout_opts = {
    preview = "main",
    layout = {
        box = "vertical",
        border = "solid",
        min_width = 50,
        min_height = 10,
        backdrop = false,
        { win = "preview", title = "{preview}", width = 0.6, border = "top" },
        { win = "input", height = 1, border = "single" },
        { win = "list", border = "none" },
    },
}

function M.buffer_layout()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    -- Calculate picker dimensions based on current window (matching mini.pick logic)
    local border_width = 2
    local picker_height = math.floor(0.25 * win_height)

    -- Position at bottom-left of current window in editor coordinates
    local col = win_pos[2] -- Left edge of current window
    local row = win_pos[1] + win_height - picker_height - 1 -- Bottom of current window

    return vim.tbl_deep_extend("force", M.shared_layout_opts, {
        layout = {
            col = col,
            width = win_width - border_width,
            row = row,
            height = picker_height,
        },
    })
end

-- Layouts: ~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/config/layouts.lua
function M.smart_layout()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    -- Calculate picker dimensions based on current window (matching mini.pick logic)
    -- local border_width = 2
    local picker_height = math.floor(0.25 * win_height)

    -- Position at bottom-left of current window in editor coordinates
    -- local col = win_pos[2] -- Left edge of current window
    local row = win_pos[1] + win_height - picker_height - 1 -- Bottom of current window

    if win_width >= 165 then
        return vim.tbl_deep_extend("force", M.shared_layout_opts, {
            layout = {
                -- If we don't define col, its gets centered
                width = 0.5,
                row = row,
                height = picker_height,
            },
        })
    else
        return M.buffer_layout()
    end
end

function M.explorer()
    local explorer_pickers = Snacks.picker.get({ source = "explorer" })
    for _, v in pairs(explorer_pickers) do
        if v:is_focused() then
            v:close()
        else
            v:focus()
        end
    end
    if #explorer_pickers == 0 then
        Snacks.picker.explorer()
    end
end

--- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
--- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/sources.lua
--- https://github.com/kaiphat/dotfiles/blob/master/nvim/lua/plugins/snacks.lua

function M.keys()
    -- stylua: ignore start
    return {
        -- General
        { "<leader>.",           function() Snacks.picker.resume() end, desc = "Resume Picker" },
        { "<leader>;",           function() Snacks.picker.commands() end, desc = "Commands" },
        { "<leader>:",           function() Snacks.picker.command_history() end, desc = "Command History" },
        { "<leader>'",           function() Snacks.picker.registers() end, desc = "Registers" },

        -- App
        { "<leader>aw",          function() Snacks.picker.projects() end, desc = "[W]orkspace" },
        { "<leader>aW",          function() Snacks.picker.zoxide() end, desc = "[W]orkspace (Zoxide)" },
        { "<leader>ad",          M.file_surfer, desc = "[D]ocument" },
        { "<leader>aa",          function() Snacks.picker.commands() end, desc = "[A]ctions" },
        { "<leader>ag",          function() Snacks.lazygit() end, desc = "[G]raph" },
        { "<leader>asd",         function() Snacks.picker.files({ cwd = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots" }) end, desc = "[D]ots" },
        { "<leader>at",          function() Snacks.picker.colorschemes() end, desc = "[T]hemes" },
        { "<leader>ar",          function() Snacks.picker.recent() end, desc = "[R]ecent Documents (Anywhere)" },
        { "<leader>af",          function() Snacks.zen.zen() end, desc = "[F]ocus Mode" },
        { "<leader>az",          function() Snacks.zen.zoom() end, desc = "[Z]oom Mode" },
        { "<leader>an",          function() Snacks.notifier.show_history() end, desc = "[N]otifications" },
        { "<leader>ak",          function() Snacks.picker.keymaps() end, desc = "[K]eymaps" },
        { "<leader>aj",          function() Snacks.picker.jumps() end, desc = "[J]umps" },
        { "<leader>ahp",         function() Snacks.picker.help() end, desc = "[P]ages" },
        { "<leader>ahm",         function() Snacks.picker.man() end, desc = "[M]anuals" },
        { "<leader>ahh",         function() Snacks.picker.highlights() end, desc = "[H]ightlights" },


        -- Workspace
        { "<leader><leader>",    function() Snacks.picker.smart() end, desc = "[D]ocument" },
        { "<leader>wd",          function() Snacks.picker.smart() end, desc = "[D]ocument" },
        { "<leader>wr",          function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "[R]ecent Documents" },
        { "<leader>wt",          function() Snacks.picker.grep() end, desc = "[T]ext" },
        { "<leader>ww",          function() Snacks.picker.grep_word() end, desc = "[W]ord" },
        { "<leader>wm",          function() Snacks.picker.git_status() end, desc = "[M]odified Documents" },
        { "<leader>wc",          function() Snacks.picker.git_diff() end, desc = "[C]hanges" },
        { "<leader>wp",          function() Snacks.picker.diagnostics() end, desc = "[P]roblems" },
        { "<leader>ws",          function() Snacks.picker.lsp_workspace_symbols() end, desc = "[S]ymbols" },
        { "<leader>wgg",         function() Snacks.lazygit() end, desc = "[G]raph" },
        { "<leader>wgl",         function() Snacks.lazygit.log() end, desc = "[L]Log" },
        { "<leader>wgb",         function() Snacks.picker.git_branches() end, desc = "[B]ranches" },
        { "<leader>wgr",         function() Snacks.gitbrowse() end, desc = "[R]emote" },
        { "<leader>wgp",         function()
            local current_branch = vim.fn.system("git branch --show-current"):gsub("%s+", "")
            if vim.v.shell_error ~= 0 then
                vim.notify("Not in a git repository", vim.log.levels.ERROR)
                return
            end

            local pr_result = vim.fn.system("gh pr view --json url -q '.url' 2>/dev/null")
            if vim.v.shell_error == 0 and pr_result:match("^https://") then
                local pr_url = pr_result:gsub("%s+", "")
                vim.fn.system("open " .. pr_url)
                vim.notify("Opening PR: " .. pr_url, vim.log.levels.INFO)
            else
                vim.notify("No PR found for branch: " .. current_branch, vim.log.levels.WARN)
            end
        end, desc = "[P]R" },

        -- Document
        { "<leader>dgg",         function() Snacks.lazygit.log_file() end, desc = "[G]raph" },
        { "<leader>dt",          function() Snacks.picker.lines({ layout = M.buffer_layout }) end, desc = "[T]ext" },
        { "<leader>ds",          function() Snacks.picker.lsp_symbols() end, desc = "[S]ymbols" },
        { "<leader>du",          function() Snacks.picker.undo() end, desc = "[U]ndo" },
        { "<leader>da",          M.find_associated_files, desc = "[A]ssociated Documents" },

        { "sg",                  function() Snacks.git.blame_line() end, desc = "[G]it" },
    }
    -- stylua: ignore end
end

---@type LazyPluginSpec
return {
    "folke/snacks.nvim",
    depdencies = {
        {
            "mbbill/undotree",
            cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" },
        },
    },
    priority = 1000,
    pin = false,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },

        statuscolumn = { enabled = true },

        debug = { enabled = true },

        toggle = { enabled = true },

        gitbrowse = { enabled = true },

        input = { enabled = true },

        scroll = { enabled = false },

        notifier = {
            enabled = true,
            margin = { top = 0, right = 0, bottom = 1, left = 1 },
            top_down = false,
            style = "minimal",
        },

        -- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
        picker = {
            ui_select = true, -- replace `vim.ui.select` with the snacks picker
            layout = function()
                return M.smart_layout()
            end,

            matcher = {
                -- the bonusses below, possibly require string concatenation and path normalization,
                -- so this can have a performance impact for large lists and increase memory usage
                cwd_bonus = true, -- give bonus for matching files in the cwd
                frecency = true, -- frecency bonus
                history_bonus = true,
            },

            formatters = {
                file = {
                    filename_first = true, -- display filename before the file path
                    truncate = 80,
                },
            },

            previewers = {
                git = {
                    builtin = false, -- use external git command with delta
                },
                diff = {
                    builtin = false, -- use external delta command for diffs
                    cmd = { "delta" },
                },
            },

            win = {
                input = {
                    keys = {
                        ["<c-t>"] = { "edit_tab", mode = { "i", "n" } },
                        ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
                        ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
                        ["<c-f>"] = { "flash", mode = { "n", "i" } },
                    },
                },
                list = {
                    keys = {
                        ["<c-t>"] = "edit_tab",
                    },
                },
            },

            sources = {
                explorer = {
                    replace_netrw = true,
                    git_status = true,
                    jump = {
                        close = true,
                    },
                    hidden = true,
                    ignored = true,
                    win = {
                        list = {
                            keys = {
                                ["]c"] = "explorer_git_next",
                                ["[c"] = "explorer_git_prev",
                                ["<c-t>"] = { "tab", mode = { "n", "i" } },
                            },
                        },
                    },
                    icons = {
                        tree = {
                            vertical = "  ",
                            middle = "  ",
                            last = "  ",
                        },
                    },
                },

                buffers = {
                    current = false,
                },

                files = {
                    hidden = true,
                },

                smart = {
                    filter = {
                        paths = {
                            -- TODO: filter out current file
                            [vim.fn.getcwd()] = false,
                        },
                    },
                },

                lsp_references = {
                    pattern = "!import !default", -- Exclude Imports and Default Exports
                },

                lsp_symbols = {
                    finder = "lsp_symbols",
                    format = "lsp_symbol",
                    hierarchy = true,
                    filter = {
                        default = true,
                        markdown = true,
                        help = true,
                    },
                },

                git_status = {
                    preview = "git_status",
                },

                projects = {
                    finder = "recent_projects",
                    -- TODO: restore session
                    format = "file",
                    dev = {
                        "~/repos/nikbrunner/",
                        "~/repos/dealercenter-digital/",
                        "~/repos/black-atom-industries/",
                        "~/repos/bradtraversy/",
                        "~/repos/total-typescript/",
                        "~/.local/share/nvim/",
                    },
                },
            },
        },

        zen = {
            toggles = {
                dim = false,
                git_signs = false,
                mini_diff_signs = false,
                diagnostics = true,
            },
            ---@type snacks.zen.Config
            zoom = {
                show = { statusline = false, tabline = false },
            },
        },

        ---@type snacks.words.Config
        words = { debounce = 100 },

        terminal = {
            win = {
                border = "solid",
                wo = {
                    winbar = "",
                },
            },
        },

        lazygit = {
            configure = true,
            config = {
                os = {
                    edit = "nvim --server $NVIM --remote-send '<cmd>close<cr><cmd>lua EditFromLazygit({{filename}})<CR>'",
                    editAtLine = "nvim --server $NVIM --remote-send '<cmd>close<CR><cmd>lua EditLineFromLazygit({{filename}},{{line}})<CR>'",
                },
            },
            win = {
                backdrop = true,
                border = "solid",
                width = 0.9,
                height = 0.9,
            },
        },

        styles = {
            notification_history = {
                border = "solid",
            },
            notification = {
                border = "single",
                wo = {
                    winblend = 0,
                    winhighlight = "Normal:SnacksNotifierHistory",
                },
            },
            zen = {
                width = 0.65,
                backdrop = {
                    transparent = true,
                    blend = 20,
                },
                wo = {
                    number = false,
                    scrolloff = 999,
                },
                keys = {
                    q = function(self)
                        self:close()
                    end,
                    ["<leader>td"] = function()
                        if vim.g.snacks_animate_dim then
                            Snacks.dim.disable()
                            vim.g.snacks_animate_dim = false
                        else
                            Snacks.dim.enable()
                            vim.g.snacks_animate_dim = true
                        end
                    end,
                },
            },
        },
    },

    keys = M.keys(),

    init = function()
        -- vim.api.nvim_create_autocmd("BufEnter", {
        --     group = vim.api.nvim_create_augroup("snacks_explorer_start_directory", { clear = true }),
        --     desc = "Start Snacks Explorer with directory",
        --     once = true,
        --     callback = function()
        --         local dir = vim.fn.argv(0) --[[@as string]]
        --         if dir ~= "" and vim.fn.isdirectory(dir) == 1 then
        --             Snacks.picker.explorer({ cwd = dir })
        --         end
        --     end,
        -- })

        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- stylua: ignore start
                Snacks.toggle.line_number():map("<leader>asol")
                Snacks.toggle.inlay_hints():map("<leader>asoh")
                Snacks.toggle.treesitter():map("<leader>asoT")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>asoL")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 1 and vim.o.conceallevel or 3 }):map("<leader>asoc")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>asob")
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>asos")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>asow")
                -- stylua: ignore end
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "SnacksTerminalClose",
            callback = function()
                -- Refresh gitsigns when terminal closes
                vim.defer_fn(function()
                    local ok, gitsigns = pcall(require, "gitsigns")
                    if ok then
                        gitsigns.refresh()
                    end
                end, 100)
            end,
        })
    end,
}
