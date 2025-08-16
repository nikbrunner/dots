local M = {}

--- Centralized key mapping function
---@param mode string|table Mode(s) to set the mapping for (e.g., "n", "v", "i", {"n", "v"})
---@param lhs string Left-hand side of the mapping
---@param rhs string|function Right-hand side of the mapping
---@param opts table Optional parameters for vim.keymap.set (e.g., {desc = "Description"})
function M.map(mode, lhs, rhs, opts)
    opts = opts or {}
    opts.noremap = opts.noremap == nil and true or opts.noremap
    opts.silent = opts.silent == nil and true or opts.silent
    vim.keymap.set(mode, lhs, rhs, opts)
end

vim.keymap.set("n", "<leader>ar", ":update<CR> :source<CR>", { desc = "Save and [R]eload" })
vim.keymap.set("n", "<leader>as", "<cmd>e $MYVIMRC<cr>", { desc = "Edit settings" })

-- Escape clears search highlight, saves, hides notifier
M.map("n", "<Esc>", function()
    vim.cmd.nohlsearch()
    vim.cmd.wa()
end, { desc = "Escape and clear hlsearch" })
