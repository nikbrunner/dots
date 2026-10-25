# play

`/play` reads the last reply aloud. Haiku turns the reply into a script for listening (no code, URLs or paths read out), ElevenLabs speaks it with v4 Turbo and the Sadie voice, and mpv plays it with loudness normalization. A row in the band above the prompt shows the state and the controls.

| Command       | Does                                                    |
| ------------- | ------------------------------------------------------- |
| `/play`       | Read the last reply; replies over 3,000 chars ask first |
| `/play all`   | Read it whatever its length                             |
| `/play pause` | Pause or resume                                         |
| `/play back`  | Back 10 seconds                                         |
| `/play stop`  | Stop                                                    |

Audio is cached in `~/.cache/claude-play/`, keyed on the reply, model and voice: a replay costs nothing.

Needs the ElevenLabs API key in Proton Pass at `pass://Nik/.env/ELEVENLABS_API_TOKEN` (read once per session, held in memory), plus `pass-cli`, `curl`, `mpv` and `nc`.

## Cost

Each reply costs two things:

- **Haiku** rewrites the reply into a script, billed to the Claude account the session runs on. A few thousand tokens per reply.
- **ElevenLabs** bills every character of the script, in plan credits.

How many credits a character costs depends on how the request is authenticated:

| Request                         | v4 Turbo           | v4                 |
| ------------------------------- | ------------------ | ------------------ |
| API key (what the mod uses)     | 0.2 credits / char | 0.4 credits / char |
| `elevenlabs` CLI or the web app | 1 credit / char    | 1 credit / char    |

The `elevenlabs` CLI signs in through the browser and is billed like the web app. Measured on the account: 75 chars through the API key billed 15 credits, 80 chars through the CLI billed 80. The API rates match ElevenLabs' list prices of $0.04 (v4 Turbo) and $0.08 (v4) per 1,000 characters.

A reply is usually 1,000–1,500 chars once Haiku has scripted it, so about 200–300 credits on v4 Turbo. Starter's 30,000 credits a month read about 100–150 replies; v4 halves that.

**Beyond the plan:** pay-as-you-go top-ups (Developers → Top Up, $5 minimum, prepaid, expire after 12 months) start once the plan's credits are spent, at the same API rates. Usage pauses at a $0 balance; nothing is billed after the fact. An optional monthly spend cap lives in the same place.

**Checking what was spent:** `elevenlabs history list --format json | jq -r '.history[] | [.model_id, (.character_count_change_to - .character_count_change_from)] | @tsv'` lists each generation with the credits it took; `elevenlabs user subscription get --format json | jq '{character_count, character_limit}'` shows the month's total.

Sources: [API pricing](https://elevenlabs.io/pricing/api), [new pricing and PAYG announcement](https://elevenlabs.io/blog/weve-lowered-api-agents-pricing-and-introduced-pay-as-you-go), [pay-as-you-go docs](https://elevenlabs.io/docs/overview/administration/pay-as-you-go).
