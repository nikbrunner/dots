-- claude-edit.lua - AI-powered code refactoring in Neovim
-- Usage: Visually select code, run :ClaudeEdit, enter instruction, get refactored code

-- ========================================================================
-- Configuration
-- ========================================================================

local AI_BACKEND = "api" -- "claude-code" or "api"
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

local function call_claude_code(prompt, model, callback)
    -- Write prompt to temp file
    local temp_file = vim.fn.tempname()
    local f = io.open(temp_file, "w")
    if not f then
        callback(nil, "Failed to create temp file")
        return
    end
    f:write(prompt)
    f:close()

    local result_lines = {}
    local error_lines = {}

    -- Use bash to read temp file and pass to claude
    local cmd = string.format("cat %s | claude --model %s --print", vim.fn.shellescape(temp_file), vim.fn.shellescape(model))

    local job_id = vim.fn.jobstart({ "bash", "-c", cmd }, {
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(result_lines, line)
                    end
                end
            end
        end,
        on_stderr = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(error_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            -- Clean up temp file
            vim.fn.delete(temp_file)

            vim.schedule(function()
                if exit_code ~= 0 then
                    local error_msg = string.format(
                        "Claude Code failed (exit code: %d)\nStderr: %s",
                        exit_code,
                        table.concat(error_lines, "\n")
                    )
                    callback(nil, error_msg)
                    return
                end

                local result = table.concat(result_lines, "\n")
                result = result:gsub("^%s+", ""):gsub("%s+$", "")

                if result == "" then
                    callback(nil, "Claude Code returned empty response")
                    return
                end

                callback(result)
            end)
        end,
    })

    if job_id <= 0 then
        vim.fn.delete(temp_file)
        callback(nil, "Failed to start Claude Code process")
    end
end

local function call_claude_api(prompt, model, max_tokens, callback)
    local api_key = vim.fn.getenv("ANTHROPIC_API_KEY")
    if api_key == vim.NIL then
        callback(nil, "ANTHROPIC_API_KEY not set")
        return
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

    local result_lines = {}

    local job_id = vim.fn.jobstart({
        "curl",
        "-s",
        "-X",
        "POST",
        "https://api.anthropic.com/v1/messages",
        "-H",
        "x-api-key: " .. api_key,
        "-H",
        "anthropic-version: " .. API_VERSION,
        "-H",
        "content-type: application/json",
        "-d",
        payload,
    }, {
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(result_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            vim.schedule(function()
                if exit_code ~= 0 then
                    callback(nil, string.format("API call failed (exit code: %d)", exit_code))
                    return
                end

                local response = table.concat(result_lines, "\n")

                -- Parse JSON response
                local ok, json_response = pcall(vim.fn.json_decode, response)
                if not ok then
                    callback(nil, "Failed to parse API response: " .. tostring(json_response))
                    return
                end

                -- Extract text from response
                if json_response.content and json_response.content[1] and json_response.content[1].text then
                    local result = json_response.content[1].text
                    -- Clean up the response
                    result = result:gsub("^%s+", ""):gsub("%s+$", "")
                    callback(result)
                    return
                end

                callback(nil, "Invalid API response format")
            end)
        end,
    })

    if job_id <= 0 then
        callback(nil, "Failed to start curl process")
    end
end

local function generate_refactored_code(code, instruction, model, callback, full_file_context, start_line, end_line)
    model = model or DEFAULT_MODEL

    -- Build the prompt with optional context
    local prompt
    if full_file_context and start_line and end_line then
        prompt = string.format(
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
            start_line,
            end_line,
            full_file_context,
            start_line,
            end_line,
            code,
            instruction,
            start_line,
            end_line
        )
    else
        prompt = string.format(
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
    end

    -- Generate using appropriate method based on configuration
    if AI_BACKEND == "claude-code" and has_claude_code() then
        call_claude_code(prompt, model, callback)
    else
        call_claude_api(prompt, model, MAX_TOKENS, callback)
    end
end

-- ========================================================================
-- Diff View
-- ========================================================================

-- State for diff view and regeneration
local diff_state = {
    instruction = nil,
    original_lines = nil,
    start_line = nil,
    end_line = nil,
    source_bufnr = nil,
    right_bufnr = nil,
    win_id = nil,
    full_file_context = nil,
}

-- Forward declarations for circular dependencies
local regenerate_code

local function apply_changes(should_close_window)
    if not diff_state.source_bufnr or not diff_state.right_bufnr then
        return
    end

    -- Get edited content from buffer
    local new_lines = vim.api.nvim_buf_get_lines(diff_state.right_bufnr, 0, -1, false)

    -- Apply to source buffer
    vim.api.nvim_buf_set_lines(diff_state.source_bufnr, diff_state.start_line - 1, diff_state.end_line, false, new_lines)

    vim.notify("Changes applied successfully!", vim.log.levels.INFO)

    -- Close floating window if requested
    if should_close_window and diff_state.win_id and vim.api.nvim_win_is_valid(diff_state.win_id) then
        vim.api.nvim_win_close(diff_state.win_id, true)
    end

    -- Clean up
    diff_state = {
        instruction = nil,
        original_lines = nil,
        start_line = nil,
        end_line = nil,
        source_bufnr = nil,
        right_bufnr = nil,
        win_id = nil,
        full_file_context = nil,
    }
end

local function create_split_buffer()
    -- Create vertical split
    vim.cmd("vsplit")

    -- Create buffer for refactored code
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()

    -- Set buffer in the new split window
    vim.api.nvim_win_set_buf(win, buf)

    -- Store in state
    diff_state.right_bufnr = buf
    diff_state.win_id = win

    -- Set buffer name
    vim.api.nvim_buf_set_name(buf, "[Claude Edit - Refactored]")

    -- Set buffer options
    vim.bo[buf].buftype = "acwrite" -- Allow :w with BufWriteCmd
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modified = false -- Mark as not modified initially

    -- Get filetype from source buffer
    local ft = vim.bo[diff_state.source_bufnr].filetype
    vim.bo[buf].filetype = ft

    -- Set window options
    vim.wo[win].number = true
    vim.wo[win].relativenumber = vim.wo.relativenumber
    vim.wo[win].cursorline = true
    vim.wo[win].signcolumn = "yes"
    vim.wo[win].wrap = vim.wo.wrap

    -- Set up autocmd to handle :w and :wq
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        buffer = buf,
        callback = function()
            apply_changes(false)
            vim.bo[buf].modified = false
        end,
    })

    -- Set up keybindings
    vim.keymap.set("n", "r", function()
        regenerate_code(nil)
    end, { buffer = buf, desc = "Regenerate with same instruction" })

    vim.keymap.set("n", "e", function()
        vim.ui.input({ prompt = "New instruction: ", default = diff_state.instruction }, function(new_instruction)
            if new_instruction and new_instruction ~= "" then
                regenerate_code(new_instruction)
            end
        end)
    end, { buffer = buf, desc = "Edit instruction and regenerate" })

    return buf, win
end

local function update_buffer_content(buf, lines)
    -- Make buffer modifiable temporarily
    local was_modifiable = vim.bo[buf].modifiable
    vim.bo[buf].modifiable = true

    -- Update content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Restore modifiable state
    vim.bo[buf].modifiable = was_modifiable
    vim.bo[buf].modified = false
end

regenerate_code = function(new_instruction)
    if not diff_state.original_lines or not diff_state.source_bufnr or not diff_state.right_bufnr then
        vim.notify("Cannot regenerate - state lost", vim.log.levels.ERROR)
        return
    end

    -- Update instruction if provided
    if new_instruction and new_instruction ~= "" then
        diff_state.instruction = new_instruction
    end

    local original_code = table.concat(diff_state.original_lines, "\n")

    -- Show loading message in buffer
    update_buffer_content(diff_state.right_bufnr, { "", "⏳ Regenerating code...", "" })

    -- Generate new refactored code (async)
    generate_refactored_code(original_code, diff_state.instruction, nil, function(refactored_code, error_msg)
        if not refactored_code then
            update_buffer_content(
                diff_state.right_bufnr,
                { "", "❌ Failed to regenerate:", "", error_msg or "Unknown error" }
            )
            return
        end

        -- Clean up response
        refactored_code = refactored_code:gsub("^```%w*\n", ""):gsub("\n```$", "")

        -- Split lines preserving empty lines
        local new_lines = vim.split(refactored_code, "\n", { plain = true })

        -- Update buffer with new code
        update_buffer_content(diff_state.right_bufnr, new_lines)
    end, diff_state.full_file_context, diff_state.start_line, diff_state.end_line)
end

-- ========================================================================
-- Main Logic
-- ========================================================================

local function claude_edit()
    -- Check if AI is available
    if not check_ai_availability() then
        return
    end

    local source_bufnr = vim.api.nvim_get_current_buf()
    local start_line, end_line, lines
    local is_selection = false

    -- Check if we have a visual selection (marks persist after exiting visual mode)
    local mark_start = vim.fn.line("'<")
    local mark_end = vim.fn.line("'>")
    local current_line = vim.fn.line(".")

    -- If marks exist and are valid (not at line 1 which is the default), use them
    if
        mark_start > 0
        and mark_end > 0
        and mark_start <= mark_end
        and not (mark_start == 1 and mark_end == 1 and current_line ~= 1)
    then
        -- Visual selection - use marks
        start_line = mark_start
        end_line = mark_end
        lines = vim.api.nvim_buf_get_lines(source_bufnr, start_line - 1, end_line, false)
        is_selection = true
    else
        -- No visual selection - use entire file
        start_line = 1
        end_line = vim.fn.line("$")
        lines = vim.api.nvim_buf_get_lines(source_bufnr, 0, -1, false)
        is_selection = false
    end

    local original_code = table.concat(lines, "\n")

    if original_code == "" then
        vim.notify("No code to refactor", vim.log.levels.WARN)
        return
    end

    -- Get full file for context if we have a selection
    local full_file_context = nil
    if is_selection then
        local all_lines = vim.api.nvim_buf_get_lines(source_bufnr, 0, -1, false)
        full_file_context = table.concat(all_lines, "\n")
    end

    -- Prompt user for instruction
    vim.ui.input({ prompt = "Refactoring instruction: " }, function(instruction)
        if not instruction or instruction == "" then
            vim.notify("No instruction provided", vim.log.levels.WARN)
            return
        end

        -- Store state for diff view and regeneration
        diff_state.instruction = instruction
        diff_state.original_lines = lines
        diff_state.start_line = start_line
        diff_state.end_line = end_line
        diff_state.source_bufnr = source_bufnr
        diff_state.full_file_context = full_file_context

        -- Create split immediately with loading message
        local buf, win = create_split_buffer()
        update_buffer_content(buf, { "", "⏳ Generating refactored code...", "" })

        -- Generate refactored code asynchronously
        generate_refactored_code(original_code, instruction, nil, function(refactored_code, error_msg)
            if not refactored_code then
                update_buffer_content(buf, { "", "❌ Failed to generate code:", "", error_msg or "Unknown error" })
                return
            end

            -- Clean up response (remove markdown code blocks if present)
            refactored_code = refactored_code:gsub("^```%w*\n", ""):gsub("\n```$", "")

            -- Split lines preserving empty lines
            local new_lines = vim.split(refactored_code, "\n", { plain = true })

            if #new_lines == 0 then
                update_buffer_content(buf, { "", "❌ No code generated!" })
                return
            end

            -- Update split with refactored code
            update_buffer_content(buf, new_lines)
        end, full_file_context, start_line, end_line)
    end)
end

-- ========================================================================
-- Command Registration
-- ========================================================================

vim.api.nvim_create_user_command("ClaudeEdit", function()
    claude_edit()
end, { range = true, desc = "Refactor code using Claude AI" })

-- Keybindings
vim.keymap.set("v", "<C-g>", ":ClaudeEdit<CR>", { desc = "Claude Edit: Refactor selection" })
vim.keymap.set("n", "<C-g>", ":ClaudeEdit<CR>", { desc = "Claude Edit: Refactor entire file" })
