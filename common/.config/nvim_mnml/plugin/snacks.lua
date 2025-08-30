local present, snacks = pcall(require, "snacks")

if not present then
    vim.notify_once("`Snacks` module not found!", vim.log.levels.ERROR)
    return
end

-- Minimal Snacks setup with only profiler enabled
snacks.setup({
    profiler = {
        enabled = true,
    },
    -- Disable all other features
    bigfile = { enabled = false },
    debug = { enabled = false },
    gitbrowse = { enabled = false },
    input = { enabled = false },
    lazygit = { enabled = false },
    notifier = { enabled = false },
    picker = { enabled = false },
    quickfile = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    terminal = { enabled = false },
    toggle = { enabled = false },
    words = { enabled = false },
    zen = { enabled = false },
})

-- Add keymaps for profiling
vim.keymap.set("n", "<leader>pp", function()
    snacks.profiler.scratch()
end, { desc = "Profiler Scratch" })

vim.keymap.set("n", "<leader>ps", function()
    snacks.profiler.start()
end, { desc = "Start Profiler" })

vim.keymap.set("n", "<leader>pe", function()
    snacks.profiler.stop()
end, { desc = "Stop Profiler" })