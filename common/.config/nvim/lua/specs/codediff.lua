return {
    {
        "esmuellert/codediff.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        cmd = "CodeDiff",
        event = "VeryLazy",
        keys = {
            -- Workspace level
            { "<leader>wgd", "<cmd>CodeDiff<cr>", desc = "Workspace [D]iff to `master` (CodeDiff)" },
            { "<leader>wgD", "<cmd>CodeDiff master<cr>", desc = "Workspace [D]iff (CodeDiff)" },

            -- Document level
            { "<leader>dgd", "<cmd>CodeDiff file HEAD<cr>", desc = "Document [D]iff (CodeDiff)" },
            { "<leader>dgD", "<cmd>CodeDiff file master<cr>", desc = "Document [D]iff (CodeDiff)" },

            {
                "<leader>wgb",
                function()
                    vim.ui.input({ prompt = "Compare against branch: " }, function(branch)
                        if branch and branch ~= "" then
                            vim.cmd("CodeDiff " .. branch)
                        end
                    end)
                end,
                desc = "Compare [B]ranch (CodeDiff)",
            },

            { "<leader>wgpm", "<cmd>CodeDiff merge<cr>", desc = "[M]erge conflicts (CodeDiff)" },
        },
        opts = {
            char_brightness = 1, -- disable auto-adjustment
            explorer = {
                view_mode = "tree",
            },
            keymaps = {
                view = {
                    quit = "q",
                    toggle_explorer = "<leader>b",
                    focus_explorer = "<leader>e",
                    next_hunk = "]c",
                    prev_hunk = "[c",
                    next_file = "]f",
                    prev_file = "[f",
                    diff_get = "do",
                    diff_put = "dp",
                    open_in_prev_tab = "gf",
                    close_on_open_in_prev_tab = false,
                    toggle_stage = "-",
                    hunk_textobject = "ih",
                    show_help = "g?",
                    align_move = "gm",
                    toggle_layout = "t",
                },
                explorer = {
                    select = "<CR>",
                    hover = "K",
                    refresh = "R",
                    open_in_prev_tab = "gf",
                    toggle_view_mode = "i",
                    stage_all = "S",
                    unstage_all = "U",
                    restore = "X",
                    toggle_changes = "gu",
                    toggle_staged = "gs",
                    fold_open = "zo",
                    fold_open_recursive = "zO",
                    fold_close = "zc",
                    fold_close_recursive = "zC",
                    fold_toggle = "za",
                    fold_toggle_recursive = "zA",
                    fold_open_all = "zR",
                    fold_close_all = "zM",
                },
                history = {
                    select = "<CR>",
                    toggle_view_mode = "i",
                    fold_open = "zo",
                    fold_open_recursive = "zO",
                    fold_close = "zc",
                    fold_close_recursive = "zC",
                    fold_toggle = "za",
                    fold_toggle_recursive = "zA",
                    fold_open_all = "zR",
                    fold_close_all = "zM",
                },
                conflict = {
                    accept_incoming = "<leader>ct",
                    accept_current = "<leader>co",
                    accept_both = "<leader>cb",
                    discard = "<leader>cx",
                    next_conflict = "]x",
                    prev_conflict = "[x",
                    diffget_incoming = "2do",
                    diffget_current = "3do",
                },
            },
        },
    },
    {
        "chpeters/annotator.nvim",
        event = "VeryLazy",
        keys = {
            -- Document → Annotate
            { "<leader>daa", function() require("annotator").add() end, desc = "[A]dd" },
            { "<leader>daa", function() require("annotator").add_visual() end, desc = "[A]dd", mode = "v" },
            { "<leader>das", function() require("annotator").suggest() end, desc = "[S]uggest rewrite" },
            { "<leader>das", function() require("annotator").suggest_visual() end, desc = "[S]uggest rewrite", mode = "v" },
            -- { "<leader>dam", function() require("annotator").mark_delete() end, desc = "[M]ark for deletion" },
            -- { "<leader>dam", function() require("annotator").mark_delete_visual() end, desc = "[M]ark for deletion", mode = "v" },
            { "<leader>dad", function() require("annotator").delete() end, desc = "[D]elete annotation" },
            { "<leader>dae", function() require("annotator").edit() end, desc = "[E]dit annotation" },
            { "<leader>daL", function() require("annotator").list() end, desc = "[L]ist annotations" },
            { "<leader>daE", function() require("annotator").export() end, desc = "[E]xport annotations" },
        },
        opts = {
            mappings = false,
            storage = "state",
        },
    },
    {
        "nikbrunner/review.nvim",
        enabled = false,
        dir = require("lib.config").get_repo_path("nikbrunner/review.nvim"),
        dependencies = {
            "esmuellert/codediff.nvim",
            "MunifTanjim/nui.nvim",
        },
        event = "VeryLazy",
        cmd = "Review",
        keys = {
            { "<leader>wgpr", "<cmd>Review<cr>", desc = "[R]eview diff (review.nvim)" },
        },
        opts = {},
    },
}
