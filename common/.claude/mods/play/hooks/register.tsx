import { atom, read, update } from 'claude-code'
import type { EngineInterface, HookStream, ProcessSpawnChunk, ProcessSpawnResult, Register } from 'claude-code'
import type { Playback } from '../types'
import { forTheEar, hash, lastReply, SCRIPT_PROMPT } from './speech'

const VOICE = 'bD9maNcCuQQS75DGuteM'
const MODEL = 'eleven_v4_turbo'
const KEY_REF = 'pass://Nik/.env/ELEVENLABS_API_TOKEN'
// Every character is billed; a longer reply needs `/play all`.
const MAX_CHARS = 3000
const REQUEST_LIMIT = 10000
const REWIND_SECONDS = 10

const IDLE: Playback = { phase: 'idle', chars: 0 }
const playback = atom({ plugin: 'play', key: 'playback' } as const, IDLE)

let player: HookStream<ProcessSpawnChunk, ProcessSpawnResult> | undefined
let dir: string | undefined
let key: string | undefined

// Unix socket paths stay under ~104 bytes on macOS, so the socket lives in the
// short cache dir, not a temp dir.
async function cacheDir($: EngineInterface) {
  dir ??= `${(await $.process.run(['sh', '-c', 'printf %s "$HOME"'])).stdout}/.cache/claude-play`
  return dir
}

async function mpv($: EngineInterface, command: unknown[]) {
  const socket = `${await cacheDir($)}/mpv.sock`
  await $.process.run(['nc', '-U', '-w', '1', socket], { stdin: `${JSON.stringify({ command })}\n` })
}

async function setPhase($: EngineInterface, phase: Playback['phase'], chars?: number) {
  await update($, playback, p => ({ phase, chars: chars ?? p.chars }))
}

async function stop($: EngineInterface) {
  void player?.return({ code: null, signal: 'SIGTERM' })
  player = undefined
  await setPhase($, 'idle')
}

async function togglePause($: EngineInterface) {
  const { phase } = await read($, playback)
  if (phase !== 'playing' && phase !== 'paused') return false
  const pause = phase === 'playing'
  await mpv($, ['set_property', 'pause', pause])
  await setPhase($, pause ? 'paused' : 'playing')
  return true
}

async function rewind($: EngineInterface) {
  const { phase } = await read($, playback)
  if (phase !== 'playing' && phase !== 'paused') return false
  await mpv($, ['seek', -REWIND_SECONDS])
  return true
}

// Falls back to the plain cleanup when the model call fails, so a reply is
// always read.
async function toScript($: EngineInterface, reply: string) {
  const result = await $.model.complete({
    model: 'haiku',
    system: SCRIPT_PROMPT,
    prompt: `<reply>\n${reply}\n</reply>`,
    maxTokens: 4000,
    timeoutMs: 30_000,
  })
  return result.isAnswered && result.text.trim() ? result.text.trim() : forTheEar(reply)
}

// The key from Proton Pass, read once per session and held in memory only.
async function apiKey($: EngineInterface) {
  if (key) return key
  const { exitCode, stdout } = await $.process.run(['pass-cli', 'item', 'view', KEY_REF])
  if (exitCode !== 0 || !stdout.trim()) throw new Error(`could not read ${KEY_REF}`)
  key = stdout.trim()
  return key
}

// Calls the API with a key: the `elevenlabs` CLI signs in through the browser
// and is billed at app rates, five times the API's on v4 Turbo.
// Answers the error, or undefined once the mp3 is written.
async function synthesize($: EngineInterface, text: string, file: string) {
  const body = `${file}.json`
  await $.process.run(['mkdir', '-p', await cacheDir($)])
  await $.process.run(['sh', '-c', 'cat > "$0"', body], { stdin: JSON.stringify({ text, model_id: MODEL }) })
  // The key travels on stdin, never in argv, where `ps` would show it.
  const { exitCode, stderr } = await $.process.run(
    ['curl', '-sS', '--fail-with-body', '-H', '@-', '-H', 'Content-Type: application/json',
      '--data-binary', `@${body}`, '-o', file, `https://api.elevenlabs.io/v1/text-to-speech/${VOICE}`],
    { stdin: `xi-api-key: ${await apiKey($)}\n`, timeoutMs: 120_000 },
  )
  await $.process.run(['rm', '-f', body])
  if (exitCode === 0) return undefined
  const response = (await $.process.run(['cat', file])).stdout
  await $.process.run(['rm', '-f', file])
  return response.trim() || stderr.trim() || `curl exited ${exitCode}`
}

async function speak($: EngineInterface, reply: string, estimate: number, file: string, cached: boolean) {
  try {
    if (!cached) {
      await setPhase($, 'preparing', estimate)
      const text = await toScript($, reply)
      if (text.length > REQUEST_LIMIT) {
        $.ui.toast(`play: ${text.length} chars, over the ${REQUEST_LIMIT} a request takes.`)
        await setPhase($, 'idle')
        return
      }
      await setPhase($, 'generating', text.length)
      const error = await synthesize($, text, file)
      if (error) {
        $.ui.toast(`play: ElevenLabs failed: ${error}`)
        await setPhase($, 'idle')
        return
      }
    }
    const stream = $.process.spawn({
      argv: ['mpv', '--no-video', '--no-terminal', '--af=loudnorm', `--input-ipc-server=${await cacheDir($)}/mpv.sock`, file],
    })
    player = stream
    await setPhase($, 'playing')
    for await (const _ of stream) {
    }
    if (player === stream) {
      player = undefined
      await setPhase($, 'idle')
    }
  } catch (error) {
    $.ui.toast(`play: ${error instanceof Error ? error.message : String(error)}`)
    await setPhase($, 'idle')
  }
}

async function playLast($: EngineInterface, isAllowedLong: boolean) {
  const reply = lastReply(await $.session.messages())
  // The plain cleanup's length stands in for the script's, so the guard
  // answers before any model call.
  const estimate = forTheEar(reply).length
  if (!estimate) return 'No reply to read.'
  if (estimate > MAX_CHARS && !isAllowedLong) return `~${estimate} chars. Run /play all to spend them.`

  const file = `${await cacheDir($)}/${hash(`${MODEL}:${VOICE}:${reply}`)}.mp3`
  const cached = (await $.process.run(['test', '-s', file])).exitCode === 0

  await stop($)
  void speak($, reply, estimate, file, cached)

  return cached ? 'Playing from cache.' : `Preparing ~${estimate} chars…`
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'play',
      description: 'Read the last reply aloud (/play pause, back, stop, all)',
    })
    return next(e)
  })

  on('command.run', { command: 'play' }, async ($, e) => {
    const arg = e.args.trim()
    if (arg === 'stop') {
      const wasPlaying = player !== undefined
      await stop($)
      return { text: wasPlaying ? 'Stopped.' : 'Nothing is playing.' }
    }
    if (arg === 'pause') return { text: (await togglePause($)) ? 'Toggled pause.' : 'Nothing is playing.' }
    if (arg === 'back') return { text: (await rewind($)) ? `Back ${REWIND_SECONDS}s.` : 'Nothing is playing.' }

    return { text: await playLast($, arg === 'all') }
  })

  // The band is shared: the other mods' rows stay, this one sits below them.
  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const rest = await next(e)
    if (e.props.hasSurvey) return rest

    const { phase, chars } = await read($, playback)
    const { Box, Button, Text } = $.ui.resolve(e)
    const isBusy = phase === 'preparing' || phase === 'generating'
    const isPlaying = phase === 'playing' || phase === 'paused'

    return (
      <Box flexDirection="column">
        {rest}
        <Box gap={1}>
          <Text dimColor>♪ play</Text>
          {phase === 'idle' && (
            <Button key="play" label="▶ Play last reply" onPress={async () => $.ui.toast(`play: ${await playLast($, false)}`)} />
          )}
          {isBusy && <Text dimColor>· {phase} {chars} chars…</Text>}
          {isPlaying && <Text dimColor>· {phase} {chars} chars</Text>}
          {isPlaying && <Button key="back" label={`⏪ ${REWIND_SECONDS}s`} onPress={() => rewind($)} />}
          {isPlaying && (
            <Button key="pause" label={phase === 'playing' ? '⏸ Pause' : '▶ Resume'} onPress={() => togglePause($)} />
          )}
          {(isBusy || isPlaying) && <Button key="stop" label="■ Stop" onPress={() => stop($)} />}
        </Box>
      </Box>
    )
  })
}
