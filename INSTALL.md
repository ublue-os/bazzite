# Installing bazzite_mango on a new machine

Bazzite KDE from the official ISO, then a switch to this image. KDE Plasma
stays available at the login screen as a fallback the whole way through.

Bazzite's download server and GitHub's container registry (`ghcr.io`) refuse
connections from Syria, so **every download step below needs a VPN.**

## 0. Before you wipe the old machine

Copy these to the external disk. They aren't in the repo:

- [ ] `~/git/bazzite_mango/cosign.key`: the private signing key. It's also in
      the `SIGNING_SECRET` GitHub secret, but GitHub can't show it to you
      again.
- [ ] `~/.config/mango/weather-location`. Kept out of the public repo; re-enter it from the bar's weather popup, or copy it back.
- [ ] The Mullvad `.rpm` and the ExpressVPN installer, already on the disk.
- [ ] The Bazzite ISO, written to a USB stick.
- [ ] Anything else from `~` you want to keep (SSH keys for GitHub:
      `~/.ssh/`).

## 1. Install Bazzite

1. Boot the USB stick and run the installer.
2. If Secure Boot is on, the first boot shows a blue MOK screen: choose
   **Enroll MOK → Continue → Yes** and type the password `universalblue`.
3. Finish the first-boot setup and log in to KDE.

## 2. Get a VPN running

Bazzite's system files are read-only, so a local RPM is layered onto the system
with `rpm-ostree`, not installed with `dnf`. Plug in the external disk, then:

```bash
sudo rpm-ostree install /run/media/$USER/<disk>/MullvadVPN-*.rpm
systemctl reboot
```

After the reboot, open Mullvad, log in and connect. Check it works:

```bash
curl -s https://www.cloudflare.com/cdn-cgi/trace | grep loc=   # should not say SY
```

> If `rpm-ostree install` fails (Mullvad installs into `/opt`, which atomic
> Fedora can trip over), note the error and try the ExpressVPN installer
> instead.

## 3. Switch to bazzite_mango

With the VPN connected:

```bash
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/pauljamesharper/bazzite_mango:latest
systemctl reboot
```

This downloads about 7 GB. `rebase` (rather than `bootc switch`) keeps the
layered Mullvad package. "unverified" skips the signature check, which is
normal for a custom image.

Check it took:

```bash
rpm-ostree status    # the booted (●) entry should say pauljamesharper/bazzite_mango
```

## 4. Set up Mango

As your normal user (not sudo):

```bash
ujust mango-setup   # dotfiles, themes and wallpapers into ~/.config/mango
ujust mango-apps    # optional: Firefox, GIMP, OBS, Discord Flatpaks (VPN on)
```

Optionally restore the weather location:

```bash
cp /run/media/$USER/<disk>/weather-location ~/.config/mango/
```

Log out, choose **Mango** in the session menu at the bottom of the login
screen, and log in.

| Keys | Does |
|---|---|
| `Super + /` | keybinding cheatsheet |
| `Super + Space` | app launcher |
| `Super + Return` | terminal |
| `Super + Shift + p` | wallpaper picker (re-themes everything) |
| `Super + Ctrl + Shift + Space` | Omarchy theme menu |
| `Super + Shift + m` | quick settings |

## 5. Restore git and GitHub

```bash
cp -r /run/media/$USER/<disk>/.ssh ~/ && chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*
git config --global user.name "Paul Harper"
git config --global user.email harper.paul.j@gmail.com
git clone git@github.com:pauljamesharper/bazzite_mango.git ~/git/bazzite_mango
cp /run/media/$USER/<disk>/cosign.key ~/git/bazzite_mango/   # git ignores it
```

## Updates

- GitHub rebuilds the image every day on top of the latest Bazzite DX.
  The machine downloads it in the background, so **the VPN needs to be
  connected for updates to arrive.** `ujust update` updates everything
  manually.
- `~/.config/mango` is your copy and never changes on its own. After changing
  the dotfiles in the repo, merge to `main`, wait for the build, update, then
  run `ujust mango-setup` again. It backs up the old config first.

## If something goes wrong

- **Mango won't start or looks broken:** log out and pick **Plasma**
  instead. Everything else still works.
- **The new image won't boot:** choose the previous entry in the boot menu,
  or `sudo rpm-ostree rollback && systemctl reboot`.
- **Back to plain Bazzite DX:**
  `sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-dx:stable`
- **Bar glitches after a change:** `Super + Shift + m` → Restart bar.
