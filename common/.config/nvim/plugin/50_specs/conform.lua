-- Vite+ keeps Oxfmt options in the `fmt` block of vite.config.*, which only `vp fmt` reads
local vp_cmd = "vp_fmt"
local vp_configs = { "vite.config.ts", "vite.config.mts", "vite.config.js", "vite.config.mjs" }

---@param path string
---@return string|nil root The nearest directory holding a vite.config.* with a `fmt` block and a local `vp`
local function vp_fmt_root(path)
	for _, config in ipairs(vim.fs.find(vp_configs, { upward = true, path = path, limit = math.huge })) do
		local source = table.concat(vim.fn.readfile(config), "\n")
		if source:find("%f[%w_]fmt%s*:") then
			local root = vim.fs.dirname(config)
			return vim.fn.executable(root .. "/node_modules/.bin/vp") == 1 and root or nil
		end
	end
	return nil
end

local oxfmt_cmd = "oxfmt"
local oxfmt_configs = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts", "oxfmt.config.mts" }

local prettier_cmd = "prettier"
local prettier_configs = {
	".prettierrc",
	".prettierrc.json",
	".prettierrc.js",
	".prettierrc.cjs",
	".prettierrc.mjs",
	"prettier.config.js",
	"prettier.config.cjs",
	"prettier.config.mjs",
	"prettier.config.ts",
}

local deno_cmd = "deno_fmt"
local deno_configs = { "deno.json", "deno.jsonc" }

-- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome.lua
local biome_cmd = "biome"
local biome_configs = { "biome.json", "biome.jsonc" }

vim.g.vin_autoformat_enabled = true
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

Edit.later(function()
	vim.pack.add({ "git@github.com:stevearc/conform.nvim" })

	local conform = require("conform")

	local function handle_shared_formatter(buf)
		-- NOTE: Priority order:
		-- 1. Vite+ (`fmt` block in vite.config.*)
		-- 2. Oxfmt (explicit formatting config)
		-- 3. Prettier (explicit formatting config)
		-- 4. Deno (all-in-one tool for Deno projects)
		-- 5. Biome (all-in-one tool, but in some projects only used for linting)
		local buf_fname = vim.uri_to_fname(vim.uri_from_bufnr(buf))

		if vp_fmt_root(buf_fname) then
			return { vp_cmd, stop_after_first = true }
		end

		local is_oxfmt = conform.get_formatter_info(oxfmt_cmd, buf).available
		local oxfmt_config = vim.fs.find(oxfmt_configs, { upward = true, path = buf_fname })[1]

		if oxfmt_config ~= nil and not is_oxfmt then
			vim.notify(
				string.format("There is an `oxfmt` config (%s), but `%s` is not installed", oxfmt_config, oxfmt_cmd),
				vim.log.levels.WARN,
				{ title = "Conform" }
			)
		end

		if oxfmt_config ~= nil and is_oxfmt then
			return { oxfmt_cmd, stop_after_first = true }
		end

		local is_prettier = conform.get_formatter_info(prettier_cmd, buf).available
		local prettier_config = vim.fs.find(prettier_configs, { upward = true, path = buf_fname })[1]

		if prettier_config ~= nil and not is_prettier then
			vim.notify(
				string.format(
					"There is a `prettier` config (%s), but `%s` is not installed",
					prettier_config,
					prettier_cmd
				),
				vim.log.levels.WARN,
				{ title = "Conform" }
			)
		end

		if prettier_config ~= nil and is_prettier then
			return { prettier_cmd, stop_after_first = true }
		end

		local is_deno = conform.get_formatter_info(deno_cmd, buf).available
		local deno_config = vim.fs.find(deno_configs, { upward = true, path = buf_fname })[1]

		if deno_config ~= nil and not is_deno then
			vim.notify("There is a deno config, but deno is not installed", vim.log.levels.WARN, { title = "Conform" })
		end

		if deno_config ~= nil and is_deno then
			return { "deno_fmt", stop_after_first = true }
		end

		-- NOTE: The `biome-check` command combines the `biome` and `biome-organize-imports` commands
		-- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome-check.lua
		-- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome.lua
		-- https://github.com/kiyoon/conform.nvim/blob/f73ca2e94221d0374134b64c085d1847a6ed3593/lua/conform/formatters/biome-organize-imports.lua
		local is_biome = conform.get_formatter_info(biome_cmd, buf).available
		local biome_config = vim.fs.find(biome_configs, { upward = true, path = buf_fname })[1]

		if biome_config ~= nil and not is_biome then
			vim.notify(
				"There is a biome config, but biome is not installed",
				vim.log.levels.WARN,
				{ title = "Conform" }
			)
		end

		if biome_config ~= nil and is_biome then
			-- return { "biome", "biome-organize-imports" }
			return { "biome-check" }
		end

		-- Fallback to prettier with defaults for web-adjacent filetypes
		if is_prettier then
			return { prettier_cmd, stop_after_first = true }
		end

		return {}
	end

	conform.setup({
		log_level = vim.log.levels.DEBUG,
		formatters = {
			[vp_cmd] = {
				command = require("conform.util").from_node_modules("vp"),
				args = { "fmt", "--stdin-filepath", "$FILENAME" },
				stdin = true,
				cwd = function(_, ctx)
					return vp_fmt_root(ctx.filename)
				end,
			},
		},
		format_on_save = function(bufnr)
			if vim.g.vin_autoformat_enabled and not vim.b[bufnr].vin_autoformat_disabled then
				return { timeout_ms = 500, lsp_fallback = "fallback" }
			end
		end,
		formatters_by_ft = {
			astro = handle_shared_formatter,
			javascript = handle_shared_formatter,
			javascriptreact = handle_shared_formatter,
			markdown = handle_shared_formatter,
			json = handle_shared_formatter,
			typescript = handle_shared_formatter,
			typescriptreact = handle_shared_formatter,
			css = handle_shared_formatter,
			scss = handle_shared_formatter,
			graphql = handle_shared_formatter,
			html = handle_shared_formatter,
			lua = { "stylua" },
			svelte = handle_shared_formatter,
			yaml = handle_shared_formatter,
			toml = { "taplo" },
			go = { "gofmt" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
		},
	})

	vim.keymap.set("n", "<leader>aof", function()
		if vim.g.vin_autoformat_enabled then
			vim.g.vin_autoformat_enabled = false
		else
			vim.g.vin_autoformat_enabled = true
		end

		if vim.g.vin_autoformat_enabled then
			vim.notify("Autoformat enabled", vim.log.levels.INFO, { title = "Conform" })
		else
			vim.notify("Autoformat disabled", vim.log.levels.INFO, { title = "Conform" })
		end
	end, { desc = "Toggle Format on Save" })

	vim.keymap.set("n", "<leader>daf", function()
		local view = vim.fn.winsaveview()
		local vp_root = vp_fmt_root(vim.api.nvim_buf_get_name(0))
		local oxfmt = conform.get_formatter_info(oxfmt_cmd, 0)

		if vp_root or oxfmt.available then
			-- oxfmt applies the config's `ignorePatterns` even on stdin, so run it from the
			-- config root with only the basename to keep path-based patterns from matching
			local cmd = vp_root and { vp_root .. "/node_modules/.bin/vp", "fmt" } or { oxfmt.command }
			vim.list_extend(cmd, {
				"--stdin-filepath",
				vim.fs.basename(vim.api.nvim_buf_get_name(0)),
				"--ignore-path",
				"/dev/null",
			})

			local result = vim.system(cmd, {
				cwd = vp_root or vim.fs.root(0, oxfmt_configs) or vim.fn.getcwd(),
				stdin = vim.api.nvim_buf_get_lines(0, 0, -1, false),
			}):wait()

			if result.code ~= 0 then
				vim.notify(result.stderr, vim.log.levels.ERROR, { title = vp_root and "vp fmt" or "oxfmt" })
				return
			end

			vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n", { trimempty = true }))
		else
			vim.cmd("%!prettier --stdin-filepath % --ignore-path /dev/null")
		end

		vim.fn.winrestview(view)
	end, { desc = "[F]ormat with vp fmt, oxfmt or Prettier (ignoring ignore files)" })
end)
