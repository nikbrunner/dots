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

function M.get_news()
    require("snacks").win({
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
        },
    })
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
    local relative_filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") -- Get path relative to cwd

    Snacks.picker.files({
        pattern = current_filename,
        exclude = {
            ".git",
            relative_filepath,
        },
    })
end

function M.get_window_relative_flow_config()
    local win = vim.api.nvim_get_current_win()
    local win_config = vim.api.nvim_win_get_config(win)
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    -- Get editor dimensions
    local editor_width = vim.o.columns
    local editor_height = vim.o.lines

    -- Calculate window position in editor coordinates
    local win_col = win_pos[2]
    local win_row = win_pos[1]

    -- If it's a floating window, use its absolute position
    if win_config.relative and win_config.relative ~= "" then
        win_col = win_config.col or win_col
        win_row = win_config.row or win_row
    end

    -- Calculate picker dimensions relative to current window
    local picker_width = math.min(win_width - 4, math.floor(editor_width * 0.4)) -- Use window width but cap it
    local picker_height = math.floor(win_height * 0.3) -- 30% of window height for bottom third

    -- Position picker centered horizontally within the current window, in the bottom third
    local target_col = win_col + math.floor((win_width - picker_width) / 2)
    local target_row = win_row + math.floor(win_height * 0.67) -- Start at 67% down the window

    -- Ensure picker doesn't go off screen
    if target_col < 0 then
        target_col = 0
    end
    if target_col + picker_width > editor_width then
        target_col = editor_width - picker_width
    end
    if target_row < 0 then
        target_row = 0
    end
    if target_row + picker_height > editor_height then
        target_row = editor_height - picker_height
    end

    -- Return the proper layout structure that Snacks expects
    return {
        preview = "main",
        layout = {
            backdrop = false,
            col = target_col,
            width = picker_width,
            min_width = 50,
            row = target_row,
            height = picker_height,
            min_height = 10,
            box = "vertical",
            border = "solid",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
            { win = "input", height = 1, border = "solid" },
            { win = "list", border = "none" },
        },
    }
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
        -- App
        { "<leader>aw",          function() Snacks.picker.projects() end, desc = "[W]orkspace" },
        { "<leader>aW",          function() Snacks.picker.zoxide() end, desc = "[W]orkspace (Zoxide)" },
        { "<leader>ad",          M.file_surfer, desc = "[D]ocument" },
        { "<leader>at",          function() Snacks.picker.colorschemes() end, desc = "[T]hemes" },
        { "<leader>ag",          function() Snacks.lazygit() end, desc = "[G]raph" },
        { "<leader>af",          function() Snacks.zen.zen() end, desc = "[F]ocus Mode" },
        { "<leader>az",          function() Snacks.zen.zoom() end, desc = "[Z]oom Mode" },
        { "<leader>an",          function() Snacks.notifier.show_history() end, desc = "[N]otifications" },

        -- Workspace
        { "<leader>wgg",         function() Snacks.lazygit() end, desc = "[G]raph" },
        { "<leader>wgl",         function() Snacks.lazygit.log() end, desc = "[L]Log" },
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
        { "<leader>dgg",          function() Snacks.lazygit.log_file() end, desc = "[G]raph" },
        { "<leader>du",          function() Snacks.picker.undo() end, desc = "[U]ndo" },
        { "<leader>da",          M.find_associated_files, desc = "[A]ssociated Documents" },

        { "sg",                  function() Snacks.git.blame_line() end, desc = "[G]it" },
    }
    -- stylua: ignore end
end

---@type LazyPluginSpec
return {
    "folke/snacks.nvim",
    priority = 1000,
    pin = false,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        statuscolumn = { enabled = true },
        debug = { enabled = true },
        notifier = {
            enabled = true,
            margin = { top = 0, right = 0, bottom = 1, left = 1 },
            top_down = false,
            style = "minimal",
        },
        toggle = { enabled = true },
        gitbrowse = { enabled = true },
        input = { enabled = true },
        scroll = { enabled = false },
        -- https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
        picker = {
            icons = {
                files = {
                    enabled = false,
                },
            },
            ui_select = true, -- replace `vim.ui.select` with the snacks picker
            matcher = {
                -- the bonusses below, possibly require string concatenation and path normalization,
                -- so this can have a performance impact for large lists and increase memory usage
                cwd_bonus = true, -- give bonus for matching files in the cwd
                frecency = true, -- frecency bonus
                history_bonus = true,
            },
            formatters = {
                file = {
                    filename_first = false, -- display filename before the file path
                    truncate = 80,
                },
            },
            previewers = {
                git = {
                    native = true, -- use native (terminal) or Neovim for previewing git diffs and commits
                },
            },
            layouts = {
                default = {
                    layout = {
                        box = "vertical",
                        width = 0.9,
                        min_width = 120,
                        height = 0.8,
                        {
                            box = "vertical",
                            border = "solid",
                            title = "{title} {live} {flags}",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                        },
                        { win = "preview", title = "{preview}", border = "solid" },
                    },
                },
                ivy = {
                    layout = {
                        box = "vertical",
                        backdrop = false,
                        row = -1,
                        width = 0,
                        height = 0.4,
                        border = "solid",
                        title = " {title} {live} {flags}",
                        title_pos = "left",
                        { win = "input", height = 1, border = "bottom" },
                        {
                            box = "horizontal",
                            { win = "list", border = "none" },
                            { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                        },
                    },
                },
                float = {
                    preview = "main",
                    layout = {
                        position = "float",
                        width = 60,
                        col = 0.15,
                        min_width = 60,
                        height = 0.85,
                        min_height = 25,
                        box = "vertical",
                        border = "solid",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "input", height = 1, border = "bottom" },
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                    },
                },
                flow = {
                    preview = "main",
                    layout = {
                        backdrop = false,
                        col = 5,
                        width = 0.35,
                        min_width = 50,
                        row = 0.65,
                        height = 0.30,
                        min_height = 10,
                        box = "vertical",
                        border = "solid",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                        { win = "input", height = 1, border = "solid" },
                        { win = "list", border = "none" },
                    },
                },
                left_bottom_corner = {
                    preview = "main",
                    layout = {
                        width = 0.5,
                        min_width = 0.35,
                        height = 0.35,
                        min_height = 0.35,
                        row = 0.5,
                        col = 10,
                        border = "solid",
                        box = "vertical",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                        { win = "input", height = 1, border = "solid" },
                        { win = "list", border = "none" },
                    },
                },
                sidebar_right = {
                    preview = "main",
                    layout = {
                        backdrop = false,
                        width = 40,
                        min_width = 40,
                        height = 0,
                        position = "right",
                        border = "none",
                        box = "vertical",
                        {
                            win = "input",
                            height = 1,
                            border = "rounded",
                            title = "{title} {live} {flags}",
                            title_pos = "center",
                        },
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", height = 0.4, border = "top" },
                    },
                },
            },

            win = {
                preview = {
                    wo = {
                        number = false,
                    },
                },
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
                select = {
                    layout = { preset = "flow" },
                },
                explorer = {
                    replace_netrw = true,
                    git_status = true,
                    jump = {
                        close = true,
                    },
                    hidden = true,
                    ignored = true,
                    layout = {
                        preset = "float",
                        preview = {
                            main = true,
                            enabled = false,
                        },
                    },
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
                    layout = {
                        preset = "flow",
                        border = "solid",
                    },
                },
                ---@type snacks.picker.smart.Config
                smart = {
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                ---TODO: filter out empty file
                ---@type snacks.picker.recent.Config
                recent = {
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                lines = {
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                lsp_references = {
                    pattern = "!import !default", -- Exclude Imports and Default Exports
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
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
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                lsp_workspace_symbols = {
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                diagnostics = {
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                diagnostics_buffer = {
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                git_status = {
                    preview = "git_status",
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                git_diff = {
                    layout = function()
                        return M.get_window_relative_flow_config()
                    end,
                },
                ---@type snacks.picker.projects.Config: snacks.picker.Config
                projects = {
                    finder = "recent_projects",
                    format = "file",
                    dev = {
                        "~/repos/nikbrunner/",
                        "~/repos/dealercenter-digital/",
                        "~/repos/black-atom-industries/",
                        "~/repos/bradtraversy/",
                        "~/repos/total-typescript/",
                        "~/.local/share/nvim/lazy/",
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
