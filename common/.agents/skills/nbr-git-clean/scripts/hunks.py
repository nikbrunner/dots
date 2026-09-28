#!/usr/bin/env python3
"""List and stage individual worktree hunks by stable ID.

  hunks.py list [PATH...]        hunks of unstaged changes to tracked files
  hunks.py show ID...            full text of the given hunks
  hunks.py stage ID...           stage exactly these hunks (all or nothing)

Hunks come from a zero-context diff, so every separate change is its own
hunk. An ID hashes the file path and the hunk's changed lines, not its line
numbers, so it survives commits of other hunks. Files without text hunks
(untracked, binary, mode-only) are left to plain `git add` / `git rm`.
"""

import hashlib
import re
import subprocess
import sys

DIFF = [
    "git", "-c", "core.quotePath=false", "diff",
    "--no-color", "--no-ext-diff", "--no-renames", "--no-relative",
    "--src-prefix=a/", "--dst-prefix=b/", "-U0",
]
APPLY = ["git", "apply", "--cached", "--unidiff-zero", "--whitespace=nowarn", "-"]


def git_diff(paths):
    out = subprocess.run(DIFF + ["--"] + paths, capture_output=True, check=True)
    return out.stdout.decode("utf-8", "surrogateescape")


def parse(diff):
    """Return a list of (path, header_lines, [hunk dicts])."""
    files, cur = [], None
    for line in diff.splitlines(keepends=True):
        if line.startswith("diff --git "):
            cur = {"path": None, "header": [line], "hunks": []}
            files.append(cur)
        elif cur is None:
            continue
        elif line.startswith("@@"):
            cur["hunks"].append({"head": line, "body": []})
        elif cur["hunks"]:
            cur["hunks"][-1]["body"].append(line)
        else:
            cur["header"].append(line)
            if line.startswith(("--- a/", "+++ b/")):
                cur["path"] = line[6:].rstrip("\n\t")

    result, seen = [], {}
    for f in files:
        if f["path"] is None or not f["hunks"]:
            continue
        for h in f["hunks"]:
            raw = (f["path"] + "\0" + "".join(h["body"])).encode("utf-8", "surrogateescape")
            digest = hashlib.sha1(raw).hexdigest()[:7]
            n = seen.get(digest, 0)
            seen[digest] = n + 1
            h["id"] = digest if n == 0 else f"{digest}-{n + 1}"
        result.append(f)
    return result


def preview(h):
    for line in h["body"]:
        if line[:1] in "+-" and line[1:].strip():
            text = line.rstrip("\n")
            return text if len(text) <= 70 else text[:67] + "..."
    return ""


def index(files):
    return {h["id"]: (f, h) for f in files for h in f["hunks"]}


def cmd_list(paths):
    for f in parse(git_diff(paths)):
        print(f["path"])
        for h in f["hunks"]:
            head = h["head"].split("@@")[1].strip()
            print(f"  {h['id']:<9} {head:<20} {preview(h)}")


def cmd_show(ids):
    hunks = index(parse(git_diff([])))
    missing = [i for i in ids if i not in hunks]
    if missing:
        sys.exit(f"unknown hunk id(s): {' '.join(missing)}")
    for i in ids:
        f, h = hunks[i]
        print(f"# {i}  {f['path']}")
        sys.stdout.write(h["head"] + "".join(h["body"]))


HEAD_RE = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@(.*)$", re.S)


def rebase_heads(picked):
    """Rewrite each hunk's new-side start to count only the picked hunks.

    git apply places a zero-context hunk at its new-side line number, which
    otherwise still includes the line shifts of unpicked hunks above it.
    """
    delta, out = 0, []
    for h in picked:
        m = HEAD_RE.match(h["head"])
        old_start, old_len = int(m[1]), int(m[2] if m[2] is not None else 1)
        new_len = int(m[4] if m[4] is not None else 1)
        new_start = old_start + delta
        if old_len == 0:
            new_start += 1
        elif new_len == 0:
            new_start -= 1
        old = f"{old_start}" if m[2] is None else f"{old_start},{old_len}"
        new = f"{new_start}" if m[4] is None else f"{new_start},{new_len}"
        out.append(f"@@ -{old} +{new} @@{m[5]}")
        delta += new_len - old_len
    return out


def cmd_stage(ids):
    files = parse(git_diff([]))
    hunks = index(files)
    missing = [i for i in ids if i not in hunks]
    if missing:
        sys.exit(f"unknown hunk id(s), nothing staged: {' '.join(missing)}")
    wanted = set(ids)
    patch = []
    for f in files:
        picked = [h for h in f["hunks"] if h["id"] in wanted]
        if picked:
            patch += f["header"]
            for head, h in zip(rebase_heads(picked), picked):
                patch += [head] + h["body"]
    res = subprocess.run(APPLY, input="".join(patch).encode("utf-8", "surrogateescape"), capture_output=True)
    if res.returncode != 0:
        sys.exit(f"git apply failed, nothing staged:\n{res.stderr.decode(errors='replace')}")
    print(f"staged {len(ids)} hunk(s)")


def main():
    sys.stdout.reconfigure(errors="backslashreplace")
    if len(sys.argv) < 2 or sys.argv[1] not in ("list", "show", "stage"):
        sys.exit(__doc__)
    cmd, args = sys.argv[1], sys.argv[2:]
    if cmd != "list" and not args:
        sys.exit(f"{cmd}: needs at least one hunk id")
    {"list": cmd_list, "show": cmd_show, "stage": cmd_stage}[cmd](args)


if __name__ == "__main__":
    main()
