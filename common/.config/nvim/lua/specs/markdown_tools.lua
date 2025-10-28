local date_format = "%Y.%m.%d - %A"

---@type LazyPluginSpec
return {
    "magnusriga/markdown-tools.nvim",
    dependencies = "folke/snacks.nvim",
    ft = "markdown",
    opts = {
        picker = "snacks",

        -- Obsidian should handle this
        insert_frontmatter = false,

        frontmatter_date = function()
            return date_format
        end,

        commands = {
            -- All these are hanlded by Obsidian
            -- create_from_template = false,
            -- insert_checkbox = false,
            -- toggle_checkbox = false,
        },

        -- Keymappings for shortcuts. Set to `false` or `""` to disable.
        keymaps = {
            -- Use <leader>ni prefix for markdown insert operations
            insert_header = "<leader>nih", -- Header
            insert_code_block = "<leader>nic", -- Code block
            insert_bold = "<leader>nib", -- Bold
            insert_highlight = "<leader>niH", -- Highlight
            insert_italic = "<leader>nii", -- Italic
            insert_link = "<leader>nil", -- Link
            insert_table = "<leader>niT", -- Table
            insert_checkbox = "<leader>nit", -- Checkbox (checKbox)
            toggle_checkbox = "<C-t>", -- Toggle Checkbox (keep this as is)
            preview = "<leader>np", -- Preview
        },

        -- This handles Obisidian
        enable_local_options = false,
    },
}
