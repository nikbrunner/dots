local auto = vim.api.nvim_create_autocmd

local function auto_group(name)
    return vim.api.nvim_create_augroup("nvim_" .. name, { clear = true })
end

-- Highlight on yank
auto("TextYankPost", {
    group = auto_group("highlight_yank"),
    callback = function()
        vim.highlight.on_yank()
    end,
})

auto("User", {
    group = auto_group("new_file_reminder"),
    pattern = {
        "MiniFilesActionCreate",
        "MiniFilesActionDelete",
        "MiniFilesActionRename",
        "MiniFilesActionCopy",
        "MiniFilesActionMove",
    },
    callback = function()
        vim.notify("Don't forget to run `dots link`!", vim.log.levels.WARN)
    end,
})

