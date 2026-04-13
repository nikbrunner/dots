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
-- GitHub PR Context Detection
-- ============================================================================

-- Track the last known branch to avoid redundant checks
local last_head_name = nil

---Detect GitHub PR context for the current branch
---Updates state with PR number and repo if a PR exists
---@return nil
local function detect_gh_pr_context()
    local state = require("state")

    -- Clear previous context
    state:set("gh_current_pr", nil)
    state:set("gh_current_repo", nil)

    -- Get the git root directory for the current buffer
    local git_root = vim.fs.root(0, ".git")
    if not git_root then
        return
    end

    vim.system({ "gh", "pr", "view", "--json", "number" }, { text = true, cwd = git_root }, function(pr_result)
        vim.schedule(function()
            if pr_result.code == 0 and pr_result.stdout then
                local pr_ok, pr_data = pcall(vim.json.decode, pr_result.stdout)
                if pr_ok and pr_data.number then
                    vim.system(
                        { "gh", "repo", "view", "--json", "owner,name" },
                        { text = true, cwd = git_root },
                        function(repo_result)
                            vim.schedule(function()
                                if repo_result.code == 0 and repo_result.stdout then
                                    local repo_ok, repo_data = pcall(vim.json.decode, repo_result.stdout)
                                    if repo_ok and repo_data.owner and repo_data.name then
                                        local repo = string.format("%s/%s", repo_data.owner.login, repo_data.name)
                                        state:set("gh_current_pr", pr_data.number)
                                        state:set("gh_current_repo", repo)
                                        Snacks.notify(
                                            string.format("PR #%d ready (%s)", pr_data.number, repo),
                                            { title = "GitHub", level = "info" }
                                        )
                                    end
                                end
                            end)
                        end
                    )
                end
            end
        end)
    end)
end

-- ============================================================================
-- Custom Picker Functions
-- ============================================================================

---Get list of project directories (org/project) from repos path
---@return snacks.picker.finder.Item[] dirs, string repos_path
local function get_project_dirs()
    local repos_path = require("config").pathes.repos
    local dirs = {}
    local orgs = vim.fn.readdir(repos_path, function(name)
        return vim.fn.isdirectory(repos_path .. "/" .. name) == 1
    end)
    for _, org in ipairs(orgs) do
        local org_path = repos_path .. "/" .. org
        local projects = vim.fn.readdir(org_path, function(name)
            return vim.fn.isdirectory(org_path .. "/" .. name) == 1
        end)
        for _, project in ipairs(projects) do
            table.insert(dirs, { text = org .. "/" .. project, file = repos_path .. "/" .. org .. "/" .. project })
        end
    end
    return dirs, repos_path
end

---Pick a project directory, then open files picker in it
function M.project_files()
    local dirs, repos_path = get_project_dirs()

    Snacks.picker({
        title = "Projects",
        items = dirs,
        format = "file",
        confirm = function(picker, item)
            picker:close()
            vim.fn.chdir(item.file)
            vim.schedule(function()
                Snacks.picker.files()
            end)
        end,
    })
end

---Pick a project directory, save current session, switch cwd, restore target session
function M.project_switch()
    local dirs, repos_path = get_project_dirs()
    local get_session_name = require("lib.sessions").get_session_name

    Snacks.picker({
        title = "Switch Project",
        items = dirs,
        format = "file",
        confirm = function(picker, item)
            picker:close()
            vim.schedule(function()
                local chosen_path = item.file
                local MS = require("mini.sessions")

                -- Guard: prevent TermLeave/VimResume autocmd from
                -- triggering MS.read() during our switch
                vim.g._mini_session_switching = true

                -- Save current project session (cwd is still old project)
                MS.write(get_session_name(), { force = true })

                -- Stop LSP before buffer wipe to avoid stale callbacks
                vim.iter(vim.lsp.get_clients()):each(function(c)
                    c:stop(true)
                end)
                vim.cmd("silent! %bwipeout!")

                -- Switch to new project
                vim.fn.chdir(chosen_path)

                -- Restore target session or start fresh
                local target_session = get_session_name(chosen_path)
                if MS.detected[target_session] then
                    local data = MS.detected[target_session]
                    vim.cmd(("silent! source %s"):format(vim.fn.fnameescape(data.path)))
                    vim.v.this_session = data.path
                else
                    vim.cmd.enew()
                    vim.notify("Switched to " .. item.text .. " (no session)")
                end

                vim.g._mini_session_switching = false
            end)
        end,
    })
end

---Find files associated with the current file (same base name)
function M.associated_files()
    local current_filename = vim.fn.expand("%:t:r")
    local base_name = current_filename:match("^([^.]+)") or current_filename
    local current_path = vim.fn.expand("%:.")

    local cmd = { "rg", "--files", "--glob", "**/" .. base_name .. ".*" }
    local output = vim.fn.systemlist(cmd)
    local items = {}
    for _, file in ipairs(output) do
        if file ~= current_path then
            table.insert(items, { text = file, file = file })
        end
    end

    Snacks.picker({
        title = "Associated Files",
        items = items,
    })
end

---Show jumps for the current buffer only
function M.buffer_jumps()
    local current_buf = vim.api.nvim_get_current_buf()
    local current_file = vim.api.nvim_buf_get_name(current_buf)
    local jumps = vim.fn.getjumplist()[1]
    local items = {}

    for _, jump in ipairs(jumps) do
        local buf = jump.bufnr and vim.api.nvim_buf_is_valid(jump.bufnr) and jump.bufnr or 0
        if buf == current_buf and jump.lnum > 0 then
            local lines = vim.api.nvim_buf_get_lines(buf, jump.lnum - 1, jump.lnum, false)
            table.insert(items, 1, {
                text = string.format("%d: %s", jump.lnum, vim.trim(lines[1] or "")),
                file = current_file,
                pos = { jump.lnum, jump.col },
            })
        end
    end

    Snacks.picker({
        title = "Buffer Jumps",
        items = items,
    })
end

-- GitHub Picker Functions

function M.gh_pr_diff()
    local state = require("state")
    if state:has_gh_context() then
        local ctx = state:get_gh_context()
        Snacks.picker.gh_diff({
            repo = ctx.repo,
            pr = ctx.pr,
        })
    else
        vim.notify("No PR detected on current branch", vim.log.levels.WARN)
    end
end

function M.gh_pr_buffer()
    local state = require("state")
    if state:has_gh_context() then
        local ctx = state:get_gh_context()
        vim.cmd.edit("gh://" .. ctx.repo .. "/pr/" .. ctx.pr)
    else
        vim.notify("No PR detected on current branch", vim.log.levels.WARN)
    end
end

function M.gh_pr_browse()
    vim.ui.select({ "all", "closed", "merged", "open" }, {
        prompt = "GitHub Pull Requests",
    }, function(choice)
        if choice then
            Snacks.picker.gh_pr({ state = choice })
        end
    end)
end

function M.gh_issue_browse()
    vim.ui.select({ "all", "closed", "open" }, {
        prompt = "GitHub Issues",
    }, function(choice)
        if choice then
            Snacks.picker.gh_issue({ state = choice })
        end
    end)
end

---Show explorer filtered to only git-modified and untracked files
function M.git_explorer()
    local win = vim.api.nvim_get_current_win()
    local pos = vim.api.nvim_win_get_position(win)
    local width = vim.api.nvim_win_get_width(win)
    local height = vim.api.nvim_win_get_height(win)

    Snacks.picker.explorer({
        title = "Git Explorer",
        layout = {
            layout = {
                backdrop = false,
                row = pos[1],
                col = pos[2],
                width = width,
                height = height,
                border = "none",
                box = "vertical",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
            },
        },
        git_status = true,
        auto_close = true,
        git_status_open = true,
        git_untracked = true,
        diagnostics = false,
        ignored = false,
        transform = function(item)
            -- Always keep root directory
            if not item.parent then
                return
            end
            -- Keep files with git status (modified/untracked/etc)
            if item.status then
                return
            end
            -- Keep directories containing dirty descendants
            if item.dir_status then
                return
            end
            -- Filter out clean items
            return false
        end,
    })
end

-- ============================================================================
-- Layout Configurations
-- ============================================================================

---Shared layout options for pickers
---@type snacks.picker.layout.Config
---Get smart layout that adapts based on window width
---Uses centered layout for wide windows (>= 165 cols), compact layout otherwise
---@return snacks.picker.layout.Config
function M.smart_layout()
    local win = vim.api.nvim_get_current_win()
    local win_pos = vim.api.nvim_win_get_position(win)
    local win_width = vim.api.nvim_win_get_width(win)
    local win_height = vim.api.nvim_win_get_height(win)

    local picker_height = math.floor(0.25 * win_height)
    local row = win_pos[1] + win_height - picker_height - 1

    local col = win_pos[2]
    local border_width = 2

    local shared_layout_opts = {
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

    if win_width >= 165 then
        return vim.tbl_deep_extend("force", shared_layout_opts, {
            layout = {
                width = 0.5,
                row = row,
                height = picker_height,
            },
        })
    else
        return vim.tbl_deep_extend("force", shared_layout_opts, {
            layout = {
                col = col,
                width = win_width - border_width,
                row = row,
                height = picker_height,
            },
        })
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
    local dots_path = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots"

    -- stylua: ignore start
    return {
        -- General
        -- { "<leader><leader>",    function() Snacks.picker.smart() end, desc = "Pick file" },
        { "<leader>.",           function() Snacks.picker.resume() end, desc = "Resume Picker" },
        { "<leader>;",           function() Snacks.picker.commands() end, desc = "Commands" },
        { "<leader>:",           function() Snacks.picker.command_history() end, desc = "Command History" },
        { "<leader>'",           function() Snacks.picker.registers() end, desc = "Registers" },

        -- App
        { "<leader>aa",          function() Snacks.picker.commands() end, desc = "[A]ctions" },
        { "<leader>ad",          M.project_files, desc = "[D]ocument (in project)" },
        { "<leader>ag",          function() Snacks.lazygit() end, desc = "[G]it" },
        { "<leader>ahh",         function() Snacks.picker.highlights() end, desc = "[H]ighlights" },
        { "<leader>ahk",         function() Snacks.picker.keymaps() end, desc = "[K]eymaps" },
        { "<leader>ahm",         function() Snacks.picker.man() end, desc = "[M]anuals" },
        { "<leader>aht",         function() Snacks.picker.help() end, desc = "[T]ags" },
        { "<leader>an",          function() Snacks.notifier.show_history() end, desc = "[N]otifications" },
        { "<leader>ar",          function() Snacks.picker.recent() end, desc = "[R]ecent Documents (Anywhere)" },
        { "<leader>a,",          function() Snacks.picker.files({ cwd = dots_path }) end, desc = "[,]Settings (Dots)" },
        { "<leader>at",          function() Snacks.picker.colorschemes() end, desc = "[T]hemes" },
        { "<leader>aw",          M.project_switch, desc = "[W]orkspace" },

        -- Workspace
        { "<leader>we",          function() Snacks.picker.explorer() end, desc = "[E]xplorer" },
        { "<leader>wc",          function() Snacks.picker.git_diff() end, desc = "[C]hanges" },
        -- { "<leader>wd",          function() Snacks.picker.files() end, desc = "[D]ocument" },
        { "<leader>wj",          function() Snacks.picker.jumps() end, desc = "[J]umps" },
        { "<leader>wm",          function() Snacks.picker.git_status() end, desc = "[M]odified Documents" },
        { "<leader>wM",          M.git_explorer, desc = "[M]odified Explorer" },
        { "<leader>wp",          function() Snacks.picker.diagnostics() end, desc = "[P]roblems" },
        { "<leader>wr",          function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "[R]ecent Documents" },
        { "<leader>ws",          function() Snacks.picker.lsp_symbols() end, desc = "[S]ymbols" },
        -- { "<leader>wt",          function() Snacks.picker.grep({ hidden = true }) end, desc = "[T]ext" },
        -- { "<leader>ww",          function() Snacks.picker.grep_word() end, desc = "[W]ord" },
        { "<leader>wgb",         function() Snacks.picker.git_branches() end, desc = "[B]ranches" },
        { "<leader>wgh",         function() Snacks.picker.git_log() end, desc = "[H]istory" },
        { "<leader>wgH",         function() Snacks.lazygit.log() end, desc = "[H]istory (Lazygit)" },
        { "<leader>wgr",         function() Snacks.gitbrowse() end, desc = "[R]emote (GitHub)" },
        { "<leader>wgs",         function() Snacks.lazygit() end, desc = "[S]tatus (Lazygit)" },
        { "<leader>wgib",         M.gh_issue_browse, desc = "[B]rowse Issues" },
        { "<leader>wgpc",         M.gh_pr_diff, desc = "[C]hanges in current PR" },
        { "<leader>wgpd",         M.gh_pr_buffer, desc = "[D]escription of current PR" },
        { "<leader>wgpb",         M.gh_pr_browse, desc = "[B]rowse Pull Requests" },

        -- Document
        { "<leader>da",          M.associated_files, desc = "[A]ssociated Documents" },
        { "<leader>dc",          function() Snacks.picker.git_diff({ current_file = true }) end, desc = "[C]hanges" },
        { "<leader>dgh",         function() Snacks.picker.git_log_file() end, desc = "[H]istory" },
        { "<leader>dgH",         function() Snacks.lazygit.log_file() end, desc = "[H]istory (Lazygit)" },
        { "<leader>dj",          M.buffer_jumps, desc = "[J]umps" },
        { "<leader>dp",          function() Snacks.picker.diagnostics({ filter = { buf = 0 } }) end, desc = "[P]roblems" },
        { "<leader>ds",          function() Snacks.picker.lsp_symbols() end, desc = "[S]ymbols" },
        { "<leader>dt",          function() Snacks.picker.lines() end, desc = "[T]ext" },
        { "<leader>du",          function() Snacks.picker.undo() end, desc = "[U]ndo" },

        -- Symbol
        { "<leader>sgb",          function() Snacks.git.blame_line() end, desc = "[B]lame" },
        { "<leader>sgh",          function() Snacks.picker.git_log_line() end, desc = "[H]istory" },
        { "<leader>si",           function() Snacks.picker.lsp_implementations() end, desc = "[I]mplementations" },
        { "<leader>sr",           function() Snacks.picker.lsp_references() end, desc = "[R]eferences" },
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

        -- Detect PR context on branch change (via mini.git)
        vim.api.nvim_create_autocmd("User", {
            pattern = "MiniGitUpdated",
            callback = function(data)
                local buf_data = vim.b[data.buf].minigit_summary
                if buf_data and buf_data.head_name then
                    if buf_data.head_name ~= last_head_name then
                        last_head_name = buf_data.head_name
                        vim.defer_fn(detect_gh_pr_context, 500)
                    end
                end
            end,
        })

        -- Detect PR context on directory change
        vim.api.nvim_create_autocmd("DirChanged", {
            callback = function()
                vim.defer_fn(detect_gh_pr_context, 500)
            end,
        })
    end,

    dependencies = {},

    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        statuscolumn = { enabled = true },
        debug = { enabled = true },
        toggle = { enabled = true },
        gitbrowse = { enabled = true },
        input = { enabled = false },
        scroll = { enabled = false },
        gh = {
            keys = {
                select = { "<cr>", "gh_actions", desc = "Select Action" },
                edit = { "e", "gh_edit", desc = "Edit" },
                comment = { "a", "gh_comment", desc = "Add Comment" },
                close = { "q", "gh_close", desc = "Close" },
                reopen = { "o", "gh_reopen", desc = "Reopen" },
            },
            wo = {
                -- I had to disable conceallevel because this has led to a bug
                conceallevel = 0,
            },
        },
        notifier = {
            enabled = true,
            margin = { top = 0, right = 0, bottom = 1, left = 1 },
            -- top_down = false,
            style = "compact",
        },
        picker = {
            -- ~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/config/defaults.lua
            ui_select = true,
            layouts = {
                gh_diff = {
                    layout = {
                        box = "horizontal",
                        width = 0,
                        min_width = 120,
                        height = 0,
                        {
                            box = "vertical",
                            border = true,
                            title = "{title} {live} {flags}",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                        },
                        { win = "preview", title = "{preview}", border = true, width = 0.66 },
                    },
                },
            },
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
                    filename_first = false, -- display filename before the file path
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
                        close = false,
                    },
                    hidden = true,
                    ignored = true,
                    actions = {
                        explorer_nodes_under_cursor = function(picker)
                            local Tree = require("snacks.explorer.tree")
                            local root = Tree:find(picker:dir())
                            local open = not root.open
                            Tree:walk(root, function(node)
                                if node.dir then
                                    node.open = open
                                end
                            end, { all = true })
                            require("snacks.explorer.actions").update(picker, { refresh = true })
                        end,
                    },
                    win = {
                        list = {
                            keys = {
                                ["]c"] = "explorer_git_next",
                                ["[c"] = "explorer_git_prev",
                                ["<c-t>"] = { "tab", mode = { "n", "i" } },
                                ["O"] = "explorer_nodes_under_cursor",
                                ["<C-w>m"] = "toggle_maximize",
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
                    sort = { fields = { "source_id" } },
                    filter = { cwd = true },
                },
                lsp_references = {
                    pattern = "!import !default",
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
                git_status = { preview = "git_status" },
                gh_diff = { layout = { preset = "gh_diff" } },
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
            configure = false, -- Theme managed by pick-theme via Black Atom adapter
            win = {
                backdrop = true,
                border = "solid",
                width = 0,
                height = 0,
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
        },
    },

    keys = M.keys(),
}
