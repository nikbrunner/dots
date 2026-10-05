export type Task = { subject: string; status: 'pending' | 'in_progress' | 'completed' }

export type GitFile = {
  path: string
  status: string
  isStaged: boolean
  added?: number
  removed?: number
}

export type Git = {
  repo: string
  upstream?: string
  last?: { hash: string; age: string; subject: string }
  stashes: number
  files: GitFile[]
  isWorktree: boolean
  branch?: string
  ahead: number
  behind: number
  added: number
  modified: number
  deleted: number
  untracked: number
}

export type Limit = { kind: string; percent: number; resetsAt?: string }

export type Usage = { context?: number; tokens?: number; window?: number; startedAt?: number; limits: Limit[]; cost?: number }

export type Agent = {
  account?: string
  isWork: boolean
  model: string
  effort?: string
  style?: string
}

export type Work = { cwd: string; mode?: string; turns: number }

export type Cache = { hit?: number; lastAt?: number; misses: number }

declare module 'claude-code' {
  interface PluginState {
    'dash-pane': {
      git: Git | null
      agent: Agent
      title: string
      work: Work
      tasks: Task[]
      usage: Usage
      cache: Cache
      lines: { added: number; removed: number }
      tick: number
    }
  }
}
