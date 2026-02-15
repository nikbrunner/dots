-- Force English locale for date formatting (prevents German month/day names)
os.setlocale("C", "time")

local periodic = require("lib.periodic")

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
            folder = periodic.log_dir,
            date_format = periodic.notes.daily.path_fmt,
            template = "Daily Note.md",
        },
        templates = {
            folder = periodic.templates_dir,
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
        ui = {
            enable = false,
            -- Empty hl_groups prevents obsidian.nvim from overriding colorscheme highlights
            -- See: https://github.com/epwalsh/obsidian.nvim/issues/755
            hl_groups = {},
        },
    },
    config = function(_, opts)
        require("obsidian").setup(opts)

        -- Command abbreviation: :o -> :Obsidian
        vim.cmd.cnoreabbrev("o", "Obsidian")
    end,
    keys = {
        -- Periodic notes (daily via obsidian.nvim)
        { ",npd", "<cmd>Obsidian today<cr>", desc = "Periodic: daily (today)" },
        { ",nph", "<cmd>Obsidian yesterday<cr>", desc = "Periodic: prev daily" },
        { ",npl", "<cmd>Obsidian tomorrow<cr>", desc = "Periodic: next daily" },
        { ",npD", "<cmd>Obsidian dailies<cr>", desc = "Periodic: dailies picker" },
        -- Periodic notes (weekly/monthly/quarterly/yearly via lib.periodic)
        { ",npw", function() periodic.open("weekly") end, desc = "Periodic: weekly" },
        { ",npm", function() periodic.open("monthly") end, desc = "Periodic: monthly" },
        { ",npq", function() periodic.open("quarterly") end, desc = "Periodic: quarterly" },
        { ",npy", function() periodic.open("yearly") end, desc = "Periodic: yearly" },
        -- General notes
        { ",nn", "<cmd>Obsidian new<cr>", desc = "New note" },
        { ",ns", "<cmd>Obsidian search<cr>", desc = "Search notes" },
        { ",nq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
        { ",nl", "<cmd>Obsidian links<cr>", desc = "Note links" },
        { ",nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
        { ",nt", "<cmd>Obsidian template<cr>", desc = "Insert template" },
        { ",nT", "<cmd>Obsidian tags<cr>", desc = "Search tags" },
        { ",no", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian" },
        { ",nr", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
        { ",nc", "<cmd>Obsidian toc<cr>", desc = "Table of contents" },
        { ",nx", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox" },
    },
}
