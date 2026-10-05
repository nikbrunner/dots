export function describeCall(e: Record<string, unknown>): string {
  const arg =
    [e.file_path, e.path, e.notebook_path].find(v => typeof v === 'string')?.toString().split('/').pop() ??
    [e.description, e.pattern, e.query, e.subject, e.command, e.url, e.skill].find(v => typeof v === 'string')
  return `${e.tool}${arg ? ` ${String(arg).split('\n')[0]}` : ''}`.slice(0, 80)
}

export function oneLine(text: string): string {
  return (text.split('\n').find(l => l.trim() !== '') ?? '').trim().replace(/[.。]$/, '')
}
