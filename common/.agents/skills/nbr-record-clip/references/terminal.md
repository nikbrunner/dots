# Terminal lane

[VHS](https://github.com/charmbracelet/vhs) types a tape into a headless terminal and renders every frame 20 ms apart,
however slow the machine. Write raw frames: VHS's own gif, mp4, and webm outputs cap at 25 fps.

## Tape

```text
Output frames/
Set Shell zsh
Set FontSize 22
Set Width 1200
Set Height 600
Set Framerate 50
Set TypingSpeed 60ms

Hide
Type "cd ~/repos/nikbrunner/mdn.nvim && clear"
Enter
Show

Type "nvim README.md"
Enter
Sleep 1s
```

- `Hide` and `Show` keep setup out of the clip.
- A Neovim session loads the person's own config. To show one plugin alone, run `nvim --clean -u <init.lua>`.

Run it from a fresh scratchpad directory:

```sh
vhs demo.tape
```

## Compose

`frames/` holds two layers per frame, `frame-text-NNNNN.png` and `frame-cursor-NNNNN.png`, without padding. Overlay them and
pad with the terminal background, then encode as in [`SKILL.md`](../SKILL.md#encode) with `<fps>` 50 and `<frames>`
`composed`:

```sh
bg=$(magick frames/frame-text-00001.png -format '%[hex:p{0,0}]' info:)
mkdir composed
ffmpeg -loglevel error -framerate 50 -i frames/frame-text-%05d.png -framerate 50 -i frames/frame-cursor-%05d.png \
  -filter_complex "[0][1]overlay,pad=iw+80:ih+80:40:40:color=0x$bg" composed/f%05d.png
```
