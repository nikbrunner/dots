-- cerebras-completion.lua - AI-powered inline completions using Cerebras
-- Supermaven-style ghost text completions with Tab to accept

-- ============================================================================
-- Configuration
-- ============================================================================

local config = {
    enabled = true,
    debounce_ms = 150,
    max_context_lines = 50,
    model = "qwen-3-235b-a22b-instruct-2507",
    max_tokens = 128,
    temperature = 0.2,
    stop_sequences = { "\n", "```", "---" },  -- Stop at newline to prefer single-line completions
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

        -- If line before cursor is only whitespace and completion doesn't start
        -- with whitespace, this is likely a dedent (like "end" in Lua).
        -- Clear the line's whitespace so completion goes to proper indent level.
        if before_cursor:match("^%s*$") and not text_to_insert:match("^%s") then
            col = 0
            vim.api.nvim_set_current_line(current_line:sub(col + 1))
            current_line = vim.api.nvim_get_current_line()
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
    })

    local result_lines = {}

    state.pending_job = vim.fn.jobstart({
        "curl",
        "-s",
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
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(result_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, exit_code)
            state.pending_job = nil

            vim.schedule(function()
                if exit_code ~= 0 then
                    callback(nil, "API call failed (exit code: " .. exit_code .. ")")
                    return
                end

                local response = table.concat(result_lines, "\n")
                local ok, json_response = pcall(vim.fn.json_decode, response)

                if not ok then
                    callback(nil, "Failed to parse response")
                    return
                end

                -- Check for error in response
                if json_response.error then
                    callback(nil, json_response.error.message or "API error")
                    return
                end

                -- Extract completion text
                if json_response.choices and json_response.choices[1] and json_response.choices[1].text then
                    callback(json_response.choices[1].text)
                else
                    callback(nil, "No completion in response")
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

    -- Get file info
    local filepath = vim.api.nvim_buf_get_name(buf)
    local filetype = vim.bo[buf].filetype
    local filename = vim.fn.fnamemodify(filepath, ":t")

    -- Get lines before cursor (up to max_context_lines)
    local start_line = math.max(1, row - config.max_context_lines)
    local lines_before = vim.api.nvim_buf_get_lines(buf, start_line - 1, row - 1, false)

    -- Get current line up to cursor
    local current_line = vim.api.nvim_get_current_line()
    local line_before_cursor = current_line:sub(1, col)

    -- Build prompt with file context
    local prompt_parts = {}

    -- Add file header comment based on filetype
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

    if filename and filename ~= "" then
        table.insert(prompt_parts, comment_prefix .. " File: " .. filename)
    end

    -- Add context lines
    for _, line in ipairs(lines_before) do
        table.insert(prompt_parts, line)
    end

    -- Add current line up to cursor
    table.insert(prompt_parts, line_before_cursor)

    return table.concat(prompt_parts, "\n")
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
        vim.notify(
            string.format("Cerebras Completion: %s\nAPI Key: %s\nModel: %s", status, has_key, config.model),
            vim.log.levels.INFO
        )
    end, { desc = "Show Cerebras completion status" })
end

-- Initialize on load
setup()
