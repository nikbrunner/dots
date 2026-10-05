export type Line = string

declare module 'claude-code' {
  interface PluginState {
    topbar: { title: Line; focus: Line; now: Line; tool: Line }
  }
}
