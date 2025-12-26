---@type LazyPluginSpec
return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    event = "VeryLazy",
    -- ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false,
        -- Use the provided title/id if given, otherwise generate zettel-style ID
        note_id_func = function(title)
            if title ~= nil and title ~= "" then
                return title
            end
            -- Fallback to zettel-style ID for new notes without a title
            local suffix = ""
            for _ = 1, 4 do
                suffix = suffix .. string.char(math.random(65, 90))
            end
            return tostring(os.time()) .. "-" .. suffix
        end,
        workspaces = {
            {
                name = "notes",
                path = "~/repos/nikbrunner/notes",
            },
        },
        notes_subdir = "00 - Inbox",
        daily_notes = {
            folder = "02 - Areas/Log",
            date_format = "%Y/%m - %B/%Y.%m.%d - %A",
            template = "Daily Note.md",
        },
        templates = {
            folder = "05 - Meta/Templates",
            date_format = "%y.%m.%d — %A",
            time_format = "%H:%M",
            substitutions = {
                -- Handle Obsidian's native {{date:YYYY.MM.DD - dddd}} syntax
                ["date:YYYY.MM.DD - dddd"] = function()
                    return os.date("%Y.%m.%d - %A")
                end,
            },
        },
        checkbox = {
            enabled = true,
            create_new = true,
            order = { " ", ">", "x" },
        },
        completion = {
            blink = true,
            min_chars = 2,
        },
        picker = {
            name = "snacks.pick",
        },
        preferred_link_style = "wiki",
        ui = { enable = false },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)

        -- Command abbreviation: :o -> :Obsidian
        vim.cmd.cnoreabbrev("o", "Obsidian")
    end,
    keys = {
        { ",nd", "<cmd>Obsidian today<cr>", desc = "Daily note (today)" },
        { ",ny", "<cmd>Obsidian yesterday<cr>", desc = "Yesterday's note" },
        { ",nm", "<cmd>Obsidian tomorrow<cr>", desc = "Tomorrow's note" },
        { ",nn", "<cmd>Obsidian new<cr>", desc = "New note" },
        { ",ns", "<cmd>Obsidian search<cr>", desc = "Search notes" },
        { ",nq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
        { ",nl", "<cmd>Obsidian links<cr>", desc = "Note links" },
        { ",nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
        { ",nt", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    },
}
