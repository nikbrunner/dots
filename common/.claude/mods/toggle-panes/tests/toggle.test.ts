import { expect, test } from 'claude-code/testing'

test('/toggle-panes alternates between hiding and showing', async $ => {
  const run = () => $.command.run({ command: 'toggle-panes', args: '' } as never) as Promise<unknown>
  expect(await run()).toMatchObject({ text: 'Panes hidden.' })
  expect(await run()).toMatchObject({ text: 'Panes shown.' })
  expect(await run()).toMatchObject({ text: 'Panes hidden.' })
})
