-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
local function basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function get_time()
	return os.date("%H:%M")
end

---@diagnostic disable-next-line: unused-local
return function(wezterm, config)
	config.use_fancy_tab_bar = false
	config.hide_tab_bar_if_only_one_tab = true
	config.show_new_tab_button_in_tab_bar = false
	config.tab_bar_at_bottom = false
	config.tab_max_width = 32

	-- Note: tab_bar_style with active_tab_left, etc. was removed in WezTerm 20210502
	-- Tab styling is now handled through the format-tab-title event below

	wezterm.on("update-right-status", function(window, pane)
		local workspace = window:active_workspace()
		local time = get_time()
		window:set_right_status(workspace .. " | " .. time .. "  ")
	end)

	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		local title = ""

		if tab.tab_title and #tab.tab_title > 0 then
			title = tab.tab_title
		else
			title = basename(tab.active_pane.foreground_process_name)
		end

		-- Add 1 to make it 1-indexed for display
		local index = tab.tab_index + 1

		-- Use Nerd Font symbols for rounded edges
		local left_edge = wezterm.nerdfonts.ple_left_half_circle_thick
		local right_edge = wezterm.nerdfonts.ple_right_half_circle_thick

		-- Get the tab bar colors from the current color scheme
		local scheme = config.resolved_palette
		local bg = scheme.tab_bar.background
		local tab_bg = scheme.tab_bar.inactive_tab.bg_color
		local tab_fg = scheme.tab_bar.inactive_tab.fg_color

		if tab.is_active then
			tab_bg = scheme.tab_bar.active_tab.bg_color
			tab_fg = scheme.tab_bar.active_tab.fg_color
		elseif hover then
			tab_bg = scheme.tab_bar.inactive_tab_hover.bg_color
			tab_fg = scheme.tab_bar.inactive_tab_hover.fg_color
		end

		-- Create rounded chip appearance
		return {
			{ Background = { Color = bg } },
			{ Foreground = { Color = tab_bg } },
			{ Text = left_edge },
			{ Background = { Color = tab_bg } },
			{ Foreground = { Color = tab_fg } },
			{ Text = " " .. index .. ": " .. title .. " " },
			{ Background = { Color = bg } },
			{ Foreground = { Color = tab_bg } },
			{ Text = right_edge },
			{ Background = { Color = bg } },
			{ Text = " " }, -- spacing between tabs
		}
	end)
end
