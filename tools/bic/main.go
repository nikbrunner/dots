// borrowed intelligence cost reports agent spend per repository, split between work and
// personal, and shows which models, skills, subagents and MCP servers drove it.
//
// Cost comes from ccusage, which prices tokens but knows nothing about what
// spent them. Attribution lives only in the raw transcripts, which count tokens
// but carry no prices. borrowed intelligence cost joins the two per repository.
//
// See README.md for how the pieces fit together.
package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const usageText = `Usage: bic <command> [flags]

Commands:
  imfusion            Spend on work repositories
  personal            Spend on everything else
  record [-cwd DIR]   Note which repo a session ran in (for agent hooks)
  help                Show this help

Flags:
  -p, --period WORDS     Reporting period, see below
  --claude               Claude Code only
  --pi                   Pi only
  -s, --since YYYYMMDD   Explicit start, overrides --period
  -u, --until YYYYMMDD   Explicit end

` + periodHelp + `
Both agents are included unless one is named.

Prints one tree per repo: cost, models, and the skills, subagents, tools and
MCP servers that drove it.
`

const periodHelp = `Periods (weeks start on Monday, default is this month):
  day / today      week / this week    month / this month
  yesterday        last week           last month
  year             last 7 days         past 3 months
  all time         20260714

Quotes are optional: -p last week and -p "last week" both work.
`

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		fmt.Print(usageText)
		return
	}

	switch args[0] {
	case "imfusion":
		os.Exit(report(true, args[1:]))
	case "personal":
		os.Exit(report(false, args[1:]))
	case "record":
		os.Exit(recordCmd(args[1:]))
	case "help", "-h", "--help":
		fmt.Print(usageText)
	default:
		fmt.Fprintf(os.Stderr, "bic: unknown command %q\n\n", args[0])
		fmt.Fprint(os.Stderr, usageText)
		os.Exit(1)
	}
}

// recordCmd notes which repo a session ran in. The working directory comes
// from -cwd or from a JSON hook payload on stdin, so one binary serves both
// Claude Code hooks and Pi extensions. Safe to call on every lifecycle event:
// it writes only when something changed.
func recordCmd(args []string) int {
	var cwd string
	for i := 0; i < len(args); i++ {
		if (args[i] == "-cwd" || args[i] == "--cwd") && i+1 < len(args) {
			cwd = args[i+1]
		}
		if args[i] == "-path" || args[i] == "--path" {
			fmt.Println(ledgerPath())
			return 0
		}
	}
	if cwd == "" {
		cwd = cwdFromHookPayload()
	}
	if cwd == "" {
		return 0
	}
	if info, err := os.Stat(cwd); err != nil || !info.IsDir() {
		return 0
	}

	ledger := loadLedger()
	if ledger.record(cwd) {
		// A telemetry side-effect must never break the agent that called it.
		_ = saveLedger(ledger)
	}
	return 0
}

// cwdFromHookPayload reads the JSON both agents send on stdin.
func cwdFromHookPayload() string {
	stat, err := os.Stdin.Stat()
	if err != nil || stat.Mode()&os.ModeCharDevice != 0 {
		return ""
	}
	var payload struct {
		Cwd string `json:"cwd"`
	}
	if json.NewDecoder(os.Stdin).Decode(&payload) != nil {
		return ""
	}
	return payload.Cwd
}

// report prints one scope. Agents are branches inside each repo unless a
// filter narrows it to one, in which case the agent level is dropped.
func report(work bool, args []string) int {
	agents, rest := parseAgents(args)
	period, passthrough, err := parseRange(rest)
	if err != nil {
		fmt.Fprintf(os.Stderr, "bic: %v\n\n%s", err, periodHelp)
		return 1
	}
	since, until := period.Since, period.Until

	home, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintln(os.Stderr, "bic: cannot determine home directory")
		return 1
	}
	projectDirs := claudeProjectDirs(home)
	resolver := NewResolver(filepath.Join(home, "repos"), projectDirs)

	// repo -> agent -> spend
	byRepo := map[string]map[string]AgentSpend{}
	add := func(repo, agent string, cost *Cost, att *Attribution) {
		if cost == nil || cost.Total == 0 {
			return
		}
		if byRepo[repo] == nil {
			byRepo[repo] = map[string]AgentSpend{}
		}
		byRepo[repo][agent] = AgentSpend{agent, cost, att}
	}

	if agents["claude"] {
		costs, attribution, err := claudeSpend(work, since, until, passthrough,
			projectDirs, resolver)
		if err != nil {
			fmt.Fprintf(os.Stderr, "bic: %v\n", err)
			return 1
		}
		for repo, cost := range costs {
			add(repo, "claude", cost, attribution[repo])
		}
	}
	if agents["pi"] {
		costs, attribution := piReport(work, since, until, resolver)
		for repo, cost := range costs {
			add(repo, "pi", cost, attribution[repo])
		}
	}

	repos := make([]RepoSpend, 0, len(byRepo))
	for name, spends := range byRepo {
		repo := RepoSpend{Name: name}
		for _, spend := range spends {
			repo.Agents = append(repo.Agents, spend)
		}
		repos = append(repos, repo)
	}

	scope := "personal"
	if work {
		scope = "imfusion"
	}
	if len(agents) == 1 {
		for name := range agents {
			scope = name + " · " + scope
		}
	}

	out := &strings.Builder{}
	Report{
		Scope: scope,
		Span:  period.Describe(),
		// Pi's Codex values and Claude's Fable values are subscription equivalents.
		SplitBilling: agents["claude"] || agents["pi"],
		Repos:        repos,
		SingleAgent:  len(agents) == 1,
	}.Render(out)
	fmt.Print(out.String())
	return 0
}

// claudeProjectDirs lists the transcript stores to read. A second Anthropic
// account runs with its own CLAUDE_CONFIG_DIR (see the claude-work shell
// function), and its sessions are just as real as the primary account's.
func claudeProjectDirs(home string) []string {
	var dirs []string
	for _, base := range []string{".claude", ".claude-work"} {
		dir := filepath.Join(home, base, "projects")
		if info, err := os.Stat(dir); err == nil && info.IsDir() {
			dirs = append(dirs, dir)
		}
	}
	return dirs
}

// claudeSpend joins ccusage dollars with transcript attribution.
func claudeSpend(work bool, since, until string, passthrough []string,
	projectDirs []string, resolver *Resolver,
) (map[string]*Cost, map[string]*Attribution, error) {
	data, err := RunCcusage(append([]string{"--since", since}, passthrough...),
		projectDirs)
	if err != nil {
		return nil, nil, fmt.Errorf("ccusage failed: %w", err)
	}

	costs := map[string]*Cost{}
	for key, days := range data.Projects {
		project := resolver.Resolve(key)
		if isWorkProject(key, project) != work {
			continue
		}
		cost := costs[project.Name]
		if cost == nil {
			cost = &Cost{Models: map[string]float64{}}
			costs[project.Name] = cost
		}
		for _, day := range days {
			for _, mb := range day.ModelBreakdowns {
				model := shortModel(mb.ModelName)
				cost.Total += mb.Cost
				cost.Models[model] += mb.Cost
				if isUnbilledModel(model) {
					cost.Unbilled += mb.Cost
				}
			}
		}
	}

	// The same repo can appear under both accounts, so attribution accumulates
	// per repo across every store rather than per directory.
	attribution := map[string]*Attribution{}
	for _, projectsDir := range projectDirs {
		entries, _ := os.ReadDir(projectsDir)
		for _, entry := range entries {
			if !entry.IsDir() {
				continue
			}
			project := resolver.Resolve(entry.Name())
			if isWorkProject(entry.Name(), project) != work {
				continue
			}
			att := attribution[project.Name]
			if att == nil {
				att = newAttribution()
				attribution[project.Name] = att
			}
			ScanProject(filepath.Join(projectsDir, entry.Name()), since, until, att)
		}
	}
	return costs, attribution, nil
}

// parseAgents reads --claude/--pi filters, defaulting to every agent.
func parseAgents(args []string) (map[string]bool, []string) {
	agents := map[string]bool{}
	rest := make([]string, 0, len(args))
	for _, a := range args {
		switch a {
		case "--claude":
			agents["claude"] = true
		case "--pi":
			agents["pi"] = true
		default:
			rest = append(rest, a)
		}
	}
	if len(agents) == 0 {
		agents["claude"], agents["pi"] = true, true
	}
	return agents, rest
}

// isWorkProject judges a project by the repository it resolved to, so a
// worktree follows the repo it was cut from rather than where it sits on disk.
func isWorkProject(key string, p Project) bool {
	return strings.Contains(key, "imfusion") ||
		isWork(p.Path, "", filepath.Base(p.Path))
}

// parseRange resolves the reporting period and keeps whatever else was typed
// for ccusage. -p names a period ("last week"); -s/-u take explicit dates and
// win when both are given.
//
// A period's words may be quoted or not, so everything after -p that is not a
// flag belongs to it. Nothing else takes a bare argument.
func parseRange(args []string) (Period, []string, error) {
	var words, passthrough []string
	var since, until string

	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "-p", "--period":
			for i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
				words = append(words, args[i+1])
				i++
			}
		case "-s", "--since":
			if i+1 < len(args) {
				since = args[i+1]
				i++
			}
		case "-u", "--until":
			if i+1 < len(args) {
				until = args[i+1]
				i++
			}
		default:
			// Only flags reach ccusage. A bare word here is a period someone
			// forgot to put behind -p, and passing it on produces a bare
			// non-zero exit from ccusage instead of a usable message.
			if !strings.HasPrefix(args[i], "-") {
				return Period{}, nil, fmt.Errorf(
					"unexpected argument %q, did you mean -p %s?", args[i],
					strings.Join(args[i:], " "))
			}
			passthrough = append(passthrough, args[i])
		}
	}

	period, err := ParsePeriod(words, time.Now())
	if err != nil {
		return Period{}, nil, err
	}
	if since != "" {
		period = Period{Since: since, Until: until}
	} else if until != "" {
		period.Until = until
		period.Label = ""
	}
	if period.Until != "" {
		passthrough = append(passthrough, "--until", period.Until)
	}
	return period, passthrough, nil
}
