import { expect, test } from 'claude-code/testing'

import { compact, lastProgress, report, shortModel } from '../hooks/lib'

test('lastProgress takes the last PROGRESS line', async () => {
  const text = 'PROGRESS: 1/3 · Reading files\nstuff\nPROGRESS: 2/3 · Running tests'
  expect(lastProgress(text)).toEqual({ step: 2, total: 3, text: 'Running tests' })
  expect(lastProgress('no progress here')).toBeUndefined()
})

test('shortModel, compact and report format agent facts', async () => {
  expect(shortModel('claude-haiku-4-5-20251001')).toBe('haiku 4.5')
  expect(shortModel('opus')).toBe('opus')
  expect(compact(22_671)).toBe('23k')
  expect(compact(1_250_000)).toBe('1.3M')
  expect(report('PROGRESS: 4/4 · Done\n\nSurvey of dots:\n1. ...')).toBe('Survey of dots:\n1. ...')
})
