<!-- ![alt text](.assets/Hammerspoon.png)

<p align="left" style="font-size: 1.5em;"><em>An extensible Hammerspoon configuration for quickly launching applications, and binding them to shortcuts for fast switching.</em></p> -->

<table>
  <tr>
    <td><img src="./.assets/Hammerspoon.png" alt="Hammerspoon" width="280"></td>
    <td>
      <h2 align="center" style="margin:0;"><em>A  Hammerspoon configuration for quickly launching applications, and binding them to shortcuts for fast switching.</em></h2>
    </td>
  </tr>
</table>

<br>

**This config provides:**
- App hotkeys: `Alt+Shift+1..N` to open/focus apps listed in `workspaceApps`.
- Workspace launcher: `Cmd+Alt+Ctrl+W` launches the whole workspace sequentially.
- Rebind hotkeys: `Cmd+Alt+Ctrl+R` rebinds the app hotkeys.
- Terminal toggle: `Alt+Escape` toggles between the terminal (`Ghostty` by default) and the previously focused app.
- Auto-fullscreen: tries to set each launched app to fullscreen after a short delay, with retries.

</br>

---
# Quick start
1. Clone this repo into `~/.hammerspoon`, or place it elsewhere then symlink the `hammerspoon-config` folder to `~/.hammerspoon`.
2. Reload Hammerspoon from the `Menu Bar` icon or open the Console and run `hs.reload()`.
3. Run the script with the defined shortcut. The first `N` apps come from the `workspaceApps` table in `init.lua`.
---

</br>

Files of interest
- `init.lua` — main configuration and the place to customize apps and timings.

Customization
- Edit `workspaceApps` (by app name or bundle ID). If an entry contains a dot (`.`) it is treated as a bundle ID.
- Change behavior in the `config` table at the top of `init.lua`:
  - `terminalApp` — logical name for your terminal (default: `Ghostty`).
  - `launch.delayBetweenApps` — seconds between launching each workspace app.
  - `launch.delayForFullscreen` — wait before attempting to fullscreen a window.
  - `launch.windowRetryCount` and `launch.windowRetryInterval` — retries and interval when waiting for an app's main window.
  - `alertDuration` — how long on-screen alerts are shown.

Keybindings (default)
- `Alt+Shift+1..N` — focus/launch apps from `workspaceApps` (also saves last app for toggle).
- `Alt+Escape` — toggle between terminal (bundle `com.mitchellh.ghostty`) and last app.
- `Cmd+Alt+Ctrl+W` — launch the full workspace sequence and rebind hotkeys.
- `Cmd+Alt+Ctrl+R` — rebind app hotkeys (useful after changes).

Troubleshooting
- If apps don't open/focus reliably, increase `windowRetryCount` or `delayBetweenApps`.
- If fullscreen attempts fail, increase `delayForFullscreen` so the app has time to finish launching.
- Confirm Hammerspoon has Accessibility and Automation permissions in System Settings.
- Check the Hammerspoon Console (menu ▸ Console) for logs — the config uses `hs.printf` messages prefixed with `[hs]`.
- If everything fails, feel free to open an issue. I'll get back to you as soon as time permits.

Notes
- Use bundle IDs for reliability when possible (e.g., `com.microsoft.VSCode` instead of `Code`).
- This config expects `Ghostty` as the terminal bundle `com.mitchellh.ghostty` by default — change `terminalApp` and/or the toggle logic in `init.lua` if you use a different terminal.

## License

Unless otherwise stated, everything in this repo is covered by the following copyright notice:

```plaintext
A macOS Hammerspoon configuration.
Copyright (C) 2025  Martín Cigorraga <cig0.github@gmail.com>

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License v3 or later, as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
