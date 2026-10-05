import { mock, test } from 'claude-code/testing'

test('the pane mounts on the terminal', async ($, on) => {
  mock.clock(on, { now: 1_000_000 })
  for (const requestId of ['dash']) {
    const m = await $.ui.mount({ plugin: 'dash-pane', surface: 'terminal', component: 'Pane', props: {}, requestId } as never)
    console.log(requestId, JSON.stringify(await (m as { drawn: () => Promise<unknown> }).drawn()).slice(0, 400))
  }
})
