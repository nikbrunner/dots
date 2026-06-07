local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")


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

MiniPick.registry.smart_files = Edit.pickers.smart_files
MiniPick.registry.git_changed = Edit.pickers.git_changed
MiniPick.registry.project_switch = Edit.pickers.project_switch
MiniPick.registry.worktree_switch = Edit.pickers.worktree_switch
MiniPick.registry.associated_files = Edit.pickers.associated_files
MiniPick.registry.buffer_jumps = Edit.pickers.buffer_jumps

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
