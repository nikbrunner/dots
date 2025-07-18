return function(wezterm, config)
	local font_family = "Maple Mono NF"

	config.line_height = 1.15

	config.font = wezterm.font({
		family = font_family,
		harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	})

	config.font_rules = {
		{
			intensity = "Bold",
			font = wezterm.font({ family = font_family, weight = "Bold" }),
		},
	}
end
