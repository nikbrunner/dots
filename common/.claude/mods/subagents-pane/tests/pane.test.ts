import { mock, test } from 'claude-code/testing'

test('the pane mounts on the terminal', async ($, on) => {
  mock.clock(on, { now: 1_000_000 })
  await $.ui.mount({ plugin: 'subagents-pane', surface: 'terminal', component: 'Pane', props: {}, requestId: 'subagents' } as never)
})
