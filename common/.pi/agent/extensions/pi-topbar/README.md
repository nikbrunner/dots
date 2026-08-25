# Pi Topbar

Pi Topbar renders a sticky terminal overlay with configured provider sections.

## Configuration

Edit `config.json`:

- `shortcut` cycles compact, expanded, and hidden views.
- `maxHeight` caps the combined expanded content.
- `gap` adds blank rows between visible provider sections.
- `providers` selects providers and their compact `maxLines` values.

Compact mode uses each provider's `maxLines`. Expanded mode shows the provider output up to `maxHeight`.

The bundled providers are `session-name` and `last-response`.
