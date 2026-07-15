return {
    "chpeters/annotator.nvim",
    keys = {
        -- Document → Annotate
        {
            "<leader>daa",
            function()
                require("annotator").add()
            end,
            desc = "[A]dd",
            mode = { "n", "v" },
        },
        {
            "<leader>das",
            function()
                require("annotator").suggest()
            end,
            desc = "[S]uggest rewrite",
            mode = { "n", "v" },
        },
        -- { "<leader>dam", function() require("annotator").mark_delete() end, desc = "[M]ark for deletion", mode = { "n", "v" } },
        {
            "<leader>dad",
            function()
                require("annotator").delete()
            end,
            mode = { "n", "v" },
            desc = "[D]elete annotation",
        },
        {
            "<leader>dae",
            function()
                require("annotator").edit()
            end,
            desc = "[E]dit annotation",
        },
        {
            "<leader>dal",
            function()
                require("annotator").list()
            end,
            desc = "[L]ist annotations",
        },
        {
            "<leader>daE",
            function()
                require("annotator").export()
            end,
            desc = "[E]xport annotations",
        },
    },
    opts = {
        mappings = false,
        storage = "state",
    },
}
