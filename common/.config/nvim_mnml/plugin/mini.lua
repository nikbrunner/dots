local win_config = {
    left_buf_corner = function()
        local height = math.floor(0.2 * vim.o.lines)
        local width = math.floor(0.35 * vim.o.columns)

        return {
            relative = "win",
            height = height,
            width = width,
            row = math.floor(vim.o.lines - 5),
            col = 10,
            border = "solid",
        }
    end,
    cursor = function()
        return {
            relative = "cursor",
            anchor = "NW",
            row = 0,
            col = 0,
        }
    end,
}

local function setup_files()
    local present, MiniFiles = pcall(require, "mini.files")

    if not present then
        vim.notify_once("`mini.files` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniFiles.setup({
        mappings = {
            show_help = "g?",
            close = "q",
            go_in = "l",
            go_in_plus = "<CR>",
            go_out = "h",
            go_out_plus = "H",
            mark_goto = "'",
            mark_set = "m",
            reset = "<BS>",
            reveal_cwd = "@",
            synchronize = "w",
            trim_left = "<",
            trim_right = ">",
        },
    })

    local map_split = function(buf_id, lhs, direction)
        local rhs = function()
            -- Make new window and set it as target
            local cur_target = MiniFiles.get_explorer_state().target_window
            local new_target = vim.api.nvim_win_call(cur_target, function()
                vim.cmd(direction .. " split")
                return vim.api.nvim_get_current_win()
            end)

            MiniFiles.set_target_window(new_target)
            MiniFiles.go_in({ close_on_file = true })
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

    -- Set focused directory as current working directory
    local set_cwd = function()
        local path = (MiniFiles.get_fs_entry() or {}).path
        if path == nil then
            return vim.notify("Cursor is not on valid entry")
        end
        vim.fn.chdir(vim.fs.dirname(path))
    end

    -- Yank in register full path of entry under cursor
    local yank_path = function()
        local path = (MiniFiles.get_fs_entry() or {}).path
        if path == nil then
            return vim.notify("Cursor is not on valid entry")
        end
        vim.fn.setreg(vim.v.register, path)
    end

    -- Open path with system default handler (useful for non-text files)
    local ui_open = function()
        vim.ui.open(MiniFiles.get_fs_entry().path)
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local b = args.data.buf_id
            vim.keymap.set("n", ".", set_cwd, { buffer = b, desc = "Set cwd" })
            vim.keymap.set("n", "gx", ui_open, { buffer = b, desc = "OS open" })
            vim.keymap.set("n", "gy", yank_path, { buffer = b, desc = "Yank path" })
        end,
    })

    vim.keymap.set("n", "-", function()
        MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end, { desc = "Explorer" })
end

local function setup_pick()
    local present_pick, MiniPick = pcall(require, "mini.pick")
    local present_fuzzy, MiniFuzzy = pcall(require, "mini.fuzzy")
    local present_visits, MiniVisits = pcall(require, "mini.visits")

    if not present_pick then
        vim.notify_once("`mini.pick` module not found!", vim.log.levels.ERROR)
        return
    end

    if not present_fuzzy then
        vim.notify_once("`mini.fuzzy` module not found!", vim.log.levels.ERROR)
        return
    end

    if not present_visits then
        vim.notify_once("`mini.visits` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniPick.setup({
        mappings = {
            scroll_down = "<C-d>",
            scroll_left = "<C-h>",
            scroll_right = "<C-l>",
            scroll_up = "<C-u>",
        },
        window = {
            config = win_config.left_buf_corner,
            prompt_caret = "█",
            prompt_prefix = "  ",
        },
    })

    MiniPick.registry.frecency = function()
        local visit_paths = MiniVisits.list_paths()
        local current_file = vim.fn.expand("%")

        MiniPick.builtin.files(nil, {
            source = {
                match = function(stritems, indices, query)
                    -- Concatenate prompt to a single string
                    local prompt = vim.pesc(table.concat(query))

                    -- If ignorecase is on and there are no uppercase letters in prompt,
                    -- convert paths to lowercase for matching purposes
                    local convert_path = function(str)
                        return str
                    end
                    if vim.o.ignorecase and string.find(prompt, "%u") == nil then
                        convert_path = function(str)
                            return string.lower(str)
                        end
                    end

                    local current_file_cased = convert_path(current_file)
                    local paths_length = #visit_paths

                    -- Flip visit_paths so that paths are lookup keys for the index values
                    local flipped_visits = {}
                    for index, path in ipairs(visit_paths) do
                        local key = vim.fn.fnamemodify(path, ":.")
                        flipped_visits[convert_path(key)] = index - 1
                    end

                    local result = {}
                    for _, index in ipairs(indices) do
                        local path = stritems[index]
                        local match_score = prompt == "" and 0 or MiniFuzzy.match(prompt, path).score
                        if match_score >= 0 then
                            local visit_score = flipped_visits[path] or paths_length
                            table.insert(result, {
                                index = index,
                                -- Give current file high value so it's ranked last
                                score = path == current_file_cased and 999999 or match_score + visit_score * 10,
                            })
                        end
                    end

                    table.sort(result, function(a, b)
                        return a.score < b.score
                    end)

                    return vim.tbl_map(function(val)
                        return val.index
                    end, result)
                end,
            },
        })
    end

    vim.keymap.set("n", "<leader><leader>", MiniPick.registry.frecency, { desc = "Pick file" })
    vim.keymap.set("n", "<leader>ahp", "<cmd>Pick help<CR>", { desc = "[P]ages" })
    vim.keymap.set("n", "<leader>ds", "<cmd>Pick lsp scope='document_symbol'<CR>", { desc = "[S]ymbols" })
    vim.keymap.set("n", "<leader>ds", function()
        require("mini.extra").pickers.lsp({ scope = "document_symbol" })
    end, { desc = "[S]ymbols" })
end

local function setup_extra()
    local present, MiniExtra = pcall(require, "mini.extra")

    if not present then
        vim.notify_once("`mini.extra` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniExtra.setup()
end

local function setup_visits()
    local present, MiniVisits = pcall(require, "mini.visits")

    if not present then
        vim.notify_once("`mini.visits` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniVisits.setup()
end

local function setup_ai()
    local present, MiniAi = pcall(require, "mini.ai")

    if not present then
        vim.notify_once("`mini.ai` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniAi.setup()
end

-- TODO: Clean up
local function setup_statusline()
    local present, MiniStatusline = pcall(require, "mini.statusline")

    if not present then
        vim.notify_once("`mini.statusline` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniStatusline.setup({
        content = {
            active = function()
                local m = require("mini.statusline")

                local fnamemodify = vim.fn.fnamemodify

                local project_name = function()
                    local current_project_folder = fnamemodify(vim.fn.getcwd(), ":t")
                    local parent_project_folder = fnamemodify(vim.fn.getcwd(), ":h:t")
                    return parent_project_folder .. "/" .. current_project_folder
                end

                local word_count = function()
                    if vim.bo.filetype == "markdown" then
                        local words = vim.fn.wordcount().words
                        return " " .. words .. " "
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

                local black_atom_label = nil
                local black_atom_meta = require("black-atom.api").get_meta()

                if black_atom_meta then
                    black_atom_label = black_atom_meta.label
                end
                local colorscheme_name = black_atom_label or vim.g.colors_name or "N/A"
                local colorscheme = m.is_truncated(200) and "" or "  " .. colorscheme_name

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

                    {
                        hl = "@comment",
                        strings = { relative_filepath() },
                    },

                    "%<", -- Mark general truncate point

                    { hl = "DiagnosticError", strings = { diagnostics } },

                    "%=", -- End left alignment

                    {
                        hl = "Comment",
                        strings = (m.is_truncated(165) and {} or {
                            word_count(),
                            colorscheme,
                            "[" .. vim.o.background .. "]",
                        }),
                    },
                })
            end,
        },
    })
end

local function setup_icons()
    local present, MiniIcons = pcall(require, "mini.icons")

    if not present then
        vim.notify_once("`mini.icons` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniIcons.setup({
        file = {
            [".eslintrc.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            [".node-version"] = { glyph = "", hl = "MiniIconsGreen" },
            [".prettierrc"] = { glyph = "", hl = "MiniIconsPurple" },
            [".yarnrc.yml"] = { glyph = "", hl = "MiniIconsBlue" },
            ["eslint.config.js"] = { glyph = "󰱺", hl = "MiniIconsYellow" },
            ["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
            ["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" },
            ["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" },
            ["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" },
        },
    })
end

local function setup_surround()
    local present, MiniSurround = pcall(require, "mini.surround")

    if not present then
        vim.notify_once("`mini.surround` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniSurround.setup({
        mappings = {
            add = "Sa", -- Add surrounding in Normal and Visual modes
            delete = "Sd", -- Delete surrounding
            find = "Sf", -- Find surrounding (to the right)
            find_left = "SF", -- Find surrounding (to the left)
            highlight = "Sh", -- Highlight surrounding
            replace = "Sr", -- Replace surrounding
            update_n_lines = "Sn", -- Update `n_lines`
        },
    })
end

local function setup_clue()
    local present, MiniClue = pcall(require, "mini.clue")

    if not present then
        vim.notify_once("`mini.clue` module not found!", vim.log.levels.ERROR)
        return
    end

    MiniClue.setup({
        triggers = {
            { mode = "c", keys = "<C-r>" },
            { mode = "i", keys = "<C-r>" },
            { mode = "i", keys = "<C-x>" },
            { mode = "n", keys = "'" },
            { mode = "n", keys = "<C-w>" },
            { mode = "n", keys = "<Leader>" },
            { mode = "n", keys = "[" },
            { mode = "n", keys = "]" },
            { mode = "n", keys = "`" },
            { mode = "n", keys = "g" },
            { mode = "n", keys = "s" },
            { mode = "n", keys = "z" },
            { mode = "n", keys = '"' },
            { mode = "x", keys = "'" },
            { mode = "x", keys = "<Leader>" },
            { mode = "x", keys = "`" },
            { mode = "x", keys = "g" },
            { mode = "x", keys = "z" },
            { mode = "x", keys = '"' },
        },
        clues = {
            MiniClue.gen_clues.builtin_completion(),
            MiniClue.gen_clues.g(),
            MiniClue.gen_clues.marks(),
            MiniClue.gen_clues.registers(),
            MiniClue.gen_clues.windows(),
            MiniClue.gen_clues.z(),
            { mode = "n", keys = "<Leader>a", desc = "[A]pp" },
            { mode = "n", keys = "<Leader>w", desc = "[W]orkspace" },
            { mode = "n", keys = "<Leader>d", desc = "[D]ocument" },
            { mode = "n", keys = "<Leader>c", desc = "[C]ange" },
        },
        window = {
            config = {
                width = math.floor(0.35 * vim.o.columns),
            },
            delay = 350,
        },
    })
end

-- Initialize all mini modules
setup_visits()
setup_extra()
setup_files()
setup_pick()
setup_extra()
setup_ai()
setup_statusline()
setup_icons()
setup_pick()
setup_surround()
setup_clue()