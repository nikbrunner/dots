import type { Progress } from '../types'

export function lastProgress(text: string): Progress | undefined {
  const all = [...text.matchAll(/PROGRESS:\s*(\d+)\s*\/\s*(\d+)\s*·?\s*(.*)/g)]
  const m = all[all.length - 1]
  if (!m) return undefined
  return { step: Number(m[1]), total: Number(m[2]), text: m[3]!.trim() }
}

export function bar(percent: number, width = 10): string {
  const filled = Math.round((Math.min(100, Math.max(0, percent)) / 100) * width)
  return '▰'.repeat(filled) + '▱'.repeat(width - filled)
}

export function duration(ms: number): string {
  const s = Math.max(0, Math.floor(ms / 1000))
  if (s < 60) return `${s}s`
  if (s < 3600) return `${Math.floor(s / 60)}m${String(s % 60).padStart(2, '0')}`
  return `${Math.floor(s / 3600)}h${String(Math.floor((s % 3600) / 60)).padStart(2, '0')}`
}

export function describeCall(e: Record<string, unknown>): string {
  const arg =
    [e.file_path, e.path, e.notebook_path].find(v => typeof v === 'string')?.toString().split('/').pop() ??
    [e.description, e.pattern, e.query, e.subject, e.command, e.url, e.skill].find(v => typeof v === 'string')
  return `${e.tool}${arg ? ` ${String(arg).split('\n')[0]}` : ''}`.slice(0, 80)
}

export function shortModel(id: string): string {
  const m = id.match(/^claude-([a-z]+)-(\d+)-(\d+)/)
  return m ? `${m[1]} ${m[2]}.${m[3]}` : id
}

export function compact(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1000) return `${Math.round(n / 1000)}k`
  return String(n)
}

export function firstLine(text: string): string {
  return (text.split('\n').find(l => l.trim() !== '' && !l.startsWith('PROGRESS:')) ?? '').trim()
}
