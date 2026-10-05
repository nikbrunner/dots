import { mock, test } from 'claude-code/testing'

const props = { hasSurvey: false, isWorking: true, maxRows: 6 }

test('the empty band falls through to the engine', async ($, on) => {
  mock.clock(on, { now: 1_000_000 })
  on('ui.render', { component: 'AbovePrompt' }, ($, e) => {
    const { Box } = $.ui.resolve(e)
    return <Box />
  })
  await $.ui.mount({ plugin: 'topbar', surface: 'terminal', component: 'AbovePrompt', props } as never)
})
