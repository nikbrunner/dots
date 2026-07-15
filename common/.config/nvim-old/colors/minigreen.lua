local palette = require("mini.hues").make_palette({
    background = "#232019",
    foreground = "#b2d7a8",
    saturation = "medium",
    accent = "bg",
})

--   accent = "#e1c88e",
--   accent_bg = "#232019",
--   azure = "#89dae2",
--   azure_bg = "#004a50",
--   bg = "#232019",
--   bg_edge = "#17150e",
--   bg_edge2 = "#0a0703",
--   bg_mid = "#3d3a33",
--   bg_mid2 = "#59554d",
--   blue = "#a2d0fd",
--   blue_bg = "#002849",
--   cyan = "#9edbb7",
--   cyan_bg = "#003a22",
--   fg = "#b2d7a8",
--   fg_edge = "#c3e8b9",
--   fg_edge2 = "#d4fbca",
--   fg_mid = "#94b88a",
--   fg_mid2 = "#76996d",
--   green = "#cad194",
--   green_bg = "#333600",
--   orange = "#fbb7b2",
--   orange_bg = "#3e0a0d",
--   purple = "#ccc1fb",
--   purple_bg = "#231642",
--   red = "#eeb7dd",
--   red_bg = "#370d2d",
--   yellow = "#eec192",
--   yellow_bg = "#482a00"

require("mini.hues").apply_palette(palette)

vim.api.nvim_set_hl(0, "Pmenu", { bg = palette.bg })
