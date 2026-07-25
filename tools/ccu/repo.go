package main

import (
	"os"
	"path/filepath"
	"strings"
)

// Repos that belong to work but do not live under ~/repos/imfusion yet.
// Moving one into that tree makes its entry here redundant.
var workRepos = map[string]bool{"imf-notes": true}

// isWork decides which side of the split a repository falls on. The remote is
// the strongest signal — it identifies the repository itself rather than where
// a given checkout happens to sit on disk.
func isWork(root, remote, name string) bool {
	return strings.Contains(root, "imfusion") ||
		strings.Contains(remote, "imfusion") ||
		workRepos[name]
}

func homeDir() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return ""
	}
	return home
}

// tildify keeps recorded paths portable between machines.
func tildify(path string) string {
	home := homeDir()
	if home == "" || path == home {
		return "~"
	}
	if strings.HasPrefix(path, home+string(os.PathSeparator)) {
		return "~" + path[len(home):]
	}
	return path
}

func expandHome(path string) string {
	if path == "~" {
		return homeDir()
	}
	if strings.HasPrefix(path, "~/") {
		return filepath.Join(homeDir(), path[2:])
	}
	return path
}

// encodeProjectKey reproduces how Claude Code and ccusage name a project
// directory: the absolute path with every separator flattened to a dash.
func encodeProjectKey(path string) string {
	home := homeDir()
	if home != "" && strings.HasPrefix(path, home) {
		path = "-Users-" + filepath.Base(home) + path[len(home):]
	}
	return strings.ReplaceAll(path, "/", "-")
}

// Directory names that hold worktrees keyed by their source repo. Whatever
// creates them, the segment after one of these is the repo the branch was cut
// from. Only used for sessions recorded before the ledger existed.
var worktreeDirs = map[string]bool{
	"worktrees": true, "worktree": true, "wt": true, "trees": true,
}
