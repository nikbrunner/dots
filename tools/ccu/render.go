package main

import (
	"fmt"
	"sort"
	"strings"
)

const (
	topN     = 6    // labels shown per section before the rest roll up
	minShare = 0.01 // repos under this only pad the output
	// A single long MCP tool name would otherwise push the amount column past
	// every other row and break the alignment it exists for.
	maxLabel = 34
)

// AgentSpend is what one agent spent inside one repository.
type AgentSpend struct {
	Agent       string
	Cost        *Cost
	Attribution *Attribution
}

// RepoSpend gathers every agent that ran in a repository.
type RepoSpend struct {
	Name   string
	Agents []AgentSpend
}

func (r RepoSpend) total() float64 {
	var sum float64
	for _, a := range r.Agents {
		sum += a.Cost.Total
	}
	return sum
}

func (r RepoSpend) unbilled() float64 {
	var sum float64
	for _, a := range r.Agents {
		sum += a.Cost.Unbilled
	}
	return sum
}

// Report is everything one scope needs to print.
type Report struct {
	Scope        string
	Span         string
	SplitBilling bool
	Repos        []RepoSpend
	// SingleAgent drops the agent level when only one agent is in play, so a
	// filtered report reads the same as it did before agents were nested.
	SingleAgent bool
}

type row struct {
	label    string
	total    float64
	unbilled float64
}

// money renders a figure, disclosing the unbillable part when the two differ.
func money(total, unbilled float64, split bool) string {
	if !split || unbilled == 0 {
		return fmt.Sprintf("$%s", comma(total))
	}
	return fmt.Sprintf("$%s ($%s)", comma(total-unbilled), comma(total))
}

func comma(v float64) string {
	s := fmt.Sprintf("%.2f", v)
	whole, frac, _ := strings.Cut(s, ".")
	neg := strings.HasPrefix(whole, "-")
	whole = strings.TrimPrefix(whole, "-")
	for i := len(whole) - 3; i > 0; i -= 3 {
		whole = whole[:i] + "," + whole[i:]
	}
	if neg {
		whole = "-" + whole
	}
	return whole + "." + frac
}

func (r Report) Render(out *strings.Builder) {
	var grand, grandUnbilled float64
	for _, repo := range r.Repos {
		grand += repo.total()
		grandUnbilled += repo.unbilled()
	}
	if grand == 0 {
		out.WriteString("No usage found for this scope and range.\n")
		return
	}

	fmt.Fprintf(out, "%s  ·  %s  ·  %s\n",
		r.Scope, r.Span, money(grand, grandUnbilled, r.SplitBilling))
	if r.SplitBilling && grandUnbilled > 0 {
		fmt.Fprintf(out, "billable, (%s on the personal plan brings it to the "+
			"figure in brackets)\n", unbilledModel)
	}
	out.WriteString("\n")

	repos := append([]RepoSpend(nil), r.Repos...)
	sort.Slice(repos, func(i, j int) bool {
		return repos[i].total() > repos[j].total()
	})

	skipped := 0
	for _, repo := range repos {
		if repo.total()/grand < minShare {
			skipped++
			continue
		}
		r.renderRepo(out, repo, grand)
	}
	if skipped > 0 {
		noun := "repos"
		if skipped == 1 {
			noun = "repo"
		}
		fmt.Fprintf(out, "(%d %s under %.0f%% omitted)\n",
			skipped, noun, minShare*100)
	}
}

func (r Report) renderRepo(out *strings.Builder, repo RepoSpend, grand float64) {
	fmt.Fprintf(out, "%s  %s  (%.0f%%)\n", repo.Name,
		money(repo.total(), repo.unbilled(), r.SplitBilling),
		repo.total()/grand*100)

	agents := append([]AgentSpend(nil), repo.Agents...)
	sort.Slice(agents, func(i, j int) bool {
		return agents[i].Cost.Total > agents[j].Cost.Total
	})

	// One agent needs no agent level: the sections hang straight off the repo.
	if r.SingleAgent || len(agents) == 1 {
		r.renderSections(out, agents[0], "")
		out.WriteString("\n")
		return
	}

	for i, agent := range agents {
		last := i == len(agents)-1
		head, indent := "├─ ", "│  "
		if last {
			head, indent = "└─ ", "   "
		}
		fmt.Fprintf(out, "%s%s  %s\n", head, agent.Agent,
			money(agent.Cost.Total, agent.Cost.Unbilled, r.SplitBilling))
		r.renderSections(out, agent, indent)
	}
	out.WriteString("\n")
}

// renderSections prints models and attribution for one agent, indented under
// the agent line when there is more than one.
func (r Report) renderSections(out *strings.Builder, agent AgentSpend, indent string) {
	type section struct {
		title string
		rows  []row
	}
	cost := agent.Cost
	sections := []section{{"models", modelRows(cost)}}

	if att := agent.Attribution; att != nil {
		// Pi counts in dollars already, so its synthetic pool is priced at its
		// own size and apportioning leaves the figures untouched. Model rows
		// keep their real names either way.
		pool := cost.Models
		if att.Total[piPool] > 0 {
			pool = map[string]float64{piPool: att.Total[piPool]}
		}
		for _, kind := range []string{"skills", "subagents", "tools", "mcp"} {
			if rows := attributionRows(att, pool, kind); len(rows) > 0 {
				sections = append(sections, section{kind, rows})
			}
		}
		if total, unbilled := apportion(att.Unattributed, att.Total, pool); total > 0 {
			sections = append(sections, section{"unattributed",
				[]row{{"", total, unbilled}}})
		}
	}

	// One column for the whole repo. Letting each section size itself makes the
	// amounts zigzag across the screen and there is nothing to read down.
	// Widths count runes: the box-drawing characters are multi-byte.
	depth := len([]rune(indent))
	labelEnd, cellW := 0, 0
	for _, sec := range sections {
		if sec.title == "unattributed" {
			labelEnd = max(labelEnd, depth+3+len(sec.title))
			cellW = max(cellW, len("$"+comma(sec.rows[0].total)))
			continue
		}
		for _, rw := range capRows(sec.rows) {
			label := elide(displayLabel(rw, r.SplitBilling))
			labelEnd = max(labelEnd, depth+6+len([]rune(label)))
			cellW = max(cellW, len("$"+comma(rw.total)))
		}
	}

	for i, sec := range sections {
		last := i == len(sections)-1
		head, stem := indent+"├─ ", indent+"│  "
		if last {
			head, stem = indent+"└─ ", indent+"   "
		}
		// Most turns carry no attribution at all; naming that share keeps the
		// labels above readable as a share of the repo.
		if sec.title == "unattributed" {
			fmt.Fprintf(out, "%s%s%*s\n", head,
				leader(sec.title, labelEnd-depth-3),
				cellW, "$"+comma(sec.rows[0].total))
			continue
		}
		fmt.Fprintf(out, "%s%s\n", head, sec.title)
		writeRows(out, stem, sec.rows, r.SplitBilling, labelEnd-depth-6, cellW)
	}
}

func modelRows(cost *Cost) []row {
	rows := make([]row, 0, len(cost.Models))
	for model, dollars := range cost.Models {
		var unbilled float64
		if model == unbilledModel {
			unbilled = dollars
		}
		rows = append(rows, row{model, dollars, unbilled})
	}
	sortRows(rows)
	return rows
}

func attributionRows(att *Attribution, pool map[string]float64, kind string) []row {
	var rows []row
	for label, perModel := range att.Tally[kind] {
		total, unbilled := apportion(perModel, att.Total, pool)
		rows = append(rows, row{label, total, unbilled})
	}
	sortRows(rows)
	return rows
}

func sortRows(rows []row) {
	sort.Slice(rows, func(i, j int) bool {
		if rows[i].total != rows[j].total {
			return rows[i].total > rows[j].total
		}
		return rows[i].label < rows[j].label
	})
}

// capRows trims a section to the top handful, rolling the tail into one line
// so a long list never hides how much it accounts for.
func capRows(rows []row) []row {
	if len(rows) <= topN {
		return rows
	}
	rest := row{label: fmt.Sprintf("+%d more", len(rows)-topN)}
	for _, r := range rows[topN:] {
		rest.total += r.total
		rest.unbilled += r.unbilled
	}
	return append(rows[:topN:topN], rest)
}

func displayLabel(r row, split bool) string {
	if split && r.label == unbilledModel {
		return "(" + r.label + ")"
	}
	return r.label
}

// elide keeps a label inside the column, cutting from the front because the
// distinguishing part of an MCP tool name is its tail. One rune short of the
// cap, so there is always room for the space before the amount.
func elide(label string) string {
	runes := []rune(label)
	if len(runes) < maxLabel {
		return label
	}
	return "…" + string(runes[len(runes)-maxLabel+2:])
}

// leader pads a label to exactly width+1 runes, so the eye can follow a short
// name across to its amount and every row ends in the same column. Dots do the
// carrying once there is room; a label that fills the column gets spaces.
func leader(label string, width int) string {
	gap := max(width-len([]rune(label)), 0)
	if gap < 3 {
		return label + strings.Repeat(" ", gap+1)
	}
	return label + " " + strings.Repeat("·", gap-2) + "  "
}

// writeRows prints one section. labelW is the label column shared by the whole
// repo, measured from the start of the label itself.
func writeRows(out *strings.Builder, stem string, rows []row, split bool, labelW, cellW int) {
	capped := capRows(rows)
	for i, r := range capped {
		branch := "├─ "
		if i == len(capped)-1 {
			branch = "└─ "
		}
		// Inside a repo the billable split is already stated on the header;
		// repeating it per row buries the figure that matters.
		fmt.Fprintf(out, "%s%s%s%*s\n", stem, branch,
			leader(elide(displayLabel(r, split)), labelW),
			cellW, "$"+comma(r.total))
	}
}
