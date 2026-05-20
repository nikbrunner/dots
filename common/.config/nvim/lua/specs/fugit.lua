---@type LazyPluginSpec
return {
    -- "nikbrunner/minifugit.nvim",
    dir = require("lib.config").get_repo_path("nikbrunner/minifugit.nvim"),
    cmd = { "MinifugitStatus" },
    keys = {
        { "gs", "<cmd>MinifugitStatus<cr>", desc = "Git Status" },
    },
    opts = {
        preview = {
            -- Start diff previews with wrapping disabled.
            wrap = false,

            -- Show old/new line numbers in diff previews.
            show_line_numbers = true,

            -- Show git diff metadata rows such as `diff --git`, `index`, `---`,
            -- and `+++`.
            show_metadata = false,

            -- Diff preview layout: 'stacked', 'split', or 'auto'.
            diff_layout = "split",

            -- Editor width where 'auto' switches from stacked to split.
            diff_auto_threshold = 120,
        },
        status = {
            -- Fraction of the editor width used by the status window.
            width = 0.35,

            -- Minimum status window width in columns.
            min_width = 20,

            -- Layout: 'topleft' (opens far left) or 'replace' (replaces
            -- current buffer, like Oil).
            layout = "replace",
        },
    },
}
