# Clipse Configuration TODOs

## Image Preview with Kitty Graphics Protocol

**Status:** Not implemented

**Goal:** Enable proper image preview in clipse using the Kitty graphics protocol.

### Background

Clipse supports three image display modes:
- `basic` - Shows basic image info (current)
- `kitty` - Uses Kitty graphics protocol for inline images
- `sixel` - Uses Sixel protocol

Ghostty supports the Kitty graphics protocol, so `kitty` mode should work.

### Steps to Implement

1. Change `imageDisplay.type` from `"basic"` to `"kitty"` in `config.json`
2. Test with various image types (PNG, JPEG, etc.)
3. Adjust `scaleX`, `scaleY`, and `heightCut` values if needed for proper sizing
4. If issues persist, check:
   - Ghostty's Kitty graphics protocol support/settings
   - Terminal size and scaling
   - clipse version (may need updates)

### References

- [Clipse GitHub](https://github.com/savedra1/clipse)
- [Kitty Graphics Protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)
- [Ghostty Documentation](https://ghostty.org/docs)
