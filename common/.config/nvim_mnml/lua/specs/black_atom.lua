local M = {}

---@type vim.pack.Spec
M.spec = {
    src = "https://github.com/black-atom-industries/nvim",
    name = "black-atom",
}

function M.init()
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
end

return M
