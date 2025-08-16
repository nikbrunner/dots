local M = {}

M.spec = {
    src = "https://github.com/supermaven-inc/supermaven-nvim",
}

function M.toggle_inline_completion()
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

function M.init()
    local present, sm = pcall(require, "supermaven-nvim")

    if not present then
        vim.notify_once("`Supermaven` module not found!", vim.log.levels.ERROR)
        return
    end

    sm.setup({
        keymaps = {
            accept_suggestion = "<Tab>",
            accept_word = "<S-Tab>",
            clear_suggestion = "<Left>",
        },
        -- log_level = "off", -- set to "off" to disable logging completely
    })

    -- Disable inline completion by default
    require("supermaven-nvim.completion_preview").disable_inline_completion = false

    vim.keymap.set("n", "<leader>aoa", M.toggle_inline_completion, { desc = "[A]uto-Completion" })
end

return M
