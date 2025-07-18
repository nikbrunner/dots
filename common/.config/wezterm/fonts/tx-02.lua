return function(wezterm, config)
	local font_family = "TX-02"

	config.line_height = 1.25
	config.bold_brightens_ansi_colors = true

	config.font = wezterm.font({
		family = font_family,
		weight = 400,
		harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	})

	config.font_rules = {
		{
			intensity = "Bold",
			font = wezterm.font({ family = font_family, weight = 700 }),
		},

		{
			italic = true,
			font = wezterm.font({
				family = font_family,
				style = "Oblique",
			}),
		},
		{
			italic = true,
			intensity = "Bold",
			font = wezterm.font({
				family = font_family,
				weight = 700,
				style = "Oblique",
			}),
		},
	}
end
