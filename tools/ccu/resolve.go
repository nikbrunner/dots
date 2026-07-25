package main

import (
	"bufio"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
)

// Resolver turns a ccusage project key into the repository it belongs to.
//
// Sources are tried strongest first: a checkout under the repo tree, then the
// ledger recorded by `ccu record`, then git itself, and only then guesswork
// from the path. Everything below the ledger exists for sessions that predate
// it, or for directories that have since been deleted.
type Resolver struct {
	roots       []repoRoot        // repos found on disk
	byName      map[string]string // basename -> path, for worktree fallback
	recorded    map[string]string // project key -> repo root, from the ledger
	projectsDir string
	cache       map[string]Project
}

type repoRoot struct {
	key  string // ccusage-encoded path
	base string
	path string
}

// Project is a resolved repository: what to call it, and where it lives.
type Project struct {
	Name string
	Path string
}

func NewResolver(reposDir, projectsDir string) *Resolver {
	r := &Resolver{
		byName:      map[string]string{},
		recorded:    loadLedger().sessionIndex(),
		projectsDir: projectsDir,
		cache:       map[string]Project{},
	}

	// Only the tree holding real working repos is scanned. Walking all of $HOME
	// drags in hundreds of vendored checkouts under .cache and .config for no
	// gain.
	filepath.WalkDir(reposDir, func(path string, d os.DirEntry, err error) error {
		if err != nil || !d.IsDir() {
			return nil
		}
		if d.Name() != ".git" {
			if strings.Count(path[len(reposDir):], "/") > 4 {
				return filepath.SkipDir
			}
			return nil
		}
		root := filepath.Dir(path)
		base := filepath.Base(root)
		r.roots = append(r.roots, repoRoot{encodeProjectKey(root), base, root})
		// A name can exist in several places (a work repo and a personal
		// checkout of the same project); an imfusion path wins so worktree
		// spend lands on the work side.
		if _, seen := r.byName[base]; !seen || strings.Contains(root, "imfusion") {
			r.byName[base] = root
		}
		return filepath.SkipDir
	})
	return r
}

// Resolve names the repository behind a project key.
func (r *Resolver) Resolve(key string) Project {
	if hit, ok := r.cache[key]; ok {
		return hit
	}
	p := r.resolve(key)
	r.cache[key] = p
	return p
}

func (r *Resolver) resolve(key string) Project {
	// A checkout inside the repo tree names itself.
	for _, root := range r.roots {
		if key == root.key || strings.HasPrefix(key, root.key+"-") {
			return Project{root.base, root.path}
		}
	}
	// Recorded while the directory still existed, so it needs no guessing.
	if root, ok := r.recorded[key]; ok {
		return Project{filepath.Base(root), root}
	}
	// Still on disk: git knows exactly, including for worktrees.
	if cwd := r.sessionCwd(key); cwd != "" {
		if gitDir := git(cwd, "rev-parse", "--path-format=absolute",
			"--git-common-dir"); strings.HasSuffix(gitDir, "/.git") {
			root := filepath.Dir(gitDir)
			return Project{filepath.Base(root), root}
		}
	}
	return r.guess(key)
}

// guess is the last resort for sessions recorded before the ledger existed,
// whose directories are gone. ccusage flattens "/" to "-", so nothing marks
// where a repo name ends; probing segment runs against known repo names is the
// best available.
func (r *Resolver) guess(key string) Project {
	prefix := "-Users-" + filepath.Base(homeDir()) + "-"
	rest := strings.TrimPrefix(key, prefix)
	var segs []string
	for _, s := range strings.Split(rest, "-") {
		if s != "" {
			segs = append(segs, s)
		}
	}

	// Only paths naming a worktree container are folded, so scratch checkouts
	// under ~/tmp stay separate instead of being absorbed by a same-named repo.
	start := -1
	for i, s := range segs {
		if worktreeDirs[s] {
			start = i + 1
		}
	}
	if start >= 0 {
		after := segs[start:]
		for take := len(after); take > 0; take-- {
			if root, ok := r.byName[strings.Join(after[:take], "-")]; ok {
				return Project{filepath.Base(root), root}
			}
		}
		return Project{strings.Join(segs[:start], "/"), strings.ReplaceAll(rest, "-", "/")}
	}
	if len(segs) > 2 {
		segs = segs[:2]
	}
	return Project{strings.Join(segs, "/") + "/…", strings.ReplaceAll(rest, "-", "/")}
}

// sessionCwd reads the working directory recorded in a project's transcripts.
func (r *Resolver) sessionCwd(key string) string {
	matches, _ := filepath.Glob(filepath.Join(r.projectsDir, key, "*.jsonl"))
	for _, path := range matches {
		fh, err := os.Open(path)
		if err != nil {
			continue
		}
		scanner := bufio.NewScanner(fh)
		scanner.Buffer(make([]byte, 0, 1024*1024), 8*1024*1024)
		for scanner.Scan() {
			line := scanner.Bytes()
			if !strings.Contains(string(line), `"cwd"`) {
				continue
			}
			var rec struct {
				Cwd string `json:"cwd"`
			}
			if json.Unmarshal(line, &rec) == nil && rec.Cwd != "" {
				fh.Close()
				if info, err := os.Stat(rec.Cwd); err == nil && info.IsDir() {
					return rec.Cwd
				}
				return ""
			}
		}
		fh.Close()
	}
	return ""
}
