local M = {}

---@type vim.pack.Spec
M.spec = {
    src = "https://github.com/numToStr/Navigator.nvim",
}

function M.init()
    local present, navigator = pcall(require, "Navigator")

    if not present then
        vim.notify_once("`Navigator` module not found!", vim.log.levels.ERROR)
        return
    end

    navigator.setup()

    vim.keymap.set("n", "<c-h>", "<cmd>NavigatorLeft<cr>")
    vim.keymap.set("n", "<c-l>", "<cmd>NavigatorRight<cr>")
    vim.keymap.set("n", "<c-k>", "<cmd>NavigatorUp<cr>")
    vim.keymap.set("n", "<c-j>", "<cmd>NavigatorDown<cr>")
end

return M
