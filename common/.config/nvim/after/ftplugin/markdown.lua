-- Lives in after/ because the runtime markdown ftplugin sets formatlistpat too.
-- Task checkboxes count as list markers, so wrapped todos indent under their text.
vim.opt_local.formatlistpat = [[^\s*\%(\d\+\.\|[-*+]\)\s\+\%(\[.\]\s\+\)\=]]
