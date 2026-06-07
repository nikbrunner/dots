--- Sources:
--- https://github.com/JulesNP/nvim/blob/main/lua/plugins/mini.lua
--- https://github.com/SylvanFranklin/.config/blob/main/nvim/init.lua
--- https://github.com/nvim-mini/mini.nvim/issues/987

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

                ---@diagnostic disable-next-line: unused-local
                local _mode, mode_hl = m.section_mode({ trunc_width = 120 })
                local git = m.section_git({ trunc_width = 75 })

                return m.combine_groups({
                    { hl = mode_hl, strings = { "  VIN" } },
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

                    {
                        hl = "@variable.parameter",
                        strings = { "󰓩  " .. vim.fn.tabpagenr() .. ":" .. vim.fn.tabpagenr("$") .. "" },
                    },
                })
            end,
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

function M.sessions()
    require("mini.sessions").setup({
        autowrite = true,
        directory = vim.fn.stdpath("config") .. "/sessions/",
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
                    -- Close codediff tabpages so their scratch buffers don't end up in the session
                    local ok, codediff = pcall(require, "codediff.ui.lifecycle.session")
                    if ok and codediff.get_active_diffs then
                        local active_diffs = codediff.get_active_diffs()
                        for tabpage, _ in pairs(active_diffs) do
                            if vim.api.nvim_tabpage_is_valid(tabpage) then
                                vim.api.nvim_set_current_tabpage(tabpage)
                                vim.cmd("tabclose")
                            end
                        end
                    end

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
        vim.system({ "dots", "clean-sessions", "--raw" }, {}, function(result)
            vim.schedule(function()
                local output = vim.trim(result.stdout or "")
                if output == "" or result.code ~= 0 then
                    vim.notify("No sessions to clean up", vim.log.levels.INFO)
                    return
                end

                local orphans, old = {}, {}
                for _, line in ipairs(vim.split(output, "\n")) do
                    local name = line:match("^ORPHAN:(.+)$")
                    if name then
                        table.insert(orphans, name)
                    else
                        name = line:match("^OLD:(.+)$")
                        if name then
                            table.insert(old, name)
                        end
                    end
                end

                local parts = {}
                if #orphans > 0 then
                    table.insert(parts, string.format("%d orphaned: %s", #orphans, table.concat(orphans, ", ")))
                end
                if #old > 0 then
                    table.insert(parts, string.format("%d old (>2d): %s", #old, table.concat(old, ", ")))
                end

                if #parts > 0 then
                    vim.notify(string.format("Cleaned %s", table.concat(parts, ", ")), vim.log.levels.INFO)
                else
                    vim.notify("No sessions to clean up", vim.log.levels.INFO)
                end
            end)
        end)
    end, { desc = "[C]lean" })

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
                    -- Skip session creation inside git worktrees (e.g., .claude/worktrees/)
                    if cwd:find("worktrees", 1, true) then
                        return
                    end
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
            -- Lua version supports dynamic offsets (tomorrow, yesterday, etc.)
            gen_loader.from_file("~/.config/nvim/snippets/global.lua"),

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

function M.files()
    local MiniFiles = require("mini.files")
    local invoking_win_pos = { 0, 0 }
    local preview_enabled = false

    MiniFiles.setup({
        content = {
            prefix = function() end,
        },
        mappings = {
            show_help = "g?",
            close = "q",
            go_in = "<CR>",
            go_in_plus = "<CR>",
            go_out = "-",
            go_out_plus = "-",
            mark_goto = "'",
            mark_set = "m",
            reset = "<BS>",
            reveal_cwd = "~",
            synchronize = "=",
            trim_left = "<",
            trim_right = ">",
        },
        options = {
            use_as_default_explorer = false,
            -- Workaround for mini.nvim bug on Neovim >= 0.11: `H.lsp_fs_hook_client`
            -- in mini/files.lua (~L2866) calls `is_scheme(uri, scheme)`, which does
            -- `scheme == nil` and `scheme .. ':'`. In Neovim 0.12+ `FileOperationFilter.scheme`
            -- is decoded as `vim.NIL` (a userdata) instead of Lua `nil`, so both the
            -- nil-check fails and the concatenation crashes on `=` (synchronize).
            -- The same hook also emits the `client.supports_method is deprecated`
            -- warning via `vim.lsp.get_clients({ method = ... })`. Setting
            -- `lsp_timeout = 0` early-returns from `H.lsp_fs_hook` and avoids both.
            -- TODO: Remove once upstream lands a `vim.NIL`-aware `is_scheme` fix.
            -- Trade-off: no LSP-driven import rewrites on file ops inside the explorer.
            -- Sources:
            --   https://github.com/nvim-mini/mini.nvim/pull/2340   -- introduced the buggy code
            --   https://github.com/nvim-mini/mini.nvim/issues/2215 -- parent feature request
            lsp_timeout = 0,
        },
        windows = {
            max_number = 3,
            preview = false,
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
            config.border = "solid"
            vim.api.nvim_win_set_config(args.data.win_id, config)
        end,
    })

    -- Anchor explorer to the split it was invoked from
    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowUpdate",
        callback = function(args)
            local config = vim.api.nvim_win_get_config(args.data.win_id)
            config.row = config.row + invoking_win_pos[1]
            config.col = config.col + invoking_win_pos[2]
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

            -- Route :w to MF.synchronize via BufWriteCmd (requires buftype=acwrite)
            vim.bo[bufid].buftype = "acwrite"
            vim.api.nvim_create_autocmd("BufWriteCmd", {
                buffer = bufid,
                callback = function()
                    MF.synchronize()
                end,
            })

            -- stylua: ignore start
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

            -- Toggle preview
            map("n", "<C-p>", function()
                preview_enabled = not preview_enabled
                MiniFiles.refresh({ windows = { preview = preview_enabled } })
            end, { buffer = bufid, desc = "Toggle preview" })

            -- stylua: ignore end
        end,
    })

    -- stylua: ignore start
    vim.keymap.set("n", "<leader>we", function()
        invoking_win_pos = vim.api.nvim_win_get_position(0)
        MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end, { desc = "[E]xplorer" })

    vim.keymap.set("n", "<leader>wE", function()
        invoking_win_pos = vim.api.nvim_win_get_position(0)
        MiniFiles.open(vim.fn.getcwd())
    end, { desc = "[E]xplorer" })

    -- stylua: ignore end
end

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
            { mode = "n", keys = "Z" },
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

            -- Z mappings (ZZ, ZQ, ZR)
            { mode = "n", keys = "ZZ", desc = "Write & quit" },
            { mode = "n", keys = "ZQ", desc = "Quit without saving" },
            { mode = "n", keys = "ZR", desc = "Restart" },

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

function M.completion()
    local MiniCompletion = require("mini.completion")

    -- Capture the canonical LSP kind names BEFORE the 4-char remap below
    -- mutates the table. `item.kind` from the LSP response is the numeric
    -- enum value (6 = Class, 3 = Function, ...); looking it up here gives
    -- the canonical name so `LspKind*` highlight groups resolve correctly.
    local lsp_kind_names = vim.deepcopy(vim.lsp.protocol.CompletionItemKind)

    local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
    local process_items = function(items, base)
        -- Pre-set `kind_hlgroup` per item so the popup uses the active
        -- black-atom theme's LspKind* highlight groups. `default_process_items`
        -- preserves any value already on the item (see `or` in mini.completion),
        -- so this overrides the mini.icons lsp category that would otherwise be
        -- applied.
        for _, item in ipairs(items) do
            local kind_name = lsp_kind_names[item.kind]
            if kind_name then
                item.kind_hlgroup = "LspKind" .. kind_name
            end
        end
        return MiniCompletion.default_process_items(items, base, process_items_opts)
    end

    for _, item in ipairs(vim.fn.complete_info({ "items" }).items) do
        print(item.word, "->", item.kind, "(hl:", item.kind_hlgroup, ")")
    end
    local on_attach = function(args)
        vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
    end
    vim.api.nvim_create_autocmd("LspAttach", { callback = on_attach })

    -- Remap CompletionItemKind to 4-char labels for the native pum kind column
    local item_kinds = vim.lsp.protocol.CompletionItemKind
    for i, name in ipairs(item_kinds) do
        item_kinds[i] = name:sub(1, 4):upper()
    end

    MiniCompletion.setup({
        delay = { completion = 100, info = 0, signature = 50 },
        window = {
            info = { height = 10, width = 80, border = "solid" },
            signature = { height = 10, width = 80, border = "solid" },
        },
        lsp_completion = {
            process_items = process_items,
        },
    })

    -- Force signature help with <C-k>
    vim.keymap.set("i", "<C-k>", function()
        vim.lsp.buf.signature_help()
    end, { desc = "Signature help" })

    -- CR accepts selected item or inserts newline
    vim.keymap.set("i", "<CR>", function()
        if vim.fn.complete_info()["selected"] ~= -1 then
            return "\25"
        end
        return "\r"
    end, { expr = true })

    -- C-y: pum accept > fallback
    local termcodes = function(keys)
        return vim.api.nvim_replace_termcodes(keys, true, false, true)
    end

    vim.keymap.set("i", "<C-y>", function()
        if vim.fn.pumvisible() == 1 then
            local info = vim.fn.complete_info()
            if info.selected == -1 then
                return termcodes("<C-n><C-y>")
            end
            return termcodes("<C-y>")
        end
        return termcodes("<C-y>")
    end, { expr = true })
end

function M.cmdline()
    require("mini.cmdline").setup()
end

function M.visits()
    require("mini.visits").setup()
end

function M.extra()
    require("mini.extra").setup()
end

function M.pick()
    local MiniPick = require("mini.pick")
    local MiniExtra = require("mini.extra")
    local pickers = require("lib.mini_pickers")

    MiniPick.setup({
        window = {
            config = function()
                local win_height = vim.api.nvim_win_get_height(0)
                local win_width = vim.api.nvim_win_get_width(0)
                local height = math.floor(0.25 * win_height)
                local width = win_width >= 165 and math.floor(0.5 * vim.o.columns) or (win_width - 2)
                return {
                    relative = "win",
                    height = height,
                    width = width,
                    row = win_height - 1,
                    col = 0,
                    border = "solid",
                }
            end,
        },
    })

    MiniPick.registry.smart_files = pickers.smart_files
    MiniPick.registry.git_changed = pickers.git_changed
    MiniPick.registry.project_switch = pickers.project_switch
    MiniPick.registry.worktree_switch = pickers.worktree_switch
    MiniPick.registry.associated_files = pickers.associated_files
    MiniPick.registry.buffer_jumps = pickers.buffer_jumps

    -- Keymaps
    local map = vim.keymap.set
    local dots_path = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots"
    -- stylua: ignore start

    -- General
    map("n", "<leader>.",   function() MiniPick.builtin.resume() end, { desc = "Resume Picker" })
    map("n", "<leader>;",   function() MiniExtra.pickers.commands() end, { desc = "Commands" })
    map("n", "<leader>:",   function() MiniExtra.pickers.history({ scope = ":" }) end, { desc = "Command History" })
    map("n", "<leader>'",   function() MiniExtra.pickers.registers() end, { desc = "Registers" })

    -- App
    map("n", "<leader><leader>", function() MiniPick.registry.smart_files() end, { desc = "Files (smart)" })
    map("n", "<leader>aa",  function() MiniExtra.pickers.commands() end, { desc = "[A]ctions" })
    map("n", "<leader>ad",  function() MiniPick.builtin.files() end, { desc = "[D]ocument (in project)" })
    map("n", "<leader>ahh", function() MiniExtra.pickers.hl_groups() end, { desc = "[H]ighlights" })
    map("n", "<leader>ahk", function() MiniExtra.pickers.keymaps() end, { desc = "[K]eymaps" })
    map("n", "<leader>ahm", function() MiniExtra.pickers.manpages() end, { desc = "[M]anuals" })
    map("n", "<leader>aht", function() MiniPick.builtin.help() end, { desc = "[T]ags" })
    map("n", "<leader>ar",  function() MiniExtra.pickers.oldfiles() end, { desc = "[R]ecent Documents (Anywhere)" })
    map("n", "<leader>at",  function() MiniExtra.pickers.colorschemes() end, { desc = "[T]hemes" })
    map("n", "<leader>aw",  function() MiniPick.registry.project_switch() end, { desc = "[W]orkspace" })
    map("n", "<leader>a,",  function() MiniPick.builtin.files(nil, { source = { cwd = dots_path } }) end, { desc = "[,]Settings (Dots)" })

    -- Workspace
    map("n", "<leader>wd",  function() MiniPick.builtin.files() end, { desc = "[D]ocuments" })
    map("n", "<leader>wt",  function() MiniPick.builtin.grep_live() end, { desc = "[T]ext" })
    map("n", "<leader>wm",  function() MiniPick.registry.git_changed() end, { desc = "[M]odified files" })
    map("n", "<leader>wp",  function() MiniExtra.pickers.diagnostic() end, { desc = "[P]roblems" })
    map("n", "<leader>wr",  function() MiniExtra.pickers.oldfiles({ current_dir = true }) end, { desc = "[R]ecent Documents" })
    map("n", "<leader>ws",  function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "[S]ymbols" })
    map("n", "<leader>wc",  function() MiniExtra.pickers.git_hunks() end, { desc = "[C]hanges" })
    map("n", "<leader>wgb", function() MiniExtra.pickers.git_branches() end, { desc = "[B]ranches" })
    map("n", "<leader>wgh", function() MiniExtra.pickers.git_commits() end, { desc = "[H]istory" })
    map("n", "<leader>ww",  function() MiniPick.registry.worktree_switch() end, { desc = "[W]orktrees" })

    -- Document
    map("n", "<leader>da",  function() MiniPick.registry.associated_files() end, { desc = "[A]ssociated Documents" })
    map("n", "<leader>dc",  function() MiniExtra.pickers.git_hunks({ path = vim.fn.expand("%") }) end, { desc = "[C]hanges" })
    map("n", "<leader>dj",  function() MiniPick.registry.buffer_jumps() end, { desc = "[J]umps" })
    map("n", "<leader>dp",  function() MiniExtra.pickers.diagnostic({ scope = "current" }) end, { desc = "[P]roblems" })
    map("n", "<leader>ds",  function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "[S]ymbols" })
    map("n", "<leader>dt",  function() MiniExtra.pickers.buf_lines({ scope = "current" }) end, { desc = "[T]ext" })

    -- Symbol
    map("n", "<leader>sr",  function() MiniExtra.pickers.lsp({ scope = "references" }) end, { desc = "[R]eferences" })
    map("n", "<leader>si",  function() MiniExtra.pickers.lsp({ scope = "implementation" }) end, { desc = "[I]mplementations" })
    -- stylua: ignore end
end

function M.input()
    require("mini.input").setup({
        scope = "cursor",
    })
end

---@type LazyPluginSpec
return {
    "nvim-mini/mini.nvim",
    version = false,
    lazy = false,
    config = function()
        -- Essential at startup: UI-visible from first frame or session integrity
        M.statusline()
        M.sessions()

        -- Defer the rest to after startup
        vim.schedule(function()
            -- M.hues()
            M.clue()
            M.ai()
            M.surround()
            M.diff()
            M.git()
            M.test()
            M.files()
            M.snippets()
            M.input()
            M.completion()
            M.cmdline()
            M.visits()
            M.extra()
            M.pick()
            require("mini.snippets").start_lsp_server()
        end)
    end,
}
