package main

import (
	"encoding/json"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

// configDirsFor turns transcript directories back into the config directories
// that contain them, in the comma-separated form ccusage expects.
func configDirsFor(projectDirs []string) string {
	dirs := make([]string, 0, len(projectDirs))
	for _, dir := range projectDirs {
		dirs = append(dirs, filepath.Dir(dir))
	}
	return strings.Join(dirs, ",")
}

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
//
// ccusage reads only ~/.claude unless told otherwise, which would silently
// omit every session run under a second account.
func RunCcusage(args []string, projectDirs []string) (*ccusageOutput, error) {
	cmd := exec.Command("ccusage", append(
		[]string{"claude", "daily", "--instances", "--json"}, args...)...)
	if configDirs := configDirsFor(projectDirs); configDirs != "" {
		cmd.Env = append(os.Environ(), "CLAUDE_CONFIG_DIR="+configDirs)
	}
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
