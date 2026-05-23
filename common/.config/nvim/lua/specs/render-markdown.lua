return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            max_file_size = 5.0,
            ignore = function(buf)
                return vim.api.nvim_buf_line_count(buf) > 2000
            end,
            render_modes = { "n", "c", "t", "i", "v" },
            completions = { lsp = { enabled = true } },
            debounce = 1000,
            bullet = {
                icons = "󰛄 ",
            },
            win_options = {
                conceallevel = {
                    default = 0,
                    rendered = vim.o.conceallevel,
                },
            },
            checkbox = {
                unchecked = {
                    icon = "󰄰 ",
                },
                checked = {
                    icon = "󰗠 ",
                    -- highlight = "RenderMarkdownSuccess",
                    highlight = "@markup.list.checked",
                },
                custom = {
                    progress = {
                        raw = "[~]",
                        rendered = "󰦕 ",
                        highlight = "@markup.list.unchecked",
                    },
                    event = {
                        raw = "[o]",
                        rendered = "󰃭 ",
                        highlight = "RenderMarkdownInfo",
                    },
                    migrated = {
                        raw = "[>]",
                        rendered = "󰁖 ",
                        highlight = "RenderMarkdownWarn",
                    },
                    scheduled = {
                        raw = "[<]",
                        rendered = "󰸗 ",
                        highlight = "RenderMarkdownInfo",
                    },
                    cancelled = {
                        raw = "[-]",
                        rendered = "󰜺 ",
                        highlight = "RenderMarkdownError",
                    },
                },
            },
        },
    },
}
