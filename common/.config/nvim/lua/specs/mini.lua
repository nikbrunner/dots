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

---@type LazyPluginSpec
return {
    "nvim-mini/mini.nvim",
    version = false,
    lazy = false,
    config = function()
        M.visits()
        M.extra()
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
