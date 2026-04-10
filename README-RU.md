<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [🇨🇳](https://github.com/ublue-os/bazzite/blob/main/README-zh-cn.md) [🇫🇷](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [🇧🇷](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md) [🇷🇺](https://github.com/ublue-os/bazzite/blob/main/README-RU.md) [🇹🇼](https://github.com/ublue-os/bazzite/blob/main/README-ZH-TW.md)

<p align="center">
  <a href="https://download.bazzite.gg/"><img src="/repo_content/download.png?raw=true" alt="Скачать Bazzite"/></a>
</p>

---

# Содержание
- [🇺🇸 🇪🇸 🇮🇩 🇨🇳 🇫🇷 🇧🇷 🇳🇱 🇷🇺 🇹🇼](#--------)
- [Содержание](#содержание)
  - [О проекте и особенности](#о-проекте-и-особенности)
    - [Десктопная версия](#десктопная-версия)
    - [Steam Deck/Домашние кинотеатры (HTPC)](#steam-deckдомашние-кинотеатры-htpc)
      - [Альтернативные портативные устройства](#альтернативные-портативные-устройства)
    - [GNOME](#gnome)
    - [Особенности базовой системы](#особенности-базовой-системы)
      - [Universal Blue](#universal-blue)
      - [Особенности Fedora Linux (Kinoite и Silverblue)](#особенности-fedora-linux-kinoite-и-silverblue)
  - [Почему Bazzite?](#почему-bazzite)
  - [Демонстрация](#демонстрация)
  - [Документация](#документация)
  - [Проверка подлинности](#проверка-подлинности)
  - [Secure Boot](#secure-boot)
  - [Метрики участников](#метрики-участников)
  - [История звезд](#история-звезд)
  - [Особая благодарность](#особая-благодарность)
  - [Соберите свою версию](#соберите-свою-версию)
  - [Присоединяйтесь к сообществу](#присоединяйтесь-к-сообществу)
---

## О проекте и особенности

[Посетите наш сайт](https://bazzite.gg/) для удобного объяснения, что такое Bazzite. Этот файл README содержит подробную информацию.

[Bazzite](https://bazzite.gg/) — это пользовательский образ [Fedora Atomic](https://fedoraproject.org/atomic-desktops/), созданный с использованием [облачных технологий](https://universal-blue.org/#cloud-native), который предлагает лучшее для игр на Linux **на всех ваших устройствах, включая любимые портативные**.

Bazzite основан на [ublue-os/main](https://github.com/ublue-os/main) и [ublue-os/nvidia](https://github.com/ublue-os/nvidia) с использованием технологий [Fedora](https://fedoraproject.org/), что обеспечивает расширенную поддержку оборудования и встроенные драйверы. Дополнительно Bazzite включает следующие функции:

- Использует [ядро bazzite](https://github.com/bazzite-org/kernel-bazzite) для поддержки HDR и расширенной работы с оборудованием, а также множество других патчей.
- Поддержка HDR в игровом режиме.
- NVK доступен в сборках без NVIDIA.
- Полная поддержка аппаратного ускорения для декодирования H264.
- Полная поддержка ROCM OpenCL/HIP от AMD.
- Драйвер [xone](https://github.com/medusalix/xone) для контроллеров Xbox.
- Полная поддержка [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Включены темы KDE от Valve из SteamOS.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud) и [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) установлены по умолчанию.
- [Исправленный Switcheroo-Control](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) для корректного переключения между iGPU и dGPU.
- Расширение [ROM Properties Page](https://github.com/GerbilSoft/rom-properties) включено.
- Полная поддержка [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) предустановлен.
- Упрощенная установка Davinci Resolve с [davincibox](https://github.com/zelikos/davincibox) (`ujust install-resolve`).
- [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) используется по умолчанию. Этот терминал разработан для работы с контейнерами. KDE Konsole и GNOME Console можно установить как Flatpak.
- Автоматическая служба `duperemove` для уменьшения места, занимаемого wine-префиксами.
- Поддержка HDMI CEC через [libCEC](https://libcec.pulse-eight.com/).
- Используется [BBR TCP от Google](https://github.com/google/bbr) для управления перегрузкой сети.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) предустановлен и включен. <sub><sup>(Доступен, но отключен по умолчанию в версии для Deck; можно включить командой `ujust restore-input-remapper`)</sup></sub>
- Bazzite Portal предоставляет простой способ установки приложений и настроек, включая [LACT](https://github.com/ilya-zlobintsev/LACT).
- [Waydroid](https://waydro.id/) предустановлен для запуска Android-приложений. Инструкции по настройке [здесь](https://docs.bazzite.gg/Installing_and_Managing_Software/Waydroid_Setup_Guide/).
- Управление приложениями с помощью [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse) и [Gear Lever](https://github.com/mijorus/gearlever).
- Драйверы [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) i2c-piix4 и i2c-nct6775 для управления RGB на некоторых материнских платах.
- Драйверы [OpenRazer](https://openrazer.github.io) встроены. Выберите OpenRazer в Bazzite Portal или выполните `ujust install-openrazer` в терминале.
- Правила udev для [OpenTabletDriver](https://opentabletdriver.net/) встроены. Полный набор ПО можно установить через Bazzite Portal или командой `ujust install-opentabletdriver`.
- Поддержка клавиатур [Wooting](https://wooting.io/) из коробки.
- Поддержка AMD GPU серий Southern Islands <sub><sup>(HD 7000)</sup></sub> и Sea Islands <sub><sup>(HD 8000)</sup></sub> с драйвером `amdgpu`.
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) доступен для демонстрации экрана в Discord на Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) позволяет создавать приложения из веб-сайтов для различных браузеров, включая Firefox.

### Десктопная версия

Основная версия `bazzite` подходит для настольных компьютеров.

- Автоматические обновления ОС, Flatpak и другое — благодаря [ublue-update](https://github.com/ublue-os/ublue-update) и [topgrade](https://github.com/topgrade-rs/topgrade).

> [!IMPORTANT]
> **ISO-образы можно скачать с нашего [сайта](https://download.bazzite.gg), а руководство по установке доступно [здесь](https://docs.bazzite.gg/General/Installation_Guide/).**

Для перехода с существующей системы Fedora Atomic на этот образ (с **открытыми драйверами GPU**):
(Примечание: NVK, открытый драйвер Mesa для GPU NVIDIA, пока нестабилен. Проблемы с NVK следует [сообщать в Mesa](https://docs.mesa3d.org/bugs.html), а не в Ublue/Bazzite.)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```
или для устройств с видеокартами Nvidia, которым нужны проприетарные драйвера Nvidia
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```
**Для пользователей с Secure Boot:** Перед переходом следуйте [инструкциям по Secure Boot](#secure-boot).

### Steam Deck/Домашние кинотеатры (HTPC)
> [!IMPORTANT]
Устройства, отличные от Steam Deck, также могут использовать образы `bazzite-deck`, но требуют современного GPU AMD. Поддержка Intel Arc также подтверждена.

Версия `bazzite-deck` предназначена для использования как альтернатива SteamOS на Steam Deck и для консольного опыта на HTPC:

- Загрузка напрямую в игровой режим, как в SteamOS.
- **Автоматический `duperemove` значительно уменьшает размер compatdata.**
- **Последняя версия Mesa создает меньшие кэши шейдеров и не требует их для предотвращения лагов.**
- **Возможность загрузки даже при заполненном диске.**
- **Поддержка всех языков, доступных в Fedora.**
- **Использует Wayland на рабочем столе с [поддержкой Steam input](https://github.com/Supreeeme/extest).**
- Включен [HHD](https://github.com/hhd-dev/hhd) для расширенной поддержки ввода на портативных устройствах.
- Порты большинства пакетов SteamOS, включая драйверы, обновления прошивок и контроллеры вентиляторов [из репозитория evlaV](https://gitlab.com/evlaV).
- Исправленная Mesa для контроля частоты кадров в Gamescope.
- Патчи [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) для полной поддержки BTRFS на SD-картах.
- Включен порт [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU).
- Опция установки [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/) и [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/) при установке.
- Обновления ОС, Flatpak и другое доступны прямо из игрового режима благодаря [ublue-update](https://github.com/ublue-os/ublue-update) и [topgrade](https://github.com/topgrade-rs/topgrade).
- Поддержка двойной загрузки с Windows благодаря GRUB от Fedora.
- Возможность отката к предыдущей версии Bazzite благодаря функции `rpm-ostree`. Можно выбрать предыдущий образ при загрузке.
- Steam и Lutris предустановлены.
- [Discover Overlay](https://github.com/trigg/Discover) для Discord предустановлен и автоматически запускается в игровом режиме и на рабочем столе. [Документация](https://trigg.github.io/Discover/bazzite).
- ZRAM <sub><sup>(4GB)</sup></sub> с алгоритмом сжатия LZ4 по умолчанию.
- [LAVD](https://crates.io/crates/scx_lavd) и [BORE](https://github.com/firelzrd/bore-scheduler) для плавного геймплея.
- Планировщик ввода-вывода Kyber для предотвращения проблем при установке игр.
- Параметры ядра SteamOS.
- Цветовые профили для матовых и глянцевых экранов Steam Deck.
- Функции для опытных пользователей:
    - Уменьшение напряжения на Steam Deck и ноутбуках AMD через [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) и [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu) (`ryzenadj.service` и `/etc/default/ryzenadj`).
    - Разгон дисплея. Например, добавьте `CUSTOM_REFRESH_RATES=30-68` в `/etc/environment`. Минимальная и максимальная частота зависят от устройства!
    - Автоматическое увеличение VRAM для Steam Deck с 32GB RAM. <sup><sub>(Поделитесь навыками пайки?)</sub></sup>
- Аппаратные службы Steam Deck можно отключить командами `ujust disable-bios-updates` и `ujust disable-firmware-updates`. Они автоматически отключаются на других устройствах и на Deck с DeckHD или 32GB RAM.
- Подробнее [здесь](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Steam_Gaming_Mode/).

> [!WARNING]
> **Из-за ошибки в базовой системе Bazzite не поддерживает Steam Deck с 64GB eMMC. Замена хранилища решает проблему.**

> [!IMPORTANT]
> **ISO-образы можно скачать с нашего [сайта](https://download.bazzite.gg), а руководство по установке доступно [здесь](https://docs.bazzite.gg/General/Installation_Guide/).**

Для перехода с существующей системы Fedora Atomic:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Альтернативные портативные устройства

Инструкции для вашего устройства и плагины Decky Loader можно найти в [Handheld Wiki](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Handheld_Wiki/).

**Также прочитайте [документацию HHD](https://github.com/hhd-dev/hhd#after-install). Некоторые устройства требуют настроек.**

Команды `ujust` для установки тем [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck):

```bash
# Установка темы Handheld Controller (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme
```

### GNOME

Сборки с GNOME доступны для десктопов и Deck. Дополнительные функции:

- [Поддержка переменной частоты обновления и дробного масштабирования в Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Меню в верхней панели для возврата в игровой режим, запуска Steam и утилит.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) предустановлен.
- [Расширение Hanabi](https://github.com/jeffshee/gnome-ext-hanabi) для аналога Wallpaper Engine.
- Дополнительные расширения, включая [исправления для улучшения опыта](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Автоматические обновления тем [Firefox GNOME](https://github.com/rafaelmardojai/firefox-gnome-theme) и [Thunderbird GNOME](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(Если установлены)</sub></sup>

> [!IMPORTANT]
> **ISO-образы можно скачать с нашего [сайта](https://download.bazzite.gg), а руководство по установке доступно [здесь](https://docs.bazzite.gg/General/Installation_Guide/).**

Для перехода с существующей системы Fedora Atomic:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

Для версии с **проприетарными драйверами NVIDIA**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

> [!WARNING]
> **Из-за ошибки в базовой системе Bazzite не поддерживает Steam Deck с 64GB eMMC.**

Для **Steam Deck/HTPC**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**Для пользователей с Secure Boot:** Перед переходом следуйте [инструкциям по Secure Boot](#secure-boot).

### Особенности базовой системы

#### Universal Blue

- Проприетарные драйверы NVIDIA предустановлены. <sub><sup>(Только для образов с NVIDIA)</sup></sub>
- Flathub включен по умолчанию.
- Команды [`ujust`](https://github.com/casey/just) для удобства.
- Мультимедийные кодеки из коробки.
- Возможность отката на 90 дней.

#### Особенности Fedora Linux (Kinoite и Silverblue)

- Стабильная база.
- Актуальные системные пакеты.
- Установка пакетов Fedora без потери при обновлениях.
- Безопасность с [SELinux](https://github.com/SELinuxProject/selinux).
- Возможность перехода на другие образы Fedora Atomic без потери данных.
- Поддержка печати через [CUPS](https://www.cups.org/).

## Почему Bazzite?

Bazzite создан для решения проблем SteamOS: устаревших пакетов и отсутствия менеджера пакетов.

Несмотря на образность системы, вы можете устанавливать любые пакеты Fedora. Они сохраняются при обновлениях. Bazzite обновляется несколько раз в неделю, предлагая стабильную и современную систему.

Bazzite использует новейшее ядро Linux, SELinux и поддерживает Secure Boot и шифрование дисков. Это делает его подходящим для повседневного использования. <sup><sub>(Да, печать работает)</sub></sup>

Читайте [FAQ](https://docs.bazzite.gg/General/FAQ/) о преимуществах Bazzite.

## Демонстрация

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "Тема KDE Vapor")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "Тема KDE VGUI2")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Игровой режим Steam")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Терминалы Distrobox")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "Тема GNOME Vapor")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "Тема GNOME VGUI2")

## Документация

- [Установка и управление приложениями](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [Обновления, откаты и переход](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/)
- [Руководство по играм](https://docs.bazzite.gg/Gaming/)

[Дополнительная документация](http://docs.bazzite.gg/).

## Проверка подлинности

Образы подписаны с помощью [cosign](https://docs.sigstore.dev/cosign/signing/overview/). Для проверки скачайте ключ `cosign.pub` и выполните:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

> [!WARNING]
> **Пользователи Steam Deck: Secure Boot по умолчанию отключен. Не включайте его без необходимости.**

Secure Boot поддерживается с нашим ключом. Публичный ключ в [репозитории](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der). Для его добавления:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

Для существующих систем Universal Blue:

```bash
ujust enroll-secure-boot-key
```

Пароль: `universalblue`.

## Метрики участников

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

## История звезд

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Особая благодарность

Bazzite — результат работы сообщества. Благодарим:

- [amelia.svg](https://bsky.app/profile/ameliasvg.bsky.social) — за логотип и брендинг.
- [SuperRiderTH](https://github.com/SuperRiderTH) — за видео загрузки игрового режима.
- [evlaV](https://gitlab.com/evlaV) — за код Valve и поддержку.
- [ChimeraOS](https://chimeraos.org/) — за gamescope-session.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) — за техническую помощь.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) — за патчи ядра.
- [nicknamenamenick](https://github.com/nicknamenamenick) — за документацию и помощь.
- [Steam Deck Homebrew](https://deckbrew.xyz) — за поддержку других дистрибутивов.
- [cyrv6737](https://github.com/cyrv6737) — за вдохновение и основу для bazzite-arch.

## Соберите свою версию

Bazzite собирается в GitHub. Создать свою версию легко: форкните репозиторий, добавьте ключ и включите GitHub Actions.

[Ознакомьтесь](https://docs.github.com/en/actions/security-guides/encrypted-secrets) с секретами в GitHub. Вам понадобится [ключ cosign](https://docs.sigstore.dev/cosign/signing/overview/). Добавьте приватный ключ в `Settings -> Secrets -> Actions` как `SIGNING_SECRET`.

Для синхронизации с upstream используйте [pull app](https://github.com/apps/pull).

## Присоединяйтесь к сообществу

- [Discord Universal Blue](https://discord.gg/f8MUghG5PB)
  - [Архив](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) обсуждений.

- [Форумы Universal Blue](https://universal-blue.discourse.group/c/bazzite/5).

- [Mastodon](https://fosstodon.org/@UniversalBlue).

[**Полный список ресурсов Bazzite**](https://docs.bazzite.gg/Resources/).
