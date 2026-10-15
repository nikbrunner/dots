---
name: nbr-record-clip
description:
  "Record motion as a smooth looping animated WebP. Use when a still screenshot cannot show the behavior, or when asked to
  record, film, or animate a terminal or Neovim session, a web page, or a native app window."
argument-hint: "<terminal | browser | native> [what to show]"
allowed-tools: Read Write Bash
---

# Record a clip

A clip is an animated WebP. Output WebP only: GitHub shows a repo-hosted mp4 as a broken image, and a GIF is limited to
256 colors and centisecond frame timing.

| Lane     | Shows                                | Read                                               |
| -------- | ------------------------------------ | -------------------------------------------------- |
| Terminal | A CLI, TUI, or Neovim session        | [`references/terminal.md`](references/terminal.md) |
| Browser  | A web page, dev server, or Storybook | [`references/browser.md`](references/browser.md)   |
| Native   | A desktop app window, such as Livery | [`references/native.md`](references/native.md)     |

## Workflow

1. Pick the lane and read its reference. Script the motion so each state holds about a second, long enough to read.
2. Record into a fresh directory in the scratchpad; the lane's reference writes `<out>.webp`.
3. Encode lossless first, as below. Flat UI and terminal text compress best that way. When the clip is too large, encode
   again with `-quality 80` in place of `-define webp:lossless=true` and keep the smaller file. Still too large: shorten the
   motion, or keep every second frame and encode with `1x<fps/2>`.
4. Split the clip into frames in the scratchpad and look at four or five across it:

   ```sh
   magick <clip>.webp -coalesce <dir>/f%05d.png
   ```

   The clip is done when the sampled frames show only the subject, every state from step 1 appears in order, and the file
   is at most 2 MB.

## Encode

Every lane ends in this command, with `<fps>` matching the capture:

```sh
magick -delay 1x<fps> -loop 0 '<frames>/f*.png' -define webp:lossless=true -define webp:method=4 <out>.webp
```

`magick` merges identical consecutive frames into one longer frame, so pauses cost almost nothing.
