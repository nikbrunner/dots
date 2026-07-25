# ccu

What Claude Code costs me, per repo, split into work and personal. And which
models, skills, subagents and MCP servers actually spent it.

```
imfusion  ·  since 2026-07-01  ·  $1,120.82 ($2,113.82)
billable, (fable-5 on the personal plan brings it to the figure in brackets)

web-ui  $1,046.94 ($2,034.82)  (96%)
├─ models
│  ├─ (fable-5)   $987.89
│  ├─ opus-4-8    $845.39
│  └─ sonnet-5    $190.52
├─ skills
│  ├─ dev-browser            $56.65
│  ├─ plannotator-review     $37.98
│  └─ +38 more              $169.85
├─ subagents
│  ├─ general-purpose          $26.46
│  └─ implementation-reviewer  $12.59
├─ mcp
│  ├─ chrome-devtools:evaluate_script   $64.61
│  └─ chrome-devtools:take_screenshot   $53.51
└─ unattributed  $1,365.66
```

## Two agents, three sources

Claude Code needs two sources joined. ccusage knows the dollars. It has no idea
what spent them. The transcripts know exactly that, skill, subagent, MCP tool,
but carry no prices. So ccu reads both and joins them per repo.

```
  ccusage                          transcripts (~/.claude/projects)
  ───────                          ────────────────────────────────
  ✓ dollars, per model             ✗ no prices
  ✗ no idea what spent them        ✓ attributionSkill
                                   ✓ attributionAgent
                                   ✓ attributionMcpServer / McpTool
                    ╲             ╱
                     ╲           ╱
                   joined per repository
```

Pi is the easy one. It writes `cost.total` into every assistant message, so ccu
reads its session files and nothing else. No ccusage, no weighting, no
apportioning. Those numbers are exact.

Both agents show up in the same tree, one branch each, when a repo saw both:

```
dots  $261.86  (17%)
├─ claude  $261.31
│  ├─ models
│  │  ├─ fable-5    $73.24
│  │  └─ opus-4-8   $71.98
│  └─ skills
│     ├─ dev-commit   $9.04
│     └─ dev-nvim     $6.03
└─ pi  $0.55
   ├─ models
   │  └─ minimax-m2.7  $0.55
   └─ tools
      ├─ bash   $0.22
      └─ read   $0.10
```

Narrow it with `--claude` or `--pi` and the agent level disappears again.

Pi has no skill or subagent attribution in its files, so its branch shows
models, tools and MCP. A turn calling several tools splits its cost evenly
between them, because the money is in the accumulated context, not in the call.

## How a skill ends up with a dollar figure

Transcripts count tokens. So a skill's cost is its share of the models it ran
on. Raw counts would lie though. A cache-read token costs a fraction of an
output token, so tokens get weighted first:

| Token type  | Weight |
| ----------- | ------ |
| output      | 5×     |
| cache write | 1.25×  |
| input       | 1×     |
| cache read  | 0.1×   |

Within one model, weighted-token share tracks cost share closely enough. So the
model's real ccusage cost gets shared out that way, then summed:

```
   dev-audit on opus-4-8 ── 12% of opus tokens ──→ 12% of $845.39 = $101.45
   dev-audit on fable-5  ──  3% of fable tokens ─→  3% of $987.89 =  $29.64
                                                            ────────────────
                                                    dev-audit    = $131.09
```

Doing it per model is the whole point. Otherwise an Opus-heavy skill reads the
same as a Fable-heavy one, and they are nowhere near the same money.

Two things to keep in mind. The sections overlap, one turn can carry a skill and
an MCP server at once, so they don't sum to the repo total. And `unattributed`
is usually the biggest line. Most turns carry no attribution at all. It's a
leftover, not a category.

## Work vs personal

A repo is work if its path or git remote mentions `imfusion`, or its name is in
`workRepos` in `repo.go`. The remote is the strongest of the three. It
identifies the repo itself, not where some checkout sits on disk.

## The worktree problem

Claude Code names a project directory after its working directory, flattening
every `/` to `-`. So a worktree looks like a completely unrelated project:

```
~/repos/imfusion/websdk/web-ui        →  -Users-me-repos-imfusion-websdk-web-ui
~/.herdr/worktrees/web-ui/websdk-179  →  -Users-me--herdr-worktrees-web-ui-websdk-179
                                                    ↑
                                          no "imfusion" anywhere
```

Leave it alone and six branches become six projects, none counted as work. Git
can answer this, but only while the worktree exists. And I delete those the
moment a branch merges.

So `ccu record` writes the answer down while it's still true. Both agents call
it on events that always fire. Session end is no good, it gets skipped on
Ctrl+C, on a closed terminal, on a crash.

```
  Claude Code  SessionStart, Stop  ─┐
                                    ├─→  ccu record  ─→  ledger
  Pi           session_start,      ─┘         │
               agent_end                      └─ git rev-parse --git-common-dir
```

The ledger sits at `~/.local/state/ccu/repo-roots.json`, keyed `owner/name`.
Paths are `~`-relative, so it survives a move to another machine:

```json
{
  "websdk/web-ui": {
    "root": "~/repos/imfusion/websdk/web-ui",
    "owner": "websdk",
    "name": "web-ui",
    "work": true,
    "session_dirs": [
      "~/.herdr/worktrees/web-ui/websdk-179",
      "~/repos/imfusion/websdk/web-ui"
    ],
    "last_seen": "2026-07-25"
  }
}
```

The git remote decides `work` while recording but is never written down. This
file is committed to a public repo, and a remote URL would publish an
employer's internal host for nothing.

`session_dirs` does the actual work here. Every directory a repo was reached
through, so a deleted worktree still maps back to where it came from.

## How a project key gets resolved

Strongest source first:

```
  1. under ~/repos          exact    the checkout names itself
  2. ledger                 exact    recorded while the directory existed
  3. git rev-parse          exact    still on disk
  4. path segments          guess    old history, directory long gone
```

Only step 4 guesses, and it's deliberately narrow. It folds a path into a repo
when a container directory (`worktrees`, `wt`, and so on) sits right before a
known repo name. I tried matching any segment first. It happily swallowed
`~/tmp/web-ui-evals` into the real `web-ui`.

The guessing shrinks over time as the ledger fills up.

## Commands

```
ccu imfusion            spend on work repos
ccu personal            spend on everything else
ccu record [-cwd DIR]   note a session's repo (hooks)
```

The period goes behind `-p`, not `--since`, because most periods have a start
and an end and cramming that into a start-only flag fights it:

```
ccu imfusion -p last week
ccu personal -p yesterday
ccu imfusion -p last 7 days --pi
```

Quotes are optional. Everything after `-p` up to the next flag is the period.

Understood: `day`, `today`, `yesterday`, `week`, `this week`, `last week`,
`month`, `this month`, `last month`, `year`, `this year`, `all time`,
`last N days|weeks|months`, `past N …`, or a plain `YYYYMMDD`. A bare unit
means the current one, so `-p week` is this week. Weeks start Monday. Default
is this month. A closed range prints its dates in the header, so `last week`
says which week it meant.

`-s`/`-u` still take explicit `YYYYMMDD` and override `-p`. `--claude` or
`--pi` narrow to one agent. Flags ccu doesn't recognise go through to
`ccusage claude daily`.

## Layout

| File             | Holds                                          |
| ---------------- | ---------------------------------------------- |
| `main.go`        | commands, and the join between cost and tokens |
| `cost.go`        | ccusage invocation, apportionment              |
| `transcripts.go` | Claude transcript scan, token weighting        |
| `pi.go`          | Pi session scan, exact per-message cost        |
| `resolve.go`     | project key → repository                       |
| `ledger.go`      | the recorded ledger                            |
| `repo.go`        | paths, key encoding, work classification       |
| `render.go`      | the tree                                       |

Needs `ccusage` on PATH (`mise install npm:ccusage`) and `git`. `dots link`
builds it into `common/.local/bin/` via `scripts/dots/build-tools.sh`. Binary is
gitignored, source is tracked.

## Things I'd forget otherwise

Dedup by `requestId` is not optional. Streaming writes the same request several
times, repeating the whole usage block. One transcript had 528 assistant records
for 292 real requests. Counting lines would have nearly doubled every number.

Transcript timestamps are UTC, converted to local dates. Otherwise the day
buckets drift against ccusage.

Files older than `--since` get skipped by mtime. A file can't hold records
written after its last write.
