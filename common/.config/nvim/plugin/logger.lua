-- Minimal logging plugin with TreeSitter function context detection
-- Simplified alternative to timber.nvim

local M = {}

-- Language-specific log templates
local templates = {
    javascript = 'console.log("DEBUG(%s%s): %s", %s)',
    typescript = 'console.log("DEBUG(%s%s): %s", %s)',
    javascriptreact = 'console.log("DEBUG(%s%s): %s", %s)',
    typescriptreact = 'console.log("DEBUG(%s%s): %s", %s)',
    lua = 'print("DEBUG(%s%s): %s", vim.inspect(%s))',
}

-- Function node types for different languages
local function_node_types = {
    javascript = { "function_declaration", "method_definition", "arrow_function" },
    typescript = { "function_declaration", "method_definition", "arrow_function" },
    javascriptreact = { "function_declaration", "method_definition", "arrow_function" },
    typescriptreact = { "function_declaration", "method_definition", "arrow_function" },
    lua = { "function_declaration", "function_definition" },
}

-- Get the filename for log context
local function get_filename()
    return vim.fn.expand("%:t")
end

-- Get current line's indentation
local function get_current_indentation()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local line_content = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)[1]
    local indent = line_content:match("^(%s*)")
    return indent or ""
end

-- Get text from a TreeSitter node
local function get_node_text(node, bufnr)
    bufnr = bufnr or 0
    return vim.treesitter.get_node_text(node, bufnr)
end

-- Find the containing function name
local function get_function_context()
    local filetype = vim.bo.filetype
    local node_types = function_node_types[filetype]

    if not node_types then
        return ""
    end

    -- Get current node under cursor
    local node = vim.treesitter.get_node()
    if not node then
        return ""
    end

    -- Traverse up the tree looking for function nodes
    local current = node
    while current do
        local node_type = current:type()

        -- Check if this is a function-like node
        for _, func_type in ipairs(node_types) do
            if node_type == func_type then
                local function_name = extract_function_name(current, node_type, filetype)
                if function_name then
                    return " | " .. function_name
                end
            end
        end

        current = current:parent()
    end

    return ""
end

-- Extract function name from different node types
function extract_function_name(node, node_type, filetype)
    if filetype == "lua" then
        -- For Lua: function name() or local function name()
        if node_type == "function_declaration" then
            for child in node:iter_children() do
                if child:type() == "identifier" then
                    return get_node_text(child)
                end
            end
        end
    else
        -- For JS/TS family
        if node_type == "function_declaration" then
            for child in node:iter_children() do
                if child:type() == "identifier" then
                    return get_node_text(child)
                end
            end
        elseif node_type == "method_definition" then
            for child in node:iter_children() do
                if child:type() == "property_identifier" then
                    return get_node_text(child)
                end
            end
        elseif node_type == "arrow_function" then
            -- Look for variable declarator parent
            local parent = node:parent()
            if parent and parent:type() == "variable_declarator" then
                for child in parent:iter_children() do
                    if child:type() == "identifier" then
                        return get_node_text(child)
                    end
                end
            end
        end
    end

    return nil
end

-- Get the word under cursor or visual selection
local function get_log_target()
    local mode = vim.api.nvim_get_mode().mode

    if mode == "v" or mode == "V" then
        -- Visual mode - get selected text
        local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
        local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))
        local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

        if #lines == 1 then
            return lines[1]:sub(start_col, end_col)
        else
            return table.concat(lines, " ")
        end
    else
        -- Normal mode - get word under cursor
        return vim.fn.expand("<cword>")
    end
end

-- Insert log statement
local function insert_log(position)
    local filetype = vim.bo.filetype
    local template = templates[filetype]

    if not template then
        vim.notify("Logging not supported for filetype: " .. filetype, vim.log.levels.WARN)
        return
    end

    local target = get_log_target()
    if target == "" then
        vim.notify("No target found for logging", vim.log.levels.WARN)
        return
    end

    local filename = get_filename()
    local context = get_function_context()
    local indent = get_current_indentation()
    local log_line = indent .. string.format(template, filename, context, target, target)

    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local insert_line = position == "above" and current_line - 1 or current_line

    vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, { log_line })
end

-- Set up keymaps
vim.keymap.set({ "n", "v" }, "slk", function()
    insert_log("above")
end, { desc = "Insert log above" })

vim.keymap.set({ "n", "v" }, "slj", function()
    insert_log("below")
end, { desc = "Insert log below" })

return M
