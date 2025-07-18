return function(wezterm, config)
	local font_family = "ComicCodeLigatures Nerd Font"

	config.line_height = 1.25

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
