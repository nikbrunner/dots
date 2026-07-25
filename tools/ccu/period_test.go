package main

import (
	"testing"
	"time"
)

func TestParsePeriod(t *testing.T) {
	// A Saturday, so "last week" and "this week" are easy to check by hand.
	now := time.Date(2026, 7, 25, 18, 0, 0, 0, time.UTC)

	cases := []struct {
		phrase string
		since  string
		until  string
	}{
		{"", "20260701", ""},
		{"this month", "20260701", ""},
		{"month", "20260701", ""}, // bare unit means the current one
		{"week", "20260720", ""},
		{"year", "20260101", ""},
		{"day", "20260725", "20260725"},
		{"today", "20260725", "20260725"},
		{"yesterday", "20260724", "20260724"},
		{"this week", "20260720", ""},          // Monday of this week
		{"last week", "20260713", "20260719"},  // Mon-Sun, fully closed
		{"last month", "20260601", "20260630"}, // June, fully closed
		{"this year", "20260101", ""},
		{"last 7 days", "20260719", ""},
		{"past 3 months", "20260425", ""},
		{"20260714", "20260714", ""},
		{"LAST WEEK", "20260713", "20260719"}, // case-insensitive
	}

	for _, c := range cases {
		got, err := ParsePeriod([]string{c.phrase}, now)
		if err != nil {
			t.Errorf("%q: unexpected error %v", c.phrase, err)
			continue
		}
		if got.Since != c.since || got.Until != c.until {
			t.Errorf("%q: got %s..%s, want %s..%s",
				c.phrase, got.Since, got.Until, c.since, c.until)
		}
	}
}

// A Monday and a Sunday are the days week arithmetic gets wrong.
func TestParsePeriodWeekEdges(t *testing.T) {
	monday := time.Date(2026, 7, 20, 9, 0, 0, 0, time.UTC)
	p, _ := ParsePeriod([]string{"this week"}, monday)
	if p.Since != "20260720" {
		t.Errorf("this week on a Monday: got %s, want 20260720", p.Since)
	}

	sunday := time.Date(2026, 7, 26, 9, 0, 0, 0, time.UTC)
	p, _ = ParsePeriod([]string{"this week"}, sunday)
	if p.Since != "20260720" {
		t.Errorf("this week on a Sunday: got %s, want 20260720", p.Since)
	}
	p, _ = ParsePeriod([]string{"last week"}, sunday)
	if p.Since != "20260713" || p.Until != "20260719" {
		t.Errorf("last week on a Sunday: got %s..%s, want 20260713..20260719",
			p.Since, p.Until)
	}
}

// January is where "last month" crosses a year boundary.
func TestParsePeriodYearBoundary(t *testing.T) {
	jan := time.Date(2026, 1, 15, 9, 0, 0, 0, time.UTC)
	p, _ := ParsePeriod([]string{"last month"}, jan)
	if p.Since != "20251201" || p.Until != "20251231" {
		t.Errorf("last month in January: got %s..%s, want 20251201..20251231",
			p.Since, p.Until)
	}
}

// The period's words may be quoted or not, and other flags must survive
// either way.
func TestParseRangeCollectsPeriodWords(t *testing.T) {
	cases := []struct {
		name string
		args []string
	}{
		{"unquoted", []string{"-p", "last", "week", "--pi"}},
		{"quoted", []string{"--period", "last week", "--pi"}},
		{"period last", []string{"--pi", "-p", "last", "week"}},
	}
	for _, c := range cases {
		period, passthrough, err := parseRange(c.args)
		if err != nil {
			t.Errorf("%s: %v", c.name, err)
			continue
		}
		if period.Label != "last week" {
			t.Errorf("%s: got label %q, want \"last week\"", c.name, period.Label)
		}
		// --pi is consumed before parseRange sees it in real use, but any
		// unrecognised flag must reach ccusage rather than the period.
		if len(passthrough) == 0 || passthrough[0] != "--pi" {
			t.Errorf("%s: lost the trailing flag, got %v", c.name, passthrough)
		}
	}
}

// Explicit dates win, so a scripted call is never reinterpreted.
func TestParseRangeSinceOverridesPeriod(t *testing.T) {
	period, _, err := parseRange([]string{"-p", "last week", "-s", "20260101"})
	if err != nil {
		t.Fatal(err)
	}
	if period.Since != "20260101" || period.Until != "" {
		t.Errorf("got %s..%s, want 20260101..", period.Since, period.Until)
	}
}

func TestParsePeriodRejectsNonsense(t *testing.T) {
	now := time.Date(2026, 7, 25, 18, 0, 0, 0, time.UTC)
	for _, phrase := range []string{"next week", "banana", "last 0 days"} {
		if _, err := ParsePeriod([]string{phrase}, now); err == nil {
			t.Errorf("%q: expected an error", phrase)
		}
	}
}
