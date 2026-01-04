--- Sources:
--- https://github.com/JulesNP/nvim/blob/main/lua/plugins/mini.lua
--- https://github.com/SylvanFranklin/.config/blob/main/nvim/init.lua

local M = {}

function M.extra()
    require("mini.extra").setup()
end

function M.visits()
    require("mini.visits").setup()
end

function M.ai()
    require("mini.ai").setup()
end

function M.statusline()
    require("mini.statusline").setup({
        content = {
            active = function()
                local m = require("mini.statusline")
                local fnamemodify = vim.fn.fnamemodify

                local project_name = function()
                    local current_project_folder = fnamemodify(vim.fn.getcwd(), ":t")
                    local parent_project_folder = fnamemodify(vim.fn.getcwd(), ":h:t")
                    return parent_project_folder .. "/" .. current_project_folder
                end

                local mode, mode_hl = m.section_mode({ trunc_width = 120 })
                local git = m.section_git({ trunc_width = 75 })
                local diagnostics = m.section_diagnostics({ trunc_width = 75 })

                return m.combine_groups({
                    { hl = mode_hl, strings = { mode } },
                    {
                        hl = "@function",
                        strings = (m.is_truncated(100) and {} or { project_name() }),
                    },
                    {
                        hl = "@variable.member",
                        strings = { git },
                    },

                    "%<", -- Mark general truncate point

                    { hl = "DiagnosticError", strings = { diagnostics } },

                    "%=", -- End left alignment
                })
            end,
        },
    })
end

function M.icons()
    require("mini.icons").setup({
        file = {
            [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
            [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
            [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
            ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
            ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
            ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
            ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
        },
    })
end

function M.surround()
    require("mini.surround").setup({
        mappings = {
            add = "Sa", -- Add surrounding in Normal and Visual modes
            delete = "Sd", -- Delete surrounding
            find = "Sf", -- Find surrounding (to the right)
            find_left = "SF", -- Find surrounding (to the left)
            highlight = "Sh", -- Highlight surrounding
            replace = "Sr", -- Replace surrounding
            update_n_lines = "Sn", -- Update `n_lines`
        },
    })
end

function M.test()
    require("mini.test").setup()
end

function M.diff()
    local MiniDiff = require("mini.diff")

    MiniDiff.setup({
        view = {
            style = "sign",
            signs = {
                add = "▎",
                change = "▎",
                delete = "▎",
            },
        },
        mappings = {
            -- Disable defaults, using custom keymaps below
            apply = "",
            reset = "",
            textobject = "gh", -- Keep textobject for use with custom mappings
            goto_first = "",
            goto_prev = "",
            goto_next = "",
            goto_last = "",
        },
    })

    local map = vim.keymap.set

    -- Navigation with centering (matching gitsigns [c / ]c)
    map("n", "]c", function()
        MiniDiff.goto_hunk("next")
        vim.cmd("norm zz")
    end, { desc = "Next Hunk" })

    map("n", "[c", function()
        MiniDiff.goto_hunk("prev")
        vim.cmd("norm zz")
    end, { desc = "Prev Hunk" })

    -- Hunk operations - normal mode uses operator + textobject
    map("n", "<leader>cs", function()
        return MiniDiff.operator("apply") .. "gh"
    end, { expr = true, remap = true, desc = "Stage Hunk" })

    map("n", "<leader>cr", function()
        return MiniDiff.operator("reset") .. "gh"
    end, { expr = true, remap = true, desc = "Reset Hunk" })

    -- Hunk operations - visual mode uses do_hunks with selection
    map("v", "<leader>cs", function()
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")
        MiniDiff.do_hunks(0, "apply", { line_start = start_line, line_end = end_line })
    end, { desc = "Stage Hunk" })

    map("v", "<leader>cr", function()
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")
        MiniDiff.do_hunks(0, "reset", { line_start = start_line, line_end = end_line })
    end, { desc = "Reset Hunk" })

    -- Preview/overlay toggle
    map({ "n", "v" }, "<leader>cv", function()
        MiniDiff.toggle_overlay(0)
    end, { desc = "Version (Hunk Preview)" })

    -- Buffer-level operations
    map("n", "<leader>dvr", function()
        MiniDiff.do_hunks(0, "reset")
    end, { desc = "[R]evert changes" })

    map("n", "<leader>dvs", function()
        MiniDiff.do_hunks(0, "apply")
    end, { desc = "[S]tage document" })
end

function M.get_session_name()
    local cwd = vim.fn.getcwd()
    local home = vim.fn.expand("~")

    -- Strip home directory to make portable across macOS/Linux
    local name = cwd
    if vim.startswith(cwd, home) then
        name = string.sub(cwd, #home + 2) -- +2 to skip the trailing slash
    end

    -- Replace remaining slashes with underscores
    name = string.gsub(name, "/", "_")

    local branch = vim.trim(vim.fn.system("git branch --show-current"))
    branch = string.gsub(branch, "/", "_")

    if vim.v.shell_error == 0 and branch ~= "" then
        return name .. "_" .. branch
    else
        return name
    end
end

-- Directories that should auto-create sessions
M.auto_create_session_dirs = {
    vim.fn.expand("~/repos/"),
}

-- https://github.com/nvim-mini/mini.nvim/issues/987
function M.sessions()
    require("mini.sessions").setup({
        -- Auto Load handled manually
        autowrite = true,
        directory = vim.fn.stdpath("config") .. "/sessions/",
        verbose = { read = true, write = true, delete = true },
        hooks = {
            pre = {
                write = function()
                    -- Delete ephemeral and non-visible buffers before writing session
                    vim.iter(vim.api.nvim_list_bufs())
                        :filter(function(bufnr)
                            return vim.api.nvim_buf_is_valid(bufnr)
                        end)
                        :filter(function(bufnr)
                            local buftype = vim.bo[bufnr].buftype
                            local bufpath = vim.api.nvim_buf_get_name(bufnr)

                            -- Delete if special buffer type (but preserve help files)
                            if buftype ~= "" and buftype ~= "help" then
                                return true
                            end

                            -- Delete if file doesn't exist on disk (but not empty/new buffers)
                            if bufpath ~= "" and vim.uv.fs_stat(bufpath) == nil then
                                return true
                            end

                            -- Delete if buffer is not in any tabpage's window list
                            local buffer_in_tabpage = false
                            for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
                                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
                                    if vim.api.nvim_win_get_buf(win) == bufnr then
                                        buffer_in_tabpage = true
                                        break
                                    end
                                end
                                if buffer_in_tabpage then
                                    break
                                end
                            end

                            if not buffer_in_tabpage then
                                return true
                            end

                            return false
                        end)
                        :each(function(bufnr)
                            vim.api.nvim_buf_delete(bufnr, { force = true })
                        end)
                end,
            },
        },
    })

    vim.keymap.set("n", "<leader>ss", function()
        require("mini.sessions").write(M.get_session_name())
    end, { desc = "[S]ave" })

    vim.keymap.set("n", "<leader>sl", function()
        require("mini.sessions").select("read")
    end, { desc = "[L]ist" })

    vim.keymap.set("n", "<leader>sd", function()
        require("mini.sessions").select("delete", { force = true })
    end, { desc = "[D]elete" })

    vim.keymap.set("n", "<leader>sc", function()
        local sessions_dir = vim.fn.stdpath("config") .. "/sessions/"
        local two_days_ago = os.time() - (2 * 24 * 60 * 60) -- 2 days in seconds
        local deleted_count = 0

        -- Scan sessions directory
        local handle = vim.loop.fs_scandir(sessions_dir)
        if handle then
            while true do
                local name, type = vim.loop.fs_scandir_next(handle)
                if not name then
                    break
                end

                if type == "file" then
                    local filepath = sessions_dir .. name
                    local stat = vim.loop.fs_stat(filepath)

                    if stat and stat.mtime.sec < two_days_ago then
                        vim.loop.fs_unlink(filepath)
                        deleted_count = deleted_count + 1
                    end
                end
            end
        end

        if deleted_count > 0 then
            vim.notify(string.format("Cleaned up %d old session(s)", deleted_count), vim.log.levels.INFO)
        else
            vim.notify("No old sessions to clean up", vim.log.levels.INFO)
        end
    end, { desc = "[C]lean old" })

    -- no args, or if the only arg is the current directory `nvim .`
    if vim.fn.argc(-1) == 0 or (vim.fn.argc(-1) == 1 and vim.fn.argv(0) == ".") then
        -- Auto-load existing session on VimEnter event
        vim.api.nvim_create_autocmd({ "VimEnter" }, {
            nested = true,
            callback = function()
                local MS = require("mini.sessions")
                local session_name = M.get_session_name()

                if MS.detected[session_name] then
                    MS.read(session_name)
                end
            end,
        })

        -- Auto-switch sessions on TermLeave event (like closing the lazygit terminal)
        vim.api.nvim_create_autocmd({ "TermLeave", "VimResume" }, {
            callback = function(event)
                -- For TermLeave events, only proceed if it's a Snacks terminal
                if event.event == "TermLeave" then
                    local buf = event.buf or vim.api.nvim_get_current_buf()
                    local is_snacks_terminal = vim.bo[buf].filetype == "snacks_terminal"

                    if not is_snacks_terminal then
                        return -- Skip fzf-lua and other non-Snacks terminals
                    end
                end

                -- Don't load session if we're already in a session load
                if vim.g.SessionLoad == 1 then
                    return
                end

                local MS = require("mini.sessions")
                local session_name = M.get_session_name()

                -- Load existing session or create new one
                if MS.detected[session_name] then
                    MS.read(session_name)
                end
            end,
        })

        -- Auto-create session on VimEnter for specified directories
        vim.api.nvim_create_autocmd({ "VimLeave" }, {
            callback = function()
                local MS = require("mini.sessions")
                local session_name = M.get_session_name()
                local cwd = vim.fn.getcwd()

                -- Check if cwd is in any of the auto_create_session_dirs
                local should_auto_create = false
                for _, dir in ipairs(M.auto_create_session_dirs) do
                    if vim.startswith(cwd, dir) then
                        should_auto_create = true
                        break
                    end
                end

                -- Only create if in specified dir and session doesn't exist
                if should_auto_create and not MS.detected[session_name] then
                    MS.write(session_name)
                end
            end,
        })
    end
end

function M.hues()
    require("mini.hues").setup({
        background = "#11262d",
        foreground = "#c0c8cc",
        plugins = {
            default = true,
            ["echasnovski/mini.nvim"] = true,
        },
    })
end

function M.git()
    require("mini.git").setup()

    -- Add last commit message to statusline summary
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniGitUpdated",
        callback = function(event)
            local bufnr = event.buf
            local git_data = vim.b[bufnr].minigit_summary

            if git_data and git_data.root and git_data.head then
                -- Fetch last commit subject (first line of commit message)
                vim.system({ "git", "log", "-1", "--pretty=%s" }, {
                    cwd = git_data.root,
                }, function(result)
                    if result.code == 0 and result.stdout then
                        local commit_msg = vim.trim(result.stdout)
                        local branch = git_data.head_name or "HEAD"
                        local status = git_data.status or ""

                        -- Format: branch (status) • last commit message
                        local summary_parts = { branch }
                        if status ~= "" then
                            table.insert(summary_parts, string.format("(%s)", status))
                        end
                        if commit_msg ~= "" then
                            table.insert(summary_parts, "• " .. commit_msg)
                        end

                        vim.b[bufnr].minigit_summary_string = table.concat(summary_parts, " ")
                    end
                end)
            end
        end,
    })
end

function M.snippets()
    local gen_loader = require("mini.snippets").gen_loader

    require("mini.snippets").setup({
        snippets = {
            -- Load global snippets (date/time available everywhere)
            gen_loader.from_file("~/.config/nvim/snippets/global.json"),

            -- Load language-specific snippets based on current filetype
            -- Looks for snippets/{lang}.json in runtimepath
            gen_loader.from_lang(),
        },
        mappings = {
            expand = "<C-j>",
            jump_next = "<C-l>",
            jump_prev = "<C-h>",
        },
    })
end

-- ============================================================================
-- MiniPick Configuration
-- ============================================================================

-- Window configuration for picker
M.win_config = {
    -- Small picker in bottom-left corner of editor
    left_corner = function()
        return {
            relative = "editor",
            anchor = "SW",
            height = math.floor(0.25 * vim.o.lines),
            width = math.floor(0.4 * vim.o.columns),
            border = "solid",
            row = vim.o.lines - 1,
            col = 0,
        }
    end,

    -- Picker at bottom of current buffer window
    buf_bottom = function()
        local window_height = vim.api.nvim_win_get_height(0)
        local height = math.floor(0.25 * window_height)

        local window_width = vim.api.nvim_win_get_width(0)
        local border_width = 2

        local width
        if window_width >= 165 then
            width = math.floor(0.5 * vim.o.columns)
        else
            width = window_width - border_width
        end

        return {
            relative = "win",
            height = height,
            border = "solid",
            width = width,
            row = math.floor(window_height - 1),
            col = 0,
        }
    end,
}

--- Smart file picker with intelligent prioritization
---
--- Combines multiple sources (alternative file, recent files, visited paths, all files)
--- into a single picker with weighted scoring for better file navigation.
---
--- Priority order (lower score = higher priority):
--- 1. Alternative file (#) - heavily prioritized for quick switching
--- 2. Recent files (oldfiles) - files recently opened in cwd
--- 3. Visited paths (mini.visits) - frequently accessed files
--- 4. All other files - general fallback
---
--- Current file is always ranked last to avoid accidental re-selection.
function M.smart_picker()
    local MiniPick = require("mini.pick")
    local MiniFuzzy = require("mini.fuzzy")
    local MiniVisits = require("mini.visits")

    local visit_paths = MiniVisits.list_paths()
    local current_file = vim.fn.expand("%")
    local cwd = vim.fn.getcwd()

    -- Get alternative file for priority boost
    local alt_file = vim.fn.expand("#")

    -- Get oldfiles scoped to current working directory
    local oldfiles = {}
    for _, file in ipairs(vim.v.oldfiles) do
        local abs_path = vim.fn.fnamemodify(file, ":p")
        if vim.startswith(abs_path, cwd) then
            table.insert(oldfiles, vim.fn.fnamemodify(file, ":."))
        end
    end

    MiniPick.builtin.files(nil, {
        source = {
            match = function(stritems, indices, query)
                -- Concatenate prompt to a single string
                local prompt = vim.pesc(table.concat(query))

                -- If ignorecase is on and there are no uppercase letters in prompt,
                -- convert paths to lowercase for matching purposes
                local convert_path = function(str)
                    return str
                end
                if vim.o.ignorecase and string.find(prompt, "%u") == nil then
                    convert_path = function(str)
                        return string.lower(str)
                    end
                end

                local current_file_cased = convert_path(current_file)
                local alt_file_rel = alt_file ~= "" and vim.fn.fnamemodify(alt_file, ":.") or nil
                local alt_file_cased = alt_file_rel and convert_path(alt_file_rel) or nil

                -- Create lookup tables for priority files
                local oldfiles_lookup = {}
                for index, file_path in ipairs(oldfiles) do
                    oldfiles_lookup[convert_path(file_path)] = index
                end

                local visits_lookup = {}
                for index, path in ipairs(visit_paths) do
                    local key = vim.fn.fnamemodify(path, ":.")
                    visits_lookup[convert_path(key)] = index
                end

                local result = {}
                for _, index in ipairs(indices) do
                    local path = stritems[index]
                    local path_cased = convert_path(path)
                    local match_score = prompt == "" and 0 or MiniFuzzy.match(prompt, path).score

                    if match_score >= 0 then
                        local score

                        -- Current file gets ranked last
                        if path_cased == current_file_cased then
                            score = 999999
                        -- Alt file gets highest priority
                        elseif alt_file_cased and path_cased == alt_file_cased then
                            score = match_score - 10000
                        -- Oldfiles get second priority
                        elseif oldfiles_lookup[path_cased] then
                            score = match_score - 1000 + oldfiles_lookup[path_cased]
                        -- Visit paths get third priority
                        elseif visits_lookup[path_cased] then
                            score = match_score + visits_lookup[path_cased]
                        -- Everything else
                        else
                            score = match_score + 100000
                        end

                        table.insert(result, {
                            index = index,
                            score = score,
                        })
                    end
                end

                table.sort(result, function(a, b)
                    return a.score < b.score
                end)

                return vim.tbl_map(function(val)
                    return val.index
                end, result)
            end,
        },
    })
end

function M.pick()
    local MiniPick = require("mini.pick")
    local MiniExtra = require("mini.extra")

    MiniPick.setup({
        mappings = {
            scroll_down = "<C-d>",
            scroll_left = "<C-h>",
            scroll_right = "<C-l>",
            scroll_up = "<C-u>",
        },
        window = {
            config = M.win_config.buf_bottom,
            prompt_caret = "█",
            prompt_prefix = "  ",
        },
    })

    MiniPick.registry.frecency = M.smart_picker

    -- Use MiniPick for vim.ui.select
    vim.ui.select = MiniPick.ui_select

    local map = vim.keymap.set

    -- stylua: ignore start
    -- General
    map("n", "<leader><leader>",    MiniPick.registry.frecency, { desc = "Pick file" })
    map("n", "<leader>.",           function() MiniPick.builtin.resume() end, { desc = "Resume Picker" })
    map("n", "<leader>;",           function() MiniExtra.pickers.commands() end, { desc = "Commands" })
    map("n", "<leader>:",           function() MiniExtra.pickers.history({ scope = ":" }) end, { desc = "Command History" })
    map("n", "<leader>'",           function() MiniExtra.pickers.registers() end, { desc = "Registers" })

    -- App
    map("n", "<leader>aa",          function() MiniExtra.pickers.commands() end, { desc = "[A]ctions" })
    map("n", "<leader>ar",          function() MiniExtra.pickers.oldfiles() end, { desc = "[R]ecent Documents (Anywhere)" })
    map("n", "<leader>at",          function() MiniExtra.pickers.colorschemes() end, { desc = "[T]hemes" })
    map("n", "<leader>ahh",         function() MiniExtra.pickers.hl_groups() end, { desc = "[H]ightlights" })
    map("n", "<leader>ahk",         function() MiniExtra.pickers.keymaps() end, { desc = "[K]eymaps" })
    map("n", "<leader>aht",         function() MiniPick.builtin.help() end, { desc = "[T]ags" })
    map("n", "<leader>as",          function() MiniPick.builtin.files(nil, { source = { cwd = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots" }}) end, { desc = "[S]ettings (Dots)" })

    -- Workspace
    map("n", "<leader>wd",          MiniPick.registry.frecency, { desc = "[D]ocument" })
    map("n", "<leader>wr",          function() MiniExtra.pickers.oldfiles({ current_dir = true }) end, { desc = "[R]ecent Documents" })
    map("n", "<leader>wt",          function() MiniPick.builtin.grep_live() end, { desc = "[T]ext" })
    map("n", "<leader>ww",          function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "[W]ord" })
    map("n", "<leader>wm",          function() MiniExtra.pickers.git_files({ scope = "modified" }) end, { desc = "[M]odified Documents" })
    map("n", "<leader>wc",          function() MiniExtra.pickers.git_hunks() end, { desc = "[C]hanges" })
    map("n", "<leader>ws",          function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "[S]ymbols" })
    map("n", "<leader>wvb",         function() MiniExtra.pickers.git_branches() end, { desc = "[B]ranches" })
    map("n", "<leader>wvh",         function() MiniExtra.pickers.git_commits() end, { desc = "[H]istory" })
    map("n", "<leader>wj",          function() MiniExtra.pickers.list({ scope = "jump" }) end, { desc = "[J]umps" })
    map("n", "<leader>wp",          function() MiniExtra.pickers.diagnostic() end, { desc = "[P]roblems" })

    -- Document
    map("n", "<leader>dt",          function() MiniExtra.pickers.buf_lines({ scope = "current" }) end, { desc = "[T]ext" })
    map("n", "<leader>ds",          function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "[S]ymbols" })
    map("n", "<leader>dp",          function() MiniExtra.pickers.diagnostic({ scope = "current" }) end, { desc = "[P]roblems" })

    -- Symbol
    map("n", "sr",                  function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "[R]eferences" })
    map("n", "si",                  function() MiniExtra.pickers.lsp({ scope = "implementation" }) end, { desc = "[I]mplementations" })
    -- stylua: ignore end
end

-- ============================================================================
-- MiniFiles Configuration
-- ============================================================================

function M.files()
    local MiniFiles = require("mini.files")

    MiniFiles.setup({
        mappings = {
            show_help = "g?",
            close = "q",
            go_in = "<CR>",
            go_in_plus = "<CR>",
            go_out = "-",
            go_out_plus = "_",
            mark_goto = "'",
            mark_set = "m",
            reset = "<BS>",
            reveal_cwd = "@",
            synchronize = "=",
            trim_left = "<",
            trim_right = ">",
        },
        options = {
            use_as_default_explorer = false,
        },
        windows = {
            max_number = 3,
            preview = true,
            width_focus = 50,
            width_nofocus = 25,
            width_preview = 65,
        },
    })

    -- Split keymaps
    local map_split = function(buf_id, lhs, direction)
        local rhs = function()
            local cur_target = MiniFiles.get_explorer_state().target_window
            local new_target = vim.api.nvim_win_call(cur_target, function()
                vim.cmd(direction .. " split")
                return vim.api.nvim_get_current_win()
            end)
            MiniFiles.set_target_window(new_target)
            MiniFiles.go_in({ close_on_file = true })
        end
        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local buf_id = args.data.buf_id
            map_split(buf_id, "<C-v>", "belowright vertical")
            map_split(buf_id, "<C-s>", "belowright horizontal")
            map_split(buf_id, "<C-t>", "tab")
        end,
    })

    -- LSP rename integration with Snacks
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
            Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
    })

    -- Path operations
    local yank_path = function()
        local path = (MiniFiles.get_fs_entry() or {}).path
        if path == nil then
            return vim.notify("Cursor is not on valid entry")
        end
        vim.fn.setreg(vim.v.register, path)
        vim.notify("Copied: " .. path, vim.log.levels.INFO)
    end

    local ui_open = function()
        local entry = MiniFiles.get_fs_entry()
        if entry then
            vim.ui.open(entry.path)
        end
    end

    -- Yank path variants
    local yank_filename = function()
        local entry = MiniFiles.get_fs_entry()
        if entry then
            local name = vim.fn.fnamemodify(entry.path, ":t")
            vim.fn.setreg("+", name)
            vim.notify("Copied filename: " .. name, vim.log.levels.INFO)
        end
    end

    local yank_relative_path = function()
        local entry = MiniFiles.get_fs_entry()
        if entry then
            local relative_path = vim.fn.fnamemodify(entry.path, ":~:.")
            vim.fn.setreg("+", relative_path)
            vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
        end
    end

    local yank_path_from_home = function()
        local entry = MiniFiles.get_fs_entry()
        if entry then
            local path_from_home = vim.fn.fnamemodify(entry.path, ":~")
            vim.fn.setreg("+", path_from_home)
            vim.notify("Copied path from home: " .. path_from_home, vim.log.levels.INFO)
        end
    end

    local yank_absolute_path = function()
        local entry = MiniFiles.get_fs_entry()
        if entry then
            vim.fn.setreg("+", entry.path)
            vim.notify("Copied absolute path: " .. entry.path, vim.log.levels.INFO)
        end
    end

    -- Buffer-local keymaps for MiniFiles
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local bufid = args.data.buf_id
            local map = vim.keymap.set

            local function setBranch(path)
                MiniFiles.set_branch({ vim.fn.expand(path) })
            end

            -- stylua: ignore start
            -- Path operations
            map("n", "gx", ui_open, { buffer = bufid, desc = "OS open" })
            map("n", "gy", yank_path, { buffer = bufid, desc = "Yank path" })

            -- Yank path variants
            map("n", "<leader>yn", yank_filename, { buffer = bufid, desc = "Yank filename" })
            map("n", "<leader>yr", yank_relative_path, { buffer = bufid, desc = "Yank relative path" })
            map("n", "<leader>yh", yank_path_from_home, { buffer = bufid, desc = "Yank path from home" })
            map("n", "<leader>ya", yank_absolute_path, { buffer = bufid, desc = "Yank absolute path" })

            -- Bookmark navigation (g prefix)
            map("n", "g.", function() setBranch(vim.fn.getcwd()) end, { buffer = bufid, desc = "Current working directory" })
            map("n", "gh", function() setBranch("$HOME/") end, { buffer = bufid, desc = "Home", nowait = true })
            map("n", "gc", function() setBranch("$HOME/.config") end, { buffer = bufid, desc = "Config", nowait = true })
            map("n", "gr", function() setBranch("$HOME/repos") end, { buffer = bufid, desc = "Repos", nowait = true })
            map("n", "gl", function() setBranch("$HOME/.local/share/nvim/lazy") end, { buffer = bufid, desc = "Lazy Packages", nowait = true })

            -- Project bookmarks (g + number)
            map("n", "g0", function() setBranch("$HOME/repos/nikbrunner/dots") end, { buffer = bufid, desc = "nbr - dots" })
            map("n", "g1", function() setBranch("$HOME/repos/nikbrunner/notes") end, { buffer = bufid, desc = "nbr - notes" })
            map("n", "g2", function() setBranch("$HOME/repos/nikbrunner/dcd-notes") end, { buffer = bufid, desc = "DCD - Notes" })
            map("n", "g4", function() setBranch("$HOME/repos/black-atom-industries/core") end, { buffer = bufid, desc = "Black Atom - core" })
            map("n", "g5", function() setBranch("$HOME/repos/black-atom-industries/nvim") end, { buffer = bufid, desc = "Black Atom - nvim" })
            map("n", "g6", function() setBranch("$HOME/repos/black-atom-industries/radar.nvim") end, { buffer = bufid, desc = "Black Atom - radar.nvim" })
            map("n", "g7", function() setBranch("$HOME/repos/nikbrunner/nbr.haus") end, { buffer = bufid, desc = "nikbrunner - nbr.haus" })
            map("n", "g8", function() setBranch("$HOME/repos/nikbrunner/koyo") end, { buffer = bufid, desc = "nikbrunner - koyo" })
            map("n", "g9", function() setBranch("$HOME/repos/dealercenter-digital/bc-desktop-client") end, { buffer = bufid, desc = "DCD - BC Desktop Client" })

            -- Picker in MiniFiles directory
            map("n", "<leader><leader>", function()
                local current_dir = vim.fn.fnamemodify(MiniFiles.get_fs_entry().path, ":h")
                MiniFiles.close()
                require("mini.pick").builtin.files(nil, { source = { cwd = current_dir }})
            end, { buffer = bufid, desc = "Find files in current directory" })
            -- stylua: ignore end
        end,
    })

    -- Global keymaps
    local map = vim.keymap.set
    -- stylua: ignore start
    map("n", "-", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "[E]xplorer" })
    map("n", "_", function() MiniFiles.open(vim.fn.getcwd()) end, { desc = "[E]xplorer (cwd)" })
    map("n", "<leader>we", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "[E]xplorer" })
    -- stylua: ignore end
end

---@type LazyPluginSpec
return {
    "nvim-mini/mini.nvim",
    version = false,
    lazy = false,
    config = function()
        M.visits()
        M.extra()
        M.pick()
        M.files()
        M.git()
        M.diff()
        M.ai()
        M.statusline()
        M.icons()
        M.surround()
        M.test()
        M.sessions()
        M.snippets()

        -- Start LSP server to show snippets in completion
        require("mini.snippets").start_lsp_server()

        -- M.hues()
    end,
}
