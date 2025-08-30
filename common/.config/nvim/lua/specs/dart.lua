---@type LazyPluginSpec
return {
    "iofq/dart.nvim",
    enabled = false,
    event = "BufRead",
    opts = {
        -- List of characters to use to mark 'pinned' buffers
        -- The characters will be chosen for new pins in order
        -- marklist = { "a", "s", "d", "f", "q", "w", "e", "r" },
        marklist = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },

        -- List of characters to use to mark recent buffers, which are displayed first (left) in the tabline
        -- Buffers that are 'marked' are not included in this list
        -- The length of this list determines how many recent buffers are tracked
        -- Set to {} to disable recent buffers in the tabline
        -- buflist = { "z", "x", "c" },
        buflist = { "a", "s", "d", "f" },
        picker = {
            -- argument to pass to vim.fn.fnamemodify `mods`, before displaying the file path in the picker
            -- e.g. ":t" for the filename, ":p:." for relative path to cwd
            path_format = ":p:.",
        },
        persist = {
            path = vim.fs.joinpath(vim.fn.stdpath("config"), "dart"),
        },
        tabline = {
            -- Function to determine the order mark/buflist items will be shown on the tabline
            -- Accepts the entire Dart config table as an argument
            -- Should return a table with keys being the mark and values being integers,
            -- e.g. { "a": 1, "b", 2 } would sort the "a" mark to the left of "b" on your tabline
            order = function(config)
                local order = {}
                -- for i, key in ipairs(vim.list_extend(vim.deepcopy(config.buflist), config.marklist)) do
                --     order[key] = i
                -- end

                -- Numbers from 1 to 9 first, then a-z
                for i, key in ipairs(vim.list_extend(config.marklist, vim.deepcopy(config.buflist))) do
                    order[key] = i
                end
                return order
            end,

            -- Function to format a tabline item after the path is built
            -- e.g. to add an icon
            -- Accepts an item (as created by gen_tabline_item())
            format_item = function(item)
                local click = string.format("%%%s@SwitchBuffer@", item.bufnr)
                return string.format("%%#%s#%s %s%%#%s#%s %%X", item.hl_label, click, item.label, item.hl, item.content)
            end,
        },
    },
}
