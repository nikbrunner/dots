-- Centralized periodic notes config for Obsidian vault.
-- Single source of truth for folder structure and date formats.
-- Uses Lua os.date format tokens (strftime).

local M = {}

M.log_dir = "02 - Areas/Log"
M.templates_dir = "05 - Meta/Templates"

---@class PeriodicNoteConfig
---@field path_fmt string|nil os.date format string for the full relative path (without .md)
---@field template string|nil Template filename (without .md)

---@type table<string, PeriodicNoteConfig>
M.notes = {
    daily = { path_fmt = "%Y/%m - %B/%Y.%m.%d - %A", template = "Daily Note" },
    weekly = { template = "Weekly Note" }, -- path needs special handling (locale week)
    monthly = { path_fmt = "%Y/%m - %B/%Y.%m - %B", template = "Monthly Note" },
    quarterly = { template = "Quarterly Note" }, -- path needs special handling (quarter)
    yearly = { path_fmt = "%Y/%Y", template = "Yearly Note" },
}

---Locale week number matching Moment.js `w` (Sunday-start, week 1 contains Jan 1).
---@return integer
function M.locale_week()
    local yday = tonumber(os.date("%j"))
    local wday = tonumber(os.date("%w")) -- 0=Sunday
    local jan1_wday = (wday - (yday - 1) % 7 + 7) % 7
    return math.floor((yday - 1 + jan1_wday) / 7) + 1
end

---Build the note title (= filename without .md) for a periodic note.
---@param kind string One of "daily", "weekly", "monthly", "quarterly", "yearly"
---@return string
function M.title(kind)
    if kind == "weekly" then
        return os.date("%Y.%m - %B") .. " - W" .. M.locale_week()
    elseif kind == "quarterly" then
        local quarter = math.ceil(tonumber(os.date("%m")) / 3)
        return os.date("%Y") .. " - Q" .. quarter
    elseif kind == "yearly" then
        return os.date("%Y")
    elseif kind == "monthly" then
        return os.date("%Y.%m - %B")
    else
        return os.date("%Y.%m.%d - %A")
    end
end

---Build the directory (relative to vault root) for a periodic note.
---@param kind string One of "daily", "weekly", "monthly", "quarterly", "yearly"
---@return string
function M.dir(kind)
    if kind == "quarterly" or kind == "yearly" then
        return M.log_dir .. "/" .. os.date("%Y")
    else
        return M.log_dir .. "/" .. os.date("%Y/%m - %B")
    end
end

---Open or create a periodic note using obsidian.nvim's Note API.
---Applies the corresponding template for new notes.
---@param kind string One of "weekly", "monthly", "quarterly", "yearly"
function M.open(kind)
    local Note = require("obsidian.note")
    local cfg = M.notes[kind]
    local note_title = M.title(kind)
    local note_dir = M.dir(kind)

    Note.create({
        id = note_title,
        dir = note_dir,
        template = cfg.template,
        should_write = true,
    }):open()
end

return M
