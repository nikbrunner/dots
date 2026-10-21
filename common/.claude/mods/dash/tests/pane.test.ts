import { mock, test } from 'claude-code/testing'

test('the band mounts on the terminal', async ($, on) => {
  mock.clock(on, { now: 1_000_000 })
  on('ui.render', ($, e) => $.ui.resolve(e).Box({}))
  for (const requestId of ['dash']) {
    const m = await $.ui.mount({ plugin: 'dash', surface: 'terminal', component: 'AbovePrompt', props: { bodyColumns: 80 }, requestId } as never)
    await (m as { drawn: () => Promise<unknown> }).drawn()
  }
})

test('the band mounts on the desktop without Nerd Font glyphs', async ($, on) => {
  mock.clock(on, { now: 1_000_000 })
  on('ui.render', ($, e) => $.ui.resolve(e).Box({}))
  const m = await $.ui.mount({ plugin: 'dash', surface: 'desktop', component: 'AbovePrompt', props: { bodyColumns: 80 }, requestId: 'dash' } as never)
  const drawn = JSON.stringify(await (m as { drawn: () => Promise<unknown> }).drawn())
  if (/[\uf000-\uf8ff]|[\u{f0000}-\u{fffff}]/u.test(drawn)) throw new Error('private-use glyph on desktop')
  if (!drawn.includes('<svg')) throw new Error('no svg icons on desktop')
})
