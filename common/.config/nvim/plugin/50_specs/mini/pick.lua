-- Frecency/visit tracking for the smart files picker
-- (pack/local/start/edit-picker/plugin/edit-picker.lua).
Edit.later(function()
	require("mini.visits").setup()
end)
