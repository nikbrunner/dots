package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// Output dominates cost and cache reads are nearly free. Weighting tokens by
// these ratios keeps a Fable-heavy skill from looking as expensive as an
// Opus-heavy one, so a label's share of a model's tokens tracks its share of
// that model's cost.
var weights = map[string]float64{
	"input_tokens":                1.0,
	"output_tokens":               5.0,
	"cache_creation_input_tokens": 1.25,
	"cache_read_input_tokens":     0.1,
}

type usage struct {
	Input      float64 `json:"input_tokens"`
	Output     float64 `json:"output_tokens"`
	CacheWrite float64 `json:"cache_creation_input_tokens"`
	CacheRead  float64 `json:"cache_read_input_tokens"`
}

func (u usage) weigh() float64 {
	return u.Input*weights["input_tokens"] +
		u.Output*weights["output_tokens"] +
		u.CacheWrite*weights["cache_creation_input_tokens"] +
		u.CacheRead*weights["cache_read_input_tokens"]
}

type record struct {
	Type      string `json:"type"`
	RequestID string `json:"requestId"`
	Timestamp string `json:"timestamp"`
	Skill     string `json:"attributionSkill"`
	Agent     string `json:"attributionAgent"`
	MCPServer string `json:"attributionMcpServer"`
	MCPTool   string `json:"attributionMcpTool"`
	Message   struct {
		Model string `json:"model"`
		Usage usage  `json:"usage"`
	} `json:"message"`
}

// Attribution accumulates weighted tokens per model, so each model's real cost
// can later be shared out among the labels that ran on it.
type Attribution struct {
	// kind ("skills"/"subagents"/"mcp") -> label -> model -> weighted tokens
	Tally        map[string]map[string]map[string]float64
	Total        map[string]float64 // model -> weighted tokens
	Unattributed map[string]float64 // model -> weighted tokens
}

func newAttribution() *Attribution {
	return &Attribution{
		Tally:        map[string]map[string]map[string]float64{},
		Total:        map[string]float64{},
		Unattributed: map[string]float64{},
	}
}

func (a *Attribution) add(kind, label, model string, tokens float64) {
	if a.Tally[kind] == nil {
		a.Tally[kind] = map[string]map[string]float64{}
	}
	if a.Tally[kind][label] == nil {
		a.Tally[kind][label] = map[string]float64{}
	}
	a.Tally[kind][label][model] += tokens
}

// ScanProject reads every transcript under one project directory.
func ScanProject(dir, since, until string, into *Attribution) {
	filepath.WalkDir(dir, func(path string, d os.DirEntry, err error) error {
		if err != nil || d.IsDir() || !strings.HasSuffix(path, ".jsonl") {
			return nil
		}
		info, err := d.Info()
		// A file cannot hold records written after its last write.
		if err != nil || (since != "" && info.ModTime().Format("20060102") < since) {
			return nil
		}
		scanFile(path, since, until, into)
		return nil
	})
}

func scanFile(path, since, until string, into *Attribution) {
	fh, err := os.Open(path)
	if err != nil {
		return
	}
	defer fh.Close()

	marker := []byte(`"assistant"`)
	seen := map[string]bool{}
	scanner := bufio.NewScanner(fh)
	scanner.Buffer(make([]byte, 0, 1024*1024), 32*1024*1024)

	for scanner.Scan() {
		line := scanner.Bytes()
		if !bytes.Contains(line, marker) {
			continue
		}
		var rec record
		if json.Unmarshal(line, &rec) != nil || rec.Type != "assistant" {
			continue
		}
		// Streaming writes the same request several times and the usage block
		// repeats in full, so counting every line would multiply the totals.
		if rec.RequestID == "" || seen[rec.RequestID] {
			continue
		}
		seen[rec.RequestID] = true

		day := localDate(rec.Timestamp)
		if day == "" || (since != "" && day < since) || (until != "" && day > until) {
			continue
		}
		tokens := rec.Message.Usage.weigh()
		if tokens == 0 {
			continue
		}
		model := shortModel(rec.Message.Model)
		into.Total[model] += tokens

		hits := 0
		if rec.Skill != "" {
			into.add("skills", rec.Skill, model, tokens)
			hits++
		}
		if rec.Agent != "" {
			into.add("subagents", rec.Agent, model, tokens)
			hits++
		}
		if rec.MCPServer != "" {
			label := rec.MCPServer
			if rec.MCPTool != "" {
				label += ":" + rec.MCPTool
			}
			into.add("mcp", label, model, tokens)
			hits++
		}
		if hits == 0 {
			into.Unattributed[model] += tokens
		}
	}
}

// localDate converts a transcript's UTC timestamp to a local calendar day, so
// buckets line up with the days ccusage reports.
func localDate(ts string) string {
	parsed, err := time.Parse(time.RFC3339, ts)
	if err != nil {
		return ""
	}
	return parsed.Local().Format("20060102")
}
