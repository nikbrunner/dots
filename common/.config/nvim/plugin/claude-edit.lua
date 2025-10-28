-- claude-edit.lua - AI-powered code refactoring in Neovim
-- Usage: Visually select code, run :ClaudeEdit, enter instruction, get refactored code

-- ========================================================================
-- Configuration
-- ========================================================================

local AI_BACKEND = "claude-code" -- "claude-code" or "api"
local DEFAULT_MODEL = "claude-haiku-4-5-20251001" -- Fastest and cheapest model
local MAX_TOKENS = 4096
local API_VERSION = "2023-06-01"

-- ========================================================================
-- Helper Functions
-- ========================================================================

local function has_claude_code()
	return vim.fn.executable("claude") == 1
end

local function has_api_key()
	return vim.fn.getenv("ANTHROPIC_API_KEY") ~= vim.NIL
end

local function check_ai_availability()
	if not has_claude_code() and not has_api_key() then
		vim.notify(
			"Neither Claude Code nor ANTHROPIC_API_KEY is available.\n"
				.. "Please either:\n"
				.. "  1. Install Claude Code: https://claude.ai/code\n"
				.. "  2. Set ANTHROPIC_API_KEY to your Anthropic API key",
			vim.log.levels.ERROR
		)
		return false
	end
	return true
end

-- ========================================================================
-- AI Backend Functions
-- ========================================================================

local function call_claude_code(prompt, model)
	local cmd = string.format("claude --model '%s' --print '%s' 2>&1", model, prompt:gsub("'", "'\\''"))
	local result = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		return nil, string.format("Claude Code failed (exit code: %d)\nOutput: %s", exit_code, result)
	end

	-- Clean up the response
	result = result:gsub("^%s+", ""):gsub("%s+$", "")

	if result == "" then
		return nil, "Claude Code returned empty response"
	end

	return result
end

local function call_claude_api(prompt, model, max_tokens)
	local api_key = vim.fn.getenv("ANTHROPIC_API_KEY")
	if api_key == vim.NIL then
		return nil, "ANTHROPIC_API_KEY not set"
	end

	-- Create JSON payload using vim's json_encode
	local payload = vim.fn.json_encode({
		model = model,
		max_tokens = max_tokens,
		messages = {
			{
				role = "user",
				content = prompt,
			},
		},
	})

	-- Escape for shell
	local escaped_payload = payload:gsub("'", "'\\''")

	-- Build curl command
	local cmd = string.format(
		"curl -s -X POST 'https://api.anthropic.com/v1/messages' "
			.. "-H 'x-api-key: %s' "
			.. "-H 'anthropic-version: %s' "
			.. "-H 'content-type: application/json' "
			.. "-d '%s'",
		api_key,
		API_VERSION,
		escaped_payload
	)

	local response = vim.fn.system(cmd)
	local exit_code = vim.v.shell_error

	if exit_code ~= 0 then
		return nil, string.format("API call failed (exit code: %d)", exit_code)
	end

	-- Parse JSON response
	local ok, json_response = pcall(vim.fn.json_decode, response)
	if not ok then
		return nil, "Failed to parse API response: " .. tostring(json_response)
	end

	-- Extract text from response
	if json_response.content and json_response.content[1] and json_response.content[1].text then
		local result = json_response.content[1].text
		-- Clean up the response
		result = result:gsub("^%s+", ""):gsub("%s+$", "")
		return result
	end

	return nil, "Invalid API response format"
end

-- ========================================================================
-- Main Logic
-- ========================================================================

local function generate_refactored_code(code, instruction, model)
	model = model or DEFAULT_MODEL

	-- Build the prompt
	local prompt = string.format(
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
		code,
		instruction
	)

	-- Generate using appropriate method based on configuration
	if AI_BACKEND == "claude-code" and has_claude_code() then
		return call_claude_code(prompt, model)
	else
		return call_claude_api(prompt, model, MAX_TOKENS)
	end
end

local function claude_edit()
	-- Check if AI is available
	if not check_ai_availability() then
		return
	end

	-- Get visual selection
	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local original_code = table.concat(lines, "\n")

	if original_code == "" then
		vim.notify("No code selected", vim.log.levels.WARN)
		return
	end

	-- Prompt user for instruction
	vim.ui.input({ prompt = "Refactoring instruction: " }, function(instruction)
		if not instruction or instruction == "" then
			vim.notify("No instruction provided", vim.log.levels.WARN)
			return
		end

		-- Show loading notification
		vim.notify("Generating refactored code...", vim.log.levels.INFO)

		-- Generate refactored code
		local refactored_code, error_msg = generate_refactored_code(original_code, instruction)

		if not refactored_code then
			vim.notify(string.format("Failed to generate refactored code:\n%s", error_msg), vim.log.levels.ERROR)
			return
		end

		-- Clean up response (remove markdown code blocks if present)
		refactored_code = refactored_code:gsub("^```%w*\n", ""):gsub("\n```$", "")

		-- Split the refactored code into lines
		local new_lines = {}
		for line in refactored_code:gmatch("[^\n]+") do
			table.insert(new_lines, line)
		end

		-- Replace the selection with refactored code
		vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, new_lines)

		vim.notify("Code refactored successfully!", vim.log.levels.INFO)
	end)
end

-- ========================================================================
-- Command Registration
-- ========================================================================

vim.api.nvim_create_user_command("ClaudeEdit", function()
	claude_edit()
end, { range = true, desc = "Refactor selected code using Claude AI" })

-- Keybinding: <C-g> in visual mode
vim.keymap.set("v", "<C-g>", ":ClaudeEdit<CR>", { desc = "Claude Edit: Refactor selected code" })
