return function(wezterm, config)
	-- https://www.freepik.com/search?color=black&format=search&last_filter=page&last_value=2&orientation=landscape&page=2&query=japanese+retro+vintage&selection=1&type=vector#uuid=0680bb8a-b72c-47a7-91b0-53073cd3ca09

	local wallpapers_dir = os.getenv("HOME") .. "/repos/nikbrunner/wallpapers"

	config.background = {
		{
			source = { File = wallpapers_dir .. "/black/black_aspen.jpg" },
			hsb = { brightness = 0.5, hue = 2, saturation = 0.5 },
		},
		-- {
		-- 	source = { File = wallpapers_dir .. "/pixelart/image48.png" },
		-- 	hsb = { brightness = 0.05, hue = 1, saturation = 0.5 },
		-- },
	}
end
