# quickshell shell for mango

The same desktop shell as the dwm / bspwm / openbox setups — bar, popups,
wallpaper-driven theming, and the network app — with a mango backend.
Nothing here touches X11: mango is a Wayland compositor and the bar is a
wlr-layer-shell panel.

Launch: `qs -p ~/.config/mango/quickshell -d -n` (config.conf's exec-once
does this), or `scripts/bar restart|log` which handles the `-p` flag.

## WM-specific files (everything else is shared verbatim with the other ports)

- `Wm.qml` — mango backend. One `mmsg watch all-monitors` stream (JSON,
  one line per state change, snapshot on connect) supplies tags,
  occupancy, urgency, focused title and layout. Actions go through
  `mmsg dispatch`. `scripts/mango-ipc` wraps mmsg and finds the socket
  when MANGO_INSTANCE_SIGNATURE is missing from the environment.
- `Bar.qml` — no Follow module (mango has no window-follow toggle).
- `LayoutPicker.qml` — the fourteen mango layouts as glyph tiles
  (`setlayout,<name>`); inner gap via `setoption,gappih/gappiv`
  (persisted to `mango-gaps`, re-applied by Wm.qml on start); outer gaps
  via `setoption,gappoh/gappov`, always equal to the bar's edge inset
  (`Theme.edgeInset`, 8px scaled by `Theme.autoScale` — 1.0 at 1080p,
  1.33 at 1440p, 2.0 at unscaled 4K) so windows float like the bar; a
  config reload resets both to config.conf, so `scripts/mango-reload`
  (Super+Shift+r, wallpaper-theme) reloads and then calls the `wm`
  IpcHandler in shell.qml to push them back;
  master width / count via the relative
  `setmfact` / `incnmaster` dispatches, tracked in Wm.qml since mango
  exposes no getter. Table in Wm.qml mirrors `src/layout/layout.h`.
  Effects toggles (blur / shadows / animations) and the border-width
  and unfocused-opacity sliders (`setoption,borderpx` /
  `setoption,unfocused_opacity`) go through `setoption` and persist
  together to `mango-effects` as key=value lines; with no file the bar
  pushes nothing and config.conf's values stand, so Wm.qml's defaults
  mirror config.conf. `mango-reload` re-applies these after the gaps.
  Unfocused opacity reaching windows that are already open needs
  mangowc 0.14.4-6 or newer (butterrepo; downstream patch) — upstream
  only applies it to windows opened after the change.
- `Popout.qml` — the card goes slightly translucent while blur is on
  (mango's `blur_layer` frosts what's behind it), solid when it's off.
- `TogglePill.qml` — the quick-settings pill, shared by the command
  menu and the picker's Effects row.
- `Sys.qml` — caps lock read from `/sys/class/leds/*capslock`, popups
  always card-only (`composited: false`).
- `Commands.qml` — keep-awake is a `systemd-inhibit --what=idle` holder
  process (swayidle watches logind for idle inhibitors, so this also
  keeps the monitor from powering down); night light is wlsunset; the
  updates terminal is kitty; screen off is `scripts/screen-off`, a
  one-shot swayidle that powers the outputs down and brings them back on
  the first input (a bare `wlopm --off` would stay dark until the login
  swayidle's own 15-minute resume).
- `Screenshot.qml` — `scripts/screenshot` (grim + slurp, clipboard).
- `VolumePopup.qml` — right-click on Volume: slider plus a sink picker
  (every PipeWire output, click to make it the default) and a
  pavucontrol row. Reads and writes through Quickshell's Pipewire
  service, so it follows changes made anywhere else.
- Tail of `scripts/wallpaper-theme` — mango: writes `theme.conf`
  (focus/border/urgent/root colours, sourced by config.conf) and
  `reload_config`; swaybg replaces the wallpaper and the config.conf
  exec-once line is rewritten.

Notifications are dunst (Wayland-native via layer-shell), so the
NotifyPopup / Bell / DND code is byte-identical to the X11 ports.

## Known gaps

- Popups are card-only xdg-popups: click-outside close is not available,
  Escape and the module's own button close them.
- Single-monitor state: Wm.qml follows the focused output.
