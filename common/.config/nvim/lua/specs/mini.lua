--- Sources:
--- https://github.com/JulesNP/nvim/blob/main/lua/plugins/mini.lua
--- https://github.com/SylvanFranklin/.config/blob/main/nvim/init.lua

local M = {}

-- https://github.com/echasnovski/mini.nvim/blob/2e38ed16c2ced64bcd576986ccad4b18e2006e18/doc/mini-pick.txt#L650-L660
M.win_config = {
    left_buf_corner = function()
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
    cursor = function()
        return {
            relative = "cursor",
            anchor = "NW",
            row = 0,
            col = 0,
        }
    end,
}

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
            -- Maximum number of windows to show side by side
            max_number = 3,
            -- Whether to show preview of file/directory under cursor
            preview = true,
            -- Width of focused window
            width_focus = 50,
            -- Width of non-focused window
            width_nofocus = 25,
            -- Width of preview window
            width_preview = 65,
        },
    })

    local map_split = function(buf_id, lhs, direction)
        local rhs = function()
            -- Make new window and set it as target
            local cur_target = MiniFiles.get_explorer_state().target_window
            local new_target = vim.api.nvim_win_call(cur_target, function()
                vim.cmd(direction .. " split")
                return vim.api.nvim_get_current_win()
            end)

            MiniFiles.set_target_window(new_target)
            MiniFiles.go_in({ close_on_file = true })
        end

        -- Adding `desc` will result into `show_help` entries
        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local buf_id = args.data.buf_id
            -- Tweak keys to your liking
            map_split(buf_id, "<C-v>", "belowright vertical")
            map_split(buf_id, "<C-s>", "belowright horizontal")
            map_split(buf_id, "<C-t>", "tab")
        end,
    })

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
            Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
    })

    -- Yank in register full path of entry under cursor
    local yank_path = function()
        local path = (MiniFiles.get_fs_entry() or {}).path
        if path == nil then
            return vim.notify("Cursor is not on valid entry")
        end
        vim.fn.setreg(vim.v.register, path)
    end

    -- Open path with system default handler (useful for non-text files)
    local ui_open = function()
        vim.ui.open(MiniFiles.get_fs_entry().path)
    end
    local map = vim.keymap.set

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local bufid = args.data.buf_id

            local function setBranch(path)
                MiniFiles.set_branch({ vim.fn.expand(path) })
            end

            -- stylua: ignore start
            map("n", "gx", ui_open, { buffer = bufid, desc = "OS open" })
            map("n", "gy", yank_path, { buffer = bufid, desc = "Yank path" })

            map("n", ".", function() setBranch(vim.fn.getcwd()) end, { buffer = bufid, desc = "Current working directory" })

            map("n", "gh", function() setBranch("$HOME/") end, { buffer = bufid, desc = "Home", nowait = true })
            map("n", "gc", function() setBranch("$HOME/.config") end, { buffer = bufid, desc = "Config", nowait = true })

            map("n", "0", function() setBranch("$HOME/repos/nikbrunner/dots") end, { buffer = bufid, desc = "Dots" })
            map("n", "1", function() setBranch("$HOME/repos/nikbrunner/notes") end, { buffer = bufid, desc = "Notes" })
            map("n", "2", function() setBranch("$HOME/repos/nikbrunner/dcd-notes") end, { buffer = bufid, desc = "DCD Notes" })

            map("n", "4", function() setBranch("$HOME/repos/black-atom-industries/core") end, { buffer = bufid, desc = "Black Atom - Core" })
            map("n", "5", function() setBranch("$HOME/repos/black-atom-industries/nvim") end, { buffer = bufid, desc = "Black Atom - Neovim" })
            map("n", "6", function() setBranch("$HOME/repos/black-atom-industries/radar.nvim") end, { buffer = bufid, desc = "Black Atom - Radar" })

            map("n", "7", function() setBranch("$HOME/repos/dealercenter-digital/bc-desktop-client") end, { buffer = bufid, desc = "DCD Desktop Client" })
            map("n", "8", function() setBranch("$HOME/repos/dealercenter-digital/bc-desktop-tools") end, { buffer = bufid, desc = "DCD Desktop Tools" })
            map("n", "9", function() setBranch("$HOME/repos/dealercenter-digital/bc-web-client-poc") end, { buffer = bufid, desc = "DCD Web Client" })
            -- stylua: ignore end
        end,
    })

    -- stylua: ignore start
    map("n", "-", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "[E]xplorer" })
    map("n", "_", function() MiniFiles.open(vim.fn.getcwd()) end, { desc = "[E]xplorer" })
    map("n", "<leader>we", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "[E]xplorer" })
    -- stylua: ignore end
end

function M.smart_picker()
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
            config = M.win_config.left_buf_corner,
            prompt_caret = "█",
            prompt_prefix = "  ",
        },
    })

    MiniPick.registry.frecency = M.smart_picker

    -- stylua: ignore start
    vim.keymap.set("n", "<leader><leader>",    MiniPick.registry.frecency, { desc = "Pick file" })
    vim.keymap.set("n", "<leader>.",           function() MiniPick.builtin.resume() end, { desc = "Resume Picker" })

    -- App
    vim.keymap.set("n", "<leader>a'",          function() MiniExtra.pickers.registers() end, { desc = "Registers" })
    vim.keymap.set("n", "<leader>aa",          function() MiniExtra.pickers.commands() end, { desc = "[A]ctions" })
    vim.keymap.set("n", "<leader>ar",          function() MiniExtra.pickers.oldfiles() end, { desc = "[R]ecent Documents (Anywhere)" })
    vim.keymap.set("n", "<leader>ak",          function() MiniExtra.pickers.keymaps() end, { desc = "[K]eymaps" })
    vim.keymap.set("n", "<leader>aj",          function() MiniExtra.pickers.list({ scope = "jump" }) end, { desc = "[J]umps" })
    vim.keymap.set("n", "<leader>asd",         function() MiniPick.builtin.files(nil, { source = { cwd = vim.fn.expand("$HOME") .. "/repos/nikbrunner/dots" }}) end, { desc = "[D]ocuments" })
    vim.keymap.set("n", "<leader>ahp",         function() MiniPick.builtin.help() end, { desc = "[P]ages" })
    vim.keymap.set("n", "<leader>ahh",         function() MiniExtra.pickers.hl_groups() end, { desc = "[H]ightlights" })

    -- Workspace
    vim.keymap.set("n", "<leader>wd",          MiniPick.registry.frecency, { desc = "[D]ocument" })
    vim.keymap.set("n", "<leader>wgb",         function() MiniExtra.pickers.git_branches() end, { desc = "[B]ranches" })
    vim.keymap.set("n", "<leader>wr",          function() MiniExtra.pickers.oldfiles({ current_dir = true }) end, { desc = "[R]ecent Documents" })
    vim.keymap.set("n", "<leader>wt",          function() MiniPick.builtin.grep_live() end, { desc = "[T]ext" })
    vim.keymap.set("n", "<leader>ww",          function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, { desc = "[W]ord" })
    vim.keymap.set("n", "<leader>wm",          function() MiniExtra.pickers.git_files({ scope = "modified" }) end, { desc = "[M]odified Documents" })
    vim.keymap.set("n", "<leader>wc",          function() MiniExtra.pickers.git_hunks() end, { desc = "[C]hanges" })
    vim.keymap.set("n", "<leader>ws",          function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, { desc = "[S]ymbols" })

    -- Document
    vim.keymap.set("n", "<leader>dt",          function() MiniExtra.pickers.buf_lines({ scope = "current" }) end, { desc = "[T]ext" })
    vim.keymap.set("n", "<leader>ds",          function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end, { desc = "[S]ymbols" })
    -- stylua: ignore end
end

function M.extra()
    require("mini.extra").setup()
end

function M.visits()
    require("mini.visits").setup()
end

function M.ai()
    local spec_treesitter = require("mini.ai").gen_spec.treesitter

    require("mini.ai").setup({
        custom_textobjects = {
            -- Functions
            f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),

            -- Function calls
            F = spec_treesitter({ a = "@call.outer", i = "@call.inner" }),

            -- Arguments/parameters
            a = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),

            -- Conditionals and loops
            c = spec_treesitter({
                a = { "@conditional.outer", "@loop.outer" },
                i = { "@conditional.inner", "@loop.inner" },
            }),
        },
        n_lines = 500, -- Increase search range
    })

    local map = vim.keymap.set
    -- stylua: ignore start
    map({ "n", "x", "o" }, "]f", function() require("mini.ai").move_cursor("left", "a", "f", { search_method = "next" }) end, { desc = "Next function start" })
    map({ "n", "x", "o" }, "[f", function() require("mini.ai").move_cursor("left", "a", "f", { search_method = "prev" }) end, { desc = "Prev function start" })
    map({ "n", "x", "o" }, "]F", function() require("mini.ai").move_cursor("right", "a", "f", { search_method = "next" }) end, { desc = "Next function end" })
    map({ "n", "x", "o" }, "[F", function() require("mini.ai").move_cursor("right", "a", "f", { search_method = "prev" }) end, { desc = "Prev function end" })
    -- stylua: ignore end
end

-- TODO: Clean up
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

function M.clue()
    local MiniClue = require("mini.clue")

    MiniClue.setup({
        triggers = {
            { mode = "c", keys = "<C-r>" },
            { mode = "i", keys = "<C-r>" },
            { mode = "i", keys = "<C-x>" },
            { mode = "n", keys = "'" },
            { mode = "n", keys = "<Leader>" },
            { mode = "n", keys = "[" },
            { mode = "n", keys = "]" },
            { mode = "n", keys = "`" },
            { mode = "n", keys = "g" },
            { mode = "n", keys = "s" },
            { mode = "n", keys = "m" },
            { mode = "n", keys = "c" },
            { mode = "n", keys = "v" },
            { mode = "n", keys = "z" },
            { mode = "n", keys = '"' },
            { mode = "n", keys = " " },
            { mode = "x", keys = "'" },
            { mode = "x", keys = "<Leader>" },
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
            { mode = "n", keys = "<leader>a", desc = "[A]pp" },
            { mode = "n", keys = "<leader>al", desc = "[L]anguages" },
            { mode = "n", keys = "<leader>ah", desc = "[H]elp" },
            { mode = "n", keys = "<leader>ap", desc = "[P]lugins" },
            { mode = "n", keys = "<leader>as", desc = "[S]ettings" },
            { mode = "n", keys = "<leader>ag", desc = "[G]it" },
            { mode = "n", keys = "<leader>aso", desc = "[O]ptions" },

            { mode = "n", keys = "<leader>w", desc = "[W]orkspace" },
            { mode = "n", keys = "<leader>wg", desc = "[G]it" },

            { mode = "n", keys = "<leader>d", desc = "[D]ocument" },
            { mode = "n", keys = "<leader>dy", desc = "[Y]ank" },
            { mode = "n", keys = "<leader>dg", desc = "[G]it" },

            { mode = "n", keys = "sl", desc = "[L]og" },
            { mode = "n", keys = "sc", desc = "[C]alls" },

            { mode = "n", keys = "<leader>c", desc = "[C]ange" },

            { mode = "n", keys = "<leader>s", desc = "[S]ession" },
            { mode = "n", keys = "<leader>h", desc = "[H]ttp" },
            { mode = "n", keys = "<leader>n", desc = "[N]otes" },
        },
        window = {
            config = {
                width = math.floor(0.25 * vim.o.columns),
            },
            delay = 0,
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
    end, { desc = "Git (Hunk)" })

    -- Buffer-level operations
    map("n", "<leader>dgr", function()
        MiniDiff.do_hunks(0, "reset")
    end, { desc = "[R]evert changes" })

    map("n", "<leader>dgs", function()
        MiniDiff.do_hunks(0, "apply")
    end, { desc = "[S]tage document" })
end

function M.get_session_name()
    local name = string.gsub(vim.fn.getcwd(), "/", "_")
    local branch = vim.trim(vim.fn.system("git branch --show-current"))
    branch = string.gsub(branch, "/", "_") -- Add this line

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

                            -- Delete if buffer is not visible in any window
                            if vim.fn.bufwinid(bufnr) == -1 then
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

function M.git()
    require("mini.git").setup()
end

function M.diff()
    require("mini.diff").setup()
end

---@type LazyPluginSpec
return {
    "nvim-mini/mini.nvim",
    version = "*",
    lazy = false,
    config = function()
        M.pick()
        M.files()
        M.visits()
        M.extra()
        M.diff()
        M.ai()
        M.statusline()
        M.icons()
        M.surround()
        M.clue()
        M.test()
        M.sessions()
        M.git()
        M.diff()
    end,
}
