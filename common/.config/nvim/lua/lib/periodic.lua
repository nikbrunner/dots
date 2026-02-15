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
    weekly = { path_fmt = "%Y/%m - %B/%Y.%m - %B - W%V" },
    monthly = { path_fmt = "%Y/%m - %B/%Y.%m - %B" },
    quarterly = { path_fmt = "%Y/%Y - Q*" }, -- quarter needs special handling
    yearly = { path_fmt = "%Y/%Y" },
}

---Build the absolute path for a periodic note.
---@param kind string One of "daily", "weekly", "monthly", "quarterly", "yearly"
---@return string
function M.path(kind)
    local client = require("obsidian").get_client()
    local vault = tostring(client.dir)

    local rel
    if kind == "quarterly" then
        local quarter = math.ceil(tonumber(os.date("%m")) / 3)
        rel = os.date("%Y") .. "/" .. os.date("%Y") .. " - Q" .. quarter
    else
        rel = os.date(M.notes[kind].path_fmt)
    end

    return vault .. "/" .. M.log_dir .. "/" .. rel .. ".md"
end

---Open the periodic note for the given kind, creating parent dirs as needed.
---@param kind string One of "weekly", "monthly", "quarterly", "yearly"
function M.open(kind)
    local path = M.path(kind)
    vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
    vim.cmd("edit " .. vim.fn.fnameescape(path))
end

return M
