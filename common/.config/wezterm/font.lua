---@diagnostic disable: unused-local

return function(wezterm, config)
	local font_util = require("font-util")

	config.font_size = 18.0

	font_util.register_fonts({
		{ name = "JetBrains", mod = "fonts.jetbrains" },
		{ name = "JetBrains :: Maple", mod = "fonts.jetbrains_maple" },
		{ name = "TX-02", mod = "fonts.tx-02" },
		{ name = "Berkeley", mod = "fonts.berkeley" },
		{ name = "TX-02 :: Maple", mod = "fonts.tx-02_maple" },
		{ name = "Maple", mod = "fonts.maple" },
		{ name = "SF", mod = "fonts.sf" },
		{ name = "Comic Shanns", mod = "fonts.comic_shanns" },
		{ name = "Comic Code", mod = "fonts.comic_code" },
		{ name = "Fira Code", mod = "fonts.fira_code" },
		{ name = "Rec Mono Duotone", mod = "fonts.recmono-duotone" },
		{ name = "Rec Mono Casual", mod = "fonts.recmono-casual" },
		{ name = "Menlo", mod = "fonts.menlo" },
	})

	font_util.select(config, "TX-02")
end
