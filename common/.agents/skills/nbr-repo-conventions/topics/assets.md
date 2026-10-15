# Assets

- Import application images from `src/assets/` so the bundler fingerprints them. Files that document metadata or a manifest
  consume use public URLs, with a build step that serves them there.
- Convert photographs to WebP, with the long edge at 2000px or less:

  ```sh
  magick source.png -resize '2000x2000>' -quality 80 -define webp:method=6 src/assets/name.webp
  ```

- Use PNG when the image needs alpha or exact pixels.
- Motion in docs and release notes is an animated WebP recorded with the `nbr-record-clip` skill.
- In-app icons, logos, and line art are inline SVG components, so they inherit `currentColor` and follow the theme.

These rules apply to assets added or touched. Existing files keep their format.
