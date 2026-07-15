-- Auto-detect indentation settings ('shiftwidth', 'expandtab', …) per file.
-- `now_if_args` so detection also applies to the file Neovim was opened with.

Edit.now_if_args(function()
	vim.pack.add({ "git@github.com:tpope/vim-sleuth" })
end)
