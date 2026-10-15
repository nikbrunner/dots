# Browser lane

[`scripts/record-browser.mjs`](../scripts/record-browser.mjs) loads a URL into a frame of fixed size and steps a virtual
clock 20 ms per frame, then encodes the clip. Before each screenshot it pauses every CSS animation and transition and sets
it to the clock, so transitions show every in-between state however long a screenshot takes. It needs `playwright`
resolvable from the working directory and `magick` on the path, and never starts the app: ask the person to start the dev
server or Storybook when nothing is listening.

Animation driven by JavaScript timers or `requestAnimationFrame` runs on the real clock, so its frames may jump. When they
do, record again, or name the jump in the report.

## Steps

A JSON array of actions run in order:

- `{ "wait": ms }` advances the clock, holding the state for that long;
- `{ "resize": [from, to, ms] }` eases the frame's width between two pixel values;
- `{ "click": "<selector>" }` clicks inside the page;
- `{ "press": "<key>" }` presses a key, such as a shortcut the page binds.

```json
[
  { "wait": 700 },
  { "resize": [1280, 390, 2400] },
  { "wait": 700 },
  { "click": "[aria-label='Open menu']" },
  { "wait": 1200 },
  { "resize": [390, 1280, 2400] },
  { "wait": 700 }
]
```

A looping CSS animation is one `wait` the length of its cycle, cropped to the element with `--clip`.

## Record

From the project root:

```sh
node <skill-dir>/scripts/record-browser.mjs --url <url> --steps <steps.json> --out <clip>.webp
```

`<skill-dir>` is the directory holding this skill's `SKILL.md`.

| Flag         | Sets                                                     | Default    |
| ------------ | -------------------------------------------------------- | ---------- |
| `--viewport` | Stage size, `WxH`                                        | `1280x800` |
| `--scheme`   | `light` or `dark`, for the page and the backdrop         | `light`    |
| `--clip`     | Selector whose box, plus a 24 px margin, frames the clip | full stage |
| `--fps`      | Frames per second of the clock and the encode            | `50`       |
| `--scale`    | Device scale factor                                      | `1`        |
| `--quality`  | `lossless`, or a lossy quality such as `80`              | `lossless` |

For a Storybook story, the URL is `http://localhost:<port>/iframe.html?id=<story-id>&viewMode=story`; `index.json` on the same
port lists the story IDs. The script prints the frame count, length, and size.
