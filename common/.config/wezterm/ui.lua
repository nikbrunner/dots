---[Default Key Assignments - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/config/default-keys.html)
---[Color Schemes - Wez's Terminal Emulator](https://wezfurlong.org/wezterm/colorschemes/index.html)
return function(wezterm, config)
	local function get_appearance()
		if wezterm.gui then
			return wezterm.gui.get_appearance()
		end
		return "Dark"
	end

	local function load_current_schemes()
		local schemes_file = wezterm.config_dir .. "/.current_schemes.lua"
		local ok, schemes = pcall(dofile, schemes_file)
		if ok and schemes then
			return schemes
		else
			-- Fallback to defaults if file doesn't exist or has errors
			return {
				light = "Black Atom — JPN ∷ Koyo Hiru",
				dark = "Black Atom — JPN ∷ Koyo Yoru",
			}
		end
	end

	local function scheme_for_appearance(appearance)
		local schemes = load_current_schemes()
		if appearance:find("Dark") then
			return schemes.dark
		else
			return schemes.light
		end
	end

	-- Store the current colorscheme in a global variable
	wezterm.on("window-config-reloaded", function(window, pane)
		local effective_config = window:effective_config()
		local colorscheme = effective_config.color_scheme
		local colorschemes = effective_config.color_schemes

		local local_colorscheme = colorschemes[colorscheme]
		local colors

		if local_colorscheme == nil then
			colors = effective_config.resolved_palette
		else
			colors = colorschemes[colorscheme]
		end

		wezterm.GLOBAL.current_colors = colors
	end)

	config.color_scheme = scheme_for_appearance(get_appearance())
	-- config.colors = {
	-- 	background = "#000000",
	-- 	tab_bar = {
	-- 		background = "#000000",
	-- 	},
	-- }

	config.tab_bar_at_bottom = true

	config.inactive_pane_hsb = {
		saturation = 1,
		brightness = 1,
	}

	config.initial_rows = 500
	config.initial_cols = 500

	config.max_fps = 120

	-- config.window_background_opacity = 0.9
	-- config.macos_window_background_blur = 25

	config.window_decorations = "RESIZE"

	config.window_padding = {
		left = 25,
		right = 25,
		top = 25,
		bottom = 15,
	}

	config.front_end = "WebGpu"

	-- Cursor settings - disable blinking
	config.default_cursor_style = "SteadyBlock"
	config.cursor_blink_rate = 0

	config.hyperlink_rules = wezterm.default_hyperlink_rules()

	table.insert(config.hyperlink_rules, {
		regex = [[\b(BCD-\d{4})\b]],
		format = "https://dcd.myjetbrains.com/youtrack/issue/$1",
	})

	table.insert(config.hyperlink_rules, {
		regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
		format = "https://www.github.com/$1/$3",
	})

	require("tabs")(wezterm, config)
	-- require("wallpaper")(wezterm, config)
end
