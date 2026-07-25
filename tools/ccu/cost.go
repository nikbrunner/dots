package main

import (
	"encoding/json"
	"io"
	"os/exec"
	"regexp"
	"strings"
)

// Fable is not on the ImFusion API plan; that spend lands on a personal
// subscription, so in work mode it is shown parenthesised and excluded from
// the primary (billable) figure.
const unbilledModel = "fable-5"

var dateSuffix = regexp.MustCompile(`-\d{8}$`)

// shortModel trims the vendor prefix and release date that make model names
// too wide to line up in a tree.
func shortModel(model string) string {
	return dateSuffix.ReplaceAllString(strings.TrimPrefix(model, "claude-"), "")
}

type ccusageOutput struct {
	Projects map[string][]struct {
		Date            string `json:"date"`
		ModelBreakdowns []struct {
			ModelName string  `json:"modelName"`
			Cost      float64 `json:"cost"`
		} `json:"modelBreakdowns"`
	} `json:"projects"`
}

// Cost is what one repository spent, split by model.
type Cost struct {
	Total    float64
	Unbilled float64
	Models   map[string]float64
}

// RunCcusage shells out for per-project, per-model dollars. Transcripts carry
// tokens but no prices, so this is the only source of real cost.
func RunCcusage(args []string) (*ccusageOutput, error) {
	cmd := exec.Command("ccusage", append(
		[]string{"claude", "daily", "--instances", "--json"}, args...)...)
	out, err := cmd.Output()
	if err != nil {
		return nil, err
	}
	var parsed ccusageOutput
	if err := json.Unmarshal(out, &parsed); err != nil {
		return nil, err
	}
	return &parsed, nil
}

// DecodeCcusage reads the same JSON from a stream, for tests and pipes.
func DecodeCcusage(r io.Reader) (*ccusageOutput, error) {
	var parsed ccusageOutput
	if err := json.NewDecoder(r).Decode(&parsed); err != nil {
		return nil, err
	}
	return &parsed, nil
}

// apportion shares a model's real cost among labels by their weighted-token
// share of that model. Within one model, token share tracks cost share, so
// summing across models prices Opus turns and Fable turns correctly.
func apportion(perModel, poolPerModel, costPerModel map[string]float64) (total, unbilled float64) {
	for model, tokens := range perModel {
		pool := poolPerModel[model]
		if pool == 0 {
			continue
		}
		dollars := costPerModel[model] * tokens / pool
		total += dollars
		if model == unbilledModel {
			unbilled += dollars
		}
	}
	return total, unbilled
}
