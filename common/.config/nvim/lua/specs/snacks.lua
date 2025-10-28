---@diagnostic disable: assign-type-mismatch, missing-fields
local M = {}

-- ============================================================================
-- Lazygit Integration Functions
-- ============================================================================

---Edit a file at a specific line from Lazygit
---@param file_path string The file path to edit
---@param line number The line number to jump to
---@return nil
local function edit_line_from_lazygit(file_path, line)
    local current_path = vim.fn.expand("%:p")
    if current_path ~= file_path then
        vim.cmd("e " .. file_path)
    end
    vim.cmd(tostring(line))
end

---Edit a file from Lazygit
---@param file_path string The file path to edit
---@return nil
local function edit_from_lazygit(file_path)
    local current_path = vim.fn.expand("%:p")
    if current_path ~= file_path then
        vim.cmd("e " .. file_path)
    end
end

-- Make functions globally available for Lazygit integration
_G.EditLineFromLazygit = edit_line_from_lazygit
_G.EditFromLazygit = edit_from_lazygit

-- ============================================================================
-- Custom Picker Functions
-- ============================================================================

---Open a zoxide picker, then open files picker in the selected directory
---@return nil
function M.file_surfer()
    Snacks.picker.zoxide({
        confirm = function(picker, item)
            local cwd = item._path

            picker:close()
            vim.fn.chdir(cwd)

            vim.schedule(function()
                Snacks.picker.files({
                    filter = {
                        cwd = cwd,
                    },
                })
            end)
        end,
    })
end

---Find files associated with the current file (same base name)
---Excludes suffixes like .stories, .test, .data, etc.
---@return nil
function M.find_associated_files()
    local current_filename = vim.fn.expand("%:t:r")
    local base_name = current_filename:match("^([^.]+)") or current_filename
    local relative_filepath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.")

    Snacks.picker.files({
        pattern = base_name,
        exclude = {
            ".git",
            relative_filepath,
        },
    })
end

-- ============================================================================
-- Layout Configurations
-- ============================================================================

---Shared layout options for pickers
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

---Get layout configuration for buffer-specific picker
---Positions picker at bottom-left of current window
---@return snacks.picker.layout.Config
function M.buffer_layout()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    local border_width = 2
    local picker_height = math.floor(0.25 * win_height)
    local col = win_pos[2]
    local row = win_pos[1] + win_height - picker_height - 1

    return vim.tbl_deep_extend("force", M.shared_layout_opts, {
        layout = {
            col = col,
            width = win_width - border_width,
            row = row,
            height = picker_height,
        },
    })
end

---Get smart layout that adapts based on window width
---Uses centered layout for wide windows (>= 165 cols), buffer layout otherwise
---@return snacks.picker.layout.Config
function M.smart_layout()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    local picker_height = math.floor(0.25 * win_height)
    local row = win_pos[1] + win_height - picker_height - 1

    if win_width >= 165 then
        return vim.tbl_deep_extend("force", M.shared_layout_opts, {
            layout = {
                width = 0.5,
                row = row,
                height = picker_height,
            },
        })
    else
        return M.buffer_layout()
    end
end

-- ============================================================================
-- Explorer Functions
-- ============================================================================

---Toggle or focus the file explorer
---@return nil
function M.explorer()
    local explorer_pickers = Snacks.picker.get({ source = "explorer" })
    for _, picker in pairs(explorer_pickers) do
        if picker:is_focused() then
            picker:close()
        else
            picker:focus()
        end
    end
    if #explorer_pickers == 0 then
        Snacks.picker.explorer()
    end
end

-- ============================================================================
-- Keymaps
-- ============================================================================

---Get keymaps configuration for Snacks
---@return table[]
---@see https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/defaults.lua
---@see https://github.com/folke/snacks.nvim/blob/main/lua/snacks/picker/config/sources.lua
---@see https://github.com/kaiphat/dotfiles/blob/master/nvim/lua/plugins/snacks.lua
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
        { "<leader>as",         function() Snacks.picker.files({ cwd = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots" }) end, desc = "[D]ots" },
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
        -- Main File Finding is handled via fff.nvim & fff-snacks.nvim (<leader><leader> & <leader>wd)
        { "<leader>we",          M.explorer, desc = "[E]xplorer" },
        { "<leader>wr",          function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "[R]ecent Documents" },
        { "<leader>wm",          function() Snacks.picker.git_status() end, desc = "[M]odified Documents" },
        { "<leader>wc",          function() Snacks.picker.git_diff() end, desc = "[C]hanges" },
        { "<leader>wt",          function() Snacks.picker.grep() end, desc = "[T]ext" },
        { "<leader>ww",          function() Snacks.picker.grep_word() end, desc = "[W]ord" },
        { "<leader>wp",          function() Snacks.picker.diagnostics() end, desc = "[P]roblems" },
        { "<leader>ws",          function() Snacks.picker.lsp_workspace_symbols() end, desc = "[S]ymbols" },
        { "<leader>wg",         function() Snacks.lazygit() end, desc = "[G]raph" },
        { "<leader>wl",         function() Snacks.lazygit.log() end, desc = "[L]Log" },
        { "<leader>wb",         function() Snacks.picker.git_branches() end, desc = "[B]ranches" },
        { "<leader>wb",         function() Snacks.gitbrowse() end, desc = "[R]emote" },
        { "<leader>wp",         function()
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
        { "<leader>dg",         function() Snacks.lazygit.log_file() end, desc = "[G]raph" },
        { "<leader>dt",          function() Snacks.picker.lines({ layout = M.buffer_layout }) end, desc = "[T]ext" },
        { "<leader>dc",          function()
            local file = vim.fn.expand("%")
            if file ~= "" then
                Snacks.picker.git_diff({ cmd_args = { "--", file } })
            else
                vim.notify("No file in current buffer", vim.log.levels.WARN)
            end
        end, desc = "[C]hanges" },
        { "<leader>dp",          function() Snacks.picker.diagnostics_buffer({ layout = M.buffer_layout }) end, desc = "[P]roblems" },
        { "<leader>ds",          function() Snacks.picker.lsp_symbols() end, desc = "[S]ymbols" },
        { "<leader>du",          function() Snacks.picker.undo() end, desc = "[U]ndo" },
        { "<leader>da",          M.find_associated_files, desc = "[A]ssociated Documents" },

        { "sg",                  function() Snacks.git.blame_line() end, desc = "[G]it" },
    }
    -- stylua: ignore end
end

-- ============================================================================
-- Plugin Specification
-- ============================================================================

---@type LazyPluginSpec
return {
    "folke/snacks.nvim",

    lazy = false,

    init = function()
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- stylua: ignore start
                Snacks.toggle.line_number():map("<leader>aol")
                Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>aoL")
                Snacks.toggle.inlay_hints():map("<leader>aoh")
                Snacks.toggle.treesitter():map("<leader>aoT")
                Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 1 and vim.o.conceallevel or 3 }):map("<leader>aoc")
                Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>aob")
                Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>aos")
                Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>aow")
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

    dependencies = {
        {
            "mbbill/undotree",
            cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" },
        },
        {
            "dmtrKovalenko/fff.nvim",
            lazy = false,
            build = function()
                require("fff.download").download_or_build_binary()
            end,
            opts = {
                max_results = 400,
                max_threads = 8,
                debug = {
                    enabled = true, -- we expect your collaboration at least during the beta
                    show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
                },
            },
        },
        {
            "madmaxieee/fff-snacks.nvim",
            dir = require("lib.config").get_repo_path("nikbrunner/fff-snacks.nvim"),
            dependencies = { "dmtrKovalenko/fff.nvim", "folke/snacks.nvim" },
            keys = {
                { "<leader><leader>", "<CMD>FFFSnacks<CR>", desc = "Find Files" },
                { "<leader>wd", "<CMD>FFFSnacks<CR>", desc = "[D]ocument" },
            },
            ---@module "fff-snacks"
            ---@type fff-snacks.Config
            opts = {
                layout = function()
                    return M.smart_layout()
                end,
                git_icons = {
                    added = " ",
                    modified = " ",
                    untracked = "󰎔 ",
                    deleted = " ",
                    ignored = " ",
                    renamed = " ",
                    clean = "  ",
                },
            },
        },
    },

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
        picker = {
            -- ~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/config/defaults.lua
            --
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
                    cmd = { "delta", "--width", vim.o.columns }, -- explicit width since PTY is disabled when piping input
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
                    multi = { "buffers", "recent", "files" },
                    sort = { fields = { "source_id" } }, -- source_id:asc, source_id:desc
                    filter = { cwd = true },
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
                dim = true,
                git_signs = false,
                mini_diff_signs = false,
                diagnostics = true,
            },
            ---@type snacks.zen.Config
            zoom = {
                show = { statusline = false, tabline = false },
            },
        },
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
                width = 0.9999,
                height = 0.9999,
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
                width = 125,
                backdrop = {
                    transparent = true,
                    blend = 10,
                },
                wo = {
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
}
