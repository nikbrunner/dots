local Setup = {}

function Setup.files()
    local MF = require("mini.files")

    MF.setup({
        mappings = {
            close = "q",
            go_in = "l",
            go_in_plus = "L",
            go_out = "h",
            go_out_plus = "H",
            mark_goto = "'",
            mark_set = "m",
            reset = "<BS>",
            reveal_cwd = "@",
            show_help = "g?",
            synchronize = "=",
            trim_left = "<",
            trim_right = ">",
        },
    })

    local map_split = function(buf_id, lhs, direction)
        local rhs = function()
            -- Make new window and set it as target
            local cur_target = MF.get_explorer_state().target_window
            local new_target = vim.api.nvim_win_call(cur_target, function()
                vim.cmd(direction .. " split")
                return vim.api.nvim_get_current_win()
            end)

            MF.set_target_window(new_target)
            MF.go_in({ close_on_file = true })
        end

        -- Adding `desc` will result into `show_help` entries
        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local buf_id = args.data.buf_id
            -- Tweak keys to your liking
            map_split(buf_id, "<C-v>", "belowright vertical")
            map_split(buf_id, "<C-s>", "belowright horizontal")
            map_split(buf_id, "<C-t>", "tab")
        end,
    })
end

function Setup.ai()
    require("mini.ai").setup({})
end

function Setup.statusline()
    require("mini.statusline").setup({
        content = {
            active = function()
                local m = require("mini.statusline")

                local fnamemodify = vim.fn.fnamemodify

                local project_name = function()
                    local current_project_folder = fnamemodify(vim.fn.getcwd(), ":t")
                    local parent_project_folder = fnamemodify(vim.fn.getcwd(), ":h:t")
                    return parent_project_folder .. "/" .. current_project_folder
                end

                local lazy_plug_count = function()
                    local stats = require("lazy").stats()
                    return " " .. stats.count
                end

                local lazy_startup = function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    return " " .. ms .. "ms"
                end

                local lazy_updates = function()
                    return require("lazy.status").updates()
                end

                local word_count = function()
                    if vim.bo.filetype == "markdown" then
                        local words = vim.fn.wordcount().words
                        return " " .. words .. "w"
                    end
                    return ""
                end

                local mode, mode_hl = m.section_mode({ trunc_width = 120 })

                local git = m.section_git({ trunc_width = 75 })

                local relative_filepath = function()
                    local current_cols = vim.fn.winwidth(0)
                    if current_cols > 120 then
                        return vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.") -- Filename with relative path
                    else
                        return vim.fn.expand("%:t") -- Just the filename
                    end
                end

                local diagnostics = m.section_diagnostics({ trunc_width = 75 })
                local viewport = "󰊉 " .. vim.o.lines .. ":W" .. vim.o.columns
                local position = "󰩷 " .. vim.fn.line(".") .. ":" .. vim.fn.col(".")
                local filetype = " " .. vim.bo.filetype

                local black_atom_label = nil
                local black_atom_meta = require("black-atom.api").get_meta()

                if black_atom_meta then
                    black_atom_label = black_atom_meta.label
                end
                local colorscheme_name = black_atom_label or vim.g.colors_name or "default"
                local colorscheme = m.is_truncated(200) and "" or " " .. colorscheme_name

                local dev_mode = m.is_truncated(125) and "" or "DEV_MODE: " .. (require("config").dev_mode and "ON" or "OFF")

                return m.combine_groups({
                    { hl = mode_hl, strings = { mode } },
                    {
                        hl = "@function",
                        strings = (m.is_truncated(100) and {} or { project_name() }),
                    },
                    {
                        hl = "@variable.member",
                        strings = (m.is_truncated(200) and {} or { git }),
                    },

                    "%<", -- Mark general truncate point

                    { hl = "DiagnosticError", strings = { diagnostics } },

                    "%=", -- End left alignment

                    {
                        hl = "@function",
                        strings = { dev_mode, word_count(), position, viewport, filetype },
                    },
                    {
                        hl = "Comment",
                        strings = (m.is_truncated(165) and {} or {
                            lazy_plug_count(),
                            lazy_updates(),
                            lazy_startup(),
                            colorscheme,
                            "[" .. vim.o.background .. "]",
                        }),
                    },
                })
            end,
        },
    })
end

function Setup.icons()
    require("mini.icons").setup({
        file = {
            [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
            [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
            [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
            ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
            ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
            ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
            ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
        },
    })
end

---@type LazyPluginSpec
return {
    "echasnovski/mini.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
        Setup.files()
        Setup.ai()
        Setup.statusline()
        Setup.icons()
    end,
    keys = function()
        local MF = require("mini.files")

        return {
            {
                "<leader>we",
                function()
                    MF.open(vim.api.nvim_buf_get_name(0))
                end,
                desc = "Explorer",
            },
        }
    end,
}
