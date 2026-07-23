# Anti-AI-isms

The recognizable fingerprints of AI-generated text. Strip these from anything written in my voice. Prompting alone doesn't remove them, so do an explicit pass over the draft.

## Lexical: cut or replace

- Verbs: delve, leverage, harness, foster, underscore, showcase, bolster, elevate, streamline, unlock, empower, navigate (complexities)
- Adjectives: crucial, pivotal, robust, seamless, comprehensive, transformative, cutting-edge, meticulous, intricate, vibrant, nuanced, key
- Nouns: tapestry, landscape (abstract), realm, journey, testament, paradigm, synergy, myriad, plethora, beacon
- Phrases: "in today's fast-paced world", "it's worth noting", "it's important to note", "plays a vital role", "stands as a testament", "game changer", "diverse array", "let's unpack"

Replacement rule: the plainest word that survives. "Use" not "leverage", "important" not "crucial", "solid" not "robust".

## Structural

- "It's not just X, it's Y" and "Not only... but also" contrast frames
- Rule-of-three everywhere: adjective triads, three parallel phrases, three-item lists faking completeness
- Uniform paragraph and sentence lengths, no burstiness
- Bullet mania: bolded lead-in lists ("**Speed:** ..."), headers on short content, fragments where prose belongs
- Summary endings: "In conclusion", "In summary", "Ultimately", "Overall". End on a point, not a recap
- Tacked-on significance clauses: "...ensuring consistency", "...highlighting the importance of"
- Chat residue: "Great question!", "Certainly!", "I hope this helps"

## Tonal

- Relentless positivity and promotional register ("boasts", "renowned", "exciting")
- Hedging boilerplate ("arguably", "to some extent", "in many cases") with no actual position
- Symmetrical "on one hand / on the other" balance instead of an opinion
- Vague authority ("experts argue", "studies show") without a named source
- Inflating the significance of ordinary facts

## Punctuation & format

**Em-dashes: the loudest tell.** Default to a comma. Most em-dashes are dressing up an ordinary sentence that a comma handles fine, and the reflex to reach for one is itself the fingerprint. Rewrite instead of substituting: a full stop and a second sentence usually beats both. One per longer piece is a ceiling, not a quota, and it has to earn the interruption (a genuine aside, a hard pivot).

- Don't: "The fix works — but it slows down cold start."
- Do: "The fix works, but it slows down cold start."
- Also fine: "The fix works. Cold start gets slower."

Other format tells:

- Title Case Headers, emoji-per-bullet, bold on every line, horizontal rules between short sections
- Curly quotes pasted into plain-text contexts

## Tickets, PRs, commits

- Self-narrating preambles: "This PR introduces...", "This commit adds...", "This ticket covers..."
- Describing *what* changed (visible in the diff) instead of *why*
- "Comprehensive tests", "robust error handling" and other buzzword pairs
- Section scaffolding and exhaustive checklists on a 20-line change. Description scope must match diff scope
- Imperative mood, reason included, done

## What humanizes

- Vary sentence length hard: a 3-word sentence next to a 30-word one
- Concrete specifics over abstractions: real numbers, named things, lived detail
- Take a position and commit to it; answer rhetorical questions or cut them
- Keep natural imperfections: idioms, asides, a slightly clumsy phrase that sounds like speech
- Prose over lists unless the content is genuinely enumerable

## Sources

- https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing
- https://millennialmasters.net/p/how-not-to-sound-like-chatgpt
- https://github.com/tbhb/vale-ai-tells
- https://news.ycombinator.com/item?id=45272723
