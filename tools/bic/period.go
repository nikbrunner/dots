package main

import (
	"fmt"
	"strconv"
	"strings"
	"time"
)

// Period is a closed range of local calendar days.
type Period struct {
	Since string // YYYYMMDD
	Until string // YYYYMMDD, empty means up to today
	Label string // how to describe it in the header
}

const dateLayout = "20060102"

// ParsePeriod turns words like "last week" into a range. Weeks start on
// Monday. An explicit YYYYMMDD is accepted too, so the same argument slot
// takes either.
func ParsePeriod(words []string, now time.Time) (Period, error) {
	phrase := strings.ToLower(strings.Join(words, " "))
	today := now.Format(dateLayout)
	day := func(t time.Time) string { return t.Format(dateLayout) }

	// Monday of the week containing t.
	monday := func(t time.Time) time.Time {
		offset := (int(t.Weekday()) + 6) % 7 // Sunday is 0, and ends the week
		return t.AddDate(0, 0, -offset)
	}

	// A bare unit means the current one: "--period week" is "this week".
	switch phrase {
	case "", "month", "this month":
		return Period{Since: now.Format("200601") + "01", Label: "this month"}, nil
	case "today", "day":
		return Period{Since: today, Until: today, Label: "today"}, nil
	case "yesterday":
		d := day(now.AddDate(0, 0, -1))
		return Period{Since: d, Until: d, Label: "yesterday"}, nil
	case "week", "this week":
		return Period{Since: day(monday(now)), Label: "this week"}, nil
	case "last week":
		start := monday(now).AddDate(0, 0, -7)
		return Period{
			Since: day(start),
			Until: day(start.AddDate(0, 0, 6)),
			Label: "last week",
		}, nil
	case "last month":
		first := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
		start := first.AddDate(0, -1, 0)
		return Period{
			Since: day(start),
			Until: day(first.AddDate(0, 0, -1)),
			Label: "last month",
		}, nil
	case "year", "this year":
		return Period{Since: now.Format("2006") + "0101", Label: "this year"}, nil
	case "all", "all time", "ever":
		return Period{Since: "20000101", Label: "all time"}, nil
	}

	// "last 7 days", "past 3 months", and the singular forms.
	if fields := strings.Fields(phrase); len(fields) == 3 &&
		(fields[0] == "last" || fields[0] == "past") {
		if n, err := strconv.Atoi(fields[1]); err == nil && n > 0 {
			unit := strings.TrimSuffix(fields[2], "s")
			var start time.Time
			switch unit {
			case "day":
				start = now.AddDate(0, 0, -n+1)
			case "week":
				start = monday(now).AddDate(0, 0, -7*(n-1))
			case "month":
				start = now.AddDate(0, -n, 0)
			default:
				return Period{}, fmt.Errorf("unknown period %q", phrase)
			}
			return Period{Since: day(start), Label: phrase}, nil
		}
	}

	// A bare date still works, so scripts and habits keep going.
	if _, err := time.Parse(dateLayout, phrase); err == nil {
		return Period{Since: phrase, Label: "since " + prettyDate(phrase)}, nil
	}

	return Period{}, fmt.Errorf("unknown period %q", phrase)
}

func prettyDate(d string) string {
	if len(d) != 8 {
		return d
	}
	return d[:4] + "-" + d[4:6] + "-" + d[6:]
}

// Describe names the range for the report header, preferring the words that
// were typed over the dates they resolved to.
func (p Period) Describe() string {
	if p.Label != "" {
		if p.Until != "" && p.Label != "today" && p.Label != "yesterday" {
			return fmt.Sprintf("%s (%s to %s)",
				p.Label, prettyDate(p.Since), prettyDate(p.Until))
		}
		return p.Label
	}
	if p.Until != "" {
		return prettyDate(p.Since) + " to " + prettyDate(p.Until)
	}
	return "since " + prettyDate(p.Since)
}
