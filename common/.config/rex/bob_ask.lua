-- Bob asks Nik in the command palette and gets the answer back as JSON:
--
--   rex do bob_ask --timeout 61m --args - <<'JSON'
--   {"question": "Tear it down?", "options": ["Tear down (Recommended)", "Not yet"], "multi": false, "timeout": 3600}
--   JSON
--
-- options are strings or palette items ({ id, title, subtitle }). Without options
-- Nik types one line. timeout is in seconds, at most 3600; `rex do --timeout` must
-- outlast it. Prints {"choice": id | [ids]}, {"text": "..."}, or
-- {"reason": "timeout" | "cancelled" | "busy" | "no_client" | "unsupported" | "failed"}.
rex.action({
	name = "bob_ask",
	title = "Bob asks Nik",
	args = { question = "string", options = "array?", multi = "boolean?", timeout = "integer?" },
	run = function(_, args)
		local options = args.options or {}
		local timeout = args.timeout or 3600
		if type(args.question) ~= "string" or args.question == "" then
			error("bob_ask: question must be a non-empty string", 0)
		end
		if type(options) ~= "table" then
			error("bob_ask: options must be a list", 0)
		end
		if args.multi and #options == 0 then
			error("bob_ask: multi needs options", 0)
		end
		if type(timeout) ~= "number" or timeout % 1 ~= 0 or timeout < 1 or timeout > 3600 then
			error("bob_ask: timeout must be whole seconds from 1 to 3600", 0)
		end

		-- The palette doesn't come forward over other apps, so a sound announces it.
		rex.exec.start({ "afplay", "/System/Library/Sounds/Glass.aiff" })
		local answer, reason, detail
		if #options == 0 then
			answer, reason, detail = rex.ui.input({ title = args.question, timeout = timeout })
		else
			answer, reason, detail = rex.ui.pick({
				title = args.question,
				items = options,
				multiple = args.multi,
				allow_other = not args.multi,
				timeout = timeout,
			})
		end

		if answer == nil then
			return { reason = reason, detail = detail }
		end
		if #options == 0 then
			return { text = answer }
		end
		if type(answer) == "table" and answer.text ~= nil then
			return { text = answer.text }
		end
		return { choice = answer }
	end,
})
