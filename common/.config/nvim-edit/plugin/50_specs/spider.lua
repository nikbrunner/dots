Edit.later(function()
	vim.pack.add({ "git@github.com:chrisgrieser/nvim-spider" })

	local spider = require("spider")

	vim.keymap.set({ "n", "o", "x" }, "w", function()
		spider.motion("w")
	end, { desc = "Spider: word" })

	vim.keymap.set({ "n", "o", "x" }, "e", function()
		spider.motion("e")
	end, { desc = "Spider: end of word" })

	vim.keymap.set({ "n", "o", "x" }, "b", function()
		spider.motion("b")
	end, { desc = "Spider: begin of word" })

	vim.keymap.set({ "n", "o", "x" }, "ge", function()
		spider.motion("ge")
	end, { desc = "Spider: end of word" })
end)
