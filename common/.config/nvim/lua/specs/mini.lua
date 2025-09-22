--- Sources:
--- https://github.com/JulesNP/nvim/blob/main/lua/plugins/mini.lua
--- https://github.com/SylvanFranklin/.config/blob/main/nvim/init.lua

local Mini = {}

-- https://github.com/echasnovski/mini.nvim/blob/2e38ed16c2ced64bcd576986ccad4b18e2006e18/doc/mini-pick.txt#L650-L660
Mini.win_config = {
    left_buf_corner = function()
        local height = math.floor(0.25 * vim.o.lines)
        local width = math.floor(0.35 * vim.o.columns)

        return {
            relative = "win",
            height = height,
            border = "solid",
            width = width,
            row = math.floor(vim.o.lines - 5),
            col = 10,
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

function Mini.files()
    local MiniFiles = require("mini.files")

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
            synchronize = "=",
            trim_left = "<",
            trim_right = ">",
        },
        options = {
            use_as_default_explorer = false,
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

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
            Snacks.rename.on_rename_file(event.data.from, event.data.to)
        end,
    })

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
    local map = vim.keymap.set

    vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
            local bufid = args.data.buf_id

            local function setBranch(path)
                MiniFiles.set_branch({ vim.fn.expand(path) })
            end

            -- stylua: ignore start
            map("n", "gx", ui_open, { buffer = bufid, desc = "OS open" })
            map("n", "gy", yank_path, { buffer = bufid, desc = "Yank path" })

            map("n", ".", function() setBranch(vim.fn.getcwd()) end, { buffer = bufid, desc = "Current working directory" })

            map("n", "0", function() setBranch("$HOME/repos/nikbrunner/dots") end, { buffer = bufid, desc = "Dots" })
            map("n", "1", function() setBranch("$HOME/repos/nikbrunner/notes") end, { buffer = bufid, desc = "Notes" })
            map("n", "2", function() setBranch("$HOME/repos/nikbrunner/dcd-notes") end, { buffer = bufid, desc = "DCD Notes" })

            map("n", "4", function() setBranch("$HOME/repos/black-atom-industries/core") end, { buffer = bufid, desc = "Black Atom - Core" })
            map("n", "5", function() setBranch("$HOME/repos/black-atom-industries/nvim") end, { buffer = bufid, desc = "Black Atom - Neovim" })
            map("n", "6", function() setBranch("$HOME/repos/black-atom-industries/radar.nvim") end, { buffer = bufid, desc = "Black Atom - Radar" })

            map("n", "7", function() setBranch("$HOME/repos/dealercenter-digital/bc-desktop-client") end, { buffer = bufid, desc = "DCD Desktop Client" })
            map("n", "8", function() setBranch("$HOME/repos/dealercenter-digital/bc-desktop-tools") end, { buffer = bufid, desc = "DCD Desktop Client" })
            map("n", "9", function() setBranch("$HOME/repos/dealercenter-digital/bc-web-client-poc") end, { buffer = bufid, desc = "DCD Web Client" })
            -- stylua: ignore end
        end,
    })

    -- stylua: ignore start
    map("n", "-", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "[E]xplorer" })
    map("n", "_", function() MiniFiles.open(vim.fn.getcwd()) end, { desc = "[E]xplorer" })
    map("n", "<leader>we", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end, { desc = "[E]xplorer" })
    -- stylua: ignore end
end

function Mini.pick()
    local MiniPick = require("mini.pick")
    local MiniFuzzy = require("mini.fuzzy")
    local MiniVisits = require("mini.visits")

    MiniPick.setup({
        mappings = {
            scroll_down = "<C-d>",
            scroll_left = "<C-h>",
            scroll_right = "<C-l>",
            scroll_up = "<C-u>",
        },
        window = {
            config = Mini.win_config.left_buf_corner,
            prompt_caret = "█",
            prompt_prefix = "  ",
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

    -- vim.keymap.set("n", "<leader>wd", MiniPick.registry.frecency, { desc = "Pick file" })
    -- vim.keymap.set("n", "<leader>ahp", "<cmd>Pick help<CR>", { desc = "[P]ages" })
    -- vim.keymap.set("n", "<leader>ds", function()
    --     require("mini.extra").pickers.lsp({ scope = "document_symbol" })
    -- end, { desc = "[S]ymbols" })
end

function Mini.extra()
    require("mini.extra").setup()
end

function Mini.visits()
    require("mini.visits").setup()
end

function Mini.ai()
    require("mini.ai").setup()
end

-- TODO: Clean up
function Mini.statusline()
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

                local mode, mode_hl = m.section_mode({ trunc_width = 120 })
                local git = m.section_git({ trunc_width = 75 })
                local diagnostics = m.section_diagnostics({ trunc_width = 75 })

                return m.combine_groups({
                    { hl = mode_hl, strings = { mode } },
                    {
                        hl = "@function",
                        strings = (m.is_truncated(100) and {} or { project_name() }),
                    },
                    {
                        hl = "@variable.member",
                        strings = { git },
                    },

                    "%<", -- Mark general truncate point

                    { hl = "DiagnosticError", strings = { diagnostics } },

                    "%=", -- End left alignment
                })
            end,
        },
    })
end

function Mini.icons()
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

function Mini.surround()
    require("mini.surround").setup({
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

function Mini.clue()
    local MiniClue = require("mini.clue")

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
            { mode = "n", keys = "m" },
            { mode = "n", keys = "z" },
            { mode = "n", keys = '"' },
            { mode = "n", keys = " " },
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

function Mini.test()
    require("mini.test").setup()
end

---@type LazyPluginSpec
return {
    "nvim-mini/mini.nvim",
    version = "*",
    lazy = false,
    config = function()
        -- Mini.pick()
        Mini.files()
        -- Mini.visits()
        -- Mini.extra()
        Mini.ai()
        Mini.statusline()
        Mini.icons()
        Mini.surround()
        Mini.clue()
        Mini.test()
    end,
}
