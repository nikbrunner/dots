-- Deferred via `Edit.later`: mini.ai textobjects (a/ i/ in Visual) are
-- editing actions that never fire on the first frame.
Edit.later(function()
	require("mini.ai").setup({
		mappings = {

			-- TODO: use native vim motions
			around_next = "",
			inside_next = "",
			around_last = "",
			inside_last = "",
		},
	})
end)
