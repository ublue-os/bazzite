<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [🇫🇷](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [🇧🇷](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md) [🇹🇼](https://github.com/ublue-os/bazzite/blob/main/README-ZH-TW.md)

<p align="center">
  <a href="https://bazzite.gg/#image-picker"><img src="/repo_content/download.png?raw=true" alt="Download Bazzite"/></a>
</p>

---
# Seleccionador de Imágenes
Usa nuestro [seleccionador de imágenes](https://bazzite.gg/#image-picker) para encontrar la imagen correcta basada en tu hardware y tus preferencias.

# Tabla de Contenidos
- [🇺🇸 🇪🇸 🇮🇩 🇫🇷 🇧🇷 🇳🇱 🇹🇼](#------)
- [Seleccionador de Imágenes](#seleccionador-de-imágenes)
- [Tabla de Contenidos](#tabla-de-contenidos)
  - [Acerca de y Características](#acerca-de-y-características)
    - [Computadoras de Escritorio](#computadoras-de-escritorio)
    - [Steam Deck/Computadoras para Cine en Casa (HTPCs)](#steam-deckcomputadoras-para-cine-en-casa-htpcs)
      - [Computadoras handheld alternativas](#computadoras-handheld-alternativas)
    - [GNOME](#gnome)
    - [Características del Upstream](#características-del-upstream)
      - [Universal Blue](#universal-blue)
      - [Características de Fedora Linux (Kinoite \& Silverblue)](#características-de-fedora-linux-kinoite--silverblue)
  - [¿Por qué?](#por-qué)
  - [Mira como luce Bazzite (Capturas de Pantalla)](#mira-como-luce-bazzite-capturas-de-pantalla)
  - [Documentación y Boletín informativo/Newsletters (En inglés)](#documentación-y-boletín-informativonewsletters-en-inglés)
  - [Verificación](#verificación)
  - [Arranque Seguro (Secure Boot)](#arranque-seguro-secure-boot)
  - [Métricas de Contribución](#métricas-de-contribución)
  - [Historial de Estrellas](#historial-de-estrellas)
  - [Gracias Especiales](#gracias-especiales)
  - [Hazlo tu Mismo](#hazlo-tu-mismo)
  - [Únete a la Comunidad](#únete-a-la-comunidad)

---

## Acerca de y Características

[Bazzite](https://bazzite.gg/) es una imagen OCI que sirve como un sistema operativo alterno para la [Steam Deck](https://www.steamdeck.com/), y como un sistema tipo SteamOS listo para jugar para computadoras de
escritorio, computadoras para cine en casa (HTPC), y un sinnúmero de
otras computadoras portátiles.

Bazzite es creado con [ublue-os/main](https://github.com/ublue-os/main) y [ublue-os/nvidia](https://github.com/ublue-os/nvidia) usando tecnología de [Fedora](https://fedoraproject.org/), lo que significa un soporte expandido de hardware y drivers incluidos. Adicionalmente, Bazzite añade las siguientes características:

- Utilizamos el [kernel fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) para obtener compatibilidad con HDR (alto rango dinámico) y un soporte expandido de hardware, además de otra gran cantidad de parches incluidos.
- HDR esta disponible en la sesión de Gamescope.
- Drivers propietarios de NVIDIA pre-instalados.
- Soporte total de decodificación acelerada por hardware del codec de video H264.
- Soporte completo para los tiempos de ejecución (runtimes) de ROCM OpenCL/HIP de AMD
- Se incluye el driver [xone](https://github.com/medusalix/xone), para mandos de videojuegos de Xbox.
- Soporte completo de [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Incluye los temas para KDE de SteamOS, hechos por Valve.
- También se incluyen temas opcionales de GTK3/4 inspirados en Valve, que igualan a los temas Vapor y VGUI2 de SteamOS. Para poderlos utilizar, solo tienes que instalar [Gradience](https://flathub.org/apps/com.github.GradienceTeam.Gradience).
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), y [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) instalados y disponibles por defecto.
- Utilizamos [TuneD](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/getting-started-with-tuned_monitoring-and-managing-system-status-and-performance) en lugar de PPD, para una integración completa con GNOME, KDE, y Game Mode. Esta es una herramienta tan increiblemente poderosa, que Red Hat ofrece [clases para aprender a utilizarla](https://www.redhat.com/en/services/training/rh442-red-hat-enterprise-performance-tuning).
- Incluida una [extensión de la shell para mostrar las propiedades de ROMs](https://github.com/GerbilSoft/rom-properties) (usados para la emulación de consolas) en el navegador de archivos.
- Soporte completo para [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) pre-instalado.
- Se usa por defecto la [terminal Ptyxis](https://gitlab.gnome.org/chergert/ptyxis) en todas las imágenes. Esta terminal esta especificamente diseñada para el flujo de trabajo basado en contenedores que usamos en Bazzite. Si deseas regresar a como estaba antes, simplemente ejecuta el siguiente comando en una terminal: `ujust _restore-original-terminal`
- Servicio automatizado `duperemove` incluido para reducir el espacio de disco utilizados por los contenidos de los prefijos de WINE.
- Soporte de HDMI CEC (para poder controlar todos los dispositivos conectados por HDMI) usando [libCEC](https://libcec.pulse-eight.com/).
- [System76-Scheduler](https://github.com/pop-os/system76-scheduler) pre-instalado, proveyendo ajustes automáticos de la prioridad de procesos a tu aplicación actualmente en uso, manteniendo al mínimo el tiempo que tu procesador (CPU) trabaja con procesos de fondo.
- Configuración personalizada del System76-Scheduler con reglas adicionales.
- Uso del [control de congestión TCP BBR hecho por Google](https://github.com/google/bbr) por defecto.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) pre-instalado y habilitado. <sub><sup>(Disponible pero desactivado por defecto en la variante Deck, puede ser habilitado ejecutando el siguiente comando en una terminal: `ujust _restore-input-remapper`)</sup></sub>
- El portal de Bazzite (Bazzite Portal) provee una manera fácil de instalar un sin fin de aplicaciones y ajustes, incluyendo la instalación de [LACT](https://github.com/ilya-zlobintsev/LACT) (para mejor controlar tu GPU de AMD) y [GreenWithEnvy](https://gitlab.com/leinardi/gwe) (para mejor controlar tu GPU de NVIDIA).
- [Waydroid](https://waydro.id/) pre-instalado para correr aplicaciones de Android. Para configurarlo, usa esta [guía rápida (en inglés)](https://universal-blue.discourse.group/docs?topic=32).
- Administra tus aplicaciones usando [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), y [Gear Lever](https://github.com/mijorus/gearlever).
- Drivers i2c-piix4 y i2c-nct6775 de [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) incluidos para controlar las luces RGB de ciertas tarjetas madre (motherboards).
- Drivers de [OpenRazer](https://openrazer.github.io) incorporados, Sólo selecciona OpenRazer en el Bazzite Portal o ejecuta el comando `ujust install-openrazer` en una terminal para empezar a usarlos.
- Reglas para udev de [OpenTabletDriver](https://opentabletdriver.net/) incorporadas, con la suite completa de software siendo instalable usando el Bazzite Portal ó ejecutando el comando `ujust install-opentabletdriver` en una terminal.
- Driver [GCAdapter_OC](https://github.com/hannesmann/gcadapter-oc-kmod) para aumentar la frecuencia del reloj (overclocking) del adaptador para el mando de videojuegos del Gamecube de Nintendo para obtener una taza de sondeo (polling rate) de 1000hz.
- Soporte fuera de la caja para los teclados hechos por [Wooting](https://wooting.io/).
- Soporte incorporado de las GPU de las familias <sub><sup>(HD 7000)</sup></sub> y Sea Islands <sub><sup>(HD 8000)</sup></sub> de AMD bajo el driver `amdgpu`.
- Un parche esta disponible [para un bug en juegos de 32 bits que usen el motor Source 1](https://github.com/ValveSoftware/Source-1-Games/issues/5043)<sub><sup>[(Por ejemplo: TF2)](https://github.com/ValveSoftware/Source-1-Games/issues/5043)</sup></sub> que provoca que el juego se congele al ser iniciado, para aplicar el parche, ejecuta el siguiente comando en una terminal: `ujust fix-source1-tcmalloc`
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) esta disponible para hacer posible compartir tu pantalla con Discord usando Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) esta disponible para crear aplicaciones de sitios web con una variedad de navegadores web, incluyendo Firefox.

### Computadoras de Escritorio

Esta variante común/genérica esta disponible como `bazzite`, la cual es adecuada para computadoras de escritorio, esta variante incluye la siguiente característica:

- Actualizaciones automáticas para el sistema operativo, Flatpaks y más.

> \[!IMPORTANT\]\
> **Las imágenes de disco (ISOs) pueden descargarse desde nuestra página de lanzamientos (releases) [aquí (en inglés)](https://github.com/ublue-os/bazzite/releases), también puedes encontrar una útil guía de instalación [aquí (en inglés)](https://universal-blue.discourse.group/docs?topic=30).**

Si estas actualmente usando una imagen de Universal Blue, por favor [sigue estas instrucciones (en inglés)](https://universal-blue.org/images/#image-list).

Si deseas cambiar la base (rebase) de una imagen upstream existente de un sistema ostree de Fedora Silverblue/Kinoite a la imagen **para computadoras de escritorio usando una GPU AMD o Intel**, ejecuta el siguiente comando en una terminal:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

Si deseas realizar un rebase a la imagen **para computadoras de escritorio con una GPU NVIDIA**, ejecuta el siguiente comando en una terminal:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**Para usuarios con Secure Boot habilitado:** Sigue nuestra [documentación para usuarios de Secure Boot](#secure-boot) antes de cambiar la base.

### Steam Deck/Computadoras para Cine en Casa (HTPCs)

> \[!IMPORTANT\]\
> Los dispositivos que **NO** son una Steam Deck también pueden utilizar las imágenes `bazzite-deck`, sin embargo tienen que usar una GPU de AMD moderna, se ha confirmado que las GPUs Intel ARC tambien funcionan.

Esta variante esta diseñada para usarse como una alternativa de SteamOS en la Steam Deck, e igualmente para proporcionar una experiencia como de consola de videojuegos en HTPCs y otros dispositivos portátiles, disponible como `bazzite-deck`:

- Al arrancar tu dispositivo, inicia directamente en Game Mode, emulando el mismo comportamiento que SteamOS.
- **Se aplica el servicio `duperemove` automáticamente el cual recorta por mucho el tamaño del directorio compatdata, el directorio usado por Proton para almacenar los prefijos de WINE para correr juegos de Windows en Linux.**
- **Incluye la versión mas actual de Mesa, el cual crea cachés de shaders mas pequeños, y los cuales no son requeridos para prevenir tirones/parones.**
- **Habilidad de arrancar el sistema incluso si el disco esta lleno.**
- **Soporte para cada uno de los lenguajes directamente soportados por Fedora (upstream).**
- **Uso del servidor gráfico Wayland en el escritorio con [soporte para Steam input](https://github.com/Supreeeme/extest).**
- Se incluye [HHD](https://github.com/hhd-dev/hhd) para expander el soporte de los mandos de videojuegos integrados en otras computadoras handheld que no sean de Valve
- Incluye versiones portadas de la mayoría de los paquetes de SteamOS, incluyendo drivers, actualizadores de firmware y controladores de ventiladores [del repositorio de evlaV](https://gitlab.com/evlaV).
- Version parchada de Mesa para controlar correctamente la tasa de fotogramas (framerate) usando Gamescope.
- Incluye los parches de [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) por defecto, los cuales proveen soporte completo del sistema de archivos BTRFS para tarjetas SD.
- Se incluye una copia portada de [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), habilitada por defecto.
- Opción para instalar [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), y [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), ademas de un sin fin de paquetes útiles al momento de instalar el sistema.
- Un sistema personalizado de actualizaciones que permite que tanto el sistema operativo, los Flatpaks, y más sean actualizables directamente desde la interfaz de Gamemode gracias al poder de [ublue-update](https://github.com/ublue-os/ublue-update) y [topgrade](https://github.com/topgrade-rs/topgrade).
- Soporte incluido para el arranque dual (dual-boot) con Windows, gracias a que se deja intacta la instalación de GRUB por defecto de Fedora.
- ¿Algo se rompió o dejo de funcionar después de actualizar?, ¡descuida!, puedes fácilmente retroceder a una versión previa de Bazzite, gracias a la función de reversión (rollback) de `rpm-ostree`. Inclusive puedes seleccionar imágenes previas del sistema directamente desde el menú que aparece al arrancar tu dispositivo.
- Steam y Lutris vienen pre-instalados en la imagen como paquetes en capas (layered).
- La utilidad [Discover Overlay](https://github.com/trigg/Discover) para Discord viene pre-instalada y es lanzada automáticamente tanto en Gamemode como en el escritorio, si Discord esta instalado. [Puedes ver la documentación oficial aquí (en inglés)](https://trigg.github.io/Discover/bazzite).
- Se incluye ZRAM<sub><sup>(4GB)</sup></sub>, un avanzado sistema de swap ubicado directamente en la memoria RAM, con el algoritmo de compresión de datos LZ4 por defecto.
- Se incluye el planificador (scheduler) Kyber I/O para prevenir la inanición (starvation) de E/S al instalar juegos o cuando el proceso `duperemove` corre en el fondo.
- Se aplican los parámetros del kernel de SteamOS.
- Se incluyen perfiles de color calibrados para los diferentes tipos de pantalla de la Steam Deck, mate o glossy.
- Características para usuarios avanzados que vienen desactivadas por defecto, las cuales incluyen:
  - Un servicio de bajo riesgo para reducir el voltaje de la Steam Deck gracias a [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) y [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), véase `ryzenadj.service` y `/etc/default/ryzenadj`.
  - Soporte incorporado para el overclock de la pantalla, es decir, para incrementar la tasa de refresco que el panel tiene por defecto (60Hz en modelos LCD). Por ejemplo, añade `GAMESCOPE_OVERRIDE_REFRESH_RATE=40,70` a `/etc/environment`.
  - La habilidad de utilizar el servidor gráfico X11 en vez de Wayland, si así se desea, tan solo editando `/etc/default/desktop-wayland`.
  - ¿Aplicaste el mod de 32 GB de memoria RAM en tu Steam Deck?, disfruta del doble de la cantidad máxima de VRAM, el cual es aplicado automáticamente. <sup><sub>(Hablando de, ¿crees que podrías compartirnos semejante habilidad para soldar?)</sub></sup>
- Servicios que son específicos para el hardware de la Steam Deck pueden ser deshabilitados simplemente ejecutando el siguiente comando en una terminal: `ujust disable-deck-services`, algo muy útil cuando tratas de usar esta variante en otras computadoras portátiles o HTPCs.
- Puedes encontrar más información acerca de las imágenes Steam Deck de Bazzite [aquí](https://universal-blue.discourse.group/docs?topic=37).

> \[!WARNING\]\
> **Debido a un bug en upstream, Bazzite no puede ser utilizado por el momento en Steam Decks con solo 64 GB de almacenamiento eMMC. Ampliar tu almacenamiento cambiando el disco interno soluciona este problema.**

> \[!IMPORTANT\]\
> **Las imágenes de disco (ISOs) pueden descargarse desde nuestra página de lanzamientos (releases) [aquí (en inglés)](https://github.com/ublue-os/bazzite/releases), también puedes encontrar una útil guía de instalación [aquí (en inglés)](https://universal-blue.discourse.group/docs?topic=30).**

Si estas actualmente usando una imagen de Universal Blue, por favor [sigue estas instrucciones (en inglés)](https://universal-blue.org/images/#image-list).

Si deseas cambiar la base (rebase) de una imagen upstream existente de un sistema ostree de Fedora Silverblue/Kinoite a la imagen **para Steam Deck/HTPCs**, ejecuta el siguiente comando en una terminal:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Computadoras handheld alternativas

**Igualmente, asegurate de tambien leer la [documentación de HHD (en inglés)](https://github.com/hhd-dev/hhd#after-install), algunas computadoras Handheld requieren ciertos ajustes o tweaks especificos para funcionar correctamente.**

Tambien incluimos ciertos comandos de `ujust` para instalar varios temas para [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck) que no estan disponibles en su propia tienda. Si instalas estos temas, estos tambien serán actualizados automáticamente junto con Bazzite.

### GNOME

Las sub-variantes con el entorno de escritorio GNOME están disponibles tanto para las imágenes para **Computadoras de Escritorio**, como las de **Steam Deck/HTPCs**. Estas imágenes cuentan con las siguientes características adicionales:

- [Soporte tanto para pantallas con tasa de refresco variable y como para la escala fraccional de la interfaz de usuario bajo el servidor gráfico Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Menú personalizado en la barra superior para regresar a Game Mode, lanzar Steam, y para abrir otras utilidades.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/), la versión de KDE Connect para GNOME, viene pre-instalado y listo para usarse.
- La [extension Hanabi](https://github.com/jeffshee/gnome-ext-hanabi) viene incluida, la cual ofrece características similares al Wallpaper Engine en KDE.
- Numerosas extensiones opcionales pre-instaladas, incluyendo [importantísimos parches para una mejor experiencia del usuario](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Actualizaciones automáticas para el [tema de GNOME para Firefox](https://github.com/rafaelmardojai/firefox-gnome-theme) y el [tema de GNOME para Thunderbird](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(Si se encuentran instalados)</sub></sup>

> \[!IMPORTANT\]\
> \**Las imágenes de disco (ISOs) pueden descargarse desde nuestra página de lanzamientos (releases) [aquí (en inglés)](https://github.com/ublue-os/bazzite/releases), también puedes encontrar una útil guía de instalación [aquí (en inglés)](https://universal-blue.discourse.group/docs?topic=30).**

Si deseas cambiar la base (rebase) a la imagen **para computadoras de escritorio con una GPU AMD ó Intel**, ejecuta el siguiente comando en una terminal:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

Si deseas realizar un rebase a la imagen **para computadoras de escritorio con una GPU NVIDIA**, ejecuta el siguiente comando en una terminal:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

> \[!WARNING\]\
> **Debido a un bug en upstream, Bazzite no puede ser utilizado por el momento en Steam Decks con solo 64 GB de almacenamiento eMMC. Ampliar tu almacenamiento cambiando el disco interno soluciona este problema.**

Si necesitas realizar un rebase a la imagen **para Steam Deck/HTPC con GPUs AMD modernas ó Intel ARC**, ejecuta el siguiente comando en una terminal:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```
**Para usuarios con Secure Boot habilitado:** Sigue nuestra [documentación para usuarios de Secure Boot](#secure-boot) antes de cambiar la base.

### Características del Upstream

#### Universal Blue

- Drivers propietarios de NVIDIA pre-instalados. <sub><sup>(Solo para imágenes NVDIA)</sup></sub>
- Flathub se encuentra habilitado por defecto.
- Lanzador de comandos [`ujust`](https://github.com/casey/just) incluido, con diversos comandos muy convenientes.
- Codecs multimedia fuera de la caja.
- Revierte tu instalación de Bazzite desde cualquier versión dentro de los últimos 90 días.

#### Características de Fedora Linux (Kinoite & Silverblue)

- Una base estable y sólida como una roca.
- Los paquetes del sistema se mantienen relativamente actualizados a su última versión.
- Puedes instalar paquetes de Fedora en capas (layered) sin que se pierdan entre actualizaciones.
- Enfocado en seguridad con [SELinux](https://github.com/SELinuxProject/selinux) pre-instalado y configurado fuera de la caja.
- La habilidad de cambiar de base (rebase) de una imagen atómica de Fedora, si así se desea, sin perder datos del usuario.
- Soporte para impresoras gracias a que el servidor de impresión [CUPS](https://www.cups.org/) viene pre-instalado.

## ¿Por qué?

Bazzite inicio como un proyecto para resolver los problemas que plagan SteamOS, principalmente los paquetes desactualizados (a pesar de estar basado en Arch Linux) y la carencia de un gestor de paquetes funcional.

A pesar que este proyecto también esta basado en imágenes, tienes la capacidad de instalar **cualquier** paquete de Fedora, directamente desde la terminal. Estos paquetes persistirán a través de las actualizaciones  <sub><sup>(Así que descuida, tu instala ese oscuro software de VPN con el que pasaste una hora y múltiples migrañas tratando de hacer funcionar en SteamOS)</sup></sub>. Ademas, Bazzite es actualizado múltiples veces a la semana con paquetes del upstream de Fedora, dándote el mejor rendimiento posible y las últimas características - todo con una base sólida y estable.

Bazzite se entrega con el kernel de Linux mas nuevo y SELinux esta habilitado por defecto con soporte completo de Secure Boot <sub><sup>(Ejecuta el comando `ujust enroll-secure-boot-key` en una terminal e introduce la contraseña  `universalblue` si es requerido para registrar nuestra llave de seguridad)</sup></sub>, además de soporte para la encriptación completa de tu disco, lo que convierte a Bazzite una opción razonable para la informática general. <sup><sub>(Así es, puedes mandar a imprimir el último reporte financiero de tu empresa con Bazzite)</sub></sup>

Lee nuestras [preguntas frecuentes](https://universal-blue.discourse.group/docs?topic=411) para saber más en lo que hace a Bazzite sobresalir de otras distribuciones de GNU Linux.

## Mira como luce Bazzite (Capturas de Pantalla)

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")

![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")

![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")

![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")

![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")

![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")

![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Documentación y Boletín informativo/Newsletters (En inglés)

- [Actualizaciones, Reversiones y Cambio de Base (Rebasing)](https://universal-blue.discourse.group/docs?topic=36)
- [Guía para Jugar en Linux](https://universal-blue.discourse.group/docs?topic=31)
- [Guía para Configurar el Arranque Dual con Windows (Dual Boot)](https://universal-blue.discourse.group/docs?topic=129)

Puedes encontrar documentación adicional relacionada al proyecto [aquí](http://docs.bazzite.gg/).

Checa nuestros [boletines informativos (disponibles en español](https://universal-blue.discourse.group/tag/bazzite-buzz), estos son publicados regularmente y los cuales hablan de las últimas actualizaciones del proyecto.

## Verificación

Estas imágenes son firmadas digitalmente con [cosign](https://docs.sigstore.dev/cosign/signing/overview/) de Sigstore. Para verificar la firma digital manualmente, primero tienes que descargar la llave `cosign.pub` directamente de este repositorio, y después, ejecuta el siguiente comando en una terminal:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Arranque Seguro (Secure Boot)

> [!WARNING]
> **Usuarios de la Steam Deck: La Steam Deck no viene con Arranque Seguro habilitado y no viene con ninguna llave registrada por defecto. No habilites esto a menos que estes seguro de lo que estes haciendo.**

El Arranque Seguro (Secure Boot) tiene soporte gracias a nuestra llave digital personalizada. La llave pública puede encontrarse en la raíz de [este](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der) repositorio.

Si gustas registrar esta llave antes de instalar Bazzite, descarga la llave y ejecuta el siguiente comando en una terminal:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```
Alternativamente, los usuarios que ya cuenten con una imagen de Universal Blue instalada, pueden ejecutar el siguiente comando en una terminal: `ujust enroll-secure-boot-key`.

Si se te pide una contraseña, introduce `universalblue`.

## Métricas de Contribución

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

## Historial de Estrellas

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Gracias Especiales

Bazzite es producto de esfuerzo comunitario, y no existiría sin la contribución de todos. A continuación, están listadas unas cuantas personas que nos han ayudado a lo largo del camino:

- [amelia.svg](https://bsky.app/profile/ameliasvg.bsky.social) - Por crear nuestro logo, y en general, nuestro branding.
- [SuperRiderTH](https://github.com/SuperRiderTH) - Por crear nuestro lindo video de arranque al iniciar el Game Mode de Steam.
- [evlaV](https://gitlab.com/evlaV) - Por ser [esta persona](https://xkcd.com/2347/) y liberar el código de Valve públicamente.
- [ChimeraOS](https://chimeraos.org/) - Por la creación de gamescope-session y su invaluable apoyo a lo largo del camino.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - Por brindarnos su soporte con problemas técnicos y por crear un proyecto similar. ¡En serio!, [chécalo](https://github.com/Jovian-Experiments/Jovian-NixOS), es nuestro primo basado en Nix.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - Por su asistencia con unos parches necesarios en el kernel, y por crear el repositorio [kernel-fsync repo](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) que usamos actualmente.
- [nicknamenamenick](https://github.com/nicknamenamenick) - Por ser el MVP, ya que casi por si solo, mantiene toda nuestra documentación general y de soporte, ademas de los innumerables casos donde ayuda a nuestros usuarios.
- [Steam Deck Homebrew](https://deckbrew.xyz) - Por escoger brindar soporte a otras distribuciones ademas de SteamOS, a pesar de todo el trabajo extra que esto conlleva, y damos gracias especiales a [PartyWumpus](https://github.com/PartyWumpus) por lograr que Decky Loader funcione con SELinux en Bazzite.
- [cyrv6737](https://github.com/cyrv6737) - Por la inspiración inicial para crear el proyecto, y la base que eventualmente se volvió [bazzite-arch](https://github.com/ublue-os/bazzite-arch).

## Hazlo tu Mismo

Bazzite esta construido enteramente en GitHub, y crear tu propia versión personalizada es muy fácil, tan solo crea un fork de este repositorio, añade tu propia llave digital privada, y habilita las acciones de GitHub.

[Familiarízate](https://docs.github.com/en/actions/security-guides/encrypted-secrets) en como mantener secretos en GitHub. Necesitaras [generar tus nuevas pares de claves](https://docs.sigstore.dev/cosign/signing/overview/) con cosign. La llave digital pública puede ubicarse en tu repositorio público <sub><sup>(Tus usuarios van a necesitar verificar las firmas digitales.)</sup></sub>, y puedes pegar tu llave digital privada en `Settings -> Secrets -> Actions` con el nombre `SIGNING_SECRET`.

También incluimos una configuración para la popular app de GitHub [Pull](https://github.com/apps/pull), por si gustas mantener tu fork en sincronía con el upstream. Habilita esta aplicación en tu repositorio para realizar un seguimiento de los cambios en Bazzite, mientras al mismo tiempo, haces tus propias modificaciones.

## Únete a la Comunidad

Puedes encontrarnos en el [Discord de Universal Blue (en inglés)](https://discord.gg/f8MUghG5PB) y puedes ver todo el archivo de los hilos de ayuda en nuestro [Answer Overflow](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769).

Discute y crea guias para los usuarios en nuestro [foro de Discourse de Universal Blue Discourse (en inglés)](https://universal-blue.discourse.group/c/bazzite/5).

Sigue a Universal Blue en [Mastodon](https://fosstodon.org/@UniversalBlue).
