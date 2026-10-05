import type { Git, GitFile } from '../types'

export function parseGit(repo: string, out: string): Git {
  const g: Git = {
    repo,
    isWorktree: false,
    ahead: 0,
    behind: 0,
    added: 0,
    modified: 0,
    deleted: 0,
    untracked: 0,
    stashes: 0,
    files: [],
  }
  const numstat = new Map<string, [number, number]>()
  const file = (xy: string, path: string): GitFile => {
    const [x = '.', y = '.'] = xy
    return { path, status: x !== '.' ? x : y, isStaged: x !== '.' }
  }
  for (const line of out.split('\n')) {
    if (line.startsWith('# branch.head ')) {
      const head = line.slice(14)
      g.branch = head === '(detached)' ? undefined : head
    } else if (line.startsWith('# branch.ab ')) {
      const [a, b] = line.slice(12).split(' ')
      g.ahead = Math.abs(Number(a))
      g.behind = Math.abs(Number(b))
    } else if (line.startsWith('# branch.upstream ')) {
      g.upstream = line.slice(18)
    } else if (line.startsWith('# last ')) {
      const [hash = '', age = '', subject = ''] = line.slice(7).split('\t')
      g.last = { hash, age, subject }
    } else if (line.startsWith('# stash ')) {
      g.stashes = Number(line.slice(8)) || 0
    } else if (line.startsWith('# num ')) {
      const [a, r, path] = line.slice(6).split('\t')
      if (path && a !== '-') numstat.set(path, [Number(a), Number(r)])
    } else if (line.startsWith('# gitdir ')) {
      g.isWorktree = line.includes('/worktrees/')
    } else if (line.startsWith('? ')) {
      g.untracked++
      g.files.push({ path: line.slice(2), status: '?', isStaged: false })
    } else if (line.startsWith('1 ') || line.startsWith('2 ')) {
      const parts = line.split(' ')
      const xy = parts[1] ?? ''
      const path = (line.startsWith('2 ') ? parts.slice(9) : parts.slice(8)).join(' ').split('\t')[0] ?? ''
      g.files.push(file(xy, path))
      if (xy.includes('D')) g.deleted++
      else if (xy.startsWith('A')) g.added++
      else g.modified++
    }
  }
  for (const f of g.files) {
    const n = numstat.get(f.path)
    if (n) [f.added, f.removed] = n
  }
  return g
}

export function prettyModel(id: string): string {
  const m = id.match(/^claude-([a-z]+)-(\d+)-(\d+)/)
  if (!m) return id
  const name = `${m[1]![0]!.toUpperCase()}${m[1]!.slice(1)} ${m[2]}.${m[3]}`
  return id.includes('[1m]') ? `${name} (1M context)` : name
}

export function bar(percent: number, width = 10): string {
  const filled = Math.round((Math.min(100, Math.max(0, percent)) / 100) * width)
  return '▰'.repeat(filled) + '▱'.repeat(width - filled)
}

export function heat(percent: number): string | undefined {
  if (percent >= 85) return 'red'
  if (percent >= 60) return 'yellow'
  return undefined
}

export function duration(ms: number): string {
  const s = Math.max(0, Math.floor(ms / 1000))
  if (s < 60) return `${s}s`
  if (s < 3600) return `${Math.floor(s / 60)}m${String(s % 60).padStart(2, '0')}`
  return `${Math.floor(s / 3600)}h${String(Math.floor((s % 3600) / 60)).padStart(2, '0')}`
}

export function until(iso: string | number | undefined, now: number): string {
  if (iso === undefined) return ''
  const left = (typeof iso === 'number' ? iso : Date.parse(iso)) - now
  if (!(left > 0)) return ''
  if (left >= 86_400_000) return `↓${Math.floor(left / 86_400_000)}d`
  return `↓${duration(left)}`
}

const countLines = (v: unknown) => (typeof v === 'string' && v !== '' ? v.split('\n').length : 0)

export function editDelta(e: Record<string, unknown>): { added: number; removed: number } {
  if (e.tool === 'Write') return { added: countLines(e.content), removed: 0 }
  const edits = Array.isArray(e.edits) ? (e.edits as Record<string, unknown>[]) : [e]
  let added = 0
  let removed = 0
  for (const one of edits) {
    added += countLines(one.new_string)
    removed += countLines(one.old_string)
  }
  return { added, removed }
}
