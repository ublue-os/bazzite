<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [:cn:](https://github.com/ublue-os/bazzite/blob/main/README-zh-cn.md) [🇫🇷](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [🇧🇷](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md)

<p align="center">
  <a href="https://download.bazzite.gg/"><img src="/repo_content/download.png?raw=true" alt="Download Bazzite"/></a>
</p>

---

# Inhoudsopgave
- [README Taal](#---cn)
- [Over \& Kenmerken](#about--features)
  - [Desktop](#desktop)
  - [Steam Deck/Home Theater PCs (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
    - [Alternatieve Draagbare Computers](#alternative-handhelds)
  - [GNOME](#gnome)
  - [Kenmerken van Upstream](#features-from-upstream)
    - [Universal Blue](#universal-blue)
    - [Kenmerken van Fedora Linux (Kinoite \& Silverblue)](#features-from-fedora-linux-kinoite--silverblue)
- [Waarom](#why)
- [Showcase](#showcase)
- [Documentatie \& Nieuwsbrief](#documentation--newsletters)
- [Aangepaste Paketten](#custom-packages)
- [Verificatie](#verification)
- [Secure Boot](#secure-boot)
- [Bijdragers metriek](#contributor-metrics)
- [Ster Geschiedenis](#star-history)
- [Speciale Dank](#special-thanks)
- [Bouw Je Eigen](#build-your-own)
- [Lid worden](#join-the-community)
---

## Over & Kenmerken

[Bezoek onze website](https://bazzite.gg/) voor een nieuwkomer vriendelijke uitleg. Deze readme dekt alles grondig.

[Bazzite](https://bazzite.gg/) is een OCI image die als alternatief besturingssysteem werkt voor de [Steam Deck](https://www.steamdeck.com/), en een klaar-om-te-gamen SteamOS-achtig voor desktop computers woonkamer home theater PCs.

Bazzite is gebouwd van [ublue-os/main](https://github.com/ublue-os/main) en [ublue-os/nvidia](https://github.com/ublue-os/nvidia) met [Fedora](https://fedoraproject.org/) technologie, wat betekent dat uitgebreide hardwareondersteuning en ingebouwde stuurprogramma's zijn inbegrepen. Daarnaast voegt Bazzite de volgende functies toe:

- Gebruik van de [fsync kernel](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) om HDR the krijgen, beteren hardwareondersteuning, naast talloze andere meegeleverde patches.
- HDR beschikbaar in Game mode.
- NVK beschikbaar met niet-Nvidia builds.
- Volledige ondersteuning voor hardwareversnelde codec voor H264-decodering.
- Volledige ondesteuning voor AMD's ROCM OpenCL/HIP run-times.
- [xone](https://github.com/medusalix/xone) stuurprogramma voor Xbox controllers.
- Volledige ondersteuning voor [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Bevat Valve's KDE-thema's van SteamOS.
- Met optionele Valve-geinspireerde GTK3/4 thema's die overeenkomen met Vapor en VGUI2 van SteamOS. Installeer [Gradience](https://flathub.org/apps/com.github.GradienceTeam.Gradience) om die te gebruiken.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), en [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) standaard geïnstalleerd en beschikbaar.
- [Gepatcht Switcheroo-Control](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) om gebroken iGPU/dGPU-omschakeling te herstellen.
- Ondersteuning van [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Alleen met KDE)</sup></sub>
- [ROM Properties Page shell extension](https://github.com/GerbilSoft/rom-properties) inbegrepen.
- Volledige ondersteuning van [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) voorgeïnstalleerd met automatische updates voor aangemaakte containers.
- [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) in gebruik voor al de varianten. Deze terminal is specifiek ge-designed voor de container workflow die je gebruikt in Bazzite. Als je terug wilt naar de standaard terminal, gebruik `ujust restore-original-terminal`
- Automatische `duperemove` service voor het verminderen van de schijfruimte die wordt gebruikt door de inhoud van de wine-voorvoegsel.
- Ondersteuning voor HDMI CEC via [libCEC](https://libcec.pulse-eight.com/).
- [System76-Scheduler](https://github.com/pop-os/system76-scheduler) geïnstaleerd. Dit biedt automatische procesprioriteitaanpassingen voor applicaties die in gebruik zijn en beperkt de CPU-tijd voor achtergrondprocessen tot een minimum.
- Aangepasten System76-Scheduler config met extra regels.
- Gebruikt standaard [Google's BBR TCP congestiecontrole](https://github.com/google/bbr).
- [Input Remapper](https://github.com/sezanzeb/input-remapper) geïnstaleerd en in gebruik. <sub><sup>(Beschikbaar maar is uitgeschakeld in de Deck variant, kan ingeschakeld worden met `ujust restore-input-remapper`)</sup></sub>
- Bazzite Portal is een makkelijke manier om applicaties en aanpassingen te installeren, zoals [LACT](https://github.com/ilya-zlobintsev/LACT) en [GreenWithEnvy](https://gitlab.com/leinardi/gwe).
- [Waydroid](https://waydro.id/) geïnstaleerd om Android apps tend to gebruiken. Stel het in met de [quick guide](https://universal-blue.discourse.group/docs?topic=32).
- Applicaties beheren met [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), en [Gear Lever](https://github.com/mijorus/gearlever).
- [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) i2c-piix4 and i2c-nct6775 drivers for controlling RGB on certain motherboards.
- [OpenRazer](https://openrazer.github.io) stuurprogrammas ingebouwd. Selecteer OpenRazer in de Bazzite Portal of gebruik `ujust install-openrazer` in een terminal.
- [OpenTabletDriver](https://opentabletdriver.net/) udev regels ingebouwd, met voledige software suite installeerbaar via de Bazzite Portal of met `ujust install-opentabletdriver` in een terminal.
- Onmiddellijke ondersteuning voor [Wooting](https://wooting.io/) keyboards.
- Ingebouwde ondersteuning voor Southern Islands <sub><sup>(HD 7000)</sup></sub> en Sea Islands <sub><sup>(HD 8000)</sup></sub> AMD GPUs met de `amdgpu` stuurprogramma.
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) is beschikbaar voor Discord scherm delen onder Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) is beschikbaar om application van websites the maken in veschillende browsers, zoals Firefox.

### Desktop

Gangbare variant beschikbaar als `bazzite`, voor desktop computers.

- Automatische updates voor Flatpaks en alle Distrobox containers - aangedreven door [ublue-update](https://github.com/ublue-os/ublue-update) en [topgrade](https://github.com/topgrade-rs/topgrade).

> [!IMPORTANT]  
> **ISOs kunnen gedownload worden via onze [releases pagina](https://github.com/ublue-os/bazzite/releases), en een installatiegids kan [hier](https://universal-blue.discourse.group/docs?topic=30) gevonden worden.**

Rebase van een bestaande upstream Fedora Atomic naar deze image als je **Open Source GPU Drivers** wilt:
(Let op: Mesa's Open Source optie voor NVIDIA GPU's, NVK is nog steeds gevoelig voor fouten op het moment van schrijven, voor problemen met NVK [dien een rapport in bij Mesa].([url](https://docs.mesa3d.org/bugs.html)), niet Ublue/Bazzite)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

of voor apparaten met Nvidia GPUs die de **NVIDIA Proprietary Drivers** willen gebruiken:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**Voor gebruikers die Secure Boot aan hebben:** Volg onze [secure boot documentatie](#secure-boot) voor de rebasing.

### Steam Deck/Home Theater PCs (HTPCs)
> [!IMPORTANT]  
Apparaten die NIET de Steam Deck zijn kunnen nogsteeds de  `bazzite-deck` images gebruiken maar moeten een moderne AMD GPU hebben. Intel Arc GPUs werken ook.

Varianten voor gebruik als alternatief voor SteamOS op de Steam Deck en voor console-achtige ervaring op HTPCs beschikbaar als `bazzite-deck`:

- Start direct in Game mode.
- **Automatische `duperemove` verminderd de grootte van compatdata.**
- **Laatste versie van Mesa maakt kleinere shader caches en heeft die niet nodig om haperen tegen te gaan.**
- **Kan gestart worden ook al is de drive vol.**
- **Al de talen die in Upstream Fedora beschikbaar zijn zijn hier ook beschikbaar.**
- **Gebruikt Wayland in de desktop met [ondersteuning van Steam input](https://github.com/Supreeeme/extest).**
- Gebruikt [HHD](https://github.com/hhd-dev/hhd) voor beteren invoer met non-Valve draagbare computers.
- Gebruikt overgezetten functions va SteamOS paketten, zoals bestuurprogrammas, firmware updaters, en ventilatie controle [van de evlaV repo](https://gitlab.com/evlaV).
- Aangepaste Mesa voor betere framerate controle in Gamescope.
- Komt met patches voor [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) voor een volledige BTRFS beschikbaarheid voor SD kaarten.
- Komt met [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU).
- Optie om [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), en [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/) te instaleren, met velen anderen opties.
- Aangepaste update systeem die het mogelijk maken om het bestuuringsysteem, Flatpaks en Distrobox images direct te updaten via de Game mode UI. Medemogelijk gemaat door [ublue-update](https://github.com/ublue-os/ublue-update) en [topgrade](https://github.com/topgrade-rs/topgrade).
- Makkelijk om Windows te Dual-Booten dankzij Fedora die GRUB intact laat.
- Gaat een update fout? Ga gemakelijk terug naar een ouderen versie van Bazzite met `rpm-ostree`'s rollback functionaliteit. Je kan zelfs ouderen images selecteren tijdens het starten.
- Steam en Lutris geïnstaleerd in de image.
- [Discover Overlay](https://github.com/trigg/Discover) voor Discord geïntaleerd en start automatisch in Game mode en de Desktop als Discord beschikbaar is. [Zie de officiële documentatie hier](https://trigg.github.io/Discover/bazzite).
- Gebruik van de <sub><sup>(4GB)</sup></sub> ZRAM met ZSTD compressie algoritme met de optie om terug te gaan naar een 1GB swap file en mogelijkheid om een eigen grooten te kiezen.
- Kyber I/O scheduler om I/O starvation tegen te gaan tijdens het installeren van spellen of de achtergrond `duperemove` process.
- Gebruikt SteamOS's kernel parameters.
- Kleur gecalibreerde display profielen voor matte and reflectieven Steam Deck schermen.
- Standaard uit, power-user opties zoals:
    - Mogelijkheid voor laag-risico undervolting van de Steam Deck en AMD Framework Laptops via [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) en [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), zie `ryzenadj.service` en `/etc/default/ryzenadj`.
    - Batterij oplaad limiet, zie `batterylimit.service` en `/etc/default/batterylimit`. <sup><sub>(Werkt ook als het apparaat uit is)</sub></sup>
    - Mogelijkheid om het scherm te overclocken. Bijvoorbeeld, voeg `GAMESCOPE_OVERRIDE_REFRESH_RATE=40,70` toe in `/etc/environment`.
    - Heb je 32GB ram in je Steam Deck? Geniet van de dubbelen maximalen VRAM, automatisch ingeschakeld <sup><sub>(Kan je je soldeer skills delen?)</sub></sup>
- Steam Deck hardware-specifieken services kunnen uit gezet worden met `ujust disable-bios-updates` en `ujust disable-firmware-updates` in de terminal. Dezen staan al uit op non-Deck hardware, en op Decks met DeckHD schermen of 32GB RAM mods.
- Meer informatie kan [hier](https://universal-blue.discourse.group/docs?topic=37) gevonden worden voor de Bazzite Steam Deck images.

> [!WARNING]  
> **Door een upstream probleem kan Bazzite niet gebruikt worden op Steam Decks met 64GB eMMC opslag. De opslag vervangen helpt met dit probleem.**

> [!IMPORTANT]  
> **ISOs kunnen gedownload worden via onze [releases pagina](https://github.com/ublue-os/bazzite/releases), en installatie instructies kunnen [hier](https://universal-blue.discourse.group/docs?topic=30) gevonden worden.**

Rebase van een bestaande upstream Fedora Atomic naar deze image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Alternatieve Draagbare Computers

Zie onze [Handheld Wiki](https://universal-blue.discourse.group/docs?topic=1038) voor nodige instellingen en Decky Loader plugins voor Steam Gaming Mode op jou Draagbare Computer.

Als je deze image gebruikt op een systeem anders dan de Steam Deck, kan je TDP control krijgen via de SimpleDeckyTDP Decky Loader Plugin.
- Installeer Decky Loader met: `ujust setup-decky`
- Daarna, installeer SimpleDeckyTDP met: `ujust setup-decky simpledeckytdp`

Als je een Draagbare Computer gebruikt die  [hhd](https://github.com/hhd-dev/hhd) kan gebruiken <sub><sup>(Zoals de Lenovo Legion Go en de ASUS Ally)</sup></sub>, kan je een plugin krijgen om het optie menu te integreren in Game Mode met: `ujust setup-decky hhd-decky`

**Lees de  [hhd documentatie](https://github.com/hhd-dev/hhd#after-install), somigen Draagbare Computers hebben specifieken tweaks nodig om te werken.**

We hebben ook een `ujust` command om verschilende [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck) themas te installeren, dezen kunnen in de CSS Loader store gevonden worden. De themas worden automatisch geüpdate door Bazzite als de geïntalleerd zijn.
```bash
# Installeer ROG Ally Thema voor CSS Loader (https://github.com/semakusut/SBP-ROG-Ally)
ujust install-rog-ally-theme

# Installeer Lenovo Legion Go Thema voor CSS Loader (https://github.com/frazse/SBP-Legion-Go-Theme)
ujust install-legion-go-theme

# Installeer Handheld Controller Thema (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme

# Installeer PS5-to-Xbox glyph thema voor hhd & CSS Loader (https://github.com/frazse/PS5-to-Xbox-glyphs)
ujust install-hhd-xbox-glyph-theme
```

### GNOME

GNOME desktop environment is beschikbaar in  desktop and deck varianten. Deze versies hebben de volgende toegevoegde functies:

- [Variabelen refresh rate en fractionele scaling onder Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Menu in het top menu om naar Game Mode te gaan, Steam te starten en veel meer.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) geïnstalleerd en klaar voor gebruik.
- [Hanabi extensie](https://github.com/jeffshee/gnome-ext-hanabi) met vergelijkbaren functinaliteiten voor Wallpaper Engine net als in KDE.
- Meerderen beschikbaaren extensies geïnstalleerd zoals [belangrijken gebruikers ervaring fixes](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Automatische updates voor [Firefox GNOME thema](https://github.com/rafaelmardojai/firefox-gnome-theme) en [Thunderbird GNOME thema](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(Als deze geïnstalleerd zijn)</sub></sup>

> [!IMPORTANT]  
> **ISOs kunnen gedownload worden via onze [releases pagina](https://github.com/ublue-os/bazzite/releases), en een installatiegids kan [hier](https://universal-blue.discourse.group/docs?topic=30) gevonden worden.**

Rebase van een bestaande upstream Fedora Atomic naar deze image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

Bestaande rebase ostree systeem naar een Desktop Environment met de **Proprietary NVIDIA Drivers** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

> [!WARNING]  
> **Door een upstream probleem kan Bazzite niet gebruikt worden op Steam Decks met 64GB eMMC opslag.**

To rebase an existing ostree system to the **Steam Deck/HTPC** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**For users with Secure Boot enabled:** Follow our [secure boot documentation](#secure-boot) prior to rebasing.

### Features from Upstream

#### Universal Blue

- Proprietary Nvidia drivers pre-installed. <sub><sup>(Only for Nvidia images)</sup></sub>
- Flathub is enabled by default.
- [`ujust`](https://github.com/casey/just) commands for convenience.
- Multi-media codecs out of the box.
- Rollback Bazzite from any build within the last 90 days.

#### Features from Fedora Linux (Kinoite & Silverblue)

- A rock solid and stable base.
- System packages stay relatively up to date.
- Can layer Fedora packages to the image without losing them between updates.
- Security focused with [SELinux](https://github.com/SELinuxProject/selinux) preinstalled and configured out of the box.
- The ability to rebase to different Fedora Atomic images, if desired, without losing user data.
- Printing support thanks to [CUPS](https://www.cups.org/) being preinstalled.

## Why

Bazzite started as a project to resolve some of the issues that plague SteamOS, mainly out of date packages (despite an Arch base) and the lack of a functional package manager.

Despite this project also being image-based, you are able to install any Fedora package straight from the command line. These packages will persist across updates <sub><sup>(So go ahead and install that obscure VPN software you spent an hour trying to get working in SteamOS)</sup></sub>. Additionally, Bazzite is updated multiple times a week with packages from upstream Fedora, giving you the best possible performance and latest features - all on a stable base.

Bazzite ships with the latest Linux kernel and SELinux enabled by default with full support for secure boot <sub><sup>(Run `ujust enroll-secure-boot-key` and enter the password `ublue-os` if prompted to enroll our key)</sup></sub> and disk encryption, making this a sensible solution for general computing. <sup><sub>(Yes, you can print from Bazzite)</sub></sup>

Read the [FAQ](https://universal-blue.discourse.group/docs?topic=33) for details on what makes Bazzite stand out from other Linux operating systems.

## Showcase

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Documentation & Newsletters

- [Installing and Managing Applications](https://universal-blue.discourse.group/docs?topic=35)
- [Updates, Rollbacks, and Rebasing](https://universal-blue.discourse.group/docs?topic=36)
- [Gaming Guide](https://universal-blue.discourse.group/docs?topic=31)

View [additional documentation](http://docs.bazzite.gg/) surrounding the project.

Check out our [newsletters](https://universal-blue.discourse.group/docs?topic=2252) that get published on a regular basis for updates on the project.

## Custom Packages

Ported SteamOS and ChimeraOS packages, among others used by Bazzite, are built on Copr in [bazzite](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/) and [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/).

| Package                                                                                             | Status                                                                                                                                                      |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ds-inhibit                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ds-inhibit/status_image/last_build.png?)                                  |
| duperemove                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/duperemove/status_image/last_build.png?)                                  |
| [extest](https://github.com/Supreeeme/extest)                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/extest/status_image/last_build.png?)                             |
| gamescope                                                                                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/gamescope/status_image/last_build.png?)                          |
| [gamescope-session-plus](https://github.com/ChimeraOS/gamescope-session)                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-plus/status_image/last_build.png?)                      |
| [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam)                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-steam/status_image/last_build.png?)                     |
| gamescope-shaders                                                                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-shaders/status_image/last_build.png?)                           |
| galileo-mura                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/galileo-mura/status_image/last_build.png?)                                |
| [gnome-randr-rust](https://github.com/maxwellainatchi/gnome-randr-rust)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-randr-rust/status_image/last_build.png?)                            |
| gnome-shell                                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/gnome-shell/status_image/last_build.png?)                                 |
| gnome-shell-extension-bazzite-menu                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-bazzite-menu/status_image/last_build.png?)          |
| [gnome-shell-extension-caribou-blocker](https://extensions.gnome.org/extension/1326/block-caribou/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-caribou-blocker/status_image/last_build.png?)       |
| [gnome-shell-extension-compiz-windows-effect](https://github.com/hermes83/compiz-windows-effect)    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-compiz-windows-effect/status_image/last_build.png?) |
| [gnome-shell-extension-hanabi](https://github.com/jeffshee/gnome-ext-hanabi)                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hanabi/status_image/last_build.png?)                |
| [gnome-shell-extension-hotedge](https://github.com/jdoda/hotedge)                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hotedge/status_image/last_build.png?)               |
| [joystickwake](https://github.com/foresto/joystickwake)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/joystickwake/status_image/last_build.png?)                                |
| jupiter-fan-control                                                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)                         |
| jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| jupiter-sd-mounting-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| kf6-kio                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/kf6-kio/status_image/last_build.png?)                                     |
| [mangohud](https://github.com/flightlessmango/MangoHud)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mangohud/status_image/last_build.png?)                           |
| mesa                                                                                                | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mesa/status_image/last_build.png?)                               |
| pipewire                                                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/pipewire/status_image/last_build.png?)                           |
| powerbuttond                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/powerbuttond/status_image/last_build.png?)                                |
| [python3-hid](https://github.com/apmorton/pyhidapi)                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/python3-hid/status_image/last_build.png?)                                 |
| [ryzenadj](https://github.com/FlyGoat/RyzenAdj)                                                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ryzenadj/status_image/last_build.png?)                                    |
| [sdgyrodsu](https://github.com/kmicki/SteamDeckGyroDSU)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sdgyrodsu/status_image/last_build.png?)                                   |
| steamdeck-dsp                                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-dsp/status_image/last_build.png?)                               |
| steamdeck-gnome-presets                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-gnome-presets/status_image/last_build.png?)                     |
| steamdeck-kde-presets                                                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)                       |
| steamdeck-kde-presets-desktop                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets-desktop/status_image/last_build.png?)               |
| steam_notif_daemon                                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steam_notif_daemon/status_image/last_build.png?)                          |
| [ublue-update](https://github.com/ublue-os/ublue-update)                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ublue-update/status_image/last_build.png?)                                |
| udisks2                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/udisks2/status_image/last_build.png?)                                     |
| unl0kr                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/unl0kr/status_image/last_build.png?)                                      |
| upower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/upower/status_image/last_build.png?)                                      |
| vpower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/vpower/status_image/last_build.png?)                                      |
| wireplumber                                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/wireplumber/status_image/last_build.png?)                                 |
| [xwiimote-ng](https://github.com/dev-0x7C6/xwiimote-ng)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/xwiimote-ng/status_image/last_build.png?)                                 |

Additionally, the following packages are used from other Copr repos:

| Package                                                                                                       | Status                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [discover-overlay](https://github.com/trigg/Discover)                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/mavit/discover-overlay/package/discover-overlay/status_image/last_build.png?)                           |
| [hhd](https://github.com/hhd-dev/hhd)                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/hhd-dev/hhd/package/hhd/status_image/last_build.png?)                                                   |
| [joycond](https://copr.fedorainfracloud.org/coprs/kylegospo/joycond/)                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/joycond/package/joycond/status_image/last_build.png?)                                         |
| [kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/)                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/package/kernel/status_image/last_build.png?)                                        |
| [latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/)                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)                    |
| [nerd-fonts](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/)                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/package/nerd-fonts/status_image/last_build.png?)                                         |
| [noise-suppression-for-voice](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/)                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/package/noise-suppression-for-voice/status_image/last_build.png?)                       |
| [obs-vkcapture](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/package/obs-vkcapture/status_image/last_build.png?)                             |
| [ptyxis](https://gitlab.gnome.org/chergert/ptyxis)                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/ptyxis/status_image/last_build.png?)                                           |
| [rom-properties](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/package/rom-properties/status_image/last_build.png?)                           |
| [steamdeck-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)                                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/jupiter-kmod/status_image/last_build.png?)                                      |
| [system76-scheduler](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/)                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/package/system76-scheduler/status_image/last_build.png?)                   |
| [wallpaper-engine-kde-plugin](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/package/wallpaper-engine-kde-plugin/status_image/last_build.png?) |
| [webapp-manager](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/package/webapp-manager/status_image/last_build.png?)                           |

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

> [!WARNING]  
> **Steam Deck Users: The Steam Deck does not come with secure boot enabled and does not ship with any keys enrolled by default. Do not enable this unless you absolutely know what you're doing.**

Secure boot is supported with our custom key. The pub key can be found in the root of this repository [here](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der).
If you'd like to enroll this key prior to installation or rebase, download the key and run the following:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

For users already on a Universal Blue image, you may instead run `ujust enroll-secure-boot-key`.

If asked for a password, use `ublue-os`.

### Contributor Metrics

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

#### Star History

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Special Thanks

Bazzite is a community effort and wouldn't exist without everyone's support. Below are some of the people who've helped us along the way:

- [rei.svg](https://github.com/reisvg) - For creating our logo and overall branding.
- [SuperRiderTH](https://github.com/SuperRiderTH) - For creating our Steam game mode startup video.
- [evlaV](https://gitlab.com/evlaV) - For making Valve's code available and for being [this person](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/) - For gamescope-session and for valuable support along the way.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - For supporting us with technical issues and for creating a similar project. Seriously, go check it out. It's our Nix-based cousin.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - For assistance with needed kernel patches and for creating the [kernel-fsync repo](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) we now use.
- [nicknamenamenick](https://github.com/nicknamenamenick) - For being the MVP nearly single-handedly upkeeping our documentation and support literature, and countless cases of helping users.
- [Steam Deck Homebrew](https://deckbrew.xyz) - For choosing to support distributions other than SteamOS despite the extra work, and a special thanks to [PartyWumpus](https://github.com/PartyWumpus) for getting Decky Loader working with SELinux for us.
- [cyrv6737](https://github.com/cyrv6737) - For the initial inspiration and the base that became bazzite-arch.

## Build Your Own

Bazzite is built entirely in GitHub and creating your own custom version of it is as easy as forking this repository, adding a private signing key, and enabling GitHub actions.

[Familiarize yourself](https://docs.github.com/en/actions/security-guides/encrypted-secrets) on keeping secrets in github. You'll need to [generate a new keypair](https://docs.sigstore.dev/cosign/overview/) with cosign. The public key can be in your public repo <sub><sup>(Your users need it to check the signatures)</sup></sub>, and you can paste the private key in `Settings -> Secrets -> Actions` with the name `SIGNING_SECRET`.

We also ship a config for the popular [pull app](https://github.com/apps/pull) if you'd like to keep your fork in sync with upstream. Enable this app on your repo to keep track of Bazzite changes while also making your own modifications.

## Join The Community

You can find us on the [Universal Blue Discord](https://discord.gg/f8MUghG5PB) and view the [archive](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) of support threads without an account.

Discuss and create user guides over at the [Universal Blue Discourse Forums](https://universal-blue.discourse.group/c/bazzite/5).

Follow Universal Blue on [Mastodon](https://fosstodon.org/@UniversalBlue).
