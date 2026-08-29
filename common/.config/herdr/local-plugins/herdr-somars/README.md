# Herdr Somars

A local Herdr wrapper for [Somars](https://github.com/skammer/somars), a terminal-based SomaFM player.

The plugin keeps Somars in a persistent Herdr tab and opens a popup attached to that pane. A compiled Go relay forwards Somars input and consumes `Alt+R` to close the view while playback continues; pressing it again reattaches to the same Somars session. Pressing Somars’ `q` exits the player and closes the popup.

Run `dots link` to build the relay into `common/.local/bin/` before using the plugin.

Somars is created by [skammer](https://github.com/skammer/somars) and distributed under the MIT License. This wrapper is not affiliated with SomaFM.
