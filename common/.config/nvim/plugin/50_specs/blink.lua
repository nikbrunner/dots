-- Completion engine: blink.cmp
-- Replaces mini.completion. Uses mini.snippets as the snippet engine
-- (preset = "mini_snippets"). SuperMaven runs independently alongside
-- blink.cmp (ghost text + own keymaps), not as a blink source.
--
-- Ported from the old nvim/ config (commit cb4fd8e7~1:lua/specs/blink.lua).
-- Pinned to v1.* (v2 requires Neovim 0.12+ and a separate 'blink.lib'
-- native dependency — v1 is simpler and is what the old config used).

Edit.later(function()
	vim.pack.add({
		{ src = "git@github.com:saghen/blink.cmp", version = vim.version.range("1.*") },
	})

	require("blink.cmp").setup({
		keymap = {
			preset = "default",
			-- <Tab>: accept SuperMaven ghost text if present, else accept blink
			-- completion if menu visible, else snippet forward, else fallback.
			-- <S-Tab>: accept SuperMaven word, else snippet backward, else fallback.
			-- <C-e>: clear SuperMaven suggestion, else cancel blink menu.
			["<Tab>"] = {
				function()
					local preview = require("supermaven-nvim.completion_preview")
					local inlay = preview:get_inlay_instance()
					if inlay and inlay.is_active then
						vim.schedule(function()
							preview.on_accept_suggestion()
						end)
						return true
					end
				end,
				"select_and_accept",
				"snippet_forward",
				"fallback",
			},
			["<S-Tab>"] = {
				function()
					local preview = require("supermaven-nvim.completion_preview")
					local inlay = preview:get_inlay_instance()
					if inlay and inlay.is_active then
						vim.schedule(function()
							preview.on_accept_suggestion_word()
						end)
						return true
					end
				end,
				"snippet_backward",
				"fallback",
			},
			["<C-e>"] = {
				function()
					local preview = require("supermaven-nvim.completion_preview")
					if preview:get_inlay_instance() then
						preview.on_dispose_inlay()
						return true
					end
				end,
				"cancel",
				"fallback",
			},
		},
		sources = {
			default = { "lazydev", "lsp", "snippets", "buffer", "path" },
			providers = {
				lsp = { fallbacks = {} },
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		snippets = { preset = "mini_snippets" },
		signature = { enabled = true },
		appearance = {
			kind_icons = {},
		},
		completion = {
			list = {
				selection = {
					preselect = false,
					auto_insert = true,
				},
			},
			accept = {
				auto_brackets = {
					enabled = false,
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
			},
			menu = {
				border = "solid",
				winblend = 10,
				auto_show_delay_ms = 350,
				draw = {
					columns = {
						{ "kind", gap = 1 },
						{ "label", "label_description", gap = 1 },
						{ "source_name" },
					},
					components = {
						kind = {
							text = function(ctx)
								return ctx.kind:sub(1, 4):upper()
							end,
						},
					},
				},
			},
		},
		cmdline = {
			keymap = {
				preset = "default",
			},
			completion = {
				menu = {
					auto_show = true,
				},
			},
		},
	})

	-- Wire blink's LSP capabilities into all servers
	vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities(nil, true) })
end)
