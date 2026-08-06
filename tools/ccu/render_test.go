package main

import (
	"strings"
	"testing"
)

func TestRenderSplitsSubscriptionEquivalentFromBilledSpend(t *testing.T) {
	var out strings.Builder
	Report{
		Scope:        "personal",
		Span:         "today",
		SplitBilling: true,
		Repos: []RepoSpend{{
			Name: "mixed",
			Agents: []AgentSpend{
				{Agent: "claude", Cost: &Cost{Total: 5, Unbilled: 2, Models: map[string]float64{"opus-5": 3, unbilledModel: 2}}},
				{Agent: "pi", Cost: &Cost{Total: 5, Unbilled: 5, Models: map[string]float64{"openai-codex/gpt-5": 5}}},
			},
		}},
	}.Render(&out)

	if !strings.Contains(out.String(), "personal  ·  today  ·  $3.00 ($10.00)") {
		t.Fatalf("report = %q, want billed and subscription-equivalent totals", out.String())
	}
	if !strings.Contains(out.String(), "mixed  $3.00 ($10.00)") {
		t.Fatalf("report = %q, want mixed repo totals", out.String())
	}
}

func TestRenderMarksCodexSubscriptionUsage(t *testing.T) {
	var out strings.Builder
	Report{
		Scope:        "personal",
		Span:         "today",
		SplitBilling: true,
		Repos: []RepoSpend{{
			Name: "dots",
			Agents: []AgentSpend{{
				Agent: "pi",
				Cost:  &Cost{Total: 1.25, Unbilled: 1.25, Models: map[string]float64{"openai-codex/gpt-5": 1.25}},
			}},
		}},
	}.Render(&out)

	if !strings.Contains(out.String(), "personal  ·  today  ·  $0.00 ($1.25)") {
		t.Fatalf("report = %q, want billed and subscription-equivalent totals", out.String())
	}
	if !strings.Contains(out.String(), "openai-codex/gpt-5 (subscription)") {
		t.Fatalf("report = %q, want subscription model label", out.String())
	}
	if !strings.Contains(out.String(), "$1.25") {
		t.Fatalf("report = %q, want API-equivalent value", out.String())
	}
}

func TestRenderNamesUnattributedSpendAsNoAttributedAction(t *testing.T) {
	att := newAttribution()
	att.Total["opus-5"] = 10
	att.Unattributed["opus-5"] = 10

	var out strings.Builder
	Report{
		Scope: "personal",
		Span:  "today",
		Repos: []RepoSpend{{
			Name: "dots",
			Agents: []AgentSpend{{
				Agent:       "claude",
				Cost:        &Cost{Total: 1, Models: map[string]float64{"opus-5": 1}},
				Attribution: att,
			}},
		}},
	}.Render(&out)

	if !strings.Contains(out.String(), "no attributed action") {
		t.Fatalf("report = %q, want no attributed action", out.String())
	}
}
