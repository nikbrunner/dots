package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestScanProjectAttributesUnlabelledToolUse(t *testing.T) {
	dir := t.TempDir()
	transcript := `{"type":"assistant","requestId":"tools","timestamp":"2026-08-01T10:00:00Z","message":{"model":"claude-opus-5","usage":{"input_tokens":10,"output_tokens":2},"content":[{"type":"tool_use","name":"read"},{"type":"tool_use","name":"bash"}]}}
` + `{"type":"assistant","requestId":"conversation","timestamp":"2026-08-01T10:01:00Z","message":{"model":"claude-opus-5","usage":{"input_tokens":4},"content":[{"type":"text","text":"Done"}]}}
` + `{"type":"assistant","requestId":"skill","timestamp":"2026-08-01T10:02:00Z","attributionSkill":"dev-commit","message":{"model":"claude-opus-5","usage":{"input_tokens":6},"content":[{"type":"tool_use","name":"bash"}]}}
`
	if err := os.WriteFile(filepath.Join(dir, "session.jsonl"), []byte(transcript), 0o644); err != nil {
		t.Fatal(err)
	}

	att := newAttribution()
	ScanProject(dir, "20260801", "20260801", att)

	if got := att.Tally["tools"]["read"]["opus-5"]; got != 10 {
		t.Errorf("read weighted tokens = %.0f, want 10", got)
	}
	if got := att.Tally["tools"]["bash"]["opus-5"]; got != 10 {
		t.Errorf("bash weighted tokens = %.0f, want 10", got)
	}
	if got := att.Unattributed["opus-5"]; got != 4 {
		t.Errorf("unattributed weighted tokens = %.0f, want 4", got)
	}
	if got := att.Tally["skills"]["dev-commit"]["opus-5"]; got != 6 {
		t.Errorf("skill weighted tokens = %.0f, want 6", got)
	}
	if got := att.Tally["tools"]["bash"]["opus-5"]; got != 10 {
		t.Errorf("tool weighted tokens = %.0f, want 10", got)
	}
}
