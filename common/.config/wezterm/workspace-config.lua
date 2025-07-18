local M = {}

-- Workspace configurations
M.workspaces = {
	default = {
		name = "default",
		tabs = {
			{
				title = "Home",
				cwd = os.getenv("HOME"),
			},
			{
				title = "Dots",
				cwd = os.getenv("HOME") .. "/repos/nikbrunner/dots",
				command = "nvim .\n",
			},
			{
				title = "Music",
				cwd = "/Users/nbr/pCloud Drive/02_AREAS/Music",
				command = "yazi\n",
			},
		},
		position = {
			origin = "MainScreen",
			x = 200,
			y = 300,
		},
	},
	private_notes = {
		name = "private-notes",
		tabs = {
			{
				title = "Private Notes",
				cwd = os.getenv("HOME") .. "/repos/nikbrunner/notes/",
				command = "nvim .\n",
			},
		},
	},
	work_notes = {
		name = "work-notes",
		tabs = {
			{
				title = "Work Notes",
				cwd = os.getenv("HOME") .. "/repos/nikbrunner/dcd-notes/",
				command = "nvim .\n",
			},
		},
	},
}

return M

