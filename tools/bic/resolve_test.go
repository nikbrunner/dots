package main

import (
	"path/filepath"
	"testing"
)

func TestGuessFoldsALagerWorktreeIntoItsRepo(t *testing.T) {
	root := "/repos/imfusion/cp/labels-web"
	r := &Resolver{byName: map[string]string{"labels-web": root}}
	key := "-Users-" + filepath.Base(homeDir()) + "-repos-imfusion-cp-labels-web-worktrees-sign-in-page"

	got := r.guess(key)

	if got.Path != root || got.Name != "labels-web" {
		t.Fatalf("guess(%q) = %+v, want labels-web at %s", key, got, root)
	}
}

func TestGuessPrefersTheRepoBeforeTheContainerOverATopicNamedLikeARepo(t *testing.T) {
	root := "/repos/nikbrunner/agents"
	r := &Resolver{byName: map[string]string{"agents": root, "lager": "/repos/nikbrunner/lager"}}
	key := "-Users-" + filepath.Base(homeDir()) + "-repos-nikbrunner-agents-worktrees-lager-skill"

	got := r.guess(key)

	if got.Path != root {
		t.Fatalf("guess(%q) = %+v, want %s", key, got, root)
	}
}

func TestGuessStillFoldsAWorktreeNamedAfterItsRepo(t *testing.T) {
	root := "/repos/acme/core"
	r := &Resolver{byName: map[string]string{"core": root}}
	key := "-Users-" + filepath.Base(homeDir()) + "-.herdr-worktrees-core-topic"

	got := r.guess(key)

	if got.Path != root {
		t.Fatalf("guess(%q) = %+v, want %s", key, got, root)
	}
}
