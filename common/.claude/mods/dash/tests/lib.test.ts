import { expect, test } from 'claude-code/testing'

import { describeCall, editDelta, oneLine, parseGit, prettyModel } from '../hooks/lib'

test('prettyModel names the model like the status line', async () => {
  expect(prettyModel('claude-opus-5-5[1m]')).toBe('Opus 5.5 (1M context)')
  expect(prettyModel('claude-sonnet-5-5')).toBe('Sonnet 5.5')
  expect(prettyModel('custom')).toBe('custom')
})

test('parseGit spots a worktree', async () => {
  expect(parseGit('dots', '# branch.head main\n# gitdir /r/.git/worktrees/x').isWorktree).toBe(true)
  expect(parseGit('dots', '# branch.head main\n# gitdir /r/.git').isWorktree).toBe(false)
})

test('editDelta counts lines of Edit, MultiEdit and Write', async () => {
  expect(editDelta({ tool: 'Edit', old_string: 'a\nb', new_string: 'a\nb\nc' })).toEqual({ added: 3, removed: 2 })
  expect(editDelta({ tool: 'MultiEdit', edits: [{ old_string: 'a', new_string: 'b' }, { old_string: 'c', new_string: '' }] })).toEqual({ added: 1, removed: 2 })
  expect(editDelta({ tool: 'Write', content: 'x\ny' })).toEqual({ added: 2, removed: 0 })
})

test('describeCall names the tool and its main argument', async () => {
  expect(describeCall({ tool: 'Edit', file_path: '/a/b/register.tsx' })).toBe('Edit register.tsx')
  expect(describeCall({ tool: 'Bash', command: 'git status\ngit diff' })).toBe('Bash git status')
  expect(describeCall({ tool: 'TaskList' })).toBe('TaskList')
})

test('oneLine keeps the first non-empty line without a trailing period', async () => {
  expect(oneLine('\n  Splitting the dash pane.\nmore')).toBe('Splitting the dash pane')
})
