local M = {}

---Finds a pattern in a line of a file and replaces it with a value
---@param filepath string
---@param pattern string
---@param value string
function M.update_line_in_file(filepath, pattern, value)
    -- First check if file exists and is readable
    if not vim.loop.fs_stat(filepath) then
        vim.notify("File does not exist: " .. filepath, vim.log.levels.ERROR)
        return
    end

    -- Read file safely with pcall
    local ok, lines = pcall(vim.fn.readfile, filepath)
    if not ok or not lines then
        vim.notify("Failed to read file: " .. filepath, vim.log.levels.ERROR)
        return
    end

    -- Process lines
    lines = vim.tbl_map(function(line)
        if vim.fn.match(line, pattern) ~= -1 then
            line = vim.fn.substitute(line, '".*"', value, "")
        end
        return line
    end, lines)

    -- Use a delay and write file safely with pcall
    vim.defer_fn(function()
        local write_ok, err = pcall(vim.fn.writefile, lines, filepath)
        if not write_ok then
            vim.notify("Failed to write file: " .. filepath .. " - " .. (err or "unknown error"), vim.log.levels.ERROR)
        end
    end, 500)
end

---Detects printwidth from .prettierrc or .editorconfig files
---@param start_path? string The directory to start searching from (defaults to current buffer directory)
---@return number|nil printwidth The detected printwidth or nil if not found
function M.detect_printwidth(start_path)
    start_path = start_path or vim.fn.expand("%:p:h")

    local function find_config_file(dir, filename)
        local filepath = dir .. "/" .. filename
        if vim.loop.fs_stat(filepath) then
            return filepath
        end

        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
            return nil
        end

        return find_config_file(parent, filename)
    end

    local function parse_prettierrc(filepath)
        local ok, content = pcall(vim.fn.readfile, filepath)
        if not ok or not content then
            return nil
        end

        local text = table.concat(content, "\n")

        -- Try to parse as JSON
        local json_ok, data = pcall(vim.fn.json_decode, text)
        if json_ok and data and data.printWidth then
            return tonumber(data.printWidth)
        end

        -- Fallback: simple pattern matching for printWidth
        local printwidth = text:match('"printWidth"%s*:%s*(%d+)')
        if printwidth then
            return tonumber(printwidth)
        end

        return nil
    end

    local function parse_editorconfig(filepath)
        local ok, lines = pcall(vim.fn.readfile, filepath)
        if not ok or not lines then
            return nil
        end

        local in_markdown_section = false
        local in_global_section = true
        local max_line_length = nil

        for _, line in ipairs(lines) do
            line = vim.trim(line)

            -- Skip comments and empty lines
            if line:match("^#") or line == "" then
                goto continue
            end

            -- Check for section headers
            if line:match("^%[.+%]$") then
                local section = line:match("^%[(.+)%]$")
                in_markdown_section = section:match("%.md$") or section:match("markdown") or section == "*"
                in_global_section = section == "*"
                goto continue
            end

            -- Look for max_line_length in relevant sections
            if (in_markdown_section or in_global_section) and line:match("^max_line_length") then
                local value = line:match("max_line_length%s*=%s*(%d+)")
                if value then
                    max_line_length = tonumber(value)
                    if in_markdown_section then
                        -- Prefer markdown-specific setting
                        return max_line_length
                    end
                end
            end

            ::continue::
        end

        return max_line_length
    end

    -- Try .prettierrc first
    local prettierrc_path = find_config_file(start_path, ".prettierrc")
    if prettierrc_path then
        local printwidth = parse_prettierrc(prettierrc_path)
        if printwidth then
            return printwidth
        end
    end

    -- Try .prettierrc.json
    local prettierrc_json_path = find_config_file(start_path, ".prettierrc.json")
    if prettierrc_json_path then
        local printwidth = parse_prettierrc(prettierrc_json_path)
        if printwidth then
            return printwidth
        end
    end

    -- Try .editorconfig
    local editorconfig_path = find_config_file(start_path, ".editorconfig")
    if editorconfig_path then
        local printwidth = parse_editorconfig(editorconfig_path)
        if printwidth then
            return printwidth
        end
    end

    return nil
end

return M
