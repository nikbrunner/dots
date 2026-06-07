local MC = require("mini.clue")

MC.setup({
	triggers = {
		{ mode = "c", keys = "<C-r>" },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "<leader>" },
		{ mode = "n", keys = "<localleader>" },
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },
		{ mode = "n", keys = "`" },
		{ mode = "n", keys = "g" },
		{ mode = "n", keys = "s" },
		{ mode = "n", keys = "m" },
		{ mode = "n", keys = "z" },
		{ mode = "n", keys = "y" },
		{ mode = "n", keys = "S" },
		{ mode = "n", keys = "Z" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "<leader>" },
		{ mode = "x", keys = "`" },
		{ mode = "x", keys = "g" },
		{ mode = "x", keys = "z" },
		{ mode = "x", keys = '"' },
	},
	clues = {
		MC.gen_clues.builtin_completion(),
		MC.gen_clues.g(),
		MC.gen_clues.marks(),
		MC.gen_clues.registers(),
		MC.gen_clues.windows(),
		MC.gen_clues.z(),

		-- Z mappings (ZZ, ZQ, ZR)
		{ mode = "n", keys = "ZZ", desc = "Write & quit" },
		{ mode = "n", keys = "ZQ", desc = "Quit without saving" },
		{ mode = "n", keys = "ZR", desc = "Restart" },

		-- App
		{ mode = "n", keys = "<leader>a", desc = "[A]pp" },
		{ mode = "n", keys = "<leader>al", desc = "[L]anguages" },
		{ mode = "n", keys = "<leader>ah", desc = "[H]elp" },
		{ mode = "n", keys = "<leader>ap", desc = "[P]lugins" },
		{ mode = "n", keys = "<leader>ao", desc = "[O]ptions" },

		-- Workspace
		{ mode = "n", keys = "<leader>w", desc = "[W]orkspace" },
		{ mode = "n", keys = "<leader>wg", desc = "[G]it" },
		{ mode = "n", keys = "<leader>wgi", desc = "[I]ssues" },
		{ mode = "n", keys = "<leader>wgp", desc = "[P]ull Requests" },

		-- Document
		{ mode = "n", keys = "<leader>d", desc = "[D]ocument" },
		{ mode = "n", keys = "<leader>dy", desc = "[Y]ank" },
		{ mode = "n", keys = "<leader>dg", desc = "[G]it" },

		-- Symbol
		{ mode = "n", keys = "<leader>s", desc = "[S]ymbol" },
		{ mode = "n", keys = "<leader>sl", desc = "[L]og" },
		{ mode = "n", keys = "<leader>sc", desc = "[C]alls" },
		{ mode = "n", keys = "<leader>sg", desc = "[G]it" },

		-- Other
		{ mode = "n", keys = "<leader>c", desc = "[C]hange" },
		{ mode = "n", keys = "<leader>as", desc = "[S]ession" },
		{ mode = "n", keys = "<leader>h", desc = "[H]ttp" },
		{ mode = "n", keys = "<leader>n", desc = "[N]otes" },
		{ mode = "n", keys = "<leader>x", desc = "Trouble/Quickfix" },
	},
	window = {
		config = {
			width = math.floor(0.25 * vim.o.columns),
		},
		delay = 0,
	},
})
