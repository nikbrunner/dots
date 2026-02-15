-- Centralized periodic notes config for Obsidian vault.
-- Single source of truth for folder structure and date formats.
-- Uses Lua os.date format tokens (strftime).

local M = {}

M.log_dir = "02 - Areas/Log"
M.templates_dir = "05 - Meta/Templates"

---@class PeriodicNoteConfig
---@field path_fmt string os.date format string for the full relative path (without .md)

---@type table<string, PeriodicNoteConfig>
M.notes = {
    daily = { path_fmt = "%Y/%m - %B/%Y.%m.%d - %A" },
    weekly = {}, -- needs special handling (Moment.js locale week)
    monthly = { path_fmt = "%Y/%m - %B/%Y.%m - %B" },
    quarterly = {}, -- needs special handling (quarter number)
    yearly = { path_fmt = "%Y/%Y" },
}

---Locale week number matching Moment.js `w` (Sunday-start, week 1 contains Jan 1).
---@return integer
function M.locale_week()
    local yday = tonumber(os.date("%j"))
    local wday = tonumber(os.date("%w")) -- 0=Sunday
    local jan1_wday = (wday - (yday - 1) % 7 + 7) % 7
    return math.floor((yday - 1 + jan1_wday) / 7) + 1
end

---Get the vault root directory.
---@return string
function M.vault_dir()
    ---@diagnostic disable-next-line: undefined-global
    return tostring(Obsidian.dir)
end

---Build the relative path (without .md) for a periodic note.
---@param kind string One of "daily", "weekly", "monthly", "quarterly", "yearly"
---@return string
local function rel_path(kind)
    if kind == "weekly" then
        return os.date("%Y/%m - %B/%Y.%m - %B") .. " - W" .. M.locale_week()
    elseif kind == "quarterly" then
        local quarter = math.ceil(tonumber(os.date("%m")) / 3)
        return os.date("%Y") .. "/" .. os.date("%Y") .. " - Q" .. quarter
    else
        return os.date(M.notes[kind].path_fmt)
    end
end

---Build the absolute path for a periodic note.
---@param kind string One of "daily", "weekly", "monthly", "quarterly", "yearly"
---@return string
function M.path(kind)
    return M.vault_dir() .. "/" .. M.log_dir .. "/" .. rel_path(kind) .. ".md"
end

---Open the periodic note for the given kind, creating parent dirs as needed.
---Sets the headline from the filename if the file is new.
---@param kind string One of "weekly", "monthly", "quarterly", "yearly"
function M.open(kind)
    local path = M.path(kind)
    local is_new = vim.fn.filereadable(path) == 0

    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    vim.cmd("edit " .. vim.fn.fnameescape(path))

    if is_new then
        local basename = vim.fn.fnamemodify(path, ":t:r")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "# " .. basename, "" })
    end
end

return M
