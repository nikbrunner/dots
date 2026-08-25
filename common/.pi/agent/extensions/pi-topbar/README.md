# Pi Topbar

Pi Topbar renders a sticky terminal overlay with configured provider sections.

## Configuration

Edit `config.json`:

- `shortcut` cycles compact, expanded, and hidden views.
- `maxHeight` caps the combined expanded content.
- `gap` adds blank rows between visible provider sections.
- `padding` controls the top, right, bottom, and left inset around the content.
- `border-bottom` adds a bottom border and reserves one row from `maxHeight` when enabled.
- `providers` selects providers and their compact `maxLines` values.
- `providers[].summary.enabled` turns the conversation-state progress summary on or off.
- `providers[].summary.model` selects a Pi model using `provider/model` syntax.
- `providers[].summary.minIntervalMs` throttles summary calls after settled turns. User prompts always trigger an immediate update.
- `providers[].summary.maxTokens` limits the summary response.

Compact mode uses each provider's `maxLines`. Expanded mode shows the provider output up to `maxHeight`.

The bundled providers are `session-name` and `conversation-state`. The conversation state shows a generated, stable `Focus` goal for the latest user prompt and a `Now` line that updates immediately when work starts, then refreshes with throttled progress summaries.
