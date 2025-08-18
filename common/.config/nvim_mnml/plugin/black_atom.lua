local present, black_atom = pcall(require, "black-atom")

if not present then
    vim.notify_once("`Black Atom` module not found!", vim.log.levels.ERROR)
    return
end

black_atom.setup({
    styles = {
        transparency = "none",
        cmp_kind_color_mode = "bg",
        diagnostics = {
            background = true,
        },
    },
})

-- Set colorscheme after setup
vim.cmd.colorscheme("black-atom-mnml-mikado-dark")