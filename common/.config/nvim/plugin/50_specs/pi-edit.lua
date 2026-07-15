-- pi-edit.lua — AI-powered code refactoring via the `pi` CLI.
-- Usage: visually select code and hit <C-g> (or :PiEdit), enter an
-- instruction, review the result in the split, `:w` to apply.
-- In normal mode <C-g> refactors the whole file.
-- In the result split: `r` regenerates, `e` edits the instruction,
-- `<C-r>` picks a model (from pi's enabledModels) and regenerates, `q` closes.
-- Modernized port of claude-edit.lua with `pi -p` as the only backend.

-- ========================================================================
-- Backend
-- ========================================================================

---@class PiEditSession
---@field instruction string
---@field original_lines string[]
---@field start_line integer 1-based, inclusive
---@field end_line integer 1-based, inclusive
---@field source_bufnr integer
---@field full_file string|nil full file context (only when a range was given)
---@field model string|nil model override for `pi --model` (default: pi's default)
---@field result_bufnr integer|nil
---@field win_id integer|nil
---@field proc vim.SystemObj|nil running pi process, killed on close

---@type PiEditSession|nil
local session = nil

local function build_prompt(s)
	if s.full_file then
		return string.format(
			[[Generate refactored code based on the instruction below.

CRITICAL: Return ONLY the refactored code for lines %d-%d. Do not include ANY explanations, analysis, commentary, markdown code blocks, or additional text. Just output the code and nothing else.

Requirements:
- Preserve the original code's style and formatting conventions
- Only make changes requested in the instruction
- Return valid, runnable code for the selected lines only
- Use the full file context to understand imports, types, and related code
- NO explanations, NO analysis, NO commentary, NO markdown formatting

Full file for context:
```
%s
```

Lines to refactor (%d-%d):
```
%s
```

Instruction: %s

Output: Just the refactored code for lines %d-%d, nothing more.]],
			s.start_line,
			s.end_line,
			s.full_file,
			s.start_line,
			s.end_line,
			table.concat(s.original_lines, "\n"),
			s.instruction,
			s.start_line,
			s.end_line
		)
	end

	return string.format(
		[[Generate refactored code based on the instruction below.

CRITICAL: Return ONLY the refactored code. Do not include ANY explanations, analysis, commentary, markdown code blocks, or additional text. Just output the code and nothing else.

Requirements:
- Preserve the original code's style and formatting conventions
- Only make changes requested in the instruction
- Return valid, runnable code
- NO explanations, NO analysis, NO commentary, NO markdown formatting

Original code:
```
%s
```

Instruction: %s

Output: Just the refactored code, nothing more.]],
		table.concat(s.original_lines, "\n"),
		s.instruction
	)
end

---Run `pi` asynchronously. Returns the process handle.
---@param prompt string
---@param model string|nil
---@param callback fun(result: string|nil, err: string|nil)
local function call_pi(prompt, model, callback)
	-- --no-tools: single text response, no file editing from the model's side
	-- --no-session: ephemeral, don't pollute pi's session history
	local cmd = { "pi", "-p", "--no-tools", "--no-session" }
	if model then
		vim.list_extend(cmd, { "--model", model })
	end
	table.insert(cmd, prompt)

	return vim.system(
		cmd,
		{ text = true },
		vim.schedule_wrap(function(out)
			if out.signal ~= 0 then
				return -- killed on purpose (split closed), stay silent
			end
			if out.code ~= 0 then
				callback(nil, string.format("pi failed (exit code %d)\n%s", out.code, out.stderr or ""))
				return
			end

			local result = vim.trim(out.stdout or "")
			-- Strip markdown fences in case the model ignored instructions
			result = result:gsub("^```%w*\n", ""):gsub("\n```$", "")

			if result == "" then
				callback(nil, "pi returned an empty response")
				return
			end

			callback(result)
		end)
	)
end

-- ========================================================================
-- Result split
-- ========================================================================

---Read the enabled model list from pi's settings.
---@return string[]|nil
local function get_enabled_models()
	local path = vim.fn.expand("~/.pi/agent/settings.json")
	local ok, content = pcall(vim.fn.readfile, path)
	if not ok then
		return nil
	end

	local decoded
	ok, decoded = pcall(vim.json.decode, table.concat(content, "\n"))
	if not ok or type(decoded) ~= "table" then
		return nil
	end

	return decoded.enabledModels
end

local function set_content(buf, lines)
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		return
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modified = false
end

local function close_session()
	if not session then
		return
	end
	if session.proc then
		session.proc:kill(15)
	end
	if session.win_id and vim.api.nvim_win_is_valid(session.win_id) then
		vim.api.nvim_win_close(session.win_id, true)
	end
	session = nil
end

local function generate()
	if not session then
		return
	end

	set_content(session.result_bufnr, { "", "⏳ Generating refactored code...", "" })

	local s = session
	s.proc = call_pi(build_prompt(s), s.model, function(result, err)
		if session ~= s then
			return -- session was closed or replaced in the meantime
		end
		s.proc = nil

		if not result then
			set_content(s.result_bufnr, { "", "❌ Failed to generate code:", "", err or "Unknown error" })
			return
		end

		set_content(s.result_bufnr, vim.split(result, "\n", { plain = true }))
	end)
end

local function apply_changes()
	if not session then
		return
	end

	if not vim.api.nvim_buf_is_valid(session.source_bufnr) then
		vim.notify("Source buffer no longer exists", vim.log.levels.ERROR)
		return
	end

	local new_lines = vim.api.nvim_buf_get_lines(session.result_bufnr, 0, -1, false)
	vim.api.nvim_buf_set_lines(session.source_bufnr, session.start_line - 1, session.end_line, false, new_lines)

	vim.notify("Changes applied", vim.log.levels.INFO)
end

local function open_result_split()
	vim.cmd("vsplit")

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	session.result_bufnr = buf
	session.win_id = win

	vim.api.nvim_buf_set_name(buf, "[Pi Edit]")
	vim.bo[buf].buftype = "acwrite" -- enables :w via BufWriteCmd
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].filetype = vim.bo[session.source_bufnr].filetype

	vim.wo[win][0].signcolumn = "yes"
	vim.wo[win][0].cursorline = true

	-- :w applies the (possibly hand-edited) result to the source buffer
	vim.api.nvim_create_autocmd("BufWriteCmd", {
		buffer = buf,
		callback = function()
			apply_changes()
			if vim.api.nvim_buf_is_valid(buf) then
				vim.bo[buf].modified = false
			end
		end,
	})

	-- Kill a still-running generation when the split goes away
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		callback = function()
			if session and session.result_bufnr == buf then
				if session.proc then
					session.proc:kill(15)
				end
				session = nil
			end
		end,
	})

	local function bmap(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
	end

	bmap("q", close_session, "Close without applying")
	bmap("r", generate, "Regenerate with same instruction")
	bmap("e", function()
		vim.ui.input({ prompt = "New instruction: ", default = session and session.instruction }, function(input)
			if session and input and input ~= "" then
				session.instruction = input
				generate()
			end
		end)
	end, "Edit instruction and regenerate")

	bmap("<C-r>", function()
		local models = get_enabled_models()
		if not models or #models == 0 then
			vim.notify("No enabledModels found in pi settings", vim.log.levels.WARN)
			return
		end

		vim.ui.select(models, {
			prompt = "Regenerate with model:",
			format_item = function(model)
				return (session and session.model == model) and (model .. " (current)") or model
			end,
		}, function(choice)
			if session and choice then
				session.model = choice
				generate()
			end
		end)
	end, "Pick model and regenerate")
end

-- ========================================================================
-- Entry point
-- ========================================================================

---@param opts table command opts (range, line1, line2)
local function pi_edit(opts)
	if vim.fn.executable("pi") ~= 1 then
		vim.notify("`pi` not found on PATH", vim.log.levels.ERROR)
		return
	end

	local source_bufnr = vim.api.nvim_get_current_buf()
	local has_range = opts.range > 0
	local start_line = has_range and opts.line1 or 1
	local end_line = has_range and opts.line2 or vim.api.nvim_buf_line_count(source_bufnr)

	local lines = vim.api.nvim_buf_get_lines(source_bufnr, start_line - 1, end_line, false)
	if table.concat(lines, "\n") == "" then
		vim.notify("No code to refactor", vim.log.levels.WARN)
		return
	end

	-- With a range, send the whole file as additional context
	local full_file = nil
	if has_range then
		full_file = table.concat(vim.api.nvim_buf_get_lines(source_bufnr, 0, -1, false), "\n")
	end

	vim.ui.input({ prompt = "Refactoring instruction: " }, function(instruction)
		if not instruction or instruction == "" then
			return
		end

		close_session() -- only one session at a time

		session = {
			instruction = instruction,
			original_lines = lines,
			start_line = start_line,
			end_line = end_line,
			source_bufnr = source_bufnr,
			full_file = full_file,
		}

		open_result_split()
		generate()
	end)
end

vim.api.nvim_create_user_command("PiEdit", pi_edit, { range = true, desc = "Refactor code using pi" })

vim.keymap.set("x", "<C-g>", ":PiEdit<CR>", { desc = "Pi Edit: Refactor selection" })
vim.keymap.set("n", "<C-g>", "<Cmd>PiEdit<CR>", { desc = "Pi Edit: Refactor entire file" })
