package main

import (
	"bufio"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// Pi writes its own per-message cost, so its spend is read straight from its
// session files. No ccusage, and no apportioning tokens back into dollars:
// the figures here are exact rather than estimated.

type piRecord struct {
	Type      string `json:"type"`
	Cwd       string `json:"cwd"`
	Timestamp string `json:"timestamp"`
	Message   piMsg  `json:"message"`
	ID        string `json:"id"`
}

type piMsg struct {
	Role     string `json:"role"`
	Model    string `json:"model"`
	Provider string `json:"provider"`
	// Milliseconds since the epoch, unlike the session record's RFC3339.
	Timestamp int64 `json:"timestamp"`
	Usage     struct {
		Cost struct {
			Total float64 `json:"total"`
		} `json:"cost"`
	} `json:"usage"`
	Content []struct {
		Type      string `json:"type"`
		Name      string `json:"name"`
		Arguments struct {
			Tool string `json:"tool"`
		} `json:"arguments"`
	} `json:"content"`
}

// PiSession is one conversation: where it ran, and what it spent.
type PiSession struct {
	Cwd    string
	Cost   *Cost
	Tools  map[string]float64 // tool name -> dollars
	MCP    map[string]float64 // mcp tool -> dollars
	Unused float64            // turns that called nothing
}

// ScanPi reads every Pi session in range, keyed by working directory.
func ScanPi(since, until string) []PiSession {
	base := filepath.Join(homeDir(), ".pi", "agent", "sessions")
	var out []PiSession
	filepath.WalkDir(base, func(path string, d os.DirEntry, err error) error {
		if err != nil || d.IsDir() || !strings.HasSuffix(path, ".jsonl") {
			return nil
		}
		if s := scanPiFile(path, since, until); s != nil {
			out = append(out, *s)
		}
		return nil
	})
	return out
}

func scanPiFile(path, since, until string) *PiSession {
	fh, err := os.Open(path)
	if err != nil {
		return nil
	}
	defer fh.Close()

	session := &PiSession{
		Cost:  &Cost{Models: map[string]float64{}},
		Tools: map[string]float64{},
		MCP:   map[string]float64{},
	}

	scanner := bufio.NewScanner(fh)
	scanner.Buffer(make([]byte, 0, 1024*1024), 32*1024*1024)
	for scanner.Scan() {
		var rec piRecord
		if json.Unmarshal(scanner.Bytes(), &rec) != nil {
			continue
		}
		if rec.Cwd != "" {
			session.Cwd = rec.Cwd
		}
		if rec.Type != "message" || rec.Message.Role != "assistant" {
			continue
		}
		cost := rec.Message.Usage.Cost.Total
		if cost == 0 {
			continue
		}
		day := time.UnixMilli(rec.Message.Timestamp).Format("20060102")
		if (since != "" && day < since) || (until != "" && day > until) {
			continue
		}

		session.Cost.Total += cost
		session.Cost.Models[piModelLabel(rec.Message.Provider, rec.Message.Model)] += cost

		// A turn's cost is mostly its accumulated context rather than the call
		// it happens to make, so a turn calling several tools splits evenly
		// between them instead of counting fully for each.
		var names, mcp []string
		for _, block := range rec.Message.Content {
			if block.Type != "toolCall" {
				continue
			}
			if block.Name == "mcp" && block.Arguments.Tool != "" {
				mcp = append(mcp, block.Arguments.Tool)
				continue
			}
			if block.Name != "" {
				names = append(names, block.Name)
			}
		}
		calls := len(names) + len(mcp)
		if calls == 0 {
			session.Unused += cost
			continue
		}
		share := cost / float64(calls)
		for _, n := range names {
			session.Tools[n] += share
		}
		for _, n := range mcp {
			session.MCP[n] += share
		}
	}
	if session.Cost.Total == 0 && session.Cwd == "" {
		return nil
	}
	return session
}

// piReport folds Pi sessions into per-repo costs and attribution, reusing the
// same resolver so a worktree lands on the repo it was cut from.
//
// The renderer prices a label by its share of a model's token pool. Pi already
// counts in dollars, so it uses one synthetic pool per repo whose size equals
// that repo's spend: every share then comes out as the dollars themselves.
func piReport(work bool, since, until string, resolver *Resolver) (map[string]*Cost, map[string]*Attribution) {
	costs := map[string]*Cost{}
	attribution := map[string]*Attribution{}

	for _, s := range ScanPi(since, until) {
		if s.Cwd == "" || s.Cost.Total == 0 {
			continue
		}
		key := encodeProjectKey(s.Cwd)
		project := resolver.Resolve(key)
		if isWorkProject(key, project) != work {
			continue
		}

		cost := costs[project.Name]
		if cost == nil {
			cost = &Cost{Models: map[string]float64{}}
			costs[project.Name] = cost
		}
		cost.Total += s.Cost.Total
		for model, dollars := range s.Cost.Models {
			cost.Models[model] += dollars
			if isSubscriptionModel(model) {
				cost.Unbilled += dollars
			}
		}

		att := attribution[project.Name]
		if att == nil {
			att = newAttribution()
			attribution[project.Name] = att
		}
		for name, dollars := range s.Tools {
			att.add("tools", name, piPool, dollars)
		}
		for name, dollars := range s.MCP {
			att.add("mcp", name, piPool, dollars)
		}
		att.Total[piPool] += s.Cost.Total
		att.Unattributed[piPool] += s.Unused
	}
	return costs, attribution
}

// piPool is the synthetic model key that makes apportioning a no-op.
const piPool = "\x00pi"

func piModelLabel(provider, model string) string {
	if provider == "" || strings.Contains(model, "/") {
		return model
	}
	return provider + "/" + model
}
