local function toggle_inline_completion()
	local suggestion = require("supermaven-nvim.completion_preview")
	local message = "AI Auto-Completion "

	if suggestion.disable_inline_completion then
		suggestion.disable_inline_completion = false
		vim.notify(message .. "ENABLED", vim.log.levels.INFO, { title = "SuperMaven" })
	else
		suggestion.disable_inline_completion = true
		vim.notify(message .. "DISABLED", vim.log.levels.INFO, { title = "SuperMaven" })
	end
end

Edit.now(function()
	vim.pack.add({ "git@github.com:supermaven-inc/supermaven-nvim" })

	require("supermaven-nvim").setup({
		log_level = "off", -- set to "off" to disable logging completely
	})

	require("supermaven-nvim.completion_preview").disable_inline_completion = false

	vim.keymap.set("n", "<leader>aoa", toggle_inline_completion, { desc = "[A]uto-Completion" })
end)
