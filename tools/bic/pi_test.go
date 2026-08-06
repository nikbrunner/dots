package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestPiReportTreatsCodexCostAsSubscriptionEquivalent(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)

	repo := filepath.Join(home, "repo")
	if err := os.MkdirAll(filepath.Join(home, ".pi", "agent", "sessions", "project"), 0o755); err != nil {
		t.Fatal(err)
	}
	line := `{"type":"message","cwd":"` + repo + `","message":{"role":"assistant","model":"gpt-5.3-codex","provider":"openai-codex","timestamp":1785585600000,"usage":{"cost":{"total":1.25}}}}` + "\n"
	path := filepath.Join(home, ".pi", "agent", "sessions", "project", "session.jsonl")
	if err := os.WriteFile(path, []byte(line), 0o644); err != nil {
		t.Fatal(err)
	}

	resolver := &Resolver{
		recorded: map[string]string{encodeProjectKey(repo): repo},
		cache:    map[string]Project{},
	}
	costs, _ := piReport(false, "20260801", "20260801", resolver)
	if got := costs["repo"].Unbilled; got != 1.25 {
		t.Fatalf("Codex subscription equivalent = %.2f, want 1.25", got)
	}
}

func TestScanPiIncludesNestedSessionsAndProvider(t *testing.T) {
	home := t.TempDir()
	t.Setenv("HOME", home)

	base := filepath.Join(home, ".pi", "agent", "sessions", "project")
	if err := os.MkdirAll(filepath.Join(base, "subagents", "worker"), 0o755); err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(base, "subagents", "worker", "session.jsonl")
	line := `{"type":"message","cwd":"/tmp/project","message":{"role":"assistant","model":"gpt-5.3-codex","provider":"openai-codex","timestamp":1785585600000,"usage":{"cost":{"total":1.25}}}}` + "\n"
	if err := os.WriteFile(path, []byte(line), 0o644); err != nil {
		t.Fatal(err)
	}

	sessions := ScanPi("20260801", "20260801")
	if len(sessions) != 1 {
		t.Fatalf("sessions = %d, want 1", len(sessions))
	}
	if got := sessions[0].Cost.Models["openai-codex/gpt-5.3-codex"]; got != 1.25 {
		t.Fatalf("Codex cost = %.2f, want 1.25", got)
	}
}
