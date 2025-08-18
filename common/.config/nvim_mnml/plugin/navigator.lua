local present, navigator = pcall(require, "Navigator")

if not present then
    vim.notify_once("`Navigator` module not found!", vim.log.levels.ERROR)
    return
end

navigator.setup()

vim.keymap.set("n", "<c-h>", navigator.left)
vim.keymap.set("n", "<c-l>", navigator.right)
vim.keymap.set("n", "<c-k>", navigator.up)
vim.keymap.set("n", "<c-j>", navigator.down)
