-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/denols.lua

---@type vim.lsp.Config
return {
	cmd = { "deno", "lsp" },
	cmd_env = { NO_COLOR = true },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function(bufnr, cb)
		local root = vim.fs.root(bufnr, "deno.lock") or vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })

		if root then
			cb(root)
		end
	end,

	---@diagnostic disable-next-line: unused-local
	before_init = function(params)
		vim.g.markdown_fenced_languages = {
			"ts=typescript",
		}
	end,

	-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#denols
	settings = {
		deno = {
			enable = true,
			suggest = {
				imports = {
					hosts = {
						["https://deno.land"] = true,
					},
				},
			},
		},
	},
}
