import { expect, test } from 'claude-code/testing'

test('/toggle-mods alternates between hiding and showing', async $ => {
  const run = () => $.command.run({ command: 'toggle-mods', args: '' } as never) as Promise<unknown>
  expect(await run()).toMatchObject({ text: 'Panes hidden.' })
  expect(await run()).toMatchObject({ text: 'Panes shown.' })
  expect(await run()).toMatchObject({ text: 'Panes hidden.' })
})
