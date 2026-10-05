import { expect, test } from 'claude-code/testing'

import { describeCall, oneLine } from '../hooks/lib'

test('describeCall names the tool and its main argument', async () => {
  expect(describeCall({ tool: 'Edit', file_path: '/a/b/register.tsx' })).toBe('Edit register.tsx')
  expect(describeCall({ tool: 'Bash', command: 'git status\ngit diff' })).toBe('Bash git status')
  expect(describeCall({ tool: 'TaskList' })).toBe('TaskList')
})

test('oneLine keeps the first non-empty line without a trailing period', async () => {
  expect(oneLine('\n  Splitting the dash pane.\nmore')).toBe('Splitting the dash pane')
})
