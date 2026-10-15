import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import { describeCall, oneLine } from './lib'

const MODEL = 'haiku'
const SUMMARY_INTERVAL_MS = 10_000
const TITLE_EVERY_TURNS = 3

const title = atom({ plugin: 'topbar', key: 'title' } as const, '')
const focus = atom({ plugin: 'topbar', key: 'focus' } as const, '')
const now = atom({ plugin: 'topbar', key: 'now' } as const, '')
const tool = atom({ plugin: 'topbar', key: 'tool' } as const, '')

let configDir = ''
let prompt = ''
let recent: string[] = []
let lastSummaryAt = 0
let isSummarizing = false
let prompts: string[] = []
let turns = 0
let isRenamed = false
let isTitling = false
let pendingTitle = ''

async function getConfigDir($: EngineInterface) {
  if (!configDir) {
    const run = await $.process.run(['sh', '-c', 'printf %s "${CLAUDE_CONFIG_DIR:-$HOME/.claude}"'])
    configDir = run.stdout
  }
  return configDir
}

// Titles this mod set land in the transcript as customTitle, the same as a
// /rename, so each one is logged to topbar/<session-id> and reported as ownTitle.
async function refreshTitle($: EngineInterface) {
  const run = await $.process.run([
    'sh',
    '-c',
    'f=$(ls "$1"/projects/*/"$2".jsonl 2>/dev/null | head -1); [ -n "$f" ] || exit 0; ' +
      'line=$(grep -o \'"\\(customTitle\\|aiTitle\\)":"[^"]*"\' "$f" | tail -1 | sed \'s/":"/ /; s/^"//; s/"$//\'); ' +
      'case $line in "customTitle "*) grep -Fxqs -- "${line#* }" "$1/topbar/$2" && line="ownTitle ${line#* }";; esac; ' +
      'printf %s "$line"',
    'sh',
    await getConfigDir($),
    await $.session.id(),
  ])
  const [kind, ...words] = run.stdout.trim().split(' ')
  const found = words.join(' ')
  if (!found) return
  if (kind === 'customTitle') isRenamed = true
  if (isRenamed || (await read($, title)) === '') await update($, title, () => found)
}

async function summarizeTitle($: EngineInterface) {
  if (isRenamed || isTitling || prompts.length === 0) return
  isTitling = true
  try {
    const r = await $.model.complete({
      model: MODEL,
      maxTokens: 30,
      system:
        'You name a coding session after its overall subject, the thing all its steps serve, never the latest step. ' +
        'Keep the current title unless the subject has clearly moved on. ' +
        'Reply with a title of 3 to 8 words, sentence case, no quotes, no trailing period.',
      prompt: [
        `Current title: ${(await read($, title)) || '(none)'}`,
        `Developer prompts, oldest first:\n${prompts.map(p => `- ${p.slice(0, 300)}`).join('\n')}`,
      ].join('\n\n'),
    })
    const next = r.isAnswered ? oneLine(r.text) : ''
    if (next !== '' && !isRenamed && next !== (await read($, title))) {
      await update($, title, () => next)
      pendingTitle = next
    }
  } finally {
    isTitling = false
  }
}

async function summarizeFocus($: EngineInterface, text: string) {
  const r = await $.model.complete({
    model: MODEL,
    maxTokens: 40,
    system:
      'You label what a developer asked a coding agent to do. Reply with one line of at most 10 words, ' +
      'imperative mood, no quotes, no trailing period.',
    prompt: text.slice(0, 3000),
  })
  if (r.isAnswered) await update($, focus, () => oneLine(r.text))
}

async function summarizeNow($: EngineInterface, answer: string, isDone: boolean) {
  const at = await $.clock.now()
  if (isSummarizing || (!isDone && at - lastSummaryAt < SUMMARY_INTERVAL_MS)) return
  isSummarizing = true
  lastSummaryAt = at
  try {
    const r = await $.model.complete({
      model: MODEL,
      maxTokens: 40,
      system:
        'You watch a coding agent work and report its state in one line of at most 12 words. ' +
        (isDone ? 'The turn just ended: say what it finished or is waiting for.' : 'Say what it is doing right now.') +
        ' Present tense, no quotes, no trailing period.',
      prompt: [
        `Developer asked: ${prompt.slice(0, 1500)}`,
        `Recent tool calls:\n${recent.slice(-8).join('\n') || '(none)'}`,
        `Latest agent text: ${answer.slice(-800) || '(none)'}`,
      ].join('\n\n'),
    })
    if (r.isAnswered) await update($, now, () => oneLine(r.text))
  } finally {
    isSummarizing = false
  }
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    void refreshTitle($)
    return next(e)
  })

  on('classic.UserPromptSubmit', async ($, e, next) => {
    const result = await next(e)
    if (pendingTitle === '' || isRenamed) return result
    const sessionTitle = pendingTitle
    pendingTitle = ''
    await $.process.run([
      'sh',
      '-c',
      'mkdir -p "$1/topbar" && printf "%s\\n" "$3" >> "$1/topbar/$2"',
      'sh',
      await getConfigDir($),
      await $.session.id(),
      sessionTitle,
    ])
    return { ...result, sessionTitle }
  })

  on('prompt.submit', async ($, e, next) => {
    prompt = e.text
    recent = []
    lastSummaryAt = 0
    if (e.text.trim() !== '' && !e.text.startsWith('/')) {
      prompts = [...prompts, e.text].slice(-20)
      void update($, now, () => 'Reading the request')
      void summarizeFocus($, e.text)
    }
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    if (e.agentId) return next(e)
    const call = describeCall(e as unknown as Record<string, unknown>)
    recent = [...recent, call].slice(-20)
    await update($, tool, () => call)
    return next(e)
  })

  on('turn.step', async function* ($, e, next) {
    const result = yield* next(e)
    if (!e.agentId && result.toolUses.length > 0) void summarizeNow($, result.answer, false)
    return result
  })

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if (!e.agentId) {
      await update($, tool, () => '')
      void summarizeNow($, 'answer' in e ? e.answer : '', true)
      turns += 1
      void refreshTitle($).then(() =>
        turns === 1 || turns % TITLE_EVERY_TURNS === 0 ? summarizeTitle($) : undefined,
      )
    }
    return result
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)
    const t = await read($, title)
    const f = await read($, focus)
    const n = await read($, now)
    const live = await read($, tool)
    if (t === '' && f === '' && n === '') return next(e)

    const { Box, Text } = $.ui.resolve(e)
    const rule = '╌'.repeat(Math.max(10, (e.viewport?.columns ?? 80) - 2))

    return (
      <Box flexDirection="column" paddingX={1}>
        {t !== '' && (
          <Box borderStyle="bold" borderColor="claude" paddingX={1} alignSelf="flex-start">
            <Text color="claude" bold wrap="truncate-end">
              {t.toUpperCase()}
            </Text>
          </Box>
        )}
        {f !== '' && (
          <Text wrap="truncate-end">
            <Text color="warning" bold>
              Focus{' '}
            </Text>
            <Text>{f}</Text>
          </Text>
        )}
        {n !== '' && (
          <Text wrap="truncate-end">
            <Text color="success" bold>
              Now{'   '}
            </Text>
            <Text>{n}</Text>
          </Text>
        )}
        {e.props.isWorking && live !== '' && (
          <Text dimColor wrap="truncate-end">
            {'      '}↳ {live}
          </Text>
        )}
        <Text dimColor wrap="truncate-end">
          {rule}
        </Text>
      </Box>
    )
  })
}
