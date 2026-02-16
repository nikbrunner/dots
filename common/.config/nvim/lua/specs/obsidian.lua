-- Force English locale for date formatting (prevents German month/day names)

local periodic = require("lib.periodic")

---@type LazyPluginSpec
return {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    event = "VeryLazy",
    -- ft = "markdown", // Always load
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
        legacy_commands = false,
        -- Use the provided title/id if given, otherwise generate zettel-style ID
        workspaces = {
            {
                name = "notes",
                path = "~/repos/nikbrunner/notes",
            },
        },
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
                -- Map Obsidian's {{date:FORMAT}} syntax to Lua os.date equivalents.
                -- Each key matches a {{date:*}} token used in our periodic note templates.
                ["date:YYYY.MM.DD - dddd"] = function()
                    return tostring(os.date("%Y.%m.%d - %A"))
                end,
                ["date:YYYY.MM - MMMM"] = function()
                    return tostring(os.date("%Y.%m - %B"))
                end,
                ["date:YYYY"] = function()
                    return tostring(os.date("%Y"))
                end,
                ["date:w"] = function()
                    return tostring(periodic.locale_week())
                end,
                ["date:Q"] = function()
                    return tostring(math.ceil(tonumber(os.date("%m")) / 3))
                end,
                -- Linter-compatible timestamp: "Saturday, February 15th 2026, 2:30:45 pm"
                ["date:dddd, MMMM Do YYYY, h:mm:ss a"] = function()
                    local day = tonumber(os.date("%d"))
                    local last_two = day % 100
                    local suffix
                    if last_two >= 11 and last_two <= 13 then
                        suffix = "th"
                    else
                        local last_one = day % 10
                        if last_one == 1 then
                            suffix = "st"
                        elseif last_one == 2 then
                            suffix = "nd"
                        elseif last_one == 3 then
                            suffix = "rd"
                        else
                            suffix = "th"
                        end
                    end
                    local hour24 = tonumber(os.date("%H"))
                    local hour12 = hour24 % 12
                    if hour12 == 0 then hour12 = 12 end
                    local ampm = hour24 < 12 and "am" or "pm"
                    return os.date("%A, %B ")
                        .. day
                        .. suffix
                        .. os.date(" %Y, ")
                        .. hour12
                        .. os.date(":%M:%S ")
                        .. ampm
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
        os.setlocale("C", "time")
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
        {
            ",npw",
            function()
                periodic.open("weekly")
            end,
            desc = "Periodic: weekly",
        },
        {
            ",npm",
            function()
                periodic.open("monthly")
            end,
            desc = "Periodic: monthly",
        },
        {
            ",npq",
            function()
                periodic.open("quarterly")
            end,
            desc = "Periodic: quarterly",
        },
        {
            ",npy",
            function()
                periodic.open("yearly")
            end,
            desc = "Periodic: yearly",
        },
        -- General notes
        { ",nd", "<cmd>Obsidian dailies<cr>", desc = "Dailies" },
        { ",nn", "<cmd>Obsidian new<cr>", desc = "New note" },
        { ",ns", "<cmd>Obsidian search<cr>", desc = "Search notes" },
        { ",nq", "<cmd>Obsidian quick_switch<cr>", desc = "Quick switch" },
        { ",nl", "<cmd>Obsidian links<cr>", desc = "Note links" },
        { ",nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
        { ",nT", "<cmd>Obsidian template<cr>", desc = "Insert template" },
        { ",nt", "<cmd>Obsidian tags<cr>", desc = "Search tags" },
        { ",no", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian" },
        { ",nr", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
        { ",nc", "<cmd>Obsidian toc<cr>", desc = "Table of contents" },
    },
}
