local M = {}

--- IDEA: Automatically append/sync the branch note to the PR description and YouTrack issue on every push.

---@type LazyPluginSpec
M.spec = {
    "yujinyuz/gitpad.nvim",
    opts = function()
        local cwd = vim.fn.getcwd()
        local does_include = string.find(cwd, "dealercenter-digital", 1, true)
        local dir = does_include and require("config").pathes.notes.work.dcd or require("config").pathes.notes.personal

        return {
            title = "Vinpad",
            border = "rounded",
            window_type = "floating", -- Options are 'floating' or 'split'
            dir = dir .. "/GitPad",
            on_attach = function(bufnr)
                vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<Cmd>wq<CR>", { noremap = true, silent = true })
            end,
            ---@type vim.api.keyset.win_config
            split_win_opts = {
                split = "right", -- Controls split direction if window_type == 'split'. Options are 'left', 'right', 'above', or 'below'. See :help nvim_open_win()
            },
        }
    end,
    config = function(_, opts)
        require("gitpad").setup(opts)
    end,
    keys = {
        {
            "<leader>np",
            function()
                require("gitpad").toggle_gitpad()
            end,
            desc = "Project notes",
        },
        {
            "<leader>nb",
            function()
                require("gitpad").toggle_gitpad_branch()
            end,
            desc = "Branch notes",
        },
        {
            "<leader>nf",
            function()
                local filename = vim.fn.expand("%:p") -- or just use vim.fn.bufname()
                if filename == "" then
                    vim.notify("empty bufname")
                    return
                end
                filename = vim.fn.pathshorten(filename, 2) .. ".md"
                require("gitpad").toggle_gitpad({ filename = filename })
            end,
            desc = "File notes",
        },
    },
}

return M.spec
