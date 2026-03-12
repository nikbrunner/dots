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
-- Custom Picker Functions (Snacks-unique)
-- ============================================================================

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

    if win_width >= 165 then
        return vim.tbl_deep_extend("force", M.shared_layout_opts, {
            layout = {
                width = 0.5,
                row = row,
                height = picker_height,
            },
        })
    else
        return vim.tbl_deep_extend("force", M.shared_layout_opts, {
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
    -- stylua: ignore start
    return {
        -- App (Snacks-unique features)
        { "<leader>an",          function() Snacks.notifier.show_history() end, desc = "[N]otifications" },
        { "<leader>ag",          function() Snacks.lazygit() end, desc = "[G]it" },

        -- Workspace (Snacks-unique features)
        { "<leader>wgH",         function() Snacks.lazygit.log() end, desc = "[H]istory (Lazygit)" },
        { "<leader>wgs",         function() Snacks.lazygit() end, desc = "[S]tatus (Lazygit)" },
        { "<leader>wgib",         M.gh_issue_browse, desc = "[B]rowse Issues" },
        { "<leader>wgpc",         M.gh_pr_diff, desc = "[C]hanges in current PR" },
        { "<leader>wgpd",         M.gh_pr_buffer, desc = "[D]escription of current PR" },
        { "<leader>wgpb",         M.gh_pr_browse, desc = "[B]rowse Pull Requests" },

        -- Document (Snacks-unique features)
        { "<leader>dgh",         function() Snacks.picker.git_log_file() end, desc = "[H]istory" },
        { "<leader>dgH",         function() Snacks.lazygit.log_file() end, desc = "[H]istory (Lazygit)" },
        { "<leader>du",          function() Snacks.picker.undo() end, desc = "[U]ndo" },

        -- Symbols (Snacks-unique features)
        { "<leader>sgb",          function() Snacks.git.blame_line() end, desc = "[B]lame" },
        { "<leader>sgh",          function() Snacks.picker.git_log_line() end, desc = "[H]istory" },
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

        -- Detect PR context on startup and directory change
        vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
            callback = function()
                vim.defer_fn(detect_gh_pr_context, 500)
            end,
        })
    end,

    dependencies = {
        {
            "mbbill/undotree",
            cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeHide" },
        },
    },

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
            ui_select = false, -- MiniPick handles vim.ui.select
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
