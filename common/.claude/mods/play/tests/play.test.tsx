import { expect, test } from 'claude-code/testing'
import { forTheEar, lastReply } from '../hooks/speech'

test('forTheEar keeps the sentences and drops what is not for listening', async () => {
  const markdown = [
    '## Plan',
    '',
    'Use **v4 Turbo** with `eleven_v4_turbo`, see [the docs](https://elevenlabs.io).',
    '',
    '```sh',
    'afplay out.mp3',
    '```',
    '',
    '| a | b |',
    '| - | - |',
    '',
    '- open /Users/nik/tmp/a.mp3',
    '- `~/.cache/claude-play/x.mp3` holds it',
  ].join('\n')

  expect(forTheEar(markdown)).toBe(
    ['Plan.', '', 'Use v4 Turbo with eleven v4 turbo, see the docs.', '', 'open.', 'holds it.'].join('\n'),
  )
})

test('lastReply joins the assistant text since the last typed prompt', async () => {
  const messages = [
    { role: 'user', text: 'first', toolUses: [] },
    { role: 'assistant', text: 'old answer', toolUses: [] },
    { role: 'user', text: 'second', toolUses: [] },
    { role: 'assistant', text: 'Looking.', toolUses: [] },
    { role: 'user', text: '', toolUses: [], toolResults: [{}] },
    { role: 'assistant', text: 'Found it.', toolUses: [] },
    { role: 'user', text: '/play', toolUses: [] },
  ] as never

  expect(lastReply(messages)).toBe('Looking.\n\nFound it.')
})

test('/play asks before a long reply spends credits', async ($, on) => {
  on('command.register', () => ({ value: { command: 'play' } }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))
  on('session.messages', () => ({
    value: [
      { role: 'user', text: 'go', toolUses: [] },
      { role: 'assistant', text: 'word '.repeat(700), toolUses: [] },
    ],
  }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  const result = await $.command.run({ command: 'play', args: '' } as never)
  expect(result).toMatchObject({ text: '~3499 chars. Run /play all to spend them.' })
})

test('/play stop with nothing playing says so', async ($, on) => {
  on('command.register', () => ({ value: { command: 'play' } }))
  on('session.start', (_, e) => ({ cwd: e.cwd }))

  await $.session.start({ cwd: '/', surface: 'terminal', isInteractive: true })
  expect(await $.command.run({ command: 'play', args: 'stop' } as never)).toMatchObject({ text: 'Nothing is playing.' })
})

const BAND = {
  plugin: 'play',
  component: 'AbovePrompt',
  surface: 'terminal',
  props: { bodyColumns: 80, hasSurvey: false },
} as never

test('the band keeps the other rows and shows the controls while a reply plays', async ($, on) => {
  on('state.get', () => ({ value: { value: { phase: 'playing', chars: 1770 }, version: 1 } }))
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text>cache-tax row</Text>
  })

  const ui = await $.ui.mount(BAND)

  expect(await ui.find({ type: 'Text', text: /cache-tax row/ })).toBeTruthy()
  expect((await ui.find({ type: 'Text', text: /playing/ }))?.text).toBe('· playing 1770 chars')
  expect(await ui.find({ type: 'Button', key: 'pause' })).toBeTruthy()
  await ui.unmount()
})

test('the band offers to play the last reply while idle', async ($, on) => {
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    return <Text>cache-tax row</Text>
  })

  const ui = await $.ui.mount(BAND)

  expect(await ui.find({ type: 'Button', key: 'play' })).toBeTruthy()
  expect(await ui.find({ type: 'Button', key: 'stop' })).toBeFalsy()
  await ui.unmount()
})
