import { mock, test } from 'claude-code/testing'

test('the pane mounts on the terminal', async ($, on) => {
  mock.clock(on, { now: 1_000_000 })
  for (const requestId of ['dash']) {
    const m = await $.ui.mount({ plugin: 'dash-pane', surface: 'terminal', component: 'Pane', props: {}, requestId } as never)
    console.log(requestId, JSON.stringify(await (m as { drawn: () => Promise<unknown> }).drawn()).slice(0, 400))
  }
})

test('the pane mounts on the desktop without Nerd Font glyphs', async ($, on) => {
  mock.clock(on, { now: 1_000_000 })
  const m = await $.ui.mount({ plugin: 'dash-pane', surface: 'desktop', component: 'Pane', props: {}, requestId: 'dash' } as never)
  const drawn = JSON.stringify(await (m as { drawn: () => Promise<unknown> }).drawn())
  if (/[\uf000-\uf8ff]|[\u{f0000}-\u{fffff}]/u.test(drawn)) throw new Error('private-use glyph on desktop')
  if (!drawn.includes('<svg')) throw new Error('no svg icons on desktop')
})
