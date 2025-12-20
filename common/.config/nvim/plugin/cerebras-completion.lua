-- cerebras-completion.lua - AI-powered inline completions using Cerebras
-- Supermaven-style ghost text completions with Tab to accept

-- ============================================================================
-- Configuration
-- ============================================================================

-- ============================================================================
-- Model Definitions
-- ============================================================================

-- Available models and their capabilities
-- See: https://inference-docs.cerebras.ai/api-reference/models/list-models
local models = {
    -- Standard API models (free tier)
    ["qwen-3-32b"] = {
        name = "Qwen3 32B",
        available = true,
        fim = false,
        pricing = { input = 0.20, output = 0.20 },
        docs = "https://inference-docs.cerebras.ai/models/qwen-3-32b",
    },
    ["qwen-3-235b-a22b-instruct-2507"] = {
        name = "Qwen3 235B Instruct",
        available = true,
        fim = false,
        pricing = { input = 0.60, output = 1.20 },
        docs = "https://inference-docs.cerebras.ai/models/qwen-3-235b-2507",
    },
    ["llama-3.3-70b"] = {
        name = "Llama 3.3 70B",
        available = true,
        fim = false,
        pricing = { input = 0.20, output = 0.20 },
        docs = "https://inference-docs.cerebras.ai/models/llama-3.3-70b",
    },
    ["llama3.1-8b"] = {
        name = "Llama 3.1 8B",
        available = true,
        fim = false,
        pricing = { input = 0.10, output = 0.10 },
        docs = "https://inference-docs.cerebras.ai/models/llama-3.1-8b",
    },
    -- Cerebras Code subscription models ($50-200/month)
    ["qwen-3-coder-480b"] = {
        name = "Qwen3 Coder 480B",
        available = false, -- requires Cerebras Code subscription
        fim = true,
        fim_tokens = {
            prefix = "<|fim_prefix|>",
            suffix = "<|fim_suffix|>",
            middle = "<|fim_middle|>",
        },
        pricing = { input = 2.00, output = 2.00 },
        docs = "https://www.cerebras.ai/blog/qwen3-coder-480b-is-live-on-cerebras",
    },
}

-- ============================================================================
-- Configuration
-- ============================================================================

local config = {
    enabled = true,
    debounce_ms = 150,
    max_context_lines = 100, -- lines before cursor (nil = full file)
    include_suffix = false, -- EXPERIMENTAL: unreliable without FIM-trained model
    max_file_size = 100000, -- 100KB limit (skip files larger than this)
    model = "qwen-3-235b-a22b-instruct-2507", -- see models table above
    max_tokens = 128,
    temperature = 0.2,
    stop_sequences = { "\n", "```", "---" }, -- Stop at newline to prefer single-line completions
    keymaps = {
        accept = "<Tab>",
        accept_word = "<S-Tab>",
        dismiss = "<C-]>",
        toggle = "<leader>aoa",
    },
}

-- ============================================================================
-- State
-- ============================================================================

local state = {
    pending_job = nil,
    debounce_timer = nil,
    current_completion = nil,
    extmark_id = nil,
    ns_id = vim.api.nvim_create_namespace("cerebras_completion"),
    last_cursor_pos = nil,
}

-- ============================================================================
-- Highlight Groups
-- ============================================================================

vim.api.nvim_set_hl(0, "CerebrasCompletion", { link = "Comment", default = true })

-- ============================================================================
-- Utility Functions
-- ============================================================================

local function has_api_key()
    local key = vim.fn.getenv("CEREBRAS_API_KEY")
    return key ~= vim.NIL and key ~= ""
end

local function get_api_key()
    return vim.fn.getenv("CEREBRAS_API_KEY")
end

local function is_insert_mode()
    local mode = vim.api.nvim_get_mode().mode
    return mode == "i" or mode == "ic"
end

local function cancel_pending_job()
    if state.pending_job then
        vim.fn.jobstop(state.pending_job)
        state.pending_job = nil
    end
end

local function cancel_debounce_timer()
    if state.debounce_timer then
        vim.fn.timer_stop(state.debounce_timer)
        state.debounce_timer = nil
    end
end

-- ============================================================================
-- Ghost Text Rendering
-- ============================================================================

local function clear_ghost_text()
    if state.extmark_id and vim.api.nvim_buf_is_valid(0) then
        pcall(vim.api.nvim_buf_del_extmark, 0, state.ns_id, state.extmark_id)
    end
    state.extmark_id = nil
    state.current_completion = nil
end

local function render_ghost_text(completion_text)
    if not completion_text or completion_text == "" then
        clear_ghost_text()
        return
    end

    if not is_insert_mode() then
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1
    local col = cursor[2]

    -- Check if cursor is at an indent position (only whitespace before cursor)
    local current_line = vim.api.nvim_get_current_line()
    local before_cursor = current_line:sub(1, col)
    if before_cursor:match("^%s*$") and completion_text:match("^%s") then
        -- Strip leading whitespace from completion to avoid double indent in preview
        completion_text = completion_text:gsub("^%s+", "")
    end

    -- Split completion into lines
    local lines = vim.split(completion_text, "\n", { plain = true })
    local first_line = lines[1] or ""

    -- Build virtual lines for multiline completions
    local virt_lines = {}
    for i = 2, #lines do
        table.insert(virt_lines, { { lines[i], "CerebrasCompletion" } })
    end

    -- Clear existing extmark
    clear_ghost_text()

    -- Create new extmark with virtual text
    local opts = {
        virt_text = { { first_line, "CerebrasCompletion" } },
        virt_text_pos = "inline",
        hl_mode = "combine",
    }

    if #virt_lines > 0 then
        opts.virt_lines = virt_lines
    end

    state.extmark_id = vim.api.nvim_buf_set_extmark(buf, state.ns_id, row, col, opts)
    state.current_completion = completion_text
end

-- ============================================================================
-- Accept Mechanism
-- ============================================================================

local function get_first_word(text)
    -- Match first word (including punctuation as part of code)
    local word = text:match("^(%S+)")
    return word or text
end

local function accept_completion(full)
    if not state.current_completion or state.current_completion == "" then
        return false
    end

    local text_to_insert
    if full then
        text_to_insert = state.current_completion
    else
        text_to_insert = get_first_word(state.current_completion)
    end

    -- Clear ghost text first
    clear_ghost_text()

    -- Schedule the insertion to avoid "not allowed to change text" error
    -- when called from expr mappings or blink.cmp fallback context
    vim.schedule(function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row = cursor[1]
        local col = cursor[2]
        local current_line = vim.api.nvim_get_current_line()
        local before_cursor = current_line:sub(1, col)

        -- Handle indentation when cursor is at an indent position
        if before_cursor:match("^%s*$") then
            if text_to_insert:match("^%s") then
                -- Completion has leading whitespace but we're already indented
                -- Strip the completion's leading whitespace to avoid double indent
                text_to_insert = text_to_insert:gsub("^%s+", "")
            else
                -- Completion doesn't start with whitespace (like "end" or "}")
                -- This is likely a dedent - clear line's whitespace
                col = 0
                vim.api.nvim_set_current_line(current_line:sub(col + 1))
                current_line = vim.api.nvim_get_current_line()
            end
        end

        -- Handle multiline insertion
        local lines = vim.split(text_to_insert, "\n", { plain = true })

        if #lines == 1 then
            -- Single line: insert at cursor
            local new_line = current_line:sub(1, col) .. lines[1] .. current_line:sub(col + 1)
            vim.api.nvim_set_current_line(new_line)
            vim.api.nvim_win_set_cursor(0, { row, col + #lines[1] })
        else
            -- Multiline: replace current line and add new lines
            local before_cursor = current_line:sub(1, col)
            local after_cursor = current_line:sub(col + 1)

            -- First line gets appended to text before cursor
            lines[1] = before_cursor .. lines[1]
            -- Last line gets text after cursor appended
            lines[#lines] = lines[#lines] .. after_cursor

            -- Replace lines in buffer
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, lines)

            -- Move cursor to end of inserted text
            local new_row = row + #lines - 1
            local new_col = #lines[#lines] - #after_cursor
            vim.api.nvim_win_set_cursor(0, { new_row, new_col })
        end
    end)

    return true
end

-- ============================================================================
-- Keybindings
-- ============================================================================

local function setup_keymaps()
    -- Tab: accept full completion or fallback
    vim.keymap.set("i", config.keymaps.accept, function()
        if state.current_completion then
            accept_completion(true)
            return ""
        end
        -- Fallback to original Tab behavior
        return vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
    end, { expr = true, noremap = true, desc = "Accept Cerebras completion" })

    -- Shift-Tab: accept word
    vim.keymap.set("i", config.keymaps.accept_word, function()
        if state.current_completion then
            accept_completion(false)
            return ""
        end
        return vim.api.nvim_replace_termcodes("<S-Tab>", true, false, true)
    end, { expr = true, noremap = true, desc = "Accept Cerebras completion (word)" })

    -- Dismiss
    vim.keymap.set("i", config.keymaps.dismiss, function()
        clear_ghost_text()
        cancel_pending_job()
    end, { desc = "Dismiss Cerebras completion" })

    -- Toggle
    vim.keymap.set("n", config.keymaps.toggle, function()
        config.enabled = not config.enabled
        if not config.enabled then
            clear_ghost_text()
            cancel_pending_job()
            cancel_debounce_timer()
        end
        vim.notify(
            "Cerebras Completion " .. (config.enabled and "ENABLED" or "DISABLED"),
            vim.log.levels.INFO,
            { title = "Cerebras" }
        )
    end, { desc = "[A]uto-Completion (Cerebras)" })
end

-- ============================================================================
-- API Client
-- ============================================================================

local function request_completion(prompt, callback)
    local api_key = get_api_key()
    if not api_key or api_key == "" then
        callback(nil, "CEREBRAS_API_KEY not set")
        return
    end

    -- Cancel any pending request
    cancel_pending_job()

    local payload = vim.fn.json_encode({
        model = config.model,
        prompt = prompt,
        max_tokens = config.max_tokens,
        temperature = config.temperature,
        stop = config.stop_sequences,
        stream = true, -- Enable streaming
    })

    local accumulated_text = ""
    local buffer = "" -- Buffer for incomplete SSE lines

    state.pending_job = vim.fn.jobstart({
        "curl",
        "-s",
        "-N", -- Disable buffering for streaming
        "-X",
        "POST",
        "https://api.cerebras.ai/v1/completions",
        "-H",
        "Authorization: Bearer " .. api_key,
        "-H",
        "Content-Type: application/json",
        "-d",
        payload,
    }, {
        on_stdout = function(_, data)
            if not data then
                return
            end

            -- Neovim splits output by newlines, so data is an array of lines
            for _, line in ipairs(data) do
                -- Handle incomplete lines by buffering
                if buffer ~= "" then
                    line = buffer .. line
                    buffer = ""
                end

                -- Skip empty lines
                if line == "" then
                    goto continue
                end

                -- Parse SSE data line
                if line:match("^data: ") then
                    local json_str = line:sub(7) -- Remove "data: " prefix

                    if json_str == "[DONE]" then
                        goto continue
                    end

                    local ok, json_data = pcall(vim.fn.json_decode, json_str)
                    if ok and json_data.choices and json_data.choices[1] then
                        local token = json_data.choices[1].text or ""

                        if token ~= "" then
                            accumulated_text = accumulated_text .. token

                            -- Check for stop sequences
                            local should_stop = false
                            for _, stop_seq in ipairs(config.stop_sequences) do
                                if accumulated_text:find(stop_seq, 1, true) then
                                    -- Trim at stop sequence
                                    local stop_pos = accumulated_text:find(stop_seq, 1, true)
                                    accumulated_text = accumulated_text:sub(1, stop_pos - 1)
                                    should_stop = true
                                    break
                                end
                            end

                            -- Update ghost text with accumulated tokens
                            vim.schedule(function()
                                if is_insert_mode() then
                                    render_ghost_text(accumulated_text)
                                end
                            end)

                            if should_stop then
                                -- Cancel the job since we hit a stop sequence
                                if state.pending_job then
                                    vim.fn.jobstop(state.pending_job)
                                end
                                return
                            end
                        end
                    end
                elseif not line:match("^%s*$") then
                    -- Incomplete line, buffer it
                    buffer = line
                end

                ::continue::
            end
        end,
        on_exit = function(_, exit_code)
            state.pending_job = nil

            vim.schedule(function()
                if exit_code ~= 0 and exit_code ~= 143 then -- 143 = killed by SIGTERM (normal cancel)
                    callback(nil, "API call failed (exit code: " .. exit_code .. ")")
                    return
                end

                -- Final callback with accumulated text
                if accumulated_text ~= "" then
                    callback(accumulated_text)
                end
            end)
        end,
    })

    if state.pending_job <= 0 then
        state.pending_job = nil
        callback(nil, "Failed to start curl process")
    end
end

-- ============================================================================
-- Context Collection
-- ============================================================================

local function get_context()
    local buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1]
    local col = cursor[2]

    -- Get model capabilities
    local model_info = models[config.model] or {}
    local use_fim = model_info.fim and model_info.fim_tokens

    -- Get file info
    local filepath = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.bo[buf].filetype
    local filename = vim.fn.fnamemodify(filepath, ":t")

    -- Get all lines in buffer
    local total_lines = vim.api.nvim_buf_line_count(buf)
    local all_lines = vim.api.nvim_buf_get_lines(buf, 0, total_lines, false)

    -- Check file size limit
    local total_size = 0
    for _, line in ipairs(all_lines) do
        total_size = total_size + #line + 1 -- +1 for newline
    end
    if total_size > config.max_file_size then
        return nil -- Skip large files
    end

    -- Get current line
    local current_line = all_lines[row] or ""
    local line_before_cursor = current_line:sub(1, col)
    local line_after_cursor = current_line:sub(col + 1)

    -- Build prefix (lines before cursor)
    local prefix_lines = {}

    -- Determine file header comment style
    local comment_prefix = "--"
    if filetype == "python" or filetype == "sh" or filetype == "bash" or filetype == "zsh" then
        comment_prefix = "#"
    elseif
        filetype == "javascript"
        or filetype == "typescript"
        or filetype == "typescriptreact"
        or filetype == "javascriptreact"
        or filetype == "c"
        or filetype == "cpp"
        or filetype == "java"
        or filetype == "go"
        or filetype == "rust"
    then
        comment_prefix = "//"
    end

    -- Add file header
    if filename and filename ~= "" then
        table.insert(prefix_lines, comment_prefix .. " File: " .. filename)
    end

    -- Add lines before cursor
    local start_line = 1
    if config.max_context_lines then
        start_line = math.max(1, row - config.max_context_lines)
    end

    for i = start_line, row - 1 do
        table.insert(prefix_lines, all_lines[i])
    end

    -- Add current line up to cursor
    table.insert(prefix_lines, line_before_cursor)

    local prefix = table.concat(prefix_lines, "\n")

    -- If model supports FIM, use proper FIM tokens
    if use_fim then
        local suffix_lines = {}
        table.insert(suffix_lines, line_after_cursor)
        for i = row + 1, total_lines do
            table.insert(suffix_lines, all_lines[i])
        end
        local suffix = table.concat(suffix_lines, "\n")

        local tokens = model_info.fim_tokens
        -- FIM format: <|fim_prefix|>{prefix}<|fim_suffix|>{suffix}<|fim_middle|>
        return tokens.prefix .. prefix .. tokens.suffix .. suffix .. tokens.middle
    end

    -- Non-FIM models: include suffix with cursor marker if configured
    if config.include_suffix then
        local suffix_lines = {}
        table.insert(suffix_lines, line_after_cursor)

        -- Use same max_context_lines for suffix
        local end_line = total_lines
        if config.max_context_lines then
            end_line = math.min(total_lines, row + config.max_context_lines)
        end

        for i = row + 1, end_line do
            table.insert(suffix_lines, all_lines[i])
        end

        local suffix = table.concat(suffix_lines, "\n")
        if suffix ~= "" then
            -- Use a simple cursor marker that the model can understand
            return prefix .. "█" .. suffix
        end
    end

    -- Default: just return prefix
    return prefix
end

-- ============================================================================
-- Event Handling
-- ============================================================================

local function on_text_changed()
    if not config.enabled then
        return
    end

    if not is_insert_mode() then
        return
    end

    -- Clear any existing ghost text immediately on typing
    clear_ghost_text()

    -- Cancel existing debounce timer
    cancel_debounce_timer()

    -- Set up new debounce timer
    state.debounce_timer = vim.fn.timer_start(config.debounce_ms, function()
        state.debounce_timer = nil

        vim.schedule(function()
            if not is_insert_mode() then
                return
            end

            local context = get_context()
            if not context or context == "" then
                return
            end

            request_completion(context, function(completion, err)
                if err then
                    -- Silently fail - don't spam errors
                    return
                end

                if completion and is_insert_mode() then
                    render_ghost_text(completion)
                end
            end)
        end)
    end)
end

local function setup_autocmds()
    local group = vim.api.nvim_create_augroup("cerebras_completion", { clear = true })

    -- Request completion on text change
    vim.api.nvim_create_autocmd({ "TextChangedI" }, {
        group = group,
        callback = on_text_changed,
    })

    -- Clear ghost text when leaving insert mode
    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        group = group,
        callback = function()
            clear_ghost_text()
            cancel_pending_job()
            cancel_debounce_timer()
        end,
    })

    -- Clear when buffer changes
    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = group,
        callback = function()
            clear_ghost_text()
            cancel_pending_job()
            cancel_debounce_timer()
        end,
    })

    -- Track cursor movement to clear stale completions
    vim.api.nvim_create_autocmd({ "CursorMovedI" }, {
        group = group,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            local pos_key = cursor[1] .. ":" .. cursor[2]

            -- If cursor moved significantly (not just from typing), clear
            if state.last_cursor_pos and state.last_cursor_pos ~= pos_key then
                -- Check if it's a horizontal move on same line (likely typing)
                local last_row, last_col = state.last_cursor_pos:match("(%d+):(%d+)")
                if last_row and tonumber(last_row) ~= cursor[1] then
                    -- Different line - clear completion
                    clear_ghost_text()
                end
            end

            state.last_cursor_pos = pos_key
        end,
    })
end

-- ============================================================================
-- Initialization
-- ============================================================================

local function setup()
    if not has_api_key() then
        vim.notify("CEREBRAS_API_KEY not set. Run: source ~/.env", vim.log.levels.WARN, { title = "Cerebras Completion" })
        return
    end

    setup_keymaps()
    setup_autocmds()

    -- Command to check status
    vim.api.nvim_create_user_command("CerebrasStatus", function()
        local status = config.enabled and "enabled" or "disabled"
        local has_key = has_api_key() and "set" or "NOT SET"
        local model_info = models[config.model] or {}
        local model_name = model_info.name or config.model
        local fim_status = model_info.fim and "yes" or "no"
        local pricing = model_info.pricing
                and string.format("$%.2f/$%.2f per M tokens", model_info.pricing.input, model_info.pricing.output)
            or "unknown"

        vim.notify(
            string.format(
                "Cerebras Completion: %s\nAPI Key: %s\nModel: %s (%s)\nFIM: %s\nPricing: %s",
                status,
                has_key,
                model_name,
                config.model,
                fim_status,
                pricing
            ),
            vim.log.levels.INFO
        )
    end, { desc = "Show Cerebras completion status" })
end

-- Initialize on load
setup()
