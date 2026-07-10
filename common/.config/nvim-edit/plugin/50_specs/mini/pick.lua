-- Frecency/visit tracking used by Edit.pickers.smart_files (see
-- plugin/50_specs/mini/pick.lib.lua and plugin/50_specs/snacks.lua, which
-- owns the actual picker backend and keymaps).
Edit.later(function()
	require("mini.visits").setup()
end)
