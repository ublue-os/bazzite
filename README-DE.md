<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [🇨🇳](https://github.com/ublue-os/bazzite/blob/main/README-zh-cn.md) [🇫🇷](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [🇧🇷](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md) [🇷🇺](https://github.com/ublue-os/bazzite/blob/main/README-RU.md) [🇩🇪](https://github.com/ublue-os/bazzite/blob/main/README-DE.md) [🇹🇼](https://github.com/ublue-os/bazzite/blob/main/README-ZH-TW.md)

<p align="center">
  <a href="https://download.bazzite.gg/"><img src="/repo_content/download.png?raw=true" alt="Bazzite herunterladen"/></a>
</p>

---

# Inhaltsverzeichnis

- [🇺🇸 🇪🇸 🇮🇩 🇨🇳 🇫🇷 🇧🇷 🇳🇱 🇷🇺 🇩🇪 🇹🇼](#---------)
- [Inhaltsverzeichnis](#inhaltsverzeichnis)
  - [Über \& Funktionen](#über--funktionen)
    - [Desktop](#desktop)
    - [Steam Deck/Home Theater PCs (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
      - [Alternative Handhelds](#alternative-handhelds)
    - [GNOME](#gnome)
    - [Funktionen von Upstream](#funktionen-von-upstream)
      - [Universal Blue](#universal-blue)
      - [Funktionen von Fedora Linux (Kinoite \& Silverblue)](#funktionen-von-fedora-linux-kinoite--silverblue)
  - [Warum](#warum)
  - [Galerie](#galerie)
  - [Dokumentation](#dokumentation)
  - [Verifizierung](#verifizierung)
  - [Secure Boot](#secure-boot)
  - [Mitwirkenden-Statistiken](#mitwirkenden-statistiken)
  - [Star-Verlauf](#star-verlauf)
  - [Besonderer Dank](#besonderer-dank)
  - [Eigene Version erstellen](#eigene-version-erstellen)
  - [Trete der Community bei](#trete-der-community-bei)

---

## Über & Funktionen

Für eine einsteigerfreundliche Erklärung von Bazzite [besuche bitte unsere Website](https://bazzite.gg/) (Englisch). Dieses Readme behandelt alles ausführlich.

[Bazzite](https://bazzite.gg/) ist ein angepasstes [Fedora Atomic](https://fedoraproject.org/atomic-desktops/)-Image, das mit [Cloud Native](https://universal-blue.org/#cloud-native)-Technologie erstellt wurde und das Beste des Linux-Gamings auf **alle deine Geräte bringt – einschließlich deines bevorzugten Handhelds**.

Bazzite basiert auf [ublue-os/main](https://github.com/ublue-os/main) und [ublue-os/nvidia](https://github.com/ublue-os/nvidia) unter Verwendung der [Fedora](https://fedoraproject.org/)-Technologie. Dies bedeutet erweiterte Hardware-Unterstützung und integrierte Treiber. Zusätzlich bietet Bazzite die folgenden Funktionen:

- Verwendet den [Bazzite-Kernel](https://github.com/bazzite-org/kernel-bazzite), um HDR und erweiterte Hardware-Unterstützung zu ermöglichen, neben zahlreichen anderen enthaltenen Patches – basierend auf dem [fsync-Kernel](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/).
- HDR im Spielmodus verfügbar.
- NVK auf Nicht-Nvidia-Builds verfügbar.
- Volle Hardware-beschleunigte Codec-Unterstützung für H264-Dekodierung.
- Volle Unterstützung für AMDs ROCM OpenCL/HIP Run-times.
- [xone](https://github.com/medusalix/xone)-Treiber für Xbox-Controller.
- Volle Unterstützung für [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Enthält Valves KDE-Designs von SteamOS.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud) und [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) standardmäßig installiert und verfügbar.
- [Patched Switcheroo-Control](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) das die standardmäßig defekte iGPU/dGPU-Umschaltung behebt.
- [ROM Properties Page shell extension](https://github.com/GerbilSoft/rom-properties) enthalten.
- Volle Unterstützung für [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) vorinstalliert.
- Vereinfachte Davinci Resolve-Installation mit [davincibox](https://github.com/zelikos/davincibox) (`ujust install-resolve`)
- [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) wird standardmäßig in allen Images verwendet. Dieses Terminal wurde speziell für den Container-Workflow entwickelt, den du in Bazzite nutzen wirst. KDE Konsole und GNOME Console können bei Bedarf als Flatpaks installiert werden.
- Automatischer `duperemove`-Dienst zur Reduzierung des von Wine-Prefix-Inhalten belegten Speicherplatzes.
- Unterstützung für HDMI CEC über [libCEC](https://libcec.pulse-eight.com/).
- Verwendet standardmäßig [Google's BBR TCP congestion control](https://github.com/google/bbr).
- [Input Remapper](https://github.com/sezanzeb/input-remapper) vorinstalliert und aktiviert. <sub><sup>(Verfügbar, aber standardmäßig deaktiviert auf der Deck-Variante, kann mit `ujust restore-input-remapper` aktiviert werden)</sup></sub>
- [Waydroid](https://waydro.id/) vorinstalliert für die Ausführung von Android-Apps. Richte es mit dieser [Kurzanleitung (Englisch)](https://docs.bazzite.gg/Installing_and_Managing_Software/Waydroid_Setup_Guide/) ein.
- Verwalte Anwendungen mit [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse) und [Gear Lever](https://github.com/mijorus/gearlever).
- [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) i2c-piix4- und i2c-nct6775-Treiber zur Steuerung von RGB auf bestimmten Motherboards.
- [OpenRazer](https://openrazer.github.io)-Treiber integriert. Führe `ujust install-openrazer` in einem Terminal aus, um es zu verwenden.
- [OpenTabletDriver](https://opentabletdriver.net/) udev rules integriert, mit der vollständigen Softwaresuite, die durch Ausführen von `ujust install-opentabletdriver` in einem Terminal installiert werden kann.
- Out-of-the-Box-Unterstützung für [Wooting](https://wooting.io/)-Tastaturen.
- Integrierte Unterstützung für Southern Islands <sub><sup>(HD 7000)</sup></sub> und Sea Islands <sub><sup>(HD 8000)</sup></sub> AMD GPUs unter dem `amdgpu`-Treiber.
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) ist für Discord-Screensharing unter Wayland verfügbar.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) ist verfügbar, um Anwendungen aus Websites für eine Vielzahl von Browsern, einschließlich Firefox, zu erstellen.

### Desktop

Standardvariante, verfügbar als `bazzite`, geeignet für Desktop-Computer.

- Automatische Updates für das OS, Flatpaks und mehr – angetrieben von [ublue-update](https://github.com/ublue-os/ublue-update) und [topgrade](https://github.com/topgrade-rs/topgrade).

> [!IMPORTANT]
> **ISOs können von unserer [Website](https://download.bazzite.gg) heruntergeladen werden, und eine hilfreiche Installationsanleitung findest du [hier](https://docs.bazzite.gg/General/Installation_Guide/) (Englisch).**

Rebase von einem bestehenden Upstream Fedora Atomic auf dieses Image, wenn du **Open-Source-GPU-Treiber** nutzen möchtest:
(Bitte beachte: Mesas Open-Source-Option für NVIDIA GPUs, NVK, ist zum Zeitpunkt der Erstellung dieses Dokuments noch fehleranfällig. Bei Problemen mit NVK [reiche bitte einen Bericht bei Mesa ein](https://docs.mesa3d.org/bugs.html), nicht bei Ublue/Bazzite.)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

oder für Geräte mit Nvidia GPUs, die die **proprietären NVIDIA-Treiber** wünschen:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**Für Benutzer mit aktiviertem Secure Boot:** Beachte unsere [secure boot documentation](#secure-boot) vor dem Rebase.

### Steam Deck/Home Theater PCs (HTPCs)

Diese Variante wurde für die Nutzung als Alternative zu SteamOS auf dem Steam Deck und für ein Konsolen-ähnliches Erlebnis auf HTPCs entwickelt, verfügbar als `bazzite-deck`:

- Bootet direkt in den Spielmodus, passend zum Verhalten von SteamOS.
- **Automatisches `duperemove` reduziert die Größe von Compatdata erheblich.**
- **Die neueste Version von Mesa erzeugt kleinere Shader-Caches und benötigt diese nicht, um Ruckler zu verhindern.**
- **Kann auch bei vollem Laufwerk gestartet werden.**
- **Unterstützung für jede von Upstream Fedora unterstützte Sprache.**
- **Nutzt Wayland auf dem Desktop mit [Unterstützung für Steam Input](https://github.com/Supreeeme/extest).**
- Enthält [HHD](https://github.com/hhd-dev/hhd) für erweiterte Eingabeunterstützung auf Nicht-Valve-Handhelds.
- Bietet portierte Versionen der meisten SteamOS-Pakete, einschließlich Treiber, Firmware-Updater und Lüftersteuerungen [aus dem evlaV-repository](https://gitlab.com/evlaV).
- Gepatchtes Mesa für präzise Framerate-Kontrolle von Gamescope.
- Kommt standardmäßig mit Patches von [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) für volle BTRFS-Unterstützung der SD-Karte.
- Liefert eine portierte Kopie von [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU) mit, die standardmäßig aktiviert ist.
- Option zur Installation von [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/) und [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), neben zahlreichen anderen nützlichen Paketen während der Installation.
- Ein benutzerdefiniertes Update-System ermöglicht es, das OS, Flatpaks und mehr direkt über die Game-Mode-UI zu aktualisieren, angetrieben von [ublue-update](https://github.com/ublue-os/ublue-update) und [topgrade](https://github.com/topgrade-rs/topgrade).
- Integrierte Unterstützung für Windows-Dual-Boot dank der intakten Fedora-Installation von GRUB.
- Update hat etwas kaputt gemacht? Rolle dank der Rollback-Funktion von `rpm-ostree` einfach zur vorherigen Bazzite-Version zurück. Du kannst sogar frühere Images beim Booten auswählen.
- Steam und Lutris sind als Layered Packages auf dem Image vorinstalliert.
- [Discover Overlay](https://github.com/trigg/Discover) für Discord ist vorinstalliert und startet automatisch sowohl im Spielmodus als auch auf dem Desktop, wenn Discord installiert ist. [Die offizielle Dokumentation findest du hier](https://trigg.github.io/Discover/bazzite).
- Verwendet standardmäßig ZRAM<sub><sup>(4GB)</sup></sub> mit dem LZ4-Komprimierungsalgorithmus.
- [LAVD](https://crates.io/crates/scx_lavd) und [BORE](https://github.com/firelzrd/bore-scheduler) CPU-Scheduler für flüssiges und reaktionsschnelles Gameplay.
- Kyber I/O-Scheduler, um I/O-Engpässe bei der Installation von Spielen oder während des `duperemove`-Hintergrundprozesses zu verhindern.
- Wendest SteamOS' Kernel-Parameter an.
- Farbkalibrierte Anzeigeprofile für matte und spiegelnde Steam Deck-Bildschirme enthalten.
- Standardmäßig deaktivierte Power-User-Funktionen, einschließlich:
  - Dienst für risikoarmes Undervolting des Steam Deck sowie von AMD Framework Laptops über [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) und [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), siehe `ryzenadj.service` und `/etc/default/ryzenadj`.
  - Integrierte Unterstützung für Display-Übertaktung. Füge zum Beispiel `CUSTOM_REFRESH_RATES=30-68` zu `/etc/environment` hinzu. Minimale und maximale Bildwiederholraten unterscheiden sich je nach Handheld!
  - 32GB RAM-Mod für dein Steam Deck? Genieße die doppelte maximale VRAM-Menge, automatisch angewendet. <sup><sub>(Kannst du uns deine Lötkenntnisse mitteilen?)</sub></sup>
- Steam Deck-Hardware-spezifische Dienste können durch Ausführen von `ujust disable-bios-updates` und `ujust disable-firmware-updates` im Terminal deaktiviert werden. Diese werden auf Nicht-Deck-Hardware und auf Decks mit DeckHD-Displays oder 32GB RAM-Mods automatisch deaktiviert.
- Weitere Informationen zu den Bazzite Steam Deck Images findest du [hier](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Steam_Gaming_Mode/).

> [!IMPORTANT]
> **ISOs können von unserer [Website](https://download.bazzite.gg) heruntergeladen werden, und eine hilfreiche Installationsanleitung findest du [hier](https://docs.bazzite.gg/General/Installation_Guide/) (Englisch).**

Rebase von einem bestehenden Upstream Fedora Atomic auf dieses Image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Alternative Handhelds

Bitte beziehe dich auf unser [Handheld-Wiki](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Handheld_Wiki/) für notwendige Einstellungen und Decky Loader-Plugins für den Steam Gaming Mode auf deinem spezifischen Handheld.

**Stelle sicher, dass du auch die [hhd-Dokumentation](https://github.com/hhd-dev/hhd#after-install) liest; einige Handhelds erfordern spezifische Einstellungänderungen/Anpassungen, um ordnungsgemäß zu funktionieren.**

Wir liefern auch `ujust`-Befehle mit, um verschiedene [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck)-Themes zu installieren, die im CSS Loader Store nicht gefunden werden können. Diese werden automatisch mit Bazzite aktualisiert, falls installiert.

```bash
# Install Handheld Controller Theme (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme
```

### GNOME

Builds mit der GNOME-Desktop-Umgebung sind sowohl in Desktop- als auch in Deck-Varianten verfügbar. Diese Builds bieten folgende zusätzliche Funktionen:

- [Unterstützung für variable Bildwiederholfrequenz und fraktionelle Skalierung unter Wayland aktiviert](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Benutzerdefiniertes Menü in der oberen Leiste zur Rückkehr zum Spielmodus, zum Starten von Steam und zum Öffnen einer Reihe nützlicher Dienstprogramme.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) vorinstalliert und einsatzbereit.
- [Hanabi Extension](https://github.com/jeffshee/gnome-ext-hanabi) enthalten, um ähnliche Funktionen wie Wallpaper Engine in KDE zu bieten.
- Zahlreiche optionale Erweiterungen vorinstalliert, einschließlich [wichtiger Korrekturen für die Benutzererfahrung](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Automatische Updates für das [Firefox GNOME Theme](https://github.com/rafaelmardojai/firefox-gnome-theme) und das [Thunderbird GNOME Theme](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sub><sup>(Falls installiert)</sup></sub>

> [!IMPORTANT]
> **ISOs können von unserer [Website](https://download.bazzite.gg) heruntergeladen werden, und eine hilfreiche Installationsanleitung findest du [hier](https://docs.bazzite.gg/General/Installation_Guide/) (Englisch).**

Rebase von einem bestehenden Upstream Fedora Atomic auf dieses Image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

Um ein bestehendes ostree-System auf eine Desktop-Umgebung mit der Version für die **proprietären NVIDIA-Treiber** zu rebasen:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

Um ein bestehendes ostree-System auf die **Steam Deck/HTPC-Version** zu rebasen:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**Für Benutzer mit aktiviertem Secure Boot:** Beachte unsere [Secure-Boot-Dokumentation](#secure-boot) (Englisch) vor dem Rebase.

### Funktionen von Upstream

#### Universal Blue

- Proprietäre Nvidia-Treiber vorinstalliert. <sub><sup>(Nur für Nvidia-Images)</sup></sub>
- Flathub ist standardmäßig aktiviert.
- [`ujust`](https://github.com/casey/just)-Befehle für mehr Komfort.
- Multimedia-Codecs direkt nach der Installation verfügbar.
- Rolle Bazzite von jedem Build der letzten 90 Tage zurück.

#### Funktionen von Fedora Linux (Kinoite & Silverblue)

- Eine absolut solide und stabile Basis.
- Systempakete bleiben relativ aktuell.
- Kann Fedora-Pakete dem Image hinzufügen, ohne sie bei Updates zu verlieren.
- Sicherheitsorientiert mit [SELinux](https://github.com/SELinuxProject/selinux) vorinstalliert und direkt nach der Installation konfiguriert.
- Die Möglichkeit, bei Bedarf auf verschiedene Fedora Atomic Images zu rebasen, ohne Benutzerdaten zu verlieren.
- Druckunterstützung dank vorinstalliertem [CUPS](https://www.cups.org/).

## Warum

Bazzite begann als Projekt, um einige der Probleme zu lösen, die SteamOS plagen, hauptsächlich veraltete Pakete (trotz einer Arch-Basis) und das Fehlen eines funktionalen Paketmanagers.

Obwohl dieses Projekt ebenfalls Image-basiert ist, kannst du jedes Fedora-Paket direkt über die Kommandozeile installieren. Diese Pakete bleiben über Updates hinweg erhalten <sub><sup>(Also los, installiere die obskure VPN-Software, für die du in SteamOS eine Stunde gebraucht hast, um sie zum Laufen zu bringen)</sup></sub>. Zusätzlich wird Bazzite mehrmals pro Woche mit Paketen von Upstream Fedora aktualisiert, was dir die bestmögliche Leistung und die neuesten Funktionen bietet – alles auf einer stabilen Basis.

Bazzite wird standardmäßig mit dem neuesten Linux-Kernel und aktiviertem SELinux ausgeliefert, mit voller Unterstützung für Secure Boot <sub><sup>(Führe `ujust enroll-secure-boot-key` aus und gib bei Aufforderung das Passwort `universalblue` ein, um unseren Schlüssel zu registrieren)</sup></sub> und Festplattenverschlüsselung, was es zu einer sinnvollen Lösung für den allgemeinen Gebrauch macht. <sup><sub>(Ja, du kannst von Bazzite aus drucken)</sub></sup>

Lese die [FAQ](https://docs.bazzite.gg/General/FAQ/) für Details dazu, was Bazzite von anderen Linux-basierten Betriebssystemen unterscheidet.

## Galerie

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Dokumentation

- [Anwendungen installieren und verwalten](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [Updates, Rollbacks und Rebasing](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/)
- [Gaming-Anleitung](https://docs.bazzite.gg/Gaming/)

Sieh dir [weitere Dokumentation](http://docs.bazzite.gg/) zum Projekt an.

## Verifizierung

Diese Images sind mit Sigstores [Cosign](https://docs.sigstore.dev/cosign/signing/overview/) signiert. Du kannst die Signatur überprüfen, indem du den `cosign.pub`-Schlüssel aus diesem Repo herunterlädst und den folgenden Befehl ausführst:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

> [!WARNING]
> **Steam Deck-Benutzer: Das Steam Deck wird nicht mit aktiviertem Secure Boot ausgeliefert und enthält standardmäßig keine registrierten Schlüssel. Aktiviere dies nicht, es sei denn, du weißt genau, was du tust.**

Secure Boot wird mit unserem benutzerdefinierten Schlüssel unterstützt. Der öffentliche Schlüssel ist im Root-Verzeichnis dieses Repositories [hier](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der) zu finden.
Wenn du diesen Schlüssel vor der Installation oder dem Rebase registrieren möchtest, lade den Schlüssel herunter und führe Folgendes aus:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

Für Benutzer, die bereits ein Universal Blue Image verwenden, kannst du stattdessen `ujust enroll-secure-boot-key` ausführen.

Falls nach einem Passwort gefragt wird, verwende `universalblue`.

## Mitwirkenden-Statistiken

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

## Star-Verlauf

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Besonderer Dank

Bazzite ist eine Gemeinschaftsleistung und würde ohne die Unterstützung aller nicht existieren. Im Folgenden sind einige der Personen aufgeführt, die uns auf diesem Weg geholfen haben:

- [amelia.svg](https://bsky.app/profile/ameliasvg.bsky.social) – Für die Erstellung unseres Logos und des gesamten Brandings.
- [SuperRiderTH](https://github.com/SuperRiderTH) – Für die Erstellung unseres Startvideos für den Steam Game Mode.
- [evlaV](https://gitlab.com/evlaV) – Dafür, dass Valve's Code verfügbar gemacht wurde und dafür, dass er [diese Person](https://xkcd.com/2347/) ist.
- [ChimeraOS](https://chimeraos.org/) – Für gamescope-session und für wertvolle Unterstützung auf unserem Weg.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) – Für die Unterstützung bei technischen Problemen und die Erstellung eines ähnlichen Projekts. Im Ernst, schau es dir an. Es ist unser Nix-basierter Cousin.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) – Für die Unterstützung bei benötigten Kernel-Patches und die Erstellung des [kernel-fsync-Repos](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/), das wir jetzt verwenden.
- [nicknamenamenick](https://github.com/nicknamenamenick) – Dafür, dass er der MVP war, der fast im Alleingang unsere Dokumentation und Support-Literatur gepflegt und unzählige Male Benutzern geholfen hat.
- [Steam Deck Homebrew](https://deckbrew.xyz) – Dafür, dass andere Distributionen als SteamOS trotz des Mehraufwands unterstützt werden, und ein besonderer Dank an [PartyWumpus](https://github.com/PartyWumpus) dafür, dass er Decky Loader für uns mit SELinux zum Laufen gebracht hat.
- [cyrv6737](https://github.com/cyrv6737) – Für die anfängliche Inspiration und die Basis, die zu Bazzite-Arch wurde.

## Eigene Version erstellen

Bazzite wird vollständig auf GitHub entwickelt, und das Erstellen einer eigenen, angepassten Version ist so einfach wie das Forken dieses Repositories, das Hinzufügen eines privaten Signierungsschlüssels und das Aktivieren von GitHub Actions.

[Mach dich vertraut](https://docs.github.com/en/actions/security-guides/encrypted-secrets) damit, wie du Geheimnisse auf GitHub sicher aufbewahrst. Du musst mit Cosign [ein neues Schlüsselpaar generieren](https://docs.sigstore.dev/cosign/signing/overview/). Der öffentliche Schlüssel kann in deinem öffentlichen Repo liegen <sub><sup>(Deine Benutzer benötigen ihn zur Überprüfung der Signaturen)</sup></sub>, und du kannst den privaten Schlüssel in `Settings -> Secrets -> Actions` mit dem Namen `SIGNING_SECRET` einfügen.

Wir liefern auch eine Konfiguration für die beliebte [Pull-App](https://github.com/apps/pull) mit, falls du deinen Fork mit dem Upstream synchron halten möchtest. Aktiviere diese App in deinem Repo, um Bazzite-Änderungen nachzuverfolgen und gleichzeitig deine eigenen Modifikationen vorzunehmen.

## Trete der Community bei

- Du findest uns auf dem [Universal Blue Discord](https://discord.gg/f8MUghG5PB)
  - Sieh dir das [archive](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) der Support-Threads ohne Konto an.

- Diskutiere und erstelle Benutzeranleitungen in den [Universal Blue Discourse Forums](https://universal-blue.discourse.group/c/bazzite/5).

- Folge Universal Blue auf [Mastodon](https://fosstodon.org/@UniversalBlue).

[**Sieh dir die vollständige Liste der Bazzite-Ressourcen und der sozialen Präsenz an**](https://docs.bazzite.gg/Resources/).
