# Rex

Rex config lives in two places. The Lua in this folder (`init.lua` and the modules it requires) is read by the Rex server, so it works in every client. `shortcuts.json` holds the Mac app's Settings → Shortcuts and works in the Mac app only. It lives in dots at `macos/Library/Application Support/com.superlogical.rex/Shortcuts/` and is linked into `~/Library/Application Support/com.superlogical.rex/`.

## Where a binding goes

- A key for an action, with or without arguments, goes in `shortcuts.json`. Set it in Settings → Shortcuts and the app writes it into dots through the link.
- A key that decides at press time whether Rex or the focused program gets it is a `rex.bind` with a Lua function in `keys.lua`. Returning `false` hands the key to the program.
- New behavior is a `rex.action` in a module, and its key goes in `shortcuts.json`.

Shortcuts from the app take priority over `rex.bind` for the same key, and neither `rex keymap` nor `rex.bindings()` lists them. Removing a default shortcut in Settings adds an entry under `removals`.

## Files

| File          | Holds                                                        |
| ------------- | ------------------------------------------------------------ |
| `init.lua`    | The `require`s                                               |
| `panes.lua`   | Helpers the modules share: `cwd`, every pane, jump to a pane |
| `keys.lua`    | `ctrl+hjkl` pane moves that skip Neovim, `alt+c` shell clear |
| `popups.lua`  | The `popup_*` actions                                        |
| `agents.lua`  | `agent_next`, `agent_previous`, `bob_toggle`                 |
| `bob_ask.lua` | `bob_ask`, the palette question Bob asks Nik                 |

## Working on it

- Lua changes take effect with `rex config reload` or Reload Config in the palette.
- The app holds `shortcuts.json` in memory and rewrites the whole file on every change in Settings. Quit Rex before editing it by hand, and start it again afterwards.
- `rex actions` lists the server's action names. The app's actions (palette, tabs, sidebar, settings, navigation) come from its client:

  ```sh
  rex -C "$(rex client ls --json | jq -r '.clients[] | select(.info.kind == "app") | .client_id' | head -1)" actions
  ```
