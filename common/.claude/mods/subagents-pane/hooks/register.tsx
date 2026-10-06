import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, RenderChildren } from 'claude-code'

import type { Sub } from '../types'
import { bar, compact, describeCall, duration, lastProgress, report, shortModel } from './lib'

const PANE = 'subagents'
const STALL_MS = 60_000
const LABEL = 9

const subs = atom({ plugin: 'subagents-pane', key: 'subs' } as const, [])
const tick = atom({ plugin: 'subagents-pane', key: 'tick' } as const, 0)

const isOk = (status: string) => status === 'completed' || status === 'idle'

function updateSub($: EngineInterface, id: string, fn: (s: Sub) => Sub) {
  return update($, subs, list => list.map(s => (s.id === id ? fn(s) : s)))
}

async function syncSubs($: EngineInterface) {
  const live = await $.agent.list()
  const at = await $.clock.now()
  await update($, subs, list =>
    list.map(s => {
      const status = live.find(a => a.id === s.id)?.status ?? 'completed'
      const isDone = ['completed', 'failed', 'killed', 'idle'].includes(status)
      return { ...s, status, endedAt: isDone ? (s.endedAt ?? at) : undefined }
    }),
  )
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'subagents-pane', description: 'Open the subagents pane' })
    $.clock.every(1000, () => {
      void read($, subs).then(list => {
        if (list.some(s => !s.endedAt)) void update($, tick, n => n + 1)
      })
    })
    return next(e)
  })

  on('command.run', { command: 'subagents-pane' }, async $ => {
    await $.ui.open({ id: PANE, title: 'Subagents' })
    return { text: 'Subagents pane opened.' }
  })

  on('agent.spawn', async ($, e, next) => {
    const result = await next(e)
    if (result.agentId) {
      const at = await $.clock.now()
      const sub: Sub = {
        id: result.agentId,
        type: e.subagentType,
        description: e.description,
        model: shortModel(result.model),
        isBackground: e.background,
        status: 'running',
        startedAt: at,
        lastAt: at,
        tools: 0,
        tokens: 0,
      }
      await update($, subs, list => [...list, sub].slice(-20))
      void $.ui.open({ id: PANE, title: 'Subagents' })
    }
    return result
  })

  on('turn.step', async function* ($, e, next) {
    const result = yield* next(e)
    if (e.agentId) {
      const at = await $.clock.now()
      const progress = lastProgress(result.answer)
      const u = result.usage
      const tokens = u ? u.input_tokens + u.output_tokens + u.cache_read_input_tokens + u.cache_creation_input_tokens : 0
      void updateSub($, e.agentId, s => ({
        ...s,
        progress: progress ?? s.progress,
        tokens: s.tokens + tokens,
        lastAt: at,
      }))
    }
    return result
  })

  on('tool.call', async ($, e, next) => {
    if (e.agentId) {
      const tool = describeCall(e as unknown as Record<string, unknown>)
      const at = await $.clock.now()
      void updateSub($, e.agentId, s => ({ ...s, tool, tools: s.tools + 1, lastAt: at }))
    }
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if (e.agentId) {
      const answer = report(e.answer)
      if (answer) void updateSub($, e.agentId, s => ({ ...s, result: answer }))
      void syncSubs($)
    }
    return result
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const list = await read($, subs)
    await read($, tick)
    const at = await $.clock.now()
    const running = list.filter(s => !s.endedAt).length
    const failed = list.filter(s => s.endedAt && !isOk(s.status)).length
    const rule = '╌'.repeat(Math.max(10, (e.viewport?.columns ?? 40) - 2))

    const kv = (name: string, value: RenderChildren) => (
      <Text wrap="truncate-end">
        <Text color="inactive">{name.padEnd(LABEL)}</Text>
        {value}
      </Text>
    )

    return (
      <Box flexDirection="column" paddingX={1}>
        <Box justifyContent="space-between">
          <Text color="claude" bold>
            ◆ subagents
          </Text>
          <Text>
            {running > 0 && <Text color="warning">● {running} running </Text>}
            <Text color="success">✓ {list.length - running - failed}</Text>
            {failed > 0 && <Text color="error"> ✗ {failed}</Text>}
          </Text>
        </Box>
        {list.length === 0 && <Text dimColor>No subagents yet. They show up here as soon as one spawns.</Text>}
        {[...list].reverse().map(s => {
          const isDone = s.endedAt !== undefined
          const accent = isDone ? (isOk(s.status) ? 'success' : 'error') : 'warning'
          const idle = at - (s.lastAt ?? s.startedAt)
          const isStalled = !isDone && idle > STALL_MS
          const p = s.progress
          return (
            <Box flexDirection="column">
              <Text dimColor wrap="truncate-end">
                {rule}
              </Text>
              <Box justifyContent="space-between">
                <Text color={accent} bold wrap="truncate-end">
                  {isDone ? (isOk(s.status) ? '✓' : '✗') : '●'} {s.type}
                </Text>
                <Text dimColor>
                  {isDone ? s.status : 'running'} · {duration((s.endedAt ?? at) - s.startedAt)}
                </Text>
              </Box>
              {kv('task', <Text dimColor={isDone}>{s.description}</Text>)}
              {s.model &&
                kv(
                  'model',
                  <Text>
                    <Text color="success">{s.model}</Text>
                    <Text dimColor> · {s.isBackground ? 'background' : 'foreground'}</Text>
                  </Text>,
                )}
              {p &&
                kv(
                  'progress',
                  <Text>
                    <Text color={isDone ? undefined : 'success'} dimColor={isDone}>
                      {bar((p.step / Math.max(1, p.total)) * 100, 8)}
                    </Text>
                    <Text bold>
                      {' '}
                      {p.step}/{p.total}
                    </Text>
                    <Text dimColor> {p.text}</Text>
                  </Text>,
                )}
              {!isDone && s.tool && kv('now', <Text color="suggestion">↳ {s.tool}</Text>)}
              {kv(
                'activity',
                <Text>
                  <Text>{s.tools ?? 0} tools</Text>
                  <Text dimColor> · {compact(s.tokens ?? 0)} tokens</Text>
                  {!isDone && (
                    <Text color={isStalled ? 'error' : undefined} dimColor={!isStalled}>
                      {' '}
                      · {isStalled ? 'stalled' : 'idle'} {duration(idle)}
                    </Text>
                  )}
                </Text>,
              )}
              {isDone && s.result && (
                <Box>
                  <Box width={LABEL} flexShrink={0}>
                    <Text color="inactive">result</Text>
                  </Box>
                  <Text wrap="wrap">{s.result}</Text>
                </Box>
              )}
            </Box>
          )
        })}
      </Box>
    )
  })
}
