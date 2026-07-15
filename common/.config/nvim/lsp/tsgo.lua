-- Install with: mise (npm:@typescript/native-preview) -> `tsgo` bin
-- TypeScript 7 native LSP (Go port). ~10x faster than vtsls.
--
-- Status as of TS 7.0 (Jul 2026): quickFix, organize/remove/sort imports,
-- fix-all, rename, auto-imports, inlay hints, semantic highlighting, code lens,
-- go-to-source-definition, JSX linked editing are all IN.
-- Refactorings (extract, rewrite, move, inline) are NOT implemented — the team
-- is selectively re-porting, not faithfully porting all legacy code actions.
-- See microsoft/typescript-go#4005 (RyanCavanaugh: "we won't be re-implementing
-- 100% of these"). source.addMissingImports as codeActionOnSave is open: #3318.
--
-- Trial run: vtsls disabled in lsp/vtsls.lua. Revisit after refactors land.
-- Settings use the canonical VS Code TS-server schema (verified in
-- internal/ls/lsutil/userpreferences.go). vtsls-only keys dropped — tsgo
-- bundles its own TS lib.

local shared_jsts_settings = {
	preferences = {
		-- Supported values: 'shortest', 'project-relative', 'relative', 'non-relative'. Default: 'shortest'
		importModuleSpecifier = "relative",
		preferTypeOnlyAutoImports = true,
	},
	inlayHints = {
		functionLikeReturnTypes = { enabled = true },
		parameterNames = { enabled = "literals" },
		variableTypes = { enabled = true },
	},
}

---@type vim.lsp.Config
return {
	cmd = { "tsgo", "--lsp", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function(bufnr, cb)
		local fname = vim.uri_to_fname(vim.uri_from_bufnr(bufnr))

		local deno_configs = { "deno.json", "deno.jsonc" }
		local deno_config = vim.fs.find(deno_configs, { upward = true, path = fname })[1]
		-- If there is a Deno config, we don't start the vtsls server.
		if deno_config then
			return
		end

		-- Use the git root to deal with monorepos where TypeScript is installed in the root node_modules folder.
		local git_root = vim.fs.find(".git", { upward = true, path = fname })[1]
		if git_root then
			cb(vim.fn.fnamemodify(git_root, ":h"))
			return
		end

		local ts_configs = { "tsconfig.json", "tsconfig.jsonc" }
		local ts_config = vim.fs.find(ts_configs, { upward = true, path = fname })[1]
		if ts_config then
			cb(vim.fn.fnamemodify(ts_config, ":h"))
		end
	end,
}
