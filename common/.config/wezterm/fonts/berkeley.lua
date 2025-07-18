return function(wezterm, config)
	local font_family = "BerkeleyMono Nerd Font"

	config.line_height = 1.25

	config.font = wezterm.font({ family = font_family })

	config.font_rules = {
		{
			intensity = "Bold",
			font = wezterm.font({ family = font_family, weight = "Bold" }),
		},
	}
end
