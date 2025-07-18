return function(wezterm, config)
	local regular_font = "JetBrainsMono Nerd Font"
	local italic_font = "Maple Mono NF"

	config.line_height = 1.25

	config.font = wezterm.font({
		family = regular_font,
		harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	})

	config.font_rules = {
		{
			intensity = "Normal",
			italic = false,
			font = wezterm.font({ family = regular_font }),
		},
		{
			intensity = "Normal",
			italic = true,
			font = wezterm.font({ family = italic_font, style = "Italic" }),
		},
		{
			intensity = "Bold",
			italic = true,
			font = wezterm.font({ family = italic_font, weight = "Bold", style = "Italic" }),
		},
	}
end
