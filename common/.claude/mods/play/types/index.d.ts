export type Playback = { phase: 'idle' | 'preparing' | 'generating' | 'playing' | 'paused'; chars: number }

declare module 'claude-code' {
  interface PluginState {
    play: { playback: Playback }
  }
}
