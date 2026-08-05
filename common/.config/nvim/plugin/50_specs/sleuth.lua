-- Auto-detect indentation settings ('shiftwidth', 'expandtab', …) per file.
-- Must load eagerly: detection runs from a BufReadPost autocmd, so any buffer
-- opened before the plugin loads never gets `b:sleuth` and keeps the filetype
-- plugin's defaults (e.g. markdown's shiftwidth=4) for the rest of the session.

Edit.now(function()
	vim.pack.add({ "git@github.com:tpope/vim-sleuth" })
end)
