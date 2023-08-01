<p align="center">
  <img src="/repo_content/logo.png?raw=true" alt="Bazzite Logo"/>
</p>
<p align="center">
  <img src="/repo_content/text_logo.png?raw=true" alt="Bazzite"/>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml)
[![build-bazzite-arch](https://github.com/ublue-os/bazzite-arch/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite-arch/actions/workflows/build.yml)

## About & Features

Bazzite is an OCI image that serves as an alternative operating system for the [Steam Deck](https://www.steamdeck.com/), and a ready-to-game SteamOS-like for desktop computers and living room home theater PCs. 

Bazzite is built from [ublue-os/main](https://github.com/ublue-os/main) and [ublue-os/nvidia](https://github.com/ublue-os/nvidia) using [Fedora](https://fedoraproject.org/) technology, which means expanded hardware support and built in drivers are included. Additionally, Bazzite adds the following features: 

- Proprietary Nvidia drivers pre-installed.
- Full hardware accelerated codec support for H264 decoding.
- Full support for AMD's ROCM OpenCL/HIP runtimes.
- [xpadneo](https://github.com/atar-axis/xpadneo) driver for wireless Xbox One controllers.
- Full support for [Displaylink](https://www.synaptics.com/products/displaylink-graphics).
- Includes Valve's KDE themes from SteamOS.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), and [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) installed and available by default
- Support for [Wallpaper Engine](https://www.wallpaperengine.io/en) on KDE.
- [Distrobox](https://github.com/89luca89/distrobox) preinstalled with automatic updates for created containers.
- Automated duperemove services for reducing the disk space used by wine prefix contents.
- [System76-Scheduler](https://github.com/pop-os/system76-scheduler) preinstalled, providing automatic process priority tweaks to your focused application and keeping CPU time for background processes to a minimum.
- Customized System76-Scheduler config with additional rules and CFS parameters from [Linux-TKG](https://github.com/Frogging-Family/linux-tkg).
- Uses [Google's BBR TCP congestion control](https://github.com/google/bbr) by default.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) preinstalled and enabled (Available but default-disabled on the Deck variant)
- Helpful first-start installer provides an easy way to install numerous applications and tweaks, including installing [CoreCtrl](https://gitlab.com/corectrl/corectrl) and [GreenWithEnvy](https://gitlab.com/leinardi/gwe).
- [Nix](https://nixos.org/) package manager optionally available.
- [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) i2c-piix4 and i2c-nct6775 drivers for controlling RGB on certain motherboards.
- [GCAdapter_OC](https://github.com/hannesmann/gcadapter-oc-kmod) driver for overclocking Nintendo's Gamecube Controller Adapter to 1000hz polling.
- Out of the box support for [Wooting](https://wooting.io/) keyboards.

### Desktop

Common variant available as `bazzite` and suitable for desktops and HTPCs.

- Runs Steam and Lutris in a [custom Arch Linux OCI](https://github.com/ublue-os/bazzite-arch/) via Distrobox.
- Option to automatically launch Steam in Big Picture Mode on boot for HTPCs.

To rebase an existing ostree system to this image: 

    podman pull ghcr.io/ublue-os/config && rpm-ostree install --assumeyes --apply-live --force-replacefiles $(find ~/.local/share/containers -name ublue-os-signing.noarch.rpm 2>/dev/null) && rpm-ostree rebase --uninstall $(rpm -q ublue-os-signing-* --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{Arch}') ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:latest

or for devices with Nvidia GPUs:

    podman pull ghcr.io/ublue-os/config && rpm-ostree install --assumeyes --apply-live --force-replacefiles $(find ~/.local/share/containers -name ublue-os-signing.noarch.rpm 2>/dev/null) && rpm-ostree rebase --uninstall $(rpm -q ublue-os-signing-* --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{Arch}') ostree-image-signed:docker://ghcr.io/ublue-os/bazzite-nvidia:latest

Once you've installed or rebased to a Nvidia build, [be sure to follow steps 2 and 3 from the ublue-os/nvidia guide](https://github.com/ublue-os/nvidia#2-set-kargs-after-rebasing).

### Deck

Variant designed for usage as an alternative to SteamOS on the Steam Deck, available as `bazzite-deck`:

- Directly boots to Gamemode matching SteamOS's behavior.
- Features ported versions of most SteamOS packages, including drivers, firmware updaters, and fan controllers [from the evlaV repository](https://gitlab.com/evlaV).
- Patched Mesa for proper framerate control from Gamescope.
- Comes with patches from [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) for full BTRFS support for the SD card by default.
- Ships with a ported copy of [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), enabled by default.
- Option to install [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), and [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), among numerous other useful packages on installation.
- Custom update system allows for the OS, Flatpaks, and Distrobox images to be updated directly from the Gamemode UI.
- Built in support for dual-boot thanks to Fedora's installation of GRUB being left intact.
- Update break something? Easily roll back to the previous version of Bazzite thanks to rpm-ostree's rollback functionality. You can even select previous images at boot.
- Steam and Lutris preinstalled on the image as layered packages.
- Comes with a default-disabled service for low-risk undervolting of the Steam Deck via [RyzenAdj](https://github.com/FlyGoat/RyzenAdj).
- Exclusively uses ZRAM by default with the option to switch back to a swap file and set a custom size if desired (1GB by default).
- BFQ I/O scheduler to prevent I/O starvation when installing games or during background duperemove processes.
- TLS/SSL secured DNS and NTP by default <sup><sub>(This is a handheld PC you're likely to use on random public networks after all)</sub></sup>.
- Applies SteamOS's kernel parameters and enables amd-pstate by default.
- 64GB Steam Decks gain several improvements over SteamOS, including:
    - Higher disk compression ratio increases storage space and eMMC read speeds.
    - Automatic duperemove greatly trims the size of compatdata.
    - Latest version of Mesa creates smaller shader caches and does not require them to prevent stutter.
    - Able to be booted even if the drive is full.

To rebase an existing ostree system to this image: 

    podman pull ghcr.io/ublue-os/config && rpm-ostree install --assumeyes --apply-live --force-replacefiles $(find ~/.local/share/containers -name ublue-os-signing.noarch.rpm 2>/dev/null) && rpm-ostree rebase --uninstall $(rpm -q ublue-os-signing-* --queryformat '%{NAME}-%{VERSION}-%{RELEASE}.%{Arch}') ostree-image-signed:docker://ghcr.io/ublue-os/bazzite-deck:latest

## Why

Bazzite started as a project to resolve some of the issues that plague SteamOS, mainly out of date packages despite an Arch base and the lack of a functional package manager.

Despite this project also being image-based you are able to install any Fedora package straight from the command line. These packages will persist across updates <sub><sup>(So go ahead and install that obscure VPN software you spent an hour trying to get working in SteamOS)</sup></sub>. Additionally, Bazzite is updated multiple times a week with packages from upstream Fedora, giving you the best possible performance and latest features - all on a stable base.

Bazzite ships with the latest Linux kernel and SELinux enabled by default with full support for secure boot and disk encryption, making this a sensible solution for general computing <sup><sub>(Yes, you can print from Bazzite)</sub></sup>.

![Default Theme](/repo_content/desktop1.png?raw=true "Default Theme")
![VGUI2 Theme](/repo_content/desktop2.png?raw=true "VGUI2 Theme")
  
## Custom Packages

Ported SteamOS and ChimeraOS packages, among others used by Bazzite, are built on Copr in [bazzite](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/) and [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/).

|Package|Status|
|---|---|
|ds-inhibit|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ds-inhibit/status_image/last_build.png?)|
|gamescope-session|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session/status_image/last_build.png?)|
|jupiter-fan-control|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)|
|jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)|
|mangohud|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mangohud/status_image/last_build.png?)|
|mesa|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mesa/status_image/last_build.png?)|
|python3-hid|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/python3-hid/status_image/last_build.png?)|
|ryzenadj|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ryzenadj/status_image/last_build.png?)|
|sddm-sugar-steamOS|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sddm-sugar-steamOS/status_image/last_build.png?)|
|sdgyrodsu|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sdgyrodsu/status_image/last_build.png?)|
|steamdeck-kde-presets|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)|
|steamdeck-kde-presets-desktop|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets-desktop/status_image/last_build.png?)|
|steam_notif_daemon|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steam_notif_daemon/status_image/last_build.png?)|
|udisks2|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/udisks2/status_image/last_build.png?)|
|vpower|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/vpower/status_image/last_build.png?)|

Additionally, the following packages are used from other Copr repos:
|Package|Status|
|---|---|
|[gcadapter_oc-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/gcadapter_oc-kmod/status_image/last_build.png?)|
|[hl2linux-selinux](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/package/hl2linux-selinux/status_image/last_build.png?)|
|[latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)|
|[noise-suppression-for-voice](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/package/noise-suppression-for-voice/status_image/last_build.png?)|
|[obs-vkcapture](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/package/obs-vkcapture/status_image/last_build.png?)|
|[openrgb-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/openrgb-kmod/status_image/last_build.png?)|
|[steamdeck-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)|![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/jupiter-kmod/status_image/last_build.png?)|
|[system76-scheduler](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/package/system76-scheduler/status_image/last_build.png?)|
|[wallpaper-engine-kde-plugin](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/)|![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/package/wallpaper-engine-kde-plugin/status_image/last_build.png?)|

## Verification

These images are signed with sisgstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite

## [![Repography logo](https://images.repography.com/logo.svg)](https://repography.com) / Recent activity [![Time period](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_badge.svg)](https://repography.com)
[![Timeline graph](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_timeline.svg)](https://github.com/ublue-os/bazzite/commits)
[![Issue status graph](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_issues.svg)](https://github.com/ublue-os/bazzite/issues)
[![Pull request status graph](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_prs.svg)](https://github.com/ublue-os/bazzite/pulls)
[![Top contributors](https://images.repography.com/35181738/ublue-os/bazzite/recent-activity/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_users.svg)](https://github.com/ublue-os/bazzite/graphs/contributors)

## [![Repography logo](https://images.repography.com/logo.svg)](https://repography.com) / Top contributors
[![Top contributors](https://images.repography.com/35181738/ublue-os/bazzite/top-contributors/Th70YH5TPWj_xtgglSDUV9CY1CtpE2JkmmfhzTTj4Vg/D6pCB2LvmFrU9T9B0Kp9QIfQCmY5U2q5aHoeVk0Tdds_table.svg)](https://github.com/ublue-os/bazzite/graphs/contributors)

## Special Thanks

Bazzite is a community effort and wouldn't exist without everyone's support. Below are some of the people who've helped us along the way:

 - [evlaV](https://gitlab.com/evlaV) - For making Valve's code available and for being [this person](https://xkcd.com/2347/).
 - [ChimeraOS](https://chimeraos.org/) - For gamescope-session and for valuable support along the way.
 - [Jovian-NixOS](https://github.com/Jovian-Experiments) - For supporting us with technical issues and for creating a similar project. Seriously, go check it out. It's our Nix-based cousin.
  - [Steam Deck Homebrew](https://deckbrew.xyz) - For choosing to support distributions other than SteamOS despite the extra work, and a special thanks to [PartyWumpus](https://github.com/PartyWumpus) for getting Decky Loader working with SELinux for us.
 - [cyrv6737](https://github.com/cyrv6737) - For the initial inspiration and the base that became bazzite-arch.
