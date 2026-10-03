# bazzite_mango

A personal [Bazzite DX](https://dev.bazzite.gg/) image with the
[MangoWC](https://github.com/mangowm/mango) Wayland compositor and a quickshell
rice, built on top of KDE Plasma. KDE stays installed as a fallback session.

## The aim

This repo started as an idea: take Drew's
[mangowc-setup](https://justaguy.dev/drew/mangowc-setup) and make it an
immutable, self-updating OS image.

mangowc-setup is a rice script for Debian 13. One script installs mango
(dwm-style tags and layouts, plus scenefx blur, shadows and rounded corners), a
quickshell bar, rofi, dunst, awww wallpapers and their supporting tools, then
copies in a config. I've used it on Debian and built my own changes on top of it.

This image keeps that desktop but changes how it's delivered:

| | mangowc-setup | bazzite_mango |
|---|---|---|
| Base | Debian 13 (trixie) | Bazzite DX (Fedora Atomic, KDE Plasma) |
| Install | `./install.sh` runs apt on your system | `bootc switch` to a prebuilt image |
| Packages | apt, plus Drew's butterrepo for mango/wlroots/scenefx/quickshell | dnf at image build time, plus COPRs |
| Updates | `apt full-upgrade` | the image rebuilds daily on GitHub Actions; Bazzite updates itself in the background |
| Rollback | — | boot the previous image from the boot menu |
| Fallback desktop | — | KDE Plasma, at the login screen |
| Gaming | — | everything Bazzite ships: Steam, kernel, drivers, HDR/VRR |
| Dev tools | — | everything Bazzite DX ships: Docker/Podman, VS Code, distrobox |

### What's mine, not Drew's

The dotfiles are my version of Drew's config, not his stock one:

- Omarchy themes: 22 palettes picked from a menu (`theme-menu` / `theme-set`)
- A DNS provider picker in the network panel (`scripts/dns`)
- An ExpressVPN bar module (hidden unless `expressvpnctl` is installed)
- Bluetooth, Display, Power and Pomodoro bar modules, a command `menu`, and `ws-send`
- App keybindings for my apps

## What's in the image

Translated from mangowc-setup's package list:

| Purpose | Packages | Source |
|---|---|---|
| Compositor | `mangowc` (with scenefx), Xwayland | COPR `gregoryloscombe/mangowc` |
| Bar | `quickshell` 0.3 | COPR `errornointernet/quickshell` |
| Wallpaper daemon | `awww` | COPR `dpavle/wallpaper-utils` |
| GTK / display settings | `nwg-look`, `nwg-displays` | COPR `yselkowitz/nwg-shell` |
| Launcher, notifications | `rofi`, `dunst`, `libnotify` | Fedora |
| Screenshots, clipboard | `grim`, `slurp`, `wl-clipboard`, `cliphist` | Fedora |
| Idle / lock | `swayidle`, `swaylock`, `wlopm` | Fedora |
| Portals | `xdg-desktop-portal-wlr`, `-gtk` | Fedora |
| Bar toggles | `pamixer`, `playerctl`, `brightnessctl`, `wlsunset`, `network-manager-applet`, `blueman` | Fedora |
| Apps | `kitty`, `nautilus`, `geany`, `eog`, `pavucontrol`, `gnome-pomodoro`, `wdisplays` | Fedora |
| Fonts | JetBrainsMono, FiraCode and SauceCodePro Nerd Fonts, Font Awesome, Noto Color Emoji | Nerd Fonts releases, Fedora |
| Themes | Orchis (GTK, Nord tweak) and Colloid icons (8 dark variants) | vinceliuice, built at image build time |
| Wallpapers | [drewgrif/wallpapers](https://github.com/drewgrif/wallpapers), Omarchy theme backgrounds | Git, at image build time |

Changes from the Debian version:

- **No display manager installer.** Bazzite's SDDM lists Mango next to Plasma.
- **No `power-profiles-daemon`.** Bazzite's `tuned-ppd` provides the same `powerprofilesctl` interface.
- **GUI apps are Flatpaks.** The Firefox, GIMP, OBS and Discord keybindings use `flatpak run`; `ujust mango-apps` installs them.
- **Updates go through `ujust update`.** The bar's update counter counts a pending system image plus Flatpak updates, instead of apt upgrades.
- **`mango-session`** (from butterrepo's packaging) is included, so `~/.config/mango/env` is still sourced at login.

## Layout

```
Containerfile                    FROM bazzite-dx:stable, runs build.sh
build_files/build.sh             COPRs, packages, fonts, themes, wallpapers, sanity checks
system_files/                    copied onto / in the image
  usr/bin/mango-session          login wrapper: sources ~/.config/mango/env, execs mango
  usr/bin/bazzite-mango-setup    copies the dotfiles into ~/.config/mango
  usr/share/bazzite-mango/config the dotfiles (mango, quickshell, rofi, dunst, kitty, scripts)
  usr/share/ublue-os/just/60-custom.just   ujust mango-setup / mango-apps
  usr/share/wayland-sessions/mango.desktop
  usr/share/xdg-desktop-portal/mango-portals.conf
```

## Install

Step-by-step for a fresh machine: [INSTALL.md](INSTALL.md). In short, from an existing Bazzite install (any variant):

```bash
sudo bootc switch ghcr.io/pauljamesharper/bazzite_mango:latest
systemctl reboot
```

Then, as your user:

```bash
ujust mango-setup   # dotfiles, themes and wallpapers into ~/.config/mango
ujust mango-apps    # optional: Firefox, GIMP, OBS, Discord Flatpaks
```

Log out and pick **Mango** at the login screen. Press `Super + /` for keybindings.
To go back, run `sudo bootc switch ghcr.io/ublue-os/bazzite-dx:stable`, or pick
the previous deployment from the boot menu.

## Build it yourself

```bash
just build          # podman build, tagged bazzite_mango:latest
```

GitHub Actions builds every push to `main`, plus a daily build that picks up
Bazzite updates. It pushes to `ghcr.io/pauljamesharper/bazzite_mango`. The
image is signed with cosign: generate a key pair with
`COSIGN_PASSWORD="" cosign generate-key-pair`, commit `cosign.pub`, and store
`cosign.key` as the `SIGNING_SECRET` repository secret. Never commit
`cosign.key`.

ISO and disk images can be built with the `build-disk` workflow, using the
configs in `disk_config/`.

## Credits

- [Drew / JustAGuy Linux](https://justaguy.dev/drew): mangowc-setup, the quickshell bar, and the scripts these dotfiles grew out of
- [mangowm/mango](https://github.com/mangowm/mango) and [scenefx](https://github.com/wlrfx/scenefx)
- [Universal Blue](https://universal-blue.org/) / [Bazzite](https://bazzite.gg/) and their [image-template](https://github.com/ublue-os/image-template)
- [Omarchy](https://github.com/basecamp/omarchy): themes
- [vinceliuice](https://github.com/vinceliuice): Orchis and Colloid
- [pjgeutjens/omarchy-expressvpn](https://github.com/pjgeutjens/omarchy-expressvpn): the vendored VPN state machine

## License

The dotfiles in `system_files/usr/share/bazzite-mango/config/` are derived from
mangowc-setup and stay under its **GPL-2.0** license (see the `LICENSE` file in
that folder). The rest of the repo, the build scaffolding from Universal Blue's
image-template, is **Apache-2.0** (see `LICENSE`).
