-- Minimal local bufmsg plugin - stripped down to essential functionality
-- Based on OliverChao/bufmsg.nvim

local buffer_name = "Messages"
local hint_ns = vim.api.nvim_create_namespace("bufmsg_hints")

local function is_bmessages_buffer_open()
    local bufnr = vim.fn.bufnr(buffer_name)
    return vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr)
end

local function add_keybinding_hints(bufnr)
    -- Clear existing hints
    vim.api.nvim_buf_clear_namespace(bufnr, hint_ns, 0, -1)

    -- Get last line number
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if line_count == 0 then
        return
    end

    -- Add virtual text with keybinding hints
    vim.api.nvim_buf_set_extmark(bufnr, hint_ns, line_count - 1, 0, {
        virt_text = { { " <C-u>: update | <C-r>: clear | q: close", "Comment" } },
        virt_text_pos = "eol",
    })
end

local function update_messages_buffer()
    return function()
        local new_messages = vim.api.nvim_cmd({ cmd = "messages" }, { output = true })
        if new_messages == "" then
            return
        end

        local bufnr = vim.fn.bufnr(buffer_name)
        if not vim.api.nvim_buf_is_valid(bufnr) then
            return
        end

        local lines = vim.split(new_messages, "\n")

        vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })

        -- Add keybinding hints
        add_keybinding_hints(bufnr)

        -- Auto-scroll to bottom if not in the messages buffer
        if vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) ~= buffer_name then
            local winnr = vim.fn.bufwinnr(bufnr)
            if winnr ~= -1 then
                local winid = vim.fn.win_getid(winnr)
                vim.api.nvim_win_set_cursor(winid, { #lines, 0 })
            end
        end
    end
end

local function create_raw_buffer()
    local bufnr = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(bufnr, buffer_name)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
    vim.api.nvim_set_option_value("filetype", "bufmsg", { buf = bufnr })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
    vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
    vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
    vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    return bufnr
end

local function create_messages_buffer()
    -- Close existing buffer if open
    if is_bmessages_buffer_open() then
        vim.api.nvim_buf_delete(vim.fn.bufnr(buffer_name), { force = true })
        return
    end

    -- Create horizontal split with new buffer
    vim.cmd("split | enew")
    local bufnr = create_raw_buffer()

    local update_fn = update_messages_buffer()
    update_fn()

    -- Add initial keybinding hints
    add_keybinding_hints(bufnr)

    -- Set up buffer keymaps
    vim.keymap.set("n", "<C-u>", update_fn, { silent = true, buffer = bufnr, desc = "Update messages" })
    vim.keymap.set("n", "<C-r>", function()
        vim.ui.input({ prompt = "Clear messages buffer? (y/n): " }, function(input)
            if input == "Y" or input == "y" then
                vim.cmd("messages clear")
                vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })
                vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
                vim.notify("Messages cleared", vim.log.levels.INFO)
            end
        end)
    end, { silent = true, buffer = bufnr, desc = "Clear messages" })

    vim.keymap.set("n", "q", "<CMD>close<CR>", { silent = true, buffer = bufnr, desc = "Close messages buffer" })
end

-- Create user command
vim.api.nvim_create_user_command("Bmessages", create_messages_buffer, {
    desc = "Open messages in horizontal split buffer",
})

-- Set up keymap
vim.keymap.set("n", "<leader>am", "<CMD>Bmessages<CR>", { desc = "[M]essages" })
