package main

import (
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"
)

// Repo is one repository the agents have worked in.
//
// The git remote decides `Work` while recording, but is deliberately not kept:
// the ledger is committed to a public dotfiles repo, and a remote URL would
// publish an employer's internal host for no gain. Everything a reader needs
// is the paths and the flag.
type Repo struct {
	Root        string   `json:"root"`
	Owner       string   `json:"owner"`
	Name        string   `json:"name"`
	Work        bool     `json:"work"`
	SessionDirs []string `json:"session_dirs"`
	LastSeen    string   `json:"last_seen"`
}

// Ledger maps "owner/name" to the repo it describes.
type Ledger map[string]Repo

func ledgerPath() string {
	state := os.Getenv("XDG_STATE_HOME")
	if state == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return ""
		}
		state = filepath.Join(home, ".local", "state")
	}
	return filepath.Join(state, "ccu", "repo-roots.json")
}

func loadLedger() Ledger {
	l := Ledger{}
	data, err := os.ReadFile(ledgerPath())
	if err != nil {
		return l
	}
	if json.Unmarshal(data, &l) != nil {
		return Ledger{}
	}
	return l
}

func saveLedger(l Ledger) error {
	path := ledgerPath()
	// The ledger is usually a symlink into a dotfiles repo. Renaming onto the
	// link would replace it with a regular file and orphan the tracked copy,
	// so write to whatever it points at.
	if resolved, err := filepath.EvalSymlinks(path); err == nil {
		path = resolved
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	data, err := json.MarshalIndent(l, "", "  ")
	if err != nil {
		return err
	}
	data = append(data, '\n')

	// Sessions overlap, so write through a temp file: a reader either sees the
	// previous ledger or the new one, never a half-written file.
	tmp, err := os.CreateTemp(filepath.Dir(path), ".repo-roots-*")
	if err != nil {
		return err
	}
	defer os.Remove(tmp.Name())
	if _, err := tmp.Write(data); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	// CreateTemp makes the file private; the ledger is ordinary config.
	if err := os.Chmod(tmp.Name(), 0o644); err != nil {
		return err
	}
	return os.Rename(tmp.Name(), path)
}

// sessionIndex maps every recorded session directory, encoded the way ccusage
// names project keys, to the repo it belongs to. This is what lets a deleted
// worktree still resolve to the repository it was cut from.
func (l Ledger) sessionIndex() map[string]string {
	index := map[string]string{}
	for _, repo := range l {
		root := expandHome(repo.Root)
		for _, dir := range repo.SessionDirs {
			index[encodeProjectKey(expandHome(dir))] = root
		}
	}
	return index
}

func git(cwd string, args ...string) string {
	out, err := exec.Command("git", append([]string{"-C", cwd}, args...)...).Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}

// describe reports the repo a working directory belongs to, following a
// worktree back to the repository it was created from.
func describe(cwd string) (key string, repo Repo, ok bool) {
	gitDir := git(cwd, "rev-parse", "--path-format=absolute", "--git-common-dir")
	if !strings.HasSuffix(gitDir, "/.git") {
		return "", Repo{}, false
	}
	root := filepath.Dir(gitDir)
	remote := git(cwd, "remote", "get-url", "origin")
	name := filepath.Base(root)
	owner := filepath.Base(filepath.Dir(root))

	return owner + "/" + name, Repo{
		Root:  tildify(root),
		Owner: owner,
		Name:  name,
		Work:  isWork(root, remote, name),
	}, true
}

// record merges one session's directory into the ledger, returning false when
// nothing changed so the common case touches no disk.
func (l Ledger) record(cwd string) bool {
	key, repo, ok := describe(cwd)
	if !ok {
		return false
	}
	current, existed := l[key]

	// A repo is reached through its own path and through every worktree cut
	// from it; keeping them all is what lets a reader map a session directory
	// back here after the worktree is gone.
	dirs := map[string]bool{tildify(cwd): true}
	for _, d := range current.SessionDirs {
		dirs[d] = true
	}
	repo.SessionDirs = make([]string, 0, len(dirs))
	for d := range dirs {
		repo.SessionDirs = append(repo.SessionDirs, d)
	}
	sort.Strings(repo.SessionDirs)
	repo.LastSeen = time.Now().Format("2006-01-02")

	if existed && sameRepo(current, repo) {
		return false
	}
	l[key] = repo
	return true
}

// sameRepo compares everything a reader cares about. LastSeen is excluded: it
// changes daily on its own and would make every session rewrite the file.
func sameRepo(a, b Repo) bool {
	if a.Root != b.Root || a.Owner != b.Owner || a.Name != b.Name ||
		a.Work != b.Work || len(a.SessionDirs) != len(b.SessionDirs) {
		return false
	}
	for i := range a.SessionDirs {
		if a.SessionDirs[i] != b.SessionDirs[i] {
			return false
		}
	}
	return true
}
