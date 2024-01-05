<p align="center">
  <img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/>
</p>

![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)

---

# Tabla de Contenidos

- [Características de **todas** las imágenes de Bazzite](https://github.com/ublue-os/bazzite#about--features)
  - [Características de las imágenes para **Computadoras de Escritorio**](https://github.com/ublue-os/bazzite#desktop)
  - [Características de las imágenes para **Steam Deck/HTPC**](https://github.com/ublue-os/bazzite#steam-deckhome-theater-pcs-htpcs)
  - [Características de las imágenes con el entorno de escritorio **GNOME**](https://github.com/ublue-os/bazzite#gnome)
  - [Características de Upstream](https://github.com/ublue-os/bazzite#features-from-upstream)
- [¿Por qué?](https://github.com/ublue-os/bazzite#why)
- [Demostración (Capturas de Pantalla)](https://github.com/ublue-os/bazzite#showcase)
- [Documentación y Boletín informativo/Newsletters (En inglés)](https://github.com/ublue-os/bazzite#documentation--newsletters)
- [Paquetes personalizados](https://github.com/ublue-os/bazzite#custom-packages)
- [Verificación y Métricas](https://github.com/ublue-os/bazzite#verification)
- [Gracias Especiales](https://github.com/ublue-os/bazzite#special-thanks)
- [Créalo tu Mismo](https://github.com/ublue-os/bazzite#build-your-own)
- [Comunidad (en inglés)](https://github.com/ublue-os/bazzite#join-the-community)

---

## Acerca de y Características

Bazzite es una imagen OCI que sirve como un sistema operativo alterno para la [Steam Deck](https://www.steamdeck.com/), y como un sistema tipo SteamOS listo para jugar para computadoras de 
escritorio, computadoras para cine en casa (HTPC), y un sinnúmero de 
otras computadoras portátiles.

Bazzite es creado con [ublue-os/main](https://github.com/ublue-os/main) y [ublue-os/nvidia](https://github.com/ublue-os/nvidia) usando tecnología de [Fedora](https://fedoraproject.org/), lo que significa un soporte expandido de hardware y drivers incluidos. Adicionalmente, Bazzite añade las siguientes características:

- Drivers propietarios de NVIDIA pre-instalados.
- Soporte total de decodificación acelerada por hardware del codec de video H264.
- Soporte completo para los tiempos de ejecución (runtimes) de ROCM OpenCL/HIP de AMD
- Drivers [xone](https://github.com/medusalix/xone), [xpadneo](https://github.com/atar-axis/xpadneo), y [xpad-noone](https://github.com/ublue-os/xpad-noone) para mandos de videojuegos de Xbox.
- Soporte completo de [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Incluye los temas para KDE de SteamOS, hechos por Valve.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), y [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) instalados y disponibles por defecto.
- Soporte para [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Solo en KDE)</sup></sub>
- Incluida la [extensión de la shell para mostrar las propiedades de ROMs](https://github.com/GerbilSoft/rom-properties) (usados para la emulación de consolas) en el navegador de archivos.
- Soporte completo para [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) pre-instalado con actualizaciones automáticas para los contenedores creados.
- Servicios automatizados `duperemove` y `rmlint` incluidos para reducir el espacio de disco utilizados por los contenidos de los prefijos de WINE.
- Soporte de HDMI CEC (para poder controlar todos los dispositivos conectados por HDMI) usando [libCEC](https://libcec.pulse-eight.com/).
- [System76-Scheduler](https://github.com/pop-os/system76-scheduler) pre-instalado, proveyendo ajustes automáticos de la prioridad de procesos a tu aplicación actualmente en uso, manteniendo al mínimo el tiempo que tu procesador (CPU) trabaja con procesos de fondo.
- Configuración personalizada del System76-Scheduler con reglas adicionales.
- Uso del [control de congestión TCP BBR hecho por Google](https://github.com/google/bbr) por defecto.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) pre-instalado y habilitado. <sub><sup>(Disponible pero desactivado por defecto en la variante Deck, puede ser habilitado ejecutando el siguiente comando en una terminal: `ujust enable-input-remapper`)</sup></sub>
- El portal de Bazzite (Bazzite Portal) provee una manera fácil de instalar un sin fin de aplicaciones y ajustes, incluyendo la instalación de [LACT](https://github.com/ilya-zlobintsev/LACT) (para mejor controlar tu GPU de AMD) y [GreenWithEnvy](https://gitlab.com/leinardi/gwe) (para mejor controlar tu GPU de NVIDIA).
- Gestor de paquetes [Nix](https://nixos.org/) con la opción de instalar [Fleek](https://getfleek.dev/) usando el Bazzite Portal.
- Opción para instalar el gestor de paquetes [Brew](https://brew.sh/) usando el Bazzite Portal.
- [Waydroid](https://waydro.id/) pre-instalado para correr aplicaciones de Android. Para configurarlo, usa esta [guía rápida (en inglés)](https://universal-blue.discourse.group/docs?topic=32).
- Administra tus aplicaciones usando [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), y [Gear Lever](https://github.com/mijorus/gearlever).
- Drivers i2c-piix4 y i2c-nct6775 de [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) incluidos para controlar las luces RGB de ciertas tarjetas madre (motherboards).
- Drivers de [OpenRazer](https://openrazer.github.io) incorporados, Sólo selecciona OpenRazer en el Bazzite Portal o ejecuta el comando `ujust install-openrazer` en una terminal para empezar a usarlos.
- Reglas para udev de [OpenTabletDriver](https://opentabletdriver.net/) incorporadas, con la suite completa de software siendo instalable usando el Bazzite Portal ó ejecutando el comando `ujust install-opentabletdriver` en una terminal.
- Driver [GCAdapter_OC](https://github.com/hannesmann/gcadapter-oc-kmod) para aumentar la frecuencia del reloj (overclocking) del adaptador para el mando de videojuegos del Gamecube de Nintendo para obtener una taza de sondeo (polling rate) de 1000hz.
- Soporte fuera de la caja (out of the box) para los teclados hechos por [Wooting](https://wooting.io/).
- Soporte incorporado de las GPU de las familias <sub><sup>(HD 7000)</sup></sub> y Sea Islands <sub><sup>(HD 8000)</sup></sub> de AMD bajo el driver `amdgpu`.
- Un parche esta disponible [para un bug en juegos de 32 bits que usen el motor Source 1](https://github.com/ValveSoftware/Source-1-Games/issues/5043)<sub><sup>[(Por ejemplo: TF2)](https://github.com/ValveSoftware/Source-1-Games/issues/5043)</sup></sub> que provoca que el juego se bloqueé al ser iniciado, para aplicar el parche, ejecuta el siguiente comando en una terminal: `ujust patch-source1-tcmalloc`
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) esta disponible para hacer posible compartir tu pantalla con Discord usando Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) esta disponible para crear aplicaciones de sitios web con una variedad de navegadores web, incluyendo Firefox.

### Desktop

Common variant available as `bazzite`, suitable for desktop computers.

- Automatic updates for the OS, Flatpaks, Nix packages <sup><sub>(Via Fleek)</sub></sup>, and all Distrobox containers.

> \[!IMPORTANT\]\
> \*\***ISOs can be downloaded from our releases page [here](https://github.com/ublue-os/bazzite/releases), and a helpful install guide can be found [here](https://universal-blue.discourse.group/docs?topic=30).** If you experience any issues with installing Bazzite, then check out our [troubleshoot guide](https://universal-blue.discourse.group/docs?topic=34).

If you're on an existing Universal Blue image follow [these instructions](https://universal-blue.org/images/#image-list). To rebase an existing upstream Fedora Silverblue/Kinoite ostree system to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:latest
```

or for devices with Nvidia GPUs:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:latest
```

**For users with Secure Boot enabled:** Run `ujust enroll-secure-boot-key` and enter the password `ublue-os` if prompted to enroll the required key.

### Steam Deck/Home Theater PCs (HTPCs)

> \[!IMPORTANT\]\
> Devices that are NOT the Steam Deck can still use the bazzite-deck images, but must use an AMD/Intel GPU.

Variant designed for usage as an alternative to SteamOS on the Steam Deck, and for a console-like experience on HTPCs, available as `bazzite-deck`:

- Directly boots to Gamemode matching SteamOS's behavior.
- **Automatic `duperemove` greatly trims the size of compatdata.**
- **Latest version of Mesa creates smaller shader caches and does not require them to prevent stutter.**
- **Able to be booted even if the drive is full.**
- **Support for every language supported by upstream Fedora.**
- **Uses Wayland on the desktop with [support for Steam input](https://github.com/Supreeeme/extest).**
- Features ported versions of most SteamOS packages, including drivers, firmware updaters, and fan controllers [from the evlaV repository](https://gitlab.com/evlaV).
- Patched Mesa for proper framerate control from Gamescope.
- Comes with patches from [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) for full BTRFS support for the SD card by default.
- Ships with a ported copy of [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), enabled by default.
- Option to install [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), and [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), among numerous other useful packages on installation.
- Custom update system allows for the OS, Flatpaks, Nix packages <sup><sub>(Via Fleek)</sub></sup>, and Distrobox images to be updated directly from the Gamemode UI.
- Built in support for Windows dual-boot thanks to Fedora's installation of GRUB being left intact.
- Update break something? Easily roll back to the previous version of Bazzite thanks to `rpm-ostree`'s rollback functionality. You can even select previous images at boot.
- Steam and Lutris preinstalled on the image as layered packages.
- [Discover Overlay](https://github.com/trigg/Discover) for Discord pre-installed and automatically launches in both Gamemode and on the Desktop if Discord is installed. [View the official documentation here](https://trigg.github.io/Discover/bazzite).
- Uses ZRAM<sub><sup>(4GB)</sup></sub> with the ZSTD compression algorithm by default with the option to switch back to a 1GB swap file and set a custom size for it if desired.
- Kyber I/O scheduler to prevent I/O starvation when installing games or during background `duperemove` and `rmlint` processes.
- Applies SteamOS's kernel parameters.
- Color calibrated display profiles for matte and reflective Steam Deck screens included.
- Default-disabled power-user features, including:
  - Service for low-risk undervolting of the Steam Deck via [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) and [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), see `ryzenadj.service` and `/etc/default/ryzenadj`.
  - Service for limiting the max charge level of the battery, see `batterylimit.service` and `/etc/default/batterylimit`. <sup><sub>(Works even when the device is off)</sub></sup>
  - Built in support for display overclocking. For example, add `GAMESCOPE_OVERRIDE_REFRESH_RATE=40,70` to `/etc/environment`.
  - Ability to use X11 on the desktop if desired by editing `/etc/default/desktop-wayland`.
  - 32GB RAM mod your Steam Deck? Enjoy double the maximum VRAM amount, automatically applied. <sup><sub>(Can you share your soldering skills?)</sub></sup>
- Steam Deck hardware-specific services can be disabled by running `ujust disable-deck-services` in the terminal, useful for trying this image on other handhelds or for use on HTPCs.
- More information can be found [here](https://universal-blue.discourse.group/docs?topic=37) on the Bazzite Steam Deck images.

> \[!WARNING\]\
> \*\***Due to an upstream bug, Bazzite cannot be used on Steam Decks with 64GB eMMC storage at this time. Upgrading the storage resolves the issue.**

> \[!IMPORTANT\]\
> \*\***ISOs can be downloaded from our releases page [here](https://github.com/ublue-os/bazzite/releases), and a helpful install guide can be found [here](https://universal-blue.discourse.group/docs?topic=30).** If you experience any issues with installing Bazzite, then check out our [troubleshoot guide](https://universal-blue.discourse.group/docs?topic=34).

If you're on an existing Universal Blue image follow [these instructions](https://universal-blue.org/images/#image-list). To rebase an existing upstream Fedora Silverblue/Kinoite ostree system to this image:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:latest
```

### GNOME

Builds with the GNOME desktop environment are available in both desktop and deck flavors. These builds come with the following additional features:

- [Variable refresh rate support and fractional scaling enabled under Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Custom menu in the top bar for returning to game mode, launching Steam, and opening a number of useful utilities.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) preinstalled and ready to use.
- Features optional Valve-inspired themes matching Vapor and VGUI2 from SteamOS.
- [Hanabi extension](https://github.com/jeffshee/gnome-ext-hanabi) included to offer similar features to Wallpaper Engine in KDE.
- Numerous optional extensions pre-installed, including [important user experience fixes](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Automatic updates for the [Firefox GNOME theme](https://github.com/rafaelmardojai/firefox-gnome-theme) and [Thunderbird GNOME theme](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(If installed)</sub></sup>

> \[!IMPORTANT\]\
> \*\***ISOs can be downloaded from our releases page [here](https://github.com/ublue-os/bazzite/releases), and a helpful install guide can be found [here](https://universal-blue.discourse.group/docs?topic=30).** If you experience any issues with installing Bazzite, then check out our [troubleshoot guide](https://universal-blue.discourse.group/docs?topic=34).

To rebase an existing ostree system to the **desktop** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:latest
```

To rebase an existing ostree system to the **desktop with Nvidia drivers** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:latest
```

> \[!WARNING\]\
> \*\***Due to an upstream bug, Bazzite cannot be used on Steam Decks with 64GB eMMC storage at this time.**

To rebase an existing ostree system to the **Steam Deck/HTPC** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:latest
```

### Features from Upstream

#### Universal Blue

- Flathub is enabled by default.
- [`ujust`](https://github.com/casey/just) commands for convenience.
- Multi-media codecs out of the box.
- Rollback Bazzite from any build within the last 90 days.

#### Features from Fedora Linux (Kinoite & Silverblue)

- A rock solid and stable base.
- System packages stay relatively up to date.
- Can layer Fedora packages to the image without losing them between updates.
- Security focused with [SELinux](https://github.com/SELinuxProject/selinux) preinstalled and configured out of the box.
- The ability to rebase to different Fedora libostree images, if desired, without losing user data.
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
- [Dual Booting Guide](https://universal-blue.discourse.group/docs?topic=129)
- [Miscellaneous Documentation](https://universal-blue.discourse.group/docs?topic=287)

Find additional documentation surrounding the project [here](https://universal-blue.discourse.group/docs).

Check out our [newsletters](https://universal-blue.discourse.group/tag/bazzite-buzz) that get published on a regular basis for updates on the project.

## Custom Packages

Ported SteamOS and ChimeraOS packages, among others used by Bazzite, are built on Copr in [bazzite](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/) and [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/).

| Package                                                                                             | Status                                                                                                                                                      |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| bluez                                                                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/bluez/status_image/last_build.png?)                              |
| [discover-overlay](https://github.com/trigg/Discover)                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/discover-overlay/status_image/last_build.png?)                            |
| ds-inhibit                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ds-inhibit/status_image/last_build.png?)                                  |
| duperemove                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/duperemove/status_image/last_build.png?)                                  |
| [extest](https://github.com/Supreeeme/extest)                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/extest/status_image/last_build.png?)                             |
| gamescope                                                                                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/gamescope/status_image/last_build.png?)                          |
| [gamescope-session-plus](https://github.com/ChimeraOS/gamescope-session)                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-plus/status_image/last_build.png?)                      |
| [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam)                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-steam/status_image/last_build.png?)                     |
| gamescope-shaders                                                                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-shaders/status_image/last_build.png?)                           |
| galileo-mura                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/galileo-mura/status_image/last_build.png?)                                |
| [gnome-randr-rust](https://github.com/maxwellainatchi/gnome-randr-rust)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-randr-rust/status_image/last_build.png?)                            |
| gnome-shell-extension-bazzite-menu                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-bazzite-menu/status_image/last_build.png?)          |
| [gnome-shell-extension-caribou-blocker](https://extensions.gnome.org/extension/1326/block-caribou/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-caribou-blocker/status_image/last_build.png?)       |
| [gnome-shell-extension-hanabi](https://github.com/jeffshee/gnome-ext-hanabi)                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hanabi/status_image/last_build.png?)                |
| [gnome-shell-extension-compiz-windows-effect](https://github.com/hermes83/compiz-windows-effect)    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-compiz-windows-effect/status_image/last_build.png?) |
| [hhd](https://github.com/antheas/hhd)                                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/hhd/status_image/last_build.png?)                                         |
| jupiter-fan-control                                                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)                         |
| jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| [mangohud](https://github.com/flightlessmango/MangoHud)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mangohud/status_image/last_build.png?)                           |
| mesa                                                                                                | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mesa/status_image/last_build.png?)                               |
| pipewire                                                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/pipewire/status_image/last_build.png?)                           |
| powerbuttond                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/powerbuttond/status_image/last_build.png?)                                |
| [python3-hid](https://github.com/apmorton/pyhidapi)                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/python3-hid/status_image/last_build.png?)                                 |
| rmlint                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/rmlint/status_image/last_build.png?)                                      |
| [ryzenadj](https://github.com/FlyGoat/RyzenAdj)                                                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ryzenadj/status_image/last_build.png?)                                    |
| [sdgyrodsu](https://github.com/kmicki/SteamDeckGyroDSU)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sdgyrodsu/status_image/last_build.png?)                                   |
| steamdeck-dsp                                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-dsp/status_image/last_build.png?)                               |
| steamdeck-gnome-presets                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-gnome-presets/status_image/last_build.png?)                     |
| steamdeck-kde-presets                                                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)                       |
| steamdeck-kde-presets-desktop                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets-desktop/status_image/last_build.png?)               |
| steam_notif_daemon                                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steam_notif_daemon/status_image/last_build.png?)                          |
| udisks2                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/udisks2/status_image/last_build.png?)                                     |
| upower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/upower/status_image/last_build.png?)                                      |
| vpower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/vpower/status_image/last_build.png?)                                      |
| wireplumber                                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/wireplumber/status_image/last_build.png?)                                 |
| xorg-x11-server-Xwayland                                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/xorg-x11-server-Xwayland/status_image/last_build.png?)           |

Additionally, the following packages are used from other Copr repos:

| Package                                                                                                       | Status                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [gcadapter_oc-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/gcadapter_oc-kmod/status_image/last_build.png?)                                 |
| [gnome-vrr](https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/)                                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/package/mutter/status_image/last_build.png?)                                        |
| [hl2linux-selinux](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/)                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/hl2linux-selinux/package/hl2linux-selinux/status_image/last_build.png?)                       |
| [joycond](https://copr.fedorainfracloud.org/coprs/kylegospo/joycond/)                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/joycond/package/joycond/status_image/last_build.png?)                                         |
| [kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/)                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/package/kernel/status_image/last_build.png?)                                        |
| [latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/)                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)                    |
| [noise-suppression-for-voice](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/)                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/package/noise-suppression-for-voice/status_image/last_build.png?)                       |
| [obs-vkcapture](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/package/obs-vkcapture/status_image/last_build.png?)                             |
| [prompt](https://gitlab.gnome.org/chergert/prompt)                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/prompt/package/prompt/status_image/last_build.png?)                                           |
| [rom-properties](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/package/rom-properties/status_image/last_build.png?)                           |
| [steamdeck-kmod](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/)                                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/akmods/package/jupiter-kmod/status_image/last_build.png?)                                      |
| [system76-scheduler](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/)                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/system76-scheduler/package/system76-scheduler/status_image/last_build.png?)                   |
| [VTFLib](https://copr.fedorainfracloud.org/coprs/kylegospo/VTFLib/)                                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/VTFLib/package/VTFLib/status_image/last_build.png?)                                           |
| [wallpaper-engine-kde-plugin](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/package/wallpaper-engine-kde-plugin/status_image/last_build.png?) |
| [webapp-manager](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/package/webapp-manager/status_image/last_build.png?)                           |

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

### Contributor Metrics

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

## Special Thanks

Bazzite is a community effort and wouldn't exist without everyone's support. Below are some of the people who've helped us along the way:

- [rei.svg](https://github.com/reisvg) - For creating our logo and overall branding.
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

You can find us on the [Universal Blue Discord](https://discord.gg/f8MUghG5PB) and view the archive of support threads on our [Answer Overflow](https://www.answeroverflow.com/c/1072614816579063828/1087140957096517672).

Discuss and create user guides over at the [Universal Blue Discourse Forums](https://universal-blue.discourse.group/c/bazzite/5).

Follow Universal Blue on [Mastodon](https://fosstodon.org/@UniversalBlue).
