local M = {}

M.toggle_inline_completion = function()
    local suggestion = require("supermaven-nvim.completion_preview")
    local message = "AI Auto-Completion "

    if suggestion.disable_inline_completion then
        suggestion.disable_inline_completion = false
        vim.notify(message .. "ENABLED", vim.log.levels.INFO, { title = "SuperMaven" })
    else
        suggestion.disable_inline_completion = true
        vim.notify(message .. "DISABLED", vim.log.levels.INFO, { title = "SuperMaven" })
    end
end

---@type LazyPluginSpec
M.spec = {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
        keymaps = {
            accept_suggestion = "<M-y>",
            accept_word = "<M-]>",
            clear_suggestion = "<M-[>",
        },
        log_level = "off", -- set to "off" to disable logging completely
    },
    keys = {
        { "<leader>aoa", M.toggle_inline_completion, desc = "[A]uto-Completion" },
    },
    config = function(_, opts)
        require("supermaven-nvim").setup(opts)

        -- Also accept with <C-y> (blink handles <C-y> when its menu is visible;
        -- otherwise this accepts the supermaven ghost text, falling through
        -- to default <C-y> when there's no suggestion).
        vim.keymap.set("i", "<C-y>", function()
            local cp = require("supermaven-nvim.completion_preview")
            if cp.has_suggestion() then
                cp.on_accept_suggestion()
            else
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-y>", true, false, true), "n", false)
            end
        end, { desc = "Accept suggestion" })

        -- Disable inline completion by default
        require("supermaven-nvim.completion_preview").disable_inline_completion = false
    end,
}

return M.spec
