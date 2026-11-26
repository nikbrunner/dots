-- pick-font from the fonts repo lists the fonts and applies the chosen one to
-- Ghostty, Zed and Rex. This action asks in the palette in between.
local pick_font = os.getenv("HOME") .. "/repos/nikbrunner/fonts/pick-font"

-- The server's PATH lacks the rex CLI, which pick-font sets the Rex font with.
local env = {
	PATH = os.getenv("HOME")
		.. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS:"
		.. os.getenv("PATH"),
}

local function run(...)
	local r, err = rex.exec({ pick_font, ... }, { env = env })
	if r == nil then
		error("pick_font: " .. err, 0)
	end
	if not r.ok then
		error("pick_font: " .. r.stderr, 0)
	end
	-- stderr holds the warnings, such as a Rex font that didn't apply
	local out = (r.stdout .. r.stderr):gsub("\n$", "")
	return out
end

rex.action({
	name = "pick_font",
	title = "Pick Font",
	keywords = "font typeface ghostty zed",
	run = function()
		local font, reason, detail = rex.ui.pick({
			title = "Pick font",
			placeholder = "Filter fonts",
			items = rex.json.decode(run("--items")),
		})
		if font == nil then
			if reason == "cancelled" or reason == "timeout" then
				return
			end
			error("pick_font: " .. reason .. " " .. (detail or ""), 0)
		end
		return run(font)
	end,
})
