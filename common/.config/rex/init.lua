-- https://www.superlogical.com/rex/docs/reference/lua
-- How this config is split between Lua and the app's shortcuts: README.md.

-- package.path = os.getenv("HOME") .. "/repos/black-atom-industries/helm/lua/?.lua;" .. package.path

-- require("helm").setup({
-- 	popup = false,
-- 	-- side = "cmd+shift+s",
-- 	bin = os.getenv("HOME") .. "/.local/bin/helm-rex",
-- 	bounds = { 0.25, 0.175, 0.6, 0.55 },
-- 	detail_bounds = { 0.15, 0.055, 0.9, 0.55 },
-- })

require("keys")
require("popups")
require("agents")
require("bob_ask")
