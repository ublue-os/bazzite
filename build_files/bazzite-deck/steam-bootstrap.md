# Steam bootstrap

Deck images ship `/usr/share/gamescope-session-plus/bootstrap_steam.tar.zst`,
a ready-to-run Steam client that is unpacked into `~/.local/share/Steam` the
first time Steam starts (by gamescope-session-plus in Game Mode, or by
`bazzite-steam` in Desktop Mode). Because it already contains a verified
client, Steam reaches the login screen without a network connection.

`.github/workflows/steam_bootstrap.yml` builds the archive and uploads it as
the `steam-bootstrap` Actions artifact. Deck jobs in `build.yml` download the
artifact from the newest successful run into `steam_bootstrap/`, which the
`Containerfile` mounts for the deck build script.

## Updating

The workflow runs on the 1st of every month, when
`build_files/tools/steam-bootstrap` changes, and on demand from the Actions
tab. It downloads the manifest Valve currently serves to Steam Deck stable
clients and builds the archive with `build_files/tools/steam-bootstrap`. The
next image build picks it up.

Artifacts expire after 90 days, so the monthly run also keeps one available.
If none is (the workflow kept failing, or a local build without one), the deck
build script makes the archive itself from Valve's current manifest. That
takes a minute or two longer and needs Valve's CDN to be reachable.

The archive is reproducible, so a run that finds the same client version
produces the same file (as long as the runner's zstd is unchanged) and deck
users download nothing new. When the version changes, deck users download the
bootstrap layer again (about 600 MB).

To check a new bootstrap, build a deck image and boot it with no network. Steam
should reach the login screen, and `~/.local/share/Steam/logs/bootstrap_log.txt`
should end with `Verification complete` and contain no `Downloading manifest`
line.

To build the archive locally, or to reuse one across local image builds:

```sh
curl -o manifest https://client-update.steamstatic.com/steam_client_steamdeck_stable_steamrt64
./build_files/tools/steam-bootstrap manifest steam_bootstrap/bootstrap_steam.tar.zst
```

## Where the pieces come from

Steam logs where it fetches updates from. In `logs/bootstrap_log.txt` of any
Steam install:

```text
Downloading manifest: https://client-update.fastly.steamstatic.com/steam_client_steamrt64
```

Manifests live at `https://client-update.steamstatic.com/steam_client_<channel>_<platform>`.
The channel is empty for stable desktop, or `publicbeta`, `steamdeck_stable` or
`steamdeck_publicbeta`. The platform is `steamrt64` on every channel, stable
included; `ubuntu12` is the old 32-bit client that the previous bootstrap
shipped. Each package entry's `file` is downloaded from the same host, and
`steam-bootstrap` checks it against the entry's `sha2`. Bazzite starts Steam
with `-steamdeck`, so it reads the `steamdeck_stable` channel.

A Steam install records what it has unpacked in `package/`, next to a copy of
the manifest. `steam-bootstrap` writes the same files for both the
`steam_client_steamrt64` and `steam_client_steamdeck_stable_steamrt64` names.
The `.installed` file has one `path,size;mtime;crc32` line per file
(directories have size `-1` and crc `0`, symlinks size `-2`), then
`OSVER=-183`, `VERSION=3`, and `SHA1=` with the uppercase SHA-1 of everything
above it. When this file is missing or wrong, Steam refuses to start offline
with "Steam needs to be online to update".

If a new bootstrap stops working offline, compare against a real install that
runs the same client version (the `version` in its `package/*.manifest` must
match):

```sh
tar -xf bootstrap_steam.tar.zst -O Steam/package/steam_client_steamrt64.installed | sort > bootstrap.installed
sort ~/.local/share/Steam/package/steam_client_steamrt64.installed > real.installed
diff bootstrap.installed real.installed
```

Only the `SHA1=` line should differ, because the two files list the same
entries in a different order.
