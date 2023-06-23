# Bazzite

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml)

Bazzite is an OCI that serves as an alternative OS for the [Steam Deck](https://www.steamdeck.com/), and a ready-to-game SteamOS-like for desktop computers.

## Usage

TODO

## Features

- Built from a base [ublue-os/kinoite](https://github.com/ublue-os/main) or [ublue-os/kinoite-nvidia](https://github.com/ublue-os/nvidia) image
- Initial setup wizard provides [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), and an assortment of useful Flatpaks.
- Adds ported versions of Valve's Steam Deck packages
- Ships with [Distrobox](https://github.com/89luca89/distrobox) installed and ready to use
- Desktop variant uses [ublue-os/bazzite-arch](https://github.com/ublue-os/bazzite-arch) [![build-bazzite-arch](https://github.com/ublue-os/bazzite-arch/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite-arch/actions/workflows/build.yml) in Distrobox to run Steam and other gaming workloads.
- Adds h264 decoding out of the box via [RPM Fusion](https://rpmfusion.org/)
- Supports [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX) and [vkBasalt](https://github.com/DadSchoorse/vkBasalt) out of the box
- Comes with services for automatic system, distrobox, and flatpak updates.
- BTRFS by default, including the SD card
- Built in duperemove services
- Pre-tuned for gaming workloads
- Matches SteamOS as closely as possible
  
## Copr

Ported SteamOS and ChimeraOS packages, among others used by Bazzite, are built on Copr in [this repo](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/).

|Package|Status|
|---|---|
|gamescope|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope/status_image/last_build.png?)|
|gamescope-session|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session/status_image/last_build.png?)|
|jupiter-fan-control|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)|
|jupiter-hw-support|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support/status_image/last_build.png?)|
|jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)|
|python3-hid|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/python3-hid/status_image/last_build.png?)|
|ryzenadj|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ryzenadj/status_image/last_build.png?)|
|sddm-sugar-steamOS|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sddm-sugar-steamOS/status_image/last_build.png?)|
|steamdeck-kde-presets|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)|
|steamdeck-kde-themes|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-themes/status_image/last_build.png?)|
|wallpaper-engine-kde-plugin|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/wallpaper-engine-kde-plugin/status_image/last_build.png?)|

Additionally, the following packages are used from other Copr repos:
|Package|Status|
|---|---|
|[hl2linux-selinux](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/package/hl2linux-selinux/status_image/last_build.png?)|
|[latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)|

## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
