-- ┌────────────────────────────────────────┐
-- │ nvim-edit — init.lua (minimal bootstrap)│
-- └────────────────────────────────────────┘
-- Defines the Config table, helpers, and loads mini.nvim.
-- Options, keymaps, autocmds live in plugin/10_*.lua (auto-loaded).
-- Plugin specs live in plugin/50_specs/*.lua (auto-loaded).

-- Disable netrw entirely — mini.files is the file explorer. Must be set
-- here, before runtime plugins (incl. netrw) are sourced.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ┌────────────────┐
-- │ Config helpers │
-- └────────────────┘

---@class Edit
_G.Edit = {}

-- Load project-specific `.nvim.lua` files (run `:trust` to allow execution).
-- Must live here: the exrc search runs right after init.lua, before plugin/ files.
vim.o.exrc = true

local gr = vim.api.nvim_create_augroup("nvim-edit", {})
Edit.new_autocmd = function(event, pattern, callback, desc)
	vim.api.nvim_create_autocmd(event, { group = gr, pattern = pattern, callback = callback, desc = desc })
end

Edit.on_packchanged = function(plugin_name, kinds, callback, desc)
	local f = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback(ev.data)
	end
	Edit.new_autocmd("PackChanged", "*", f, desc)
end

-- ┌────────────────┐
-- │ Load mini.nvim │
-- └────────────────┘
-- (must come before defining Config.now/later so they can use mini.misc.safely)

vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

local misc = require("mini.misc")
Edit.now = function(f)
	misc.safely("now", f)
end
Edit.later = function(f)
	misc.safely("later", f)
end
Edit.now_if_args = vim.fn.argc(-1) > 0 and Edit.now or Edit.later
Edit.on_event = function(ev, f)
	misc.safely("event:" .. ev, f)
end
Edit.on_filetype = function(ft, f)
	misc.safely("filetype:" .. ft, f)
end
