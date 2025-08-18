local present, oil = pcall(require, "oil")

if not present then
    vim.notify_once("`Oil` module not found!", vim.log.levels.ERROR)
    return
end

oil.setup({
    default_file_explorer = true,
    view_options = {
        show_hidden = true,
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = false,
    },
    keymaps = {
        ["q"] = { "actions.close", mode = "n" },
        ["mh"] = "<cmd>edit $HOME<CR>",
        ["mr"] = "<cmd>edit $HOME/repos/<CR>",
        ["md"] = "<cmd>edit $HOME/repos/nikbrunner/dots<CR>",
        ["mn"] = "<cmd>edit $HOME/repos/nikbrunner/notes<CR>",
        ["<C-v>"] = { "actions.select", opts = { vertical = true } },
        ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
        ["<C-t>"] = { "actions.select", opts = { tab = true } },
    },
    lsp_file_methods = {
        enabled = true,
        autosave_changes = true,
    },
    win_options = {
        winbar = "%{v:lua.require('oil').get_current_dir()}",
    },
    float = {
        padding = 5,
        max_width = 0.35,
        max_height = 0.5,
        border = "solid",
        win_options = {
            winblend = 10,
        },
    },
    confirmation = {
        min_width = { 40, 0.35 },
        max_width = 0.65,
        max_height = 0.5,
        min_height = { 5, 0.1 },
        border = "solid",
        win_options = {
            winblend = 10,
        },
    },
    keymaps_help = {
        border = "solid",
    },
})

vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "[E]xplorer" })