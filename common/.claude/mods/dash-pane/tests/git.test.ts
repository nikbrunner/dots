import { expect, test } from 'claude-code/testing'

import { parseGit } from '../hooks/lib'

test('parses branch, divergence and dirty counts', async () => {
  const out = [
    '# branch.oid abc',
    '# branch.head main',
    '# branch.upstream origin/main',
    '# branch.ab +2 -1',
    '1 .M N... 100644 100644 100644 a b common/x',
    '1 A. N... 000000 100644 100644 a b common/y',
    '1 D. N... 100644 000000 000000 a b common/z',
    '? new.txt',
  ].join('\n')

  expect(parseGit('dots', out)).toMatchObject({
    repo: 'dots', isWorktree: false, branch: 'main', upstream: 'origin/main', ahead: 2, behind: 1,
    added: 1, modified: 1, deleted: 1, untracked: 1,
  })
})

test('detached head has no branch', async () => {
  expect(parseGit('dots', '# branch.head (detached)').branch).toBeUndefined()
})

test('lists files with status, staging and numstat', async () => {
  const out = [
    '1 .M N... 100644 100644 100644 a b src/my file.ts',
    '1 A. N... 000000 100644 100644 a b new.ts',
    '2 R. N... 100644 100644 100644 a b R100 to.ts\tfrom.ts',
    '? scratch.txt',
    '# last abc123\t2 hours ago\tFix things',
    '# stash 2',
    '# num 3\t1\tsrc/my file.ts',
  ].join('\n')
  const g = parseGit('dots', out)
  expect(g.files).toEqual([
    { path: 'src/my file.ts', status: 'M', isStaged: false, added: 3, removed: 1 },
    { path: 'new.ts', status: 'A', isStaged: true },
    { path: 'to.ts', status: 'R', isStaged: true },
    { path: 'scratch.txt', status: '?', isStaged: false },
  ])
  expect(g.last).toEqual({ hash: 'abc123', age: '2 hours ago', subject: 'Fix things' })
  expect(g.stashes).toBe(2)
})
