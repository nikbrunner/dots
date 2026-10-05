import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, RenderChildren, SessionUsage } from 'claude-code'

import type { Agent, Task, Usage } from '../types'
import { bar, editDelta, duration, heat, parseGit, prettyModel, until } from './lib'

const DASH = 'dash'
const CACHE_TTL_MS = 60 * 60 * 1000

const git = atom({ plugin: 'dash-pane', key: 'git' } as const, null)
const agent = atom({ plugin: 'dash-pane', key: 'agent' } as const, {
  isWork: false,
  model: '',
})
const title = atom({ plugin: 'dash-pane', key: 'title' } as const, '')
const tasks = atom({ plugin: 'dash-pane', key: 'tasks' } as const, [])
const usage = atom({ plugin: 'dash-pane', key: 'usage' } as const, {
  limits: [],
})
const cache = atom({ plugin: 'dash-pane', key: 'cache' } as const, {
  misses: 0,
})
const lines = atom({ plugin: 'dash-pane', key: 'lines' } as const, {
  added: 0,
  removed: 0,
})
const tick = atom({ plugin: 'dash-pane', key: 'tick' } as const, 0)
const work = atom({ plugin: 'dash-pane', key: 'work' } as const, {
  cwd: '',
  turns: 0,
})

const EDIT_TOOLS = new Set(['Edit', 'Write', 'MultiEdit'])
const GIT_TOOLS = new Set(['Bash', 'Edit', 'Write', 'NotebookEdit'])
const TASK_TOOLS = new Set(['TaskCreate', 'TaskUpdate'])
const FILE_COLOR: Record<string, string> = {
  A: 'success',
  M: 'warning',
  D: 'error',
  R: 'suggestion',
  C: 'suggestion',
  '?': 'suggestion',
  U: 'error',
}
const ICON = {
  dir: '\uf07b',
  branch: '\uf418',
  ctx: '\uf0e4',
  cache: '\uf06d',
  brain: '\u{f09d1}',
  tasks: '☰',
}
// Stroke icons in a 24×24 box, drawn on surfaces whose font has no Nerd Font glyphs.
const ICON_SVG: Record<keyof typeof ICON, string> = {
  dir: '<path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z"/>',
  branch: '<path d="M6 3v12"/><circle cx="18" cy="6" r="3"/><circle cx="6" cy="18" r="3"/><path d="M18 9a9 9 0 0 1-9 9"/>',
  ctx: '<path d="m12 14 4-4"/><path d="M3.34 19a10 10 0 1 1 17.32 0"/>',
  cache:
    '<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>',
  brain: '<path d="M12 3l1.9 5.1L19 10l-5.1 1.9L12 17l-1.9-5.1L5 10l5.1-1.9z"/><path d="M19 15l.8 2.2L22 18l-2.2.8L19 21l-.8-2.2L16 18l2.2-.8z"/>',
  tasks: '<path d="M10 6h11"/><path d="M10 12h11"/><path d="M10 18h11"/><path d="m3 6 1.5 1.5L7 5"/><path d="m3 12 1.5 1.5L7 11"/><path d="m3 18 1.5 1.5L7 17"/>',
}
const SVG_COLOR: Record<string, string> = {
  claude: '#d77757',
  success: '#4eba65',
  warning: '#ffc107',
  dim: '#999999',
}
const LIMIT_LABEL: Record<string, string> = {
  five_hour: '5h',
  seven_day: '7d',
}

let configDir = ''
let home = ''
let isGitQueued = false

async function refreshGit($: EngineInterface) {
  const cwd = await $.session.cwd()
  const run = await $.process.run(
    [
      'sh',
      '-c',
      'cd "$(git rev-parse --show-toplevel)" || exit 1; ' +
        'git --no-optional-locks status --porcelain=v2 --branch || exit 1; ' +
        'printf "# gitdir %s\\n" "$(git rev-parse --absolute-git-dir)"; ' +
        'git log -1 --format="# last %h%x09%cr%x09%s" 2>/dev/null; ' +
        'printf "# stash %s\\n" "$(git stash list 2>/dev/null | wc -l | tr -d " ")"; ' +
        'git --no-optional-locks diff --numstat HEAD 2>/dev/null | sed "s/^/# num /"',
    ],
    { cwd, timeoutMs: 3000 },
  )
  const root = (await $.session.repo())?.root ?? cwd
  const repo = root.split('/').pop() ?? root
  await update($, git, () => (run.exitCode === 0 ? parseGit(repo, run.stdout) : null))
}

function queueGit($: EngineInterface) {
  if (isGitQueued) return
  isGitQueued = true
  $.clock.after(500, () => {
    isGitQueued = false
    void refreshGit($)
  })
}

async function refreshTasks($: EngineInterface) {
  const dir = `${configDir}/tasks/${await $.session.id()}`
  if (!(await $.fs.exists(dir))) return
  const files = (await $.fs.list(dir)).filter(f => f.kind === 'file' && f.name.endsWith('.json'))
  const list: Task[] = []
  for (const f of files) {
    try {
      const t = JSON.parse(await $.fs.read(`${dir}/${f.name}`))
      list.push({ subject: t.activeForm ?? t.subject ?? '', status: t.status })
    } catch {}
  }
  await update($, tasks, () => list)
}

async function loadAgent($: EngineInterface) {
  const paths = await $.process.run([
    'sh',
    '-c',
    'printf "%s\\n%s\\n%s" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}" "${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json" "$HOME"',
  ])
  const [dir = '', configFile = '', homeDir = ''] = paths.stdout.split('\n')
  configDir = dir
  home = homeDir
  const auth = await $.session.authorize()
  let account: string | undefined
  try {
    account = JSON.parse(await $.fs.read(configFile)).oauthAccount?.emailAddress?.split('@')[0]
  } catch {}
  const model = prettyModel(await $.session.model())
  await update($, agent, a => ({
    ...a,
    model,
    account,
    isWork: auth?.kind === 'api-key',
  }))
}

async function refreshTitle($: EngineInterface) {
  const run = await $.process.run([
    'sh',
    '-c',
    'f=$(ls "$1"/projects/*/"$2".jsonl 2>/dev/null | head -1); [ -n "$f" ] || exit 0; ' +
      'grep -o \'"\\(customTitle\\|aiTitle\\)":"[^"]*"\' "$f" | tail -1 | sed \'s/.*":"//; s/"$//\'',
    'sh',
    configDir,
    await $.session.id(),
  ])
  const found = run.stdout.trim()
  if (found) await update($, title, () => found)
}

async function refreshWork($: EngineInterface) {
  const cwd = await $.session.cwd()
  const turns = await $.session.turns()
  await update($, work, w => ({
    ...w,
    cwd: home && cwd.startsWith(home) ? `~${cwd.slice(home.length)}` : cwd,
    turns,
  }))
}

function toUsage(u: Pick<SessionUsage, 'context' | 'rateLimits' | 'cost'>): Usage {
  return {
    context: u.context.percent,
    tokens: u.context.tokens,
    window: u.context.window,
    startedAt: 'startedAt' in u ? (u as SessionUsage).startedAt : undefined,
    limits: u.rateLimits.map(l => ({
      kind: l.kind,
      percent: l.percentUsed,
      resetsAt: l.resetsAt,
    })),
    cost: u.cost?.usd,
  }
}

async function refreshUsage($: EngineInterface) {
  const u = await $.session.usage()
  await update($, usage, () => toUsage(u))
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'dash-pane',
      description: 'Open the session dashboard pane',
    })
    void $.ui.open({ id: DASH, title: 'Dash' })
    await loadAgent($)
    void refreshTitle($)
    void refreshWork($)
    void refreshGit($)
    void refreshTasks($)
    void refreshUsage($)
    $.clock.every(1000, () => void update($, tick, n => n + 1))
    return next(e)
  })

  on('command.run', { command: 'dash-pane' }, async $ => {
    await $.ui.open({ id: DASH, title: 'Dash' })
    return { text: 'Dash pane opened.' }
  })

  on('classic.UserPromptSubmit', async ($, e, next) => {
    if (e.session_title) await update($, title, () => e.session_title ?? '')
    const mode = e.permission_mode
    if (mode) void update($, work, w => ({ ...w, mode }))
    return next(e)
  })

  on('prompt.submit', async ($, e, next) => {
    queueGit($)
    void refreshUsage($)
    void refreshWork($)
    void $.session.model().then(m => update($, agent, a => ({ ...a, model: prettyModel(m) })))
    return next(e)
  })

  on('prompt.compose', async ($, e, next) => {
    const style = e.outputStyle?.name
    void update($, agent, a => ({ ...a, style }))
    return next(e)
  })

  on('turn.step', async function* ($, e, next) {
    const result = yield* next(e)
    if (e.agentId) return result
    if (e.effort !== undefined) void update($, agent, a => ({ ...a, effort: String(e.effort) }))
    const u = result.usage
    if (u) {
      const at = await $.clock.now()
      const total = u.cache_read_input_tokens + u.cache_creation_input_tokens + u.input_tokens
      await update($, cache, c => {
        const wasWarm = c.lastAt !== undefined && at - c.lastAt < CACHE_TTL_MS
        const isMiss = wasWarm && u.cache_read_input_tokens === 0
        return {
          hit: total > 0 ? u.cache_read_input_tokens / total : c.hit,
          lastAt: at,
          misses: c.misses + (isMiss ? 1 : 0),
        }
      })
    }
    return result
  })

  on('tool.call', async ($, e, next) => {
    if (EDIT_TOOLS.has(e.tool)) {
      const delta = editDelta(e as unknown as Record<string, unknown>)
      const ran = await next(e)
      if (!ran.isError)
        void update($, lines, l => ({
          added: l.added + delta.added,
          removed: l.removed + delta.removed,
        }))
      queueGit($)
      return ran
    }
    const ran = await next(e)
    if (GIT_TOOLS.has(e.tool)) queueGit($)
    if (!e.agentId && TASK_TOOLS.has(e.tool)) void refreshTasks($)
    return ran
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if (!e.agentId) {
      void refreshTitle($)
      void refreshWork($)
    }
    return result
  })

  on('session.measure', async ($, e, next) => {
    await update($, usage, prev => ({
      ...toUsage(e),
      startedAt: prev.startedAt,
    }))
    return next(e)
  })

  on('ui.render', { component: 'Pane', requestId: DASH }, async ($, e) => {
    const els = $.ui.resolve(e)
    const { Box, Text } = els
    // The desktop app's font carries no Nerd Font glyphs and lays text out proportionally.
    const isDesktop = e.surface === 'desktop'
    const Svg = 'Svg' in els ? els.Svg : undefined
    const mark = (key: keyof typeof ICON, color: string) =>
      isDesktop && Svg ? (
        <Svg
          alt={key}
          width={14}
          height={14}
          source={`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="${SVG_COLOR[color] ?? color}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${ICON_SVG[key]}</svg>`}
        />
      ) : (
        <Text color={color === 'dim' ? undefined : color} dimColor={color === 'dim'}>
          {ICON[key]}
        </Text>
      )
    const g = await read($, git)
    const a: Agent = await read($, agent)
    const t = await read($, title)
    const tk = await read($, tasks)
    const u = await read($, usage)
    const c = await read($, cache)
    const ln = await read($, lines)
    const w = await read($, work)
    await read($, tick)
    const at = await $.clock.now()
    const done = tk.filter(x => x.status === 'completed').length
    const isCacheWarm = c.lastAt !== undefined && at - c.lastAt < CACHE_TTL_MS
    const room = Math.max(4, (e.viewport?.rows ?? 40) - 32 - (tk.length > 0 && done < tk.length ? tk.length + 2 : 0))

    const rule = '╌'.repeat(Math.max(10, (e.viewport?.columns ?? 40) - 2))
    let isFirstCard = true
    const card = (icon: keyof typeof ICON, name: string, meta: RenderChildren, body: RenderChildren, accent = 'claude') => {
      const isFirst = isFirstCard
      isFirstCard = false
      return (
        <Box flexDirection="column" paddingX={1}>
          {!isFirst &&
            (isDesktop ? (
              <Box marginTop={1} />
            ) : (
              <Text dimColor wrap="truncate-end">
                {rule}
              </Text>
            ))}
          <Box justifyContent="space-between">
            <Box gap={1} alignItems="center">
              {mark(icon, accent)}
              <Text color={accent} bold>
                {name}
              </Text>
            </Box>
            {meta}
          </Box>
          {body}
        </Box>
      )
    }

    const LABEL = 9
    const kv = (
      name: string,
      value: RenderChildren,
      wrap: 'truncate-end' | 'truncate-start' = 'truncate-end',
      lead?: RenderChildren,
    ) => (
      <Box alignItems="center">
        <Box width={LABEL} flexShrink={0}>
          <Text color="inactive">{name}</Text>
        </Box>
        {lead && (
          <Box marginRight={1} flexShrink={0}>
            {lead}
          </Box>
        )}
        <Text wrap={wrap}>{value}</Text>
      </Box>
    )

    const gauge = (percent: number, width: number, fill = 'rate_limit_fill') => {
      if (isDesktop) {
        const pct = Math.min(100, Math.max(0, percent))
        return (
          <Box width={width} height={1} flexShrink={0} alignItems="center">
            <Box width="100%" height={0.4} backgroundColor="rate_limit_empty" overflow="hidden">
              <Box width={`${pct}%`} backgroundColor={fill} />
            </Box>
          </Box>
        )
      }
      const b = bar(percent, width)
      const n = b.lastIndexOf('▰') + 1
      return (
        <Text>
          <Text color={fill}>{b.slice(0, n)}</Text>
          <Text color="rate_limit_empty">{b.slice(n)}</Text>
        </Text>
      )
    }

    const meter = (name: string, percent: number, extra: string) => (
      <Box justifyContent="space-between">
        <Box>
          <Box width={LABEL} flexShrink={0}>
            <Text color="inactive">{name}</Text>
          </Box>
          {gauge(percent, 12, heat(percent))}
          <Text bold> {String(Math.round(percent)).padStart(3)}%</Text>
        </Box>
        <Text dimColor>{extra}</Text>
      </Box>
    )

    return (
      <Box flexDirection="column">
        {card(
          'dir',
          g?.repo ?? '-',
          g?.isWorktree ? <Text color="suggestion">worktree</Text> : null,
          <Box flexDirection="column">
            {kv('cwd', <Text>{w.cwd}</Text>, 'truncate-start')}
            {t !== '' &&
              kv(
                'session',
                <Text color="suggestion" italic>
                  {t}
                </Text>,
              )}
            {u.startedAt !== undefined && kv('age', <Text>{duration(at - u.startedAt)}</Text>)}
          </Box>,
        )}

        {card(
          'brain',
          a.model,
          a.isWork ? (
            <Text color="error" bold>
              ⚠ WORK
            </Text>
          ) : null,
          <Box flexDirection="column">
            {a.account && kv('account', <Text color="suggestion">{a.account}</Text>)}
            {a.effort && kv('effort', <Text color="warning">{a.effort}</Text>)}
            {w.mode && kv('mode', <Text>{w.mode}</Text>)}
            {a.style && a.style !== 'default' && kv('style', <Text>{a.style}</Text>)}
            {kv('turns', <Text>{w.turns}</Text>)}
          </Box>,
          'success',
        )}

        {tk.length > 0 &&
          done < tk.length &&
          card(
            'tasks',
            'tasks',
            <Box>
              {gauge((done / tk.length) * 100, 8)}
              <Text bold>
                {' '}
                {done}/{tk.length}
              </Text>
            </Box>,
            <Box flexDirection="column">
              {tk.map(x => (
                <Text
                  dimColor={x.status === 'completed'}
                  color={x.status === 'in_progress' ? 'warning' : undefined}
                  wrap="truncate-end"
                >
                  {x.status === 'completed' ? '✓ ' : x.status === 'in_progress' ? '▸ ' : '· '}
                  {x.subject}
                </Text>
              ))}
            </Box>,
          )}

        {card(
          'ctx',
          'session',
          null,
          <Box flexDirection="column">
            {u.context !== undefined &&
              meter(
                'context',
                u.context,
                u.tokens !== undefined && u.window !== undefined
                  ? `${Math.round(u.tokens / 1000)}k/${u.window >= 1_000_000 ? `${u.window / 1_000_000}M` : `${Math.round(u.window / 1000)}k`}`
                  : '',
              )}
            {u.limits.map(l => meter(LIMIT_LABEL[l.kind] ?? l.kind, l.percent, until(l.resetsAt, at)))}
            {kv(
              'cache',
              <Text>
                <Text>{c.hit !== undefined ? `${Math.round(c.hit * 100)}% hit` : '–'}</Text>
                <Text dimColor>
                  {' '}
                  · {isCacheWarm && c.lastAt ? `expires ${until(c.lastAt + CACHE_TTL_MS, at)}` : 'cold'}
                </Text>
                {c.misses > 0 && <Text color="error"> · {c.misses} miss</Text>}
              </Text>,
              'truncate-end',
              mark('cache', isCacheWarm ? 'warning' : 'dim'),
            )}
            {kv(
              'edits',
              <Text>
                <Text color="success">+{ln.added}</Text>
                <Text dimColor>/</Text>
                <Text color="error">-{ln.removed}</Text>
                <Text dimColor> lines</Text>
              </Text>,
            )}
            {u.cost !== undefined && kv('cost', <Text color="warning">${u.cost.toFixed(2)}</Text>)}
          </Box>,
        )}

        {g &&
          card(
            'branch',
            g.branch ?? 'detached',
            null,
            <Box flexDirection="column">
              {g.upstream &&
                kv(
                  'upstream',
                  <Text>
                    <Text>{g.upstream}</Text>
                    {g.ahead > 0 && <Text color="success"> ↑{g.ahead}</Text>}
                    {g.behind > 0 && <Text color="error"> ↓{g.behind}</Text>}
                    {g.ahead === 0 && g.behind === 0 && <Text dimColor> in sync</Text>}
                  </Text>,
                )}
              {g.last &&
                kv(
                  'last',
                  <Text>
                    <Text color="warning">{g.last.hash}</Text>
                    <Text> {g.last.subject}</Text>
                    <Text dimColor> · {g.last.age}</Text>
                  </Text>,
                )}
              {g.stashes > 0 && kv('stashes', <Text color="suggestion">{g.stashes}</Text>)}
              {kv(
                'changes',
                g.files.length === 0 ? (
                  <Text color="success">✓ clean</Text>
                ) : (
                  <Text>
                    {g.added > 0 && <Text color="success">+{g.added} added </Text>}
                    {g.modified > 0 && <Text color="warning">~{g.modified} modified </Text>}
                    {g.deleted > 0 && <Text color="error">-{g.deleted} deleted </Text>}
                    {g.untracked > 0 && <Text color="suggestion">?{g.untracked} untracked</Text>}
                  </Text>
                ),
              )}
              {g.files.length > 0 && (
                <Box flexDirection="column" marginTop={1}>
                  {g.files.slice(0, room).map(f => (
                    <Box justifyContent="space-between">
                      <Text wrap="truncate-start">
                        <Text color={FILE_COLOR[f.status] ?? 'warning'} bold={f.isStaged}>
                          {f.isStaged ? '●' : '○'} {f.status}{' '}
                        </Text>
                        <Text>{f.path}</Text>
                      </Text>
                      <Text>
                        {f.added !== undefined && <Text color="success">+{f.added}</Text>}
                        {f.removed !== undefined && <Text color="error"> -{f.removed}</Text>}
                      </Text>
                    </Box>
                  ))}
                  {g.files.length > room && <Text dimColor>… {g.files.length - room} more</Text>}
                  <Text dimColor>● staged ○ unstaged</Text>
                </Box>
              )}
            </Box>,
          )}
      </Box>
    )
  })
}
