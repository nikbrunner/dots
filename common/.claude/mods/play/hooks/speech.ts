import type { SessionMessage } from 'claude-code'

// The assistant text since the last prompt the person typed: one reply, however
// many tool steps it took.
export function lastReply(messages: readonly SessionMessage[]): string {
  const parts: string[] = []
  let i = messages.length - 1
  while (i >= 0 && !(messages[i]?.role === 'assistant' && messages[i]?.text.trim())) i--
  for (; i >= 0; i--) {
    const m = messages[i]
    if (!m) continue
    if (m.role === 'user' && !m.toolResults?.length) break
    if (m.role === 'assistant' && m.text.trim()) parts.unshift(m.text)
  }
  return parts.join('\n\n')
}

export const SCRIPT_PROMPT = `You turn an assistant's reply from a coding session into a script that a text-to-speech voice reads aloud to the person who asked. Answer with the script alone: plain sentences, no Markdown, no preamble.

- Keep the substance, the order and the first-person voice. Rephrase only what does not work spoken. Do not summarize prose, and add no commentary of your own.
- The reply may open with short progress notes written while working ("Checking the config."). Drop them, unless one carries a finding the rest of the reply does not repeat; then keep that finding in one sentence.
- Never read code. Replace a code block with one short sentence saying what it is ("Then a shell command that installs mpv.").
- Turn a table into a few sentences carrying its point: what it compares and what stands out.
- Never read a URL. A list of links becomes one sentence naming what they point to.
- Say a file path by its last part and where it lives ("register.tsx in the play mod").
- Write identifiers and abbreviations the way a person says them: "CLI" stays CLI, "v1.3" becomes version 1.3, "snake_case_name" becomes snake case name.
- Drop emojis.`

// Markdown to sentences: what the listener would not want read out goes.
export function forTheEar(markdown: string): string {
  return markdown
    .replace(/^(```|~~~)[^\n]*\n[\s\S]*?^\1[^\n]*$/gm, '')
    .replace(/^[ \t]*\|.*$/gm, '')
    .replace(/^[ \t]*(-{3,}|\*{3,})[ \t]*$/gm, '')
    .replace(/!?\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/\[\[(?:[^\]|]*\|)?([^\]]*)\]\]/g, '$1')
    .replace(/https?:\/\/\S+/g, '')
    .replace(/`([^`\n]*)`/g, (_, code: string) => spokenCode(code))
    .replace(/(^|\s)(~|\.{0,2})\/[\w.@~/-]+/g, '$1')
    .replace(/^[ \t]{0,3}#{1,6}\s+(.*)$/gm, (_, h: string) => endSentence(h))
    .replace(/^[ \t]*>\s?/gm, '')
    .replace(/^[ \t]*(?:[-*+]|\d+\.)\s+(.*)$/gm, (_, item: string) => endSentence(item))
    .replace(/(\*\*|__|\*|_)(\S(?:.*?\S)?)\1/g, '$2')
    .replace(/<[^>]+>/g, '')
    .replace(/[ \t]+/g, ' ')
    .replace(/ +([.,;:!?])/g, '$1')
    .replace(/\n{3,}/g, '\n\n')
    .trim()
}

// A slash command keeps its name, a path goes, anything else reads as words.
function spokenCode(code: string): string {
  if (/^\/[\w:-]+$/.test(code)) return code.slice(1)
  if (code.includes('/')) return ''
  return code.replace(/_/g, ' ')
}

function endSentence(line: string): string {
  const trimmed = line.trim()
  return /[.!?:;,]$/.test(trimmed) ? trimmed : `${trimmed}.`
}

// cyrb53: enough to name a cache file, not a security hash.
export function hash(text: string): string {
  let h1 = 0xdeadbeef
  let h2 = 0x41c6ce57
  for (let i = 0; i < text.length; i++) {
    const c = text.charCodeAt(i)
    h1 = Math.imul(h1 ^ c, 2654435761)
    h2 = Math.imul(h2 ^ c, 1597334677)
  }
  h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507) ^ Math.imul(h2 ^ (h2 >>> 13), 3266489909)
  h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507) ^ Math.imul(h1 ^ (h1 >>> 13), 3266489909)
  return (4294967296 * (2097151 & h2) + (h1 >>> 0)).toString(36)
}
