-- Linting via nvim-lint. Picks the linter per buffer based on which config
-- file is found upward from the buffer (deno > Vite+ > eslint).

local vp_configs = { "vite.config.ts", "vite.config.mts", "vite.config.js", "vite.config.mjs" }

---@param path string
---@return string|nil root The directory holding a vite.config.* with a `lint` block and a local `vp`
local function vp_lint_root(path)
	local config = vim.fs.find(vp_configs, { upward = true, path = path })[1]
	if not config then
		return nil
	end

	local root = vim.fs.dirname(config)
	if vim.fn.executable(root .. "/node_modules/.bin/vp") == 0 then
		return nil
	end

	local source = table.concat(vim.fn.readfile(config), "\n")
	return source:find("%f[%w_]lint%s*:") and root or nil
end

Edit.later(function()
	vim.pack.add({ "git@github.com:mfussenegger/nvim-lint" })

	local lint = require("lint")

	-- `vp lint` reads the `lint` block in vite.config.*; its github format matches oxlint's parser
	lint.linters.vp_lint = function()
		local root = vp_lint_root(vim.api.nvim_buf_get_name(0)) or vim.fn.getcwd()
		return vim.tbl_extend("force", require("lint.linters.oxlint"), {
			cmd = root .. "/node_modules/.bin/vp",
			args = { "lint", "--format", "github" },
			cwd = root,
		})
	end

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

		if vp_lint_root(fname) then
			return "vp_lint"
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
		group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
		callback = function()
			setup_linters()
			lint.try_lint(nil, { ignore_errors = true })
		end,
	})
end)
