local present, gs = pcall(require, "gitsigns")

if not present then
    vim.notify_once("`Gitsings` module not found!", vim.log.levels.ERROR)
    return
end

gs.setup()

local util = {
    prev_hunk = function()
        gs.nav_hunk("prev")
        vim.cmd("norm zz")
    end,
    next_hunk = function()
        gs.nav_hunk("next")
        vim.cmd("norm zz")
    end,
}

local map = vim.keymap.set

map("n", "[c", util.prev_hunk, { desc = "Prev Hunk" })
map("n", "]c", util.next_hunk, { desc = "Next Hunk" })

map({ "n", "v" }, "<leader>cs", gs.stage_hunk, { desc = "[S]tage Hunk" })
map("n", "<leader>dvr", gs.reset_buffer, { desc = "[R]evert changes" })
map("n", "<leader>dvs", gs.stage_buffer, { desc = "[S]tage document" })

map({ "n", "v" }, "<leader>cr", gs.reset_hunk, { desc = "Reset Hunk" })
map({ "n", "v" }, "<leader>cu", gs.stage_hunk, { desc = "Undo Stage Hunk" })
map({ "n", "v" }, "<leader>cg", gs.preview_hunk, { desc = "Git (Hunk)" })