import { atom, update } from 'claude-code'
import type { Register } from 'claude-code'

const isHidden = atom({ plugin: 'toggle-mods', key: 'isHidden' } as const, false)

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'toggle-mods', description: 'Hide or show the dash and the mod panes' })
    return next(e)
  })

  on('command.run', { command: 'toggle-mods' }, async $ => {
    let hidden = false
    await update($, isHidden, h => (hidden = !h))
    return { text: hidden ? 'Panes hidden.' : 'Panes shown.' }
  })
}
