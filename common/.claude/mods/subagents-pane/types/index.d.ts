export type Progress = { step: number; total: number; text: string }

export type Sub = {
  id: string
  type: string
  description: string
  model: string
  isBackground: boolean
  status: string
  startedAt: number
  lastAt: number
  endedAt?: number
  progress?: Progress
  tool?: string
  tools: number
  tokens: number
  result?: string
}

declare module 'claude-code' {
  interface PluginState {
    'subagents-pane': { subs: Sub[]; tick: number }
  }
}
