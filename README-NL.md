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
- [Over \& Kenmerken](#over--kenmerken)
  - [Desktop](#desktop)
  - [Steam Deck/Home Theater PCs (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
    - [Alternatieve Draagbare Computers](#alternatieve-draagbare-computers)
  - [GNOME](#gnome)
  - [Kenmerken van Upstream](#kenmerken-van-upstream)
    - [Universal Blue](#universal-blue)
    - [Kenmerken van Fedora Linux (Kinoite \& Silverblue)](#kenmerken-van-fedora-linux-kinoite--silverblue)
- [Waarom](#waarom)
- [Showcase](#showcase)
- [Documentatie \& Nieuwsbrief](#documentatie--nieuwsbrief)
- [Aangepaste Paketten](#aangepaste-paketten)
- [Verificatie](#verificatie)
- [Secure Boot](#secure-boot)
- [Bijdragers metriek](#bijdragers-metriek)
- [Ster Geschiedenis](#ster-geschiedenis)
- [Speciale Dank](#speciale-dank)
- [Zelf Bouwen](#zelf-bouwen)
- [Lid worden](#lid-worden)
---

## Over & Kenmerken

[Bezoek onze website](https://bazzite.gg/) voor een nieuwkomer vriendelijke uitleg. Deze readme dekt alles grondig.

[Bazzite](https://bazzite.gg/) is een OCI image die als alternatief besturingssysteem werkt voor de [Steam Deck](https://www.steamdeck.com/) en een klaar-om-te-gamen SteamOS-achtig alternatief voor desktop computers en woonkamer home theater PCs.

Bazzite is gebouwd van [ublue-os/main](https://github.com/ublue-os/main) en [ublue-os/nvidia](https://github.com/ublue-os/nvidia) met [Fedora](https://fedoraproject.org/) technologie, wat betekent dat uitgebreide hardwareondersteuning en ingebouwde stuurprogramma's zijn inbegrepen. Daarnaast voegt Bazzite de volgende functies toe:

- Gebruik van de [fsync kernel](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) om HDR the krijgen, beteren hardwareondersteuning, naast talloze andere meegeleverde patches.
- HDR beschikbaar in Game mode.
- NVK beschikbaar met niet-Nvidia builds.
- Volledige ondersteuning voor hardwareversnelde codec voor H264-decodering.
- Volledige ondesteuning voor AMD's ROCM OpenCL/HIP run-times.
- [xone](https://github.com/medusalix/xone) stuurprogramma voor Xbox controllers.
- Volledige ondersteuning voor [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Bevat Valve's KDE-thema's van SteamOS.
- Met optionele Valve-geïnspireerde GTK3/4 thema's die overeenkomen met Vapor en VGUI2 van SteamOS. Installeer [Gradience](https://flathub.org/apps/com.github.GradienceTeam.Gradience) om die te gebruiken.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud) en [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) zijn standaard geïnstalleerd en beschikbaar.
- [Gepatchte Switcheroo-Control](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) om gebroken iGPU/dGPU-omschakeling te herstellen.
- Ondersteuning van [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Alleen met KDE)</sup></sub>
- [ROM Properties Page shell extension](https://github.com/GerbilSoft/rom-properties) inbegrepen.
- Volledige ondersteuning van [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) voorgeïnstalleerd met automatische updates voor aangemaakte containers.
- [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) in gebruik voor al de varianten. Deze terminal is specifiek ge-designed voor de container workflow die je gebruikt in Bazzite. Als je terug wilt naar de standaard terminal, gebruik `ujust _restore-original-terminal`
- Automatische `duperemove` service voor het verminderen van de schijfruimte die wordt gebruikt door de inhoud van de wine-voorvoegsel.
- Ondersteuning voor HDMI CEC via [libCEC](https://libcec.pulse-eight.com/).
- [System76-Scheduler](https://github.com/pop-os/system76-scheduler) geïnstaleerd. Dit biedt automatische procesprioriteitaanpassingen voor applicaties die in gebruik zijn en beperkt de CPU-tijd voor achtergrondprocessen tot een minimum.
- Aangepasten System76-Scheduler config met extra regels.
- Gebruikt standaard [Google's BBR TCP congestiecontrole](https://github.com/google/bbr).
- [Input Remapper](https://github.com/sezanzeb/input-remapper) geïnstaleerd en in gebruik. <sub><sup>(Beschikbaar maar is uitgeschakeld in de Deck variant, kan ingeschakeld worden met `ujust _restore-input-remapper`)</sup></sub>
- Bazzite Portal is een makkelijke manier om applicaties en aanpassingen te installeren, zoals [LACT](https://github.com/ilya-zlobintsev/LACT) en [GreenWithEnvy](https://gitlab.com/leinardi/gwe).
- [Waydroid](https://waydro.id/) geïnstaleerd om Android apps tend to gebruiken. Stel het in met de [quick guide](https://universal-blue.discourse.group/docs?topic=32).
- Applicaties beheren met [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse) en [Gear Lever](https://github.com/mijorus/gearlever).
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
> **ISOs kunnen gedownload worden via onze [releases pagina](https://github.com/ublue-os/bazzite/releases) en een installatiegids kan [hier](https://universal-blue.discourse.group/docs?topic=30) gevonden worden.**

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
- Gebruikt overgezetten functions va SteamOS paketten, zoals bestuurprogrammas, firmware updaters en ventilatie controle [van de evlaV repo](https://gitlab.com/evlaV).
- Aangepaste Mesa voor betere framerate controle in Gamescope.
- Komt met patches voor [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) voor een volledige BTRFS beschikbaarheid voor SD kaarten.
- Komt met [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU).
- Optie om [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/) en [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/) te instaleren, met velen anderen opties.
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
- Steam Deck hardware-specifieken services kunnen uit gezet worden met `ujust disable-bios-updates` en `ujust disable-firmware-updates` in de terminal. Dezen staan al uit op non-Deck hardware en op Decks met DeckHD schermen of 32GB RAM mods.
- Meer informatie kan [hier](https://universal-blue.discourse.group/docs?topic=37) gevonden worden voor de Bazzite Steam Deck images.

> [!WARNING]  
> **Door een upstream probleem kan Bazzite niet gebruikt worden op Steam Decks met 64GB eMMC opslag. De opslag vervangen helpt met dit probleem.**

> [!IMPORTANT]  
> **ISOs kunnen gedownload worden via onze [releases pagina](https://github.com/ublue-os/bazzite/releases) en installatie instructies kunnen [hier](https://universal-blue.discourse.group/docs?topic=30) gevonden worden.**

Rebase van een bestaande upstream Fedora Atomic naar deze image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Alternatieve Draagbare Computers

Zie onze [Handheld Wiki](https://universal-blue.discourse.group/docs?topic=1038) voor nodige instellingen en Decky Loader plugins voor Steam Gaming Mode op jou Draagbare Computer.

**Lees de  [hhd documentatie](https://github.com/hhd-dev/hhd#after-install), somigen Draagbare Computers hebben specifieken tweaks nodig om te werken.**

We hebben ook een `ujust` command om verschilende [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck) thema's te installeren, dezen kunnen in de CSS Loader store gevonden worden. De themas worden automatisch geüpdate door Bazzite als die geïntalleerd zijn.

```bash
# Installeer Handheld Controller Thema (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme
```

### GNOME

GNOME desktop environment is beschikbaar in alle desktop and deck varianten. Deze versies hebben de volgende toegevoegde functies:

- [Variabelen refresh rate en fractionele scaling onder Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Optiess in het top menu om naar Game Mode te gaan, Steam te starten en veel meer.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) geïnstalleerd en klaar voor gebruik.
- [Hanabi extensie](https://github.com/jeffshee/gnome-ext-hanabi) met vergelijkbaren functinaliteiten voor Wallpaper Engine net als in KDE.
- Meerderen beschikbaaren extensies geïnstalleerd zoals [belangrijken gebruikers ervaring fixes](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Automatische updates voor [Firefox GNOME thema](https://github.com/rafaelmardojai/firefox-gnome-theme) en [Thunderbird GNOME thema](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(Als deze geïnstalleerd zijn)</sub></sup>

> [!IMPORTANT]  
> **ISOs kunnen gedownload worden via onze [releases pagina](https://github.com/ublue-os/bazzite/releases) en een installatiegids kan [hier](https://universal-blue.discourse.group/docs?topic=30) gevonden worden.**

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

Om een bestaande ostree systeem te rebasen naar de **Steam Deck/HTPC** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**FVoor gebruikers met Secure Boot:** Volg onze [secure boot documentatie](#secure-boot) voordat je rebased.

### Kenmerken van Upstream

#### Universal Blue

- Proprietary Nvidia bestuurprogrammas geïnstaleerd. <sub><sup>(Alleen voor NVidia images)</sup></sub>
- Flathub staat aan.
- [`ujust`](https://github.com/casey/just) commands voor uw gemak.
- Multi-media codecs.
- Mogelijkheid om terug te gaan naar ouderen Bazzite images binnen 90 dagen.

#### Kenmerken van Fedora Linux (Kinoite & Silverblue)

- Super stabiele basis.
- Systeem onderdelen blijven relatief up-to-date.
- Mogelijkheid om Fedora programmas te gebruiken die na updates op uw systeem blijven.
- Beveiligd dankzij [SELinux](https://github.com/SELinuxProject/selinux) die geïnstaleerd is en aan staat.
- Mogelijkheid om verschilende Fedora Atomic images te gebruiken, als je dat wilt, zonder gebruikers data te verliezen (spellen, instellingen, apps, etc).
- Printer ondersteuning dankzij [CUPS](https://www.cups.org/).

## Waarom

Bazzite is begonnen als project om verschilende problemen die SteamOS heeft te reparerent, vooral oude packages (ondanks dat het een Arch basis heeft) en het gebrek aan een functionele package manager.

Ondanks dit project ook image-based is kun je al de Fedora packages installeren via de terminal. Deze packages blijven op uw systeem ook na updates. <sub><sup>(Installeer maar die obscure VPN software wat je uren lang hebt geprobeerd op SteamOS.)</sup></sub>. Bazzite is ook meerderen keren per week geüpdate met upstream Fedora packages. Dit geeft Bazzite de beste prestatie en laatste kenmerken - allemaal op een stabiele basis.

Bazzite komt met de laatste Linux kernel en SELinux met volledige mogelijkheid voor Secure Boot <sub><sup>(Gebruik `ujust enroll-secure-boot-key` in de terminal en gebruik wachtwoord `universalblue` als dit gevraagd wordt om onze sleutels te gebruiken )</sup></sub> en disk encryptie maakt Bazzite een geweldig alternatief voor normaal computer gevruik. <sup><sub>(Ja, je kan printen met Bazzite)</sub></sup>

Lees de [FAQ](https://universal-blue.discourse.group/docs?topic=33) om te zien wat Bazzite speciaal maakt vergeleken met anderen Linux distributies.

## Showcase

![KDE Vapor Thema](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Thema](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME Vapor Thema](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Thema](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Documentatie & Nieuwsbrief

- [Applicaties intalleren en beheren](https://universal-blue.discourse.group/docs?topic=35)
- [Updates, Rollbacks en Rebasing](https://universal-blue.discourse.group/docs?topic=36)
- [Gaming Gids](https://universal-blue.discourse.group/docs?topic=31)

Zie [extra documentatie](http://docs.bazzite.gg/) rondom het project.

Zie onze [nieuwsbrief](https://universal-blue.discourse.group/docs?topic=2252) die regelmaatig geüpdate wordt voor info rondom het project.

## Aangepaste Paketten

Overgezetten SteamOS en ChimeraOS paketten, onderanderen in gebruik door Bazzite, worden gebouwd met copr in [bazzite](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/) en [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite-multilib/).

| Pakket                                                                                              | Status                                                                                                                                                      |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ds-inhibit                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/ds-inhibit/status_image/last_build.png?)                                  |
| duperemove                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/duperemove/status_image/last_build.png?)                                  |
| [extest](https://github.com/Supreeeme/extest)                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite-multilib/package/extest/status_image/last_build.png?)                             |
| gamescope                                                                                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite-multilib/package/gamescope/status_image/last_build.png?)                          |
| [gamescope-session-plus](https://github.com/ChimeraOS/gamescope-session)                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gamescope-session-plus/status_image/last_build.png?)                      |
| [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam)                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gamescope-session-steam/status_image/last_build.png?)                     |
| gamescope-shaders                                                                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gamescope-shaders/status_image/last_build.png?)                           |
| galileo-mura                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/galileo-mura/status_image/last_build.png?)                                |
| [gnome-randr-rust](https://github.com/maxwellainatchi/gnome-randr-rust)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gnome-randr-rust/status_image/last_build.png?)                            |
| gnome-shell                                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/gnome-shell/status_image/last_build.png?)                                 |
| gnome-shell-extension-bazzite-menu                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gnome-shell-extension-bazzite-menu/status_image/last_build.png?)          |
| [gnome-shell-extension-caribou-blocker](https://extensions.gnome.org/extension/1326/block-caribou/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gnome-shell-extension-caribou-blocker/status_image/last_build.png?)       |
| [gnome-shell-extension-compiz-windows-effect](https://github.com/hermes83/compiz-windows-effect)    | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gnome-shell-extension-compiz-windows-effect/status_image/last_build.png?) |
| [gnome-shell-extension-hanabi](https://github.com/jeffshee/gnome-ext-hanabi)                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gnome-shell-extension-hanabi/status_image/last_build.png?)                |
| [gnome-shell-extension-hotedge](https://github.com/jdoda/hotedge)                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/gnome-shell-extension-hotedge/status_image/last_build.png?)               |
| [joystickwake](https://github.com/foresto/joystickwake)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/joystickwake/status_image/last_build.png?)                                |
| jupiter-fan-control                                                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/jupiter-fan-control/status_image/last_build.png?)                         |
| jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| jupiter-sd-mounting-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| kf6-kio                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/kf6-kio/status_image/last_build.png?)                                     |
| [mangohud](https://github.com/flightlessmango/MangoHud)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite-multilib/package/mangohud/status_image/last_build.png?)                           |
| mesa                                                                                                | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite-multilib/package/mesa/status_image/last_build.png?)                               |
| pipewire                                                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite-multilib/package/pipewire/status_image/last_build.png?)                           |
| powerbuttond                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/powerbuttond/status_image/last_build.png?)                                |
| [python3-hid](https://github.com/apmorton/pyhidapi)                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/python3-hid/status_image/last_build.png?)                                 |
| [ryzenadj](https://github.com/FlyGoat/RyzenAdj)                                                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/ryzenadj/status_image/last_build.png?)                                    |
| [sdgyrodsu](https://github.com/kmicki/SteamDeckGyroDSU)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/sdgyrodsu/status_image/last_build.png?)                                   |
| steamdeck-dsp                                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/steamdeck-dsp/status_image/last_build.png?)                               |
| steamdeck-gnome-presets                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/steamdeck-gnome-presets/status_image/last_build.png?)                     |
| steamdeck-kde-presets                                                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)                       |
| steamdeck-kde-presets-desktop                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/steamdeck-kde-presets-desktop/status_image/last_build.png?)               |
| steam_notif_daemon                                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/steam_notif_daemon/status_image/last_build.png?)                          |
| [ublue-update](https://github.com/ublue-os/ublue-update)                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/ublue-update/status_image/last_build.png?)                                |
| udisks2                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/udisks2/status_image/last_build.png?)                                     |
| unl0kr                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/unl0kr/status_image/last_build.png?)                                      |
| upower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/upower/status_image/last_build.png?)                                      |
| vpower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/vpower/status_image/last_build.png?)                                      |
| wireplumber                                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/wireplumber/status_image/last_build.png?)                                 |
| [xwiimote-ng](https://github.com/dev-0x7C6/xwiimote-ng)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/package/xwiimote-ng/status_image/last_build.png?)                                 |

De volgende paketten worden gebruikt van anderen Copr repos:

| Pakket                                                                                                        | Status                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [discover-overlay](https://github.com/trigg/Discover)                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/mavit/discover-overlay/package/discover-overlay/status_image/last_build.png?)                           |
| [hhd](https://github.com/hhd-dev/hhd)                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/hhd-dev/hhd/package/hhd/status_image/last_build.png?)                                                   |
| [joycond](https://copr.fedorainfracloud.org/coprs/bazzite-org/joycond/)                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/joycond/package/joycond/status_image/last_build.png?)                                         |
| [kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/)                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/package/kernel/status_image/last_build.png?)                                        |
| [latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/bazzite-org/LatencyFleX/)                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)                    |
| [nerd-fonts](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/)                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/package/nerd-fonts/status_image/last_build.png?)                                         |
| [noise-suppression-for-voice](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/)                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/package/noise-suppression-for-voice/status_image/last_build.png?)                       |
| [obs-vkcapture](https://copr.fedorainfracloud.org/coprs/bazzite-org/obs-vkcapture/)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/obs-vkcapture/package/obs-vkcapture/status_image/last_build.png?)                             |
| [ptyxis](https://gitlab.gnome.org/chergert/ptyxis)                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/ptyxis/status_image/last_build.png?)                                           |
| [rom-properties](https://copr.fedorainfracloud.org/coprs/bazzite-org/rom-properties/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/rom-properties/package/rom-properties/status_image/last_build.png?)                           |
| [steamdeck-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)                                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/jupiter-kmod/status_image/last_build.png?)                                      |
| [system76-scheduler](https://copr.fedorainfracloud.org/coprs/bazzite-org/system76-scheduler/)                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/system76-scheduler/package/system76-scheduler/status_image/last_build.png?)                   |
| [wallpaper-engine-kde-plugin](https://copr.fedorainfracloud.org/coprs/bazzite-org/wallpaper-engine-kde-plugin/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/wallpaper-engine-kde-plugin/package/wallpaper-engine-kde-plugin/status_image/last_build.png?) |
| [webapp-manager](https://copr.fedorainfracloud.org/coprs/bazzite-org/webapp-manager/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/bazzite-org/webapp-manager/package/webapp-manager/status_image/last_build.png?)                           |

## Verificatie

De images worden getekend door sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). U kunt de tekening verifieren om `cosign.pub` te downloaden en het volgende in de terminal te voegen:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

> [!WARNING]  
> **Steam Deck Gebruikers: De Steam Deck komt niet met Secure Boot aan en komt zonder sleutels ingeschakeld. Zet dit niet aan behalven als je ABSOLUUT weet wat je doet.**

Secure boot is beschikbaar met onze eigen sleutel. De pub sleutel kan [hier](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der) gevonden worden.
Als je de sleutel voor installatie wilt gebruiken, voeg dit in de terminal in:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

Voor gebruikers die de Universal Blue image al gebruiken kun je `ujust enroll-secure-boot-key` in de terminal voegen.

Als er voor een wachtwoord gevraagd wordt, gebruik `universalblue`.

### Bijdragers Metriek

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

#### Ster Geschiedenis

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Speciale Dank

Bazzite is een gemeenschapsinspanning en bestaat niet zonder hen. Zie hieronder mensen die ons hulp hebben verleend since het begin:

- [rei.svg](https://github.com/reisvg) - Voor het creëren van ons logo en branding.
- [SuperRiderTH](https://github.com/SuperRiderTH) - Voor het creëren van de Steam Game Mode start video.
- [evlaV](https://gitlab.com/evlaV) - Om Valve's code beschikbaar te maken en om [dit persoon](https://xkcd.com/2347/) te zijn.
- [ChimeraOS](https://chimeraos.org/) - Voor gamescope-sessies en voor belangrijk hulp.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - Met de hulp van techische problemen en het maken van projecten net als Bazzite. Serieus, ge kijken. Het is onze op Nix gebaseerde neef.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - Voor hulp met kernel patches en de [kernel-fsync repo](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) die wij nu gebruiken.
- [nicknamenamenick](https://github.com/nicknamenamenick) - Om de VIP te zijn met het onderhoud van onze documentatie en met tallozen keren hulp geven aan onze gebruikers.
- [Steam Deck Homebrew](https://deckbrew.xyz) - Om ons te ondersteunen ondanks het extra werk, met speciale dank aan [PartyWumpus](https://github.com/PartyWumpus) om Decky Loader beschikbaar te maken onder SELinux.
- [cyrv6737](https://github.com/cyrv6737) - Voor de inspiratie en de basis die bazzite-arch werd.

## Zelf Bouwen

Bazzite word in z'n geheel in Github gemaakt en je eigen versie maken is even makkelijk als deze repo forken, een prive sleutel toe te voegen en GithubActions in te schakelen.

[Zie hier](https://docs.github.com/en/actions/security-guides/encrypted-secrets) om geheimen te behouden op GitHub. Je moet  [nieuwe sleutels genereren](https://docs.sigstore.dev/cosign/overview/) met cosign. De publieke sleutel kan in jou repo gezet worden. <sub><sup>(Jou gebruikers hebben het nodig om de signatures te checken)</sup></sub> en je kan je prive sleutel in `Settings -> Secrets -> Actions` toevoegen met de naam  `SIGNING_SECRET`.

We hebben ook een populaire config voor de [pull app](https://github.com/apps/pull) als je jou fork up-to-date wilt houden met upstream.Zet deze app aan in jou repo on Bazzite updates te gebruiken zodra die uitkomen terwijl je zelf ook dingen kan veranderen.

## Lid worden

Je kunt ons vinden in de  [Universal Blue Discord](https://discord.gg/f8MUghG5PB) en de [archive](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) zien van hulp threads zonder een account.

Discusieer en creër gebruikers gidsen in de [Universal Blue Discourse Forums](https://universal-blue.discourse.group/c/bazzite/5).

Volg Universal Blue op [Mastodon](https://fosstodon.org/@UniversalBlue).
