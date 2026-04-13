--- Sources:
--- https://github.com/JulesNP/nvim/blob/main/lua/plugins/mini.lua
--- https://github.com/SylvanFranklin/.config/blob/main/nvim/init.lua

local M = {}

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
                local diagnostics = vim.diagnostic.status()
                local lsp_status = vim.lsp.status()
                local lsp_names = table.concat(
                    vim.iter(vim.lsp.get_clients())
                        :map(function(c)
                            return "[" .. c.name .. "]"
                        end)
                        :totable(),
                    " "
                )
                local lsp_section = table.concat(vim.list_slice({ lsp_status, lsp_names }, 1, 2), " ")

                -- Treesitter attachment indicator
                local ts_section = ""
                local ts_hl = "NonText"
                local bufnr = vim.api.nvim_get_current_buf()
                local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
                if ok and parser then
                    local lang = parser:lang() or ""
                    ts_section = " TS " .. lang
                    ts_hl = "String"
                else
                    ts_section = " --"
                    ts_hl = "NonText"
                end

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

                    "%=", -- End left alignment

                    { hl = "@type", strings = { lsp_section } },

                    { hl = ts_hl, strings = { ts_section } },

                    { hl = "DiagnosticError", strings = { diagnostics } },
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
    map({ "n", "v" }, "<leader>cg", function()
        MiniDiff.toggle_overlay(0)
    end, { desc = "[G]it (Hunk Preview)" })

    -- Buffer-level operations
    map("n", "<leader>dgr", function()
        MiniDiff.do_hunks(0, "reset")
    end, { desc = "[R]evert changes" })

    map("n", "<leader>dgs", function()
        MiniDiff.do_hunks(0, "apply")
    end, { desc = "[S]tage document" })
end

-- Session helpers (shared with snacks.lua picker)
M.get_session_name = require("lib.sessions").get_session_name
M.auto_create_session_dirs = require("lib.sessions").auto_create_session_dirs

-- https://github.com/nvim-mini/mini.nvim/issues/987
function M.sessions()
    require("mini.sessions").setup({
        -- Auto Load handled manually
        autowrite = true,
        directory = vim.fn.stdpath("config") .. "/sessions/",
        verbose = { read = true, write = true, delete = true },
        hooks = {
            pre = {
                -- Save current session before loading a different one
                -- (e.g., after branch switch in lazygit)
                read = function()
                    if vim.v.this_session ~= "" then
                        local current = vim.fn.fnamemodify(vim.v.this_session, ":t")
                        require("mini.sessions").write(current)
                    end
                end,
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

    vim.keymap.set("n", "<leader>ass", function()
        require("mini.sessions").write(M.get_session_name())
    end, { desc = "[S]ave" })

    vim.keymap.set("n", "<leader>asl", function()
        require("mini.sessions").select("read")
    end, { desc = "[L]ist" })

    vim.keymap.set("n", "<leader>asd", function()
        require("mini.sessions").select("delete", { force = true })
    end, { desc = "[D]elete" })

    vim.keymap.set("n", "<leader>asc", function()
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
        vim.api.nvim_create_autocmd({ "TermLeave" }, {
            callback = function(event)
                -- Skip if project_switch is in progress
                if vim.g._mini_session_switching then
                    return
                end

                -- Only proceed if it's a Snacks terminal (skip fzf-lua and others)
                local buf = event.buf or vim.api.nvim_get_current_buf()
                if vim.bo[buf].filetype ~= "snacks_terminal" then
                    return
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

        -- Auto-create session on VimLeave for specified directories
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

    -- Override global winborder for MiniFiles
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowOpen",
        callback = function(args)
            local config = vim.api.nvim_win_get_config(args.data.win_id)
            config.border = "single"
            vim.api.nvim_win_set_config(args.data.win_id, config)
        end,
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

    -- Symlink indicators via extmarks
    local ns_symlink = vim.api.nvim_create_namespace("mini_files_symlink")

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferUpdate",
        callback = function(args)
            local buf_id = args.data.buf_id
            vim.api.nvim_buf_clear_namespace(buf_id, ns_symlink, 0, -1)

            local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
            for i, _ in ipairs(lines) do
                local entry = MiniFiles.get_fs_entry(buf_id, i)
                if entry then
                    local stat = vim.uv.fs_lstat(entry.path)
                    if stat and stat.type == "link" then
                        local target = vim.uv.fs_readlink(entry.path)
                        local virt_text = target and ("→ " .. target) or "→"
                        vim.api.nvim_buf_set_extmark(buf_id, ns_symlink, i - 1, 0, {
                            virt_text = { { virt_text, "Comment" } },
                            virt_text_pos = "eol",
                        })
                    end
                end
            end
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
            -- Synchronize (save) changes
            map("n", "<C-s>", MiniFiles.synchronize, { buffer = bufid, desc = "Synchronize changes" })

            -- Path operations
            map("n", "gx", ui_open, { buffer = bufid, desc = "OS open" })

            -- Yank variants
            map("n", "gyp", yank_path, { buffer = bufid, desc = "Yank path" })
            map("n", "gyn", yank_filename, { buffer = bufid, desc = "Yank filename" })
            map("n", "gyr", yank_relative_path, { buffer = bufid, desc = "Yank relative path" })
            map("n", "gyh", yank_path_from_home, { buffer = bufid, desc = "Yank path from home" })
            map("n", "gya", yank_absolute_path, { buffer = bufid, desc = "Yank absolute path" })

            -- Bookmark navigation (g prefix)
            map("n", "g.", function() setBranch(vim.fn.getcwd()) end, { buffer = bufid, desc = "Current working directory" })
            map("n", "gh", function() setBranch("$HOME/") end, { buffer = bufid, desc = "Home", nowait = true })
            map("n", "gc", function() setBranch("$HOME/.config") end, { buffer = bufid, desc = "Config", nowait = true })
            map("n", "gr", function() setBranch("$HOME/repos") end, { buffer = bufid, desc = "Repos", nowait = true })
            map("n", "gl", function() setBranch("$HOME/.local/share/nvim/lazy") end, { buffer = bufid, desc = "Lazy Packages", nowait = true })

            -- Project bookmarks (g + number)
            map("n", "g0", function() setBranch("$HOME/repos/nikbrunner/dots") end, { buffer = bufid, desc = "nbr - dots" })
            map("n", "g1", function() setBranch("$HOME/repos/nikbrunner/notes") end, { buffer = bufid, desc = "nbr - notes" })
            map("n", "g2", function() setBranch("$HOME/repos/nikbrunner/scarth-johnson") end, { buffer = bufid, desc = "DCD - Notes" })
            map("n", "g4", function() setBranch("$HOME/repos/black-atom-industries/core") end, { buffer = bufid, desc = "Black Atom - core" })
            map("n", "g6", function() setBranch("$HOME/repos/black-atom-industries/livery") end, { buffer = bufid, desc = "Black Atom - radar.nvim" })
            map("n", "g5", function() setBranch("$HOME/repos/black-atom-industries/nvim") end, { buffer = bufid, desc = "Black Atom - nvim" })
            map("n", "g7", function() setBranch("$HOME/repos/nikbrunner/nbr.haus") end, { buffer = bufid, desc = "nikbrunner - nbr.haus" })
            map("n", "g8", function() setBranch("$HOME/repos/nikbrunner/koyo") end, { buffer = bufid, desc = "nikbrunner - koyo" })
            -- map("n", "g9", function() setBranch("$HOME/repos/dealercenter-digital/bc-desktop-client") end, { buffer = bufid, desc = "DCD - BC Desktop Client" })

            -- Picker in MiniFiles directory
            map("n", "<leader><leader>", function()
                local current_dir = vim.fn.fnamemodify(MiniFiles.get_fs_entry().path, ":h")
                MiniFiles.close()
                Snacks.picker.files({ cwd = current_dir })
            end, { buffer = bufid, desc = "Find files in current directory" })
            -- stylua: ignore end
        end,
    })

    -- Global keymaps
    local map = vim.keymap.set
    -- stylua: ignore start
    map("n", "-", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "[E]xplorer" })
    map("n", "<leader>we", function() MiniFiles.open(vim.fn.getcwd()) end, { desc = "[E]xplorer (cwd)" })
    -- map("n", "<leader>wf", function() M.git_files() end, { desc = "Git [F]iles (tree)" })
    -- stylua: ignore end
end

--- Open mini.files filtered to only git modified and untracked files.
--- Directories are shown only if they contain changed files underneath.
function M.git_files()
    local MiniFiles = require("mini.files")
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if vim.v.shell_error ~= 0 then
        vim.notify("Not in a git repository", vim.log.levels.ERROR)
        return
    end

    local changed = {}
    local parent_dirs = {}

    local function register(file)
        local abs = git_root .. "/" .. file
        changed[abs] = true
        local dir = vim.fn.fnamemodify(abs, ":h")
        while dir ~= git_root and dir ~= "/" do
            parent_dirs[dir] = true
            dir = vim.fn.fnamemodify(dir, ":h")
        end
        parent_dirs[git_root] = true
    end

    for _, f in ipairs(vim.fn.systemlist("git ls-files --modified")) do
        register(f)
    end
    for _, f in ipairs(vim.fn.systemlist("git ls-files --others --exclude-standard")) do
        register(f)
    end

    if vim.tbl_isempty(changed) then
        vim.notify("No modified or untracked files", vim.log.levels.INFO)
        return
    end

    MiniFiles.open(git_root, false, {
        content = {
            filter = function(fs_entry)
                if fs_entry.fs_type == "directory" then
                    return parent_dirs[fs_entry.path] or false
                end
                return changed[fs_entry.path] or false
            end,
        },
    })
end

-- ============================================================================
-- MiniClue Configuration
-- ============================================================================

function M.clue()
    local MiniClue = require("mini.clue")

    MiniClue.setup({
        triggers = {
            { mode = "c", keys = "<C-r>" },
            { mode = "i", keys = "<C-r>" },
            { mode = "i", keys = "<C-x>" },
            { mode = "n", keys = "<C-w>" },
            { mode = "n", keys = "'" },
            { mode = "n", keys = "<leader>" },
            { mode = "n", keys = "<localleader>" },
            { mode = "n", keys = "[" },
            { mode = "n", keys = "]" },
            { mode = "n", keys = "`" },
            { mode = "n", keys = "g" },
            { mode = "n", keys = "s" },
            { mode = "n", keys = "m" },
            { mode = "n", keys = "z" },
            { mode = "n", keys = "y" },
            { mode = "n", keys = "S" },
            { mode = "n", keys = '"' },
            { mode = "x", keys = "'" },
            { mode = "x", keys = "<leader>" },
            { mode = "x", keys = "`" },
            { mode = "x", keys = "g" },
            { mode = "x", keys = "z" },
            { mode = "x", keys = '"' },
        },
        clues = {
            MiniClue.gen_clues.builtin_completion(),
            MiniClue.gen_clues.g(),
            MiniClue.gen_clues.marks(),
            MiniClue.gen_clues.registers(),
            MiniClue.gen_clues.windows(),
            MiniClue.gen_clues.z(),

            -- App
            { mode = "n", keys = "<leader>a", desc = "[A]pp" },
            { mode = "n", keys = "<leader>al", desc = "[L]anguages" },
            { mode = "n", keys = "<leader>ah", desc = "[H]elp" },
            { mode = "n", keys = "<leader>ap", desc = "[P]lugins" },
            { mode = "n", keys = "<leader>ao", desc = "[O]ptions" },

            -- Workspace
            { mode = "n", keys = "<leader>w", desc = "[W]orkspace" },
            { mode = "n", keys = "<leader>wg", desc = "[G]it" },
            { mode = "n", keys = "<leader>wgi", desc = "[I]ssues" },
            { mode = "n", keys = "<leader>wgp", desc = "[P]ull Requests" },

            -- Document
            { mode = "n", keys = "<leader>d", desc = "[D]ocument" },
            { mode = "n", keys = "<leader>dy", desc = "[Y]ank" },
            { mode = "n", keys = "<leader>dg", desc = "[G]it" },

            -- Symbol
            { mode = "n", keys = "<leader>s", desc = "[S]ymbol" },
            { mode = "n", keys = "<leader>sl", desc = "[L]og" },
            { mode = "n", keys = "<leader>sc", desc = "[C]alls" },
            { mode = "n", keys = "<leader>sg", desc = "[G]it" },

            -- Other
            { mode = "n", keys = "<leader>c", desc = "[C]hange" },
            { mode = "n", keys = "<leader>as", desc = "[S]ession" },
            { mode = "n", keys = "<leader>h", desc = "[H]ttp" },
            { mode = "n", keys = "<leader>n", desc = "[N]otes" },
            { mode = "n", keys = "<leader>x", desc = "Trouble/Quickfix" },
        },
        window = {
            config = {
                width = math.floor(0.25 * vim.o.columns),
            },
            delay = 0,
        },
    })
end

---@type LazyPluginSpec
return {
    "nvim-mini/mini.nvim",
    version = false,
    lazy = false,
    config = function()
        -- M.hues()
        -- M.files()
        M.clue()
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
    end,
}
