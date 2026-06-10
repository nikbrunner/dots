-- Linting via nvim-lint. Picks the linter per buffer based on which config
-- file is found upward from the buffer (deno > eslint).

Edit.later(function()
	vim.pack.add({ "git@github.com:mfussenegger/nvim-lint" })

	local lint = require("lint")

	-- Determine which linter to use based on config files
	local function get_linter_for_buffer(bufnr)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		if fname == "" then
			return nil
		end

		local deno_configs = { "deno.json", "deno.jsonc" }
		local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]
		if deno_config then
			return "deno"
		end

		local eslint_configs = {
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.json",
			".eslintrc.yaml",
			"eslint.config.mjs",
			"eslint.config.mts",
			"eslint.config.js",
			"eslint.config.cjs",
			"eslint.config.json",
		}
		local eslint_config = vim.fs.find(eslint_configs, { upward = true, path = fname })[1]
		if eslint_config then
			vim.env.ESLINT_D_PPID = vim.fn.getpid()
			return "eslint"
		end

		return nil
	end

	local function setup_linters()
		local bufnr = vim.api.nvim_get_current_buf()
		local linter = get_linter_for_buffer(bufnr)

		if linter then
			local ft = vim.bo[bufnr].filetype
			local supported_filetypes = {
				javascript = true,
				javascriptreact = true,
				typescript = true,
				typescriptreact = true,
				json = true,
				jsonc = true,
			}

			if supported_filetypes[ft] then
				lint.linters_by_ft[ft] = { linter }
			end
		end
	end

	vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
		group = vim.api.nvim_create_augroup("nvim-edit-lint", { clear = true }),
		callback = function()
			setup_linters()
			lint.try_lint(nil, { ignore_errors = true })
		end,
	})
end)
