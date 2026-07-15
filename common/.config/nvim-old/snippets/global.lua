--- Dynamic date snippets for mini.snippets
--- Loaded via gen_loader.from_file() — returns a table with a function element.
--- The function is called on each expand, so dates are always fresh.
--- Format: YYYY.MM.DD - Day (3-char English abbreviations)

--- Days until next target weekday from current day
--- wday: os.date("*t").wday (1=Sun, 2=Mon, ..., 7=Sat)
--- target: 1=Sun, 2=Mon, ..., 7=Sat
local function days_until_next(target)
    local wday = os.date("*t").wday
    local diff = target - wday
    if diff <= 0 then
        diff = diff + 7
    end
    return diff
end

local function format_date(offset_days)
    local time = os.time() + (offset_days or 0) * 86400
    local date = os.date("*t", time)

    local day_names = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
    local day_name = day_names[date.wday]

    return string.format("%04d.%02d.%02d - %s", date.year, date.month, date.day, day_name)
end

local function format_month(offset_months)
    local date = os.date("*t")

    local month = date.month + (offset_months or 0)
    local year = date.year

    while month > 12 do
        month = month - 12
        year = year + 1
    end
    while month < 1 do
        month = month + 12
        year = year - 1
    end

    local month_names = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

    return string.format("%04d.%02d - %s", year, month, month_names[month])
end

--- Must return a TABLE (not a function directly).
--- The function element inside is called by traverse_raw_snippets on each expand.
return {
    function()
    -- stylua: ignore start
    return {
      -- Today
      { prefix = "today",        body = format_date(0),                                          desc = "Date: today" },
      { prefix = "today-link",   body = "[[" .. format_date(0) .. "]]",                         desc = "Date: today (wikilink)" },
      { prefix = "today-header", body = "## " .. format_date(0),                                desc = "Date: today (h2 header)" },

      -- Tomorrow
      { prefix = "tomorrow",        body = format_date(1),                                       desc = "Date: tomorrow" },
      { prefix = "tomorrow-link",   body = "[[" .. format_date(1) .. "]]",                      desc = "Date: tomorrow (wikilink)" },
      { prefix = "tomorrow-header", body = "## " .. format_date(1),                              desc = "Date: tomorrow (h2 header)" },

      -- Yesterday
      { prefix = "yesterday",        body = format_date(-1),                                     desc = "Date: yesterday" },
      { prefix = "yesterday-link",   body = "[[" .. format_date(-1) .. "]]",                    desc = "Date: yesterday (wikilink)" },
      { prefix = "yesterday-header", body = "## " .. format_date(-1),                            desc = "Date: yesterday (h2 header)" },

      -- Next Monday (wday=2)
      { prefix = "next-mon",        body = format_date(days_until_next(2)),                      desc = "Date: next Monday" },
      { prefix = "next-mon-link",   body = "[[" .. format_date(days_until_next(2)) .. "]]",      desc = "Date: next Monday (wikilink)" },

      -- Next Friday (wday=6)
      { prefix = "next-fri",        body = format_date(days_until_next(6)),                      desc = "Date: next Friday" },
      { prefix = "next-fri-link",   body = "[[" .. format_date(days_until_next(6)) .. "]]",      desc = "Date: next Friday (wikilink)" },

      -- Month
      { prefix = "month",      body = format_month(0),                                           desc = "Month: current" },
      { prefix = "month-link", body = "[[" .. format_month(0) .. "]]",                           desc = "Month: current (wikilink)" },

      -- Next / Last Month
      { prefix = "next-month",      body = format_month(1),                                      desc = "Month: next" },
      { prefix = "next-month-link", body = "[[" .. format_month(1) .. "]]",                      desc = "Month: next (wikilink)" },
      { prefix = "last-month",      body = format_month(-1),                                     desc = "Month: last" },
      { prefix = "last-month-link", body = "[[" .. format_month(-1) .. "]]",                     desc = "Month: last (wikilink)" },

      -- Time
      { prefix = "time", body = os.date("%H:%M"),                                                desc = "Time (HH:MM)" },
    }
        -- stylua: ignore end
    end,
}
