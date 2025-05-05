<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [:cn:](https://github.com/ublue-os/bazzite/blob/main/README-zh-cn.md) [🇧🇷](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md)

<p align="center">
  <a href="https://download.bazzite.gg/"><img src="/repo_content/download.png?raw=true" alt="Download Bazzite"/></a>
</p>

---
# Table des matières
- [🇺🇸 🇪🇸 🇮🇩 :cn: 🇧🇷 🇳🇱](#---cn--)
- [Table des matières](#table-des-matières)
  - [À propos et fonctionnalités](#à-propos-et-fonctionnalités)
    - [Environnement de bureau](#environnement-de-bureau)
    - [Steam Deck/Home Theater PCs (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
      - [Consoles portables alternatives](#consoles-portables-alternatives)
    - [GNOME](#gnome)
    - [Fonctionnalités provenant d'autres sources](#fonctionnalités-provenant-dautres-sources)
      - [Universal Blue](#universal-blue)
      - [Fonctionnalités de Fedora Linux (Kinoite \& Silverblue)](#fonctionnalités-de-fedora-linux-kinoite--silverblue)
  - [Pourquoi](#pourquoi)
  - [Vitrine](#vitrine)
  - [Documentation et newsletters](#documentation-et-newsletters)
  - [Packages personnalisés](#packages-personnalisés)
  - [Vérification](#vérification)
  - [Secure Boot](#secure-boot)
    - [Métriques des contributeurs](#métriques-des-contributeurs)
      - [Historique des étoiles](#historique-des-étoiles)
  - [Remerciements spéciaux](#remerciements-spéciaux)
  - [Construisez le vôtre](#construisez-le-vôtre)
  - [Rejoignez la communauté](#rejoignez-la-communauté)
---

## À propos et fonctionnalités

[Veuillez consulter notre site web](https://bazzite.gg/) pour une explication conviviale de Bazzite destinée aux nouveaux utilisateurs. Ce fichier readme couvrira tout en détail.

[Bazzite](https://bazzite.gg/) est une image OCI qui sert de système d'exploitation alternatif pour le [Steam Deck](https://www.steamdeck.com/), et est un SteamOS-like prêt à l'emploi pour les ordinateurs de bureau et les PC Home Theater.

Bazzite est construit à partir de [ublue-os/main](https://github.com/ublue-os/main) et [ublue-os/nvidia](https://github.com/ublue-os/nvidia) en utilisant la technologie de [Fedora](https://fedoraproject.org/), ce qui signifie que le support matériel étendu et les pilotes intégrés sont inclus. De plus, Bazzite ajoute les fonctionnalités suivantes :

- Utilise le [noyau fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) pour obtenir la prise en charge HDR et un support matériel étendu, ainsi que de nombreux autres correctifs.
- HDR disponible en mode jeu.
- NVK disponible sur les builds non-Nvidia.
- Support complet des codecs matériel pour le décodage H264.
- Support complet pour les runtimes OpenCL/HIP ROCM d'AMD.
- Pilote [xone](https://github.com/medusalix/xone) pour les contrôleurs Xbox.
- Support complet pour [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Comprend le thème KDE de Valve issus de SteamOS.
- Thèmes optionnels GTK3/4 inspirés de celui de Valve, correspondant à Vapor et VGUI2 de SteamOS. Installez [Gradience](https://flathub.org/apps/com.github.GradienceTeam.Gradience) pour les utiliser.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), et [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) installés et disponibles par défaut.
- [Switcheroo-Control patché](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) pour corriger le basculement iGPU/dGPU cassé par défaut.
- Support pour [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Seulement sur KDE)</sup></sub>
- [Extension de shell ROM Properties Page](https://github.com/GerbilSoft/rom-properties) incluse par défaut.
- Support complet pour [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) préinstallé avec mises à jour automatiques pour les conteneurs créés.
- [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) est utilisé par défaut dans toutes les images. Ce terminal est spécialement conçu pour le workflow des conteneurs dans Bazzite. Pour revenir au terminal d'origine, exécutez `ujust _restore-original-terminal`.
- Service automatisé `duperemove` pour réduire l'espace disque utilisé par les contenus du préfixe wine.
- Support pour HDMI CEC via [libCEC](https://libcec.pulse-eight.com/).
- [System76-Scheduler](https://github.com/pop-os/system76-scheduler) préinstallé, fournissant des ajustements automatiques de priorité des processus pour l'application focalisée, gardant le temps CPU pour les processus en arrière-plan au minimum.
- Configuration personnalisée de System76-Scheduler avec des règles supplémentaires.
- Utilise par défaut [BBR TCP congestion control de Google](https://github.com/google/bbr).
- [Input Remapper](https://github.com/sezanzeb/input-remapper) préinstallé et activé par défaut. <sub><sup>(Disponible mais désactivé par défaut sur la variante SteamDeck, peut être activé avec `ujust _restore-input-remapper`)</sup></sub>
- Bazzite Portal offrant un moyen facile d'installer de nombreuses applications et ajustements, y compris l'installation de [LACT](https://github.com/ilya-zlobintsev/LACT) et [GreenWithEnvy](https://gitlab.com/leinardi/gwe).
- [Waydroid](https://waydro.id/) est préinstallé pour exécuter des applications Android. Configurable avec ce [guide rapide](https://universal-blue.discourse.group/docs?topic=32).
- Gère les applications avec [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), et [Gear Lever](https://github.com/mijorus/gearlever).
- [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) pilotes i2c-piix4 et i2c-nct6775 pour contrôler le RGB sur certaines cartes mères.
- Pilotes [OpenRazer](https://openrazer.github.io) intégrés, sélectionnez OpenRazer dans Bazzite Portal ou exécutez `ujust install-openrazer` dans un terminal pour commencer à l'utiliser.
- Règles udev [OpenTabletDriver](https://opentabletdriver.net/) intégrées, avec la suite logicielle complète installable via Bazzite Portal ou en exécutant `ujust install-opentabletdriver` dans un terminal.
- Prise en charge prête à l'emploi des claviers [Wooting](https://wooting.io/).
- Prise en charge intégrée pour les GPU AMD Southern Islands <sub><sup>(HD 7000)</sup></sub> et Sea Islands <sub><sup>(HD 8000)</sup></sub> sous le pilote `amdgpu`.
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) est disponible pour le partage d'écran Discord sur Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) est disponible pour créer des applications à partir de sites web pour une variété de navigateurs, y compris Firefox.

### Environnement de bureau

De nombreuses variantes communes sont disponibles sous le nom `bazzite`, adaptée aux ordinateurs de bureau.

- Mises à jour automatiques pour le système d'exploitation, les Flatpaks et tous les conteneurs Distrobox - propulsées par [ublue-update](https://github.com/ublue-os/ublue-update) et [topgrade](https://github.com/topgrade-rs/topgrade).

> [!IMPORTANT]
> **Les ISOs peuvent être téléchargées depuis notre [page de versions](https://github.com/ublue-os/bazzite/releases), et un guide d'installation utile peut être trouvé [ici](https://universal-blue.discourse.group/docs?topic=30).**

Rebase d'un Fedora Atomic existante de cette image est disponible ici avec des **pilotes GPU Open Source** :
(Remarque : l'option Open Source de Mesa pour les GPU NVIDIA, NVK, est encore sujette à des erreurs au moment de la rédaction. Pour tout problème lié à NVK, [merci de soumettre un rapport à Mesa]([url](https://docs.mesa3d.org/bugs.html)), pas à Ublue/Bazzite)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

ou pour les appareils avec des GPU Nvidia voulant les **pilotes propriétaires NVIDIA** :

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**Pour les utilisateurs avec Secure Boot activé :** Suivez notre [documentation sur le démarrage sécurisé](#démarrage-sécurisé) avant de faire le rebase.

### Steam Deck/Home Theater PCs (HTPCs)

> [!IMPORTANT]
Les appareils qui NE sont PAS des SteamDeck peuvent toujours utiliser les images `bazzite-deck`, mais doivent utiliser un GPU AMD moderne. Les GPU Intel Arc ont également été confirmés comme fonctionnels.

Variante conçue pour être utilisée comme alternative à SteamOS sur le SteamDeck, et pour une expérience de console sur les HTPCs, disponible sous le nom `bazzite-deck` :

- Démarre directement en mode jeu, correspondant au comportement de SteamOS.
- **Le `duperemove` automatique réduit considérablement la taille des compatdata.**
- **La dernière version de Mesa crée des caches de shaders plus petits et n'en nécessite pas pour éviter les saccades.**
- **Peut être démarré même si le disque est plein.**
- **Prise en charge de toutes les langues prises en charge par Fedora.**
- **Utilise Wayland en mode bureau avec [support pour SteamInput](https://github.com/Supreeeme/extest).**
- Inclut [HHD](https://github.com/hhd-dev/hhd) pour un support d'entrée étendu sur les consoles portables non-Valve.
- Propose la plupart des packages SteamOS, y compris les pilotes, les mises à jour de firmware et les contrôleurs du ventilateur [du dépôt evlaV](https://gitlab.com/evlaV).
- Mesa patché pour un contrôle approprié du framerate par Gamescope.
- Livré avec des patches de [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) pour un support complet de BTRFS pour le lecteur carte SD.
- Livré avec une copie de [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), activé par défaut.
- Option pour installer [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), et [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), ainsi que de nombreux autres packages utiles lors de l'installation.
- Le système de mise à jour personnalisé permet de mettre à jour directement depuis l'interface du mode jeu grâce à [ublue-update](https://github.com/ublue-os/ublue-update) et [topgrade](https://github.com/topgrade-rs/topgrade).
- Prise en charge intégrée du dual-boot Windows en laissant l'installation du GRUB de Fedora intacte.
- Une mise à jour casse quelque chose ? Reviennez facilement à la version précédente de Bazzite grâce à la fonctionnalité de rollback de `rpm-ostree`. Vous pouvez même sélectionner les images précédentes au démarrage.
- Steam et Lutris préinstallés dans l'image en tant que packages superposés.
- [Discover Overlay](https://github.com/trigg/Discover) pour Discord préinstallé et lancé automatiquement à la fois en mode jeu et sur le bureau si Discord est installé. [Consulte la documentation officielle ici](https://trigg.github.io/Discover/bazzite).
- Utilise ZRAM<sub><sup>(4GB)</sup></sub> avec l'algorithme de compression ZSTD par défaut, avec la possibilité de revenir à un fichier swap de 1GB et de définir une taille personnalisée si nécessaire.
- Planificateur d'E/S Kyber pour éviter la starvation des E/S lors de l'installation de jeux ou pendant le processus de `duperemove` en arrière-plan.
- Applique les paramètres du noyau de SteamOS.
- Profils d'affichage calibrés en couleur pour les écrans mats et réfléchissants du SteamDeck inclus.
- Fonctionnalités pour utilisateurs avancés désactivées par défaut, notamment :
    - Service pour l'undervolting à faible risque du SteamDeck ainsi que des ordinateurs portables AMD  via [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) et [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), voir `ryzenadj.service` et `/etc/default/ryzenadj`.
    - Service pour limiter le niveau de charge maximal de la batterie, voir `batterylimit.service` et `/etc/default/batterylimit`. <sup><sub>(Fonctionne même lorsque l'appareil est éteint)</sub></sup>
    - Support intégré pour l'overclocking d'affichage. Par exemple, ajoutez `GAMESCOPE_OVERRIDE_REFRESH_RATE=40,70` à `/etc/environment`.
    - Vous avez modifié votre SteamDeck avec 32 Go de RAM ? Profitez du double de la quantité maximale de VRAM, appliqué automatiquement. <sup><sub>(Pourriez-vous partager vos compétences en soudure ?)</sub></sup>
- Les services spécifiques au matériel du SteamDeck peuvent être désactivés en exécutant `ujust disable-bios-updates` et `ujust disable-firmware-updates` dans le terminal. Ils sont automatiquement désactivés sur le matériel non-Deck, et sur les Decks avec des écrans DeckHD ou des mods de 32 Go de RAM.
- Plus d'informations peuvent être trouvées [ici](https://universal-blue.discourse.group/docs?topic=37) sur les images Bazzite pour SteamDeck.

> [!WARNING]
> **En raison d'un bug amont, Bazzite ne peut pas être utilisé sur les SteamDecks avec 64 Go de stockage eMMC pour le moment. La mise à niveau du stockage résout le problème.**

> [!IMPORTANT]
> **Les ISOs peuvent être téléchargées depuis notre [page de versions](https://github.com/ublue-os/bazzite/releases), et un guide d'installation utile peut être trouvé [ici](https://universal-blue.discourse.group/docs?topic=30).**

Rebase d'un Fedora Atomic existante avec cette image :

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Consoles portables alternatives

Merci de consulter notre [Wiki des consoles portables](https://universal-blue.discourse.group/docs?topic=1038) pour les modifications de paramètres nécessaires et les plugins Decky Loader pour le mode jeu Steam sur votre console portable spécifique.

**Assurez-vous également de lire la [documentation de hhd](https://github.com/hhd-dev/hhd#after-install), certaines consoles portables nécessitent des modifications/tweaks spécifiques pour fonctionner correctement.**

Nous avons également des commandes `ujust` pour installer divers thèmes [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck) qui ne se trouvent pas sur le magasin CSS Loader. Ceux-ci seront automatiquement mis à jour avec Bazzite s'ils sont installés.

```bash
# Installer le thème Manette de jeu portable (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme
```

### GNOME

Les versions avec l'environnement de bureau GNOME sont disponibles en versions desktop et deck. Ces versions incluent les fonctionnalités supplémentaires suivantes :

- Prise en charge du taux de rafraîchissement variable et du scaling fractionné activés sous Wayland, voir [ici](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Menu personnalisé dans la barre supérieure pour revenir au mode jeu, lancer Steam et ouvrir plusieurs utilitaires utiles.
- GSConnect est préinstallé et prêt à l'emploi, voir [ici](https://extensions.gnome.org/extension/1319/gsconnect/).
- Extension Hanabi incluse pour offrir des fonctionnalités similaires à Wallpaper Engine sous KDE, voir [ici](https://github.com/jeffshee/gnome-ext-hanabi).
- Nombreuses extensions optionnelles préinstallées, y compris des correctifs importants pour l'expérience utilisateur, voir [ici](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Mises à jour automatiques pour le thème GNOME de [Firefox](https://github.com/rafaelmardojai/firefox-gnome-theme) et le thème GNOME de [Thunderbird](https://github.com/rafaelmardojai/thunderbird-gnome-theme), s'ils sont installés.

> [!IMPORTANT]
> **Les ISO peuvent être téléchargées depuis notre [page de releases](https://github.com/ublue-os/bazzite/releases), et un guide d'installation utile est disponible [ici](https://universal-blue.discourse.group/docs?topic=30).**

Pour rebaser un système ostree existant vers cette image :

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

Pour rebaser un système ostree existant vers une version avec l'environnement de bureau **Proprietary NVIDIA Drivers** :

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

> [!WARNING]
> **En raison d'un bug en amont, Bazzite ne peut pas être utilisé sur les Steam Decks avec un stockage eMMC de 64 Go pour le moment.**

Pour rebaser un système ostree existant vers la version **Steam Deck/HTPC** :

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**Pour les utilisateurs avec Secure Boot activé :** Suivez notre [documentation sur le Secure Boot](#secure-boot) avant de rebaser.

### Fonctionnalités provenant d'autres sources

#### Universal Blue

- Pilotes Nvidia propriétaires préinstallés. <sub><sup>(Uniquement pour les images Nvidia)</sup></sub>
- Flathub activé par défaut.
- Commandes [`ujust`](https://github.com/casey/just) pour plus de commodité.
- Codecs multimédia inclus dès l'installation.
- Possibilité de revenir en arrière sur Bazzite à partir de n'importe quelle version des 90 derniers jours.

#### Fonctionnalités de Fedora Linux (Kinoite & Silverblue)

- Base solide et stable.
- Packages système relativement à jour.
- Possibilité de superposer des packages Fedora à l'image sans les perdre entre les mises à jour.
- Orienté sécurité avec [SELinux](https://github.com/SELinuxProject/selinux) préinstallé et configuré par défaut.
- Capacité de rebaser sur différentes images Fedora Atomic, si désiré, sans perte de données utilisateur.
- Prise en charge de l'impression grâce à l'installation préinstallée de [CUPS](https://www.cups.org/).

## Pourquoi

Bazzite a débuté comme un projet visant à résoudre certains des problèmes qui affectent SteamOS, principalement les packages obsolètes (malgré une base Arch) et le manque d'un gestionnaire de packages fonctionnel.

Bien que ce projet soit également basé sur des images, vous pouvez installer n'importe quel package Fedora directement depuis la ligne de commande. Ces packages persisteront à travers les mises à jour <sub><sup>(Alors n'hésitez pas à installer ce logiciel VPN obscur sur lequel vous avez passé une heure à essayer de le faire fonctionner sous SteamOS)</sup></sub>. De plus, Bazzite est mis à jour plusieurs fois par semaine avec des packages de Fedora, vous offrant ainsi les meilleures performances possibles et les dernières fonctionnalités - le tout sur une base stable.

Bazzite est livré avec le dernier noyau Linux et SELinux activé par défaut, avec prise en charge complète du démarrage sécurisé <sub><sup>(Exécutez `ujust enroll-secure-boot-key` et entrez le mot de passe `universalblue` si vous êtes invité à enregistrer notre clé)</sup></sub> et du chiffrement des disques, en faisant une solution raisonnable pour l'informatique générale. <sup><sub>(Oui, vous pouvez imprimer depuis Bazzite)</sub></sup>

Consultez la [FAQ](https://universal-blue.discourse.group/docs?topic=33) pour plus de détails sur ce qui distingue Bazzite des autres systèmes d'exploitation Linux.

## Vitrine

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Documentation et newsletters

- [Installation et gestion des applications](https://universal-blue.discourse.group/docs?topic=35)
- [Mises à jour, rollback et rebasage](https://universal-blue.discourse.group/docs?topic=36)
- [Guide de jeu](https://universal-blue.discourse.group/docs?topic=31)

Consultez la [documentation supplémentaire](http://docs.bazzite.gg/) concernant le projet.

Découvrez nos [Newsletters](https://universal-blue.discourse.group/tag/bazzite-buzz) publiés régulièrement pour les mises à jour sur le projet.

## Packages personnalisés

Les paquets portés de SteamOS et ChimeraOS, entre autres utilisés par Bazzite, sont construits sur Copr dans [bazzite](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite/) et [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/bazzite-org/bazzite-multilib/).

## Vérification

Ces images sont signées avec [cosign](https://docs.sigstore.dev/cosign/overview/) de sigstore. Vous pouvez vérifier la signature en téléchargeant la clé `cosign.pub` depuis ce dépôt et en exécutant la commande suivante :

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

> [!WARNING]
> **Utilisateurs de Steam Deck : Le Steam Deck ne vient pas avec le secure boot activé et n'inclut pas de clés inscrites par défaut. Ne l'activez pas à moins de savoir parfaitement ce que vous faites.**

Le secure boot est pris en charge avec notre clé personnalisée. La clé publique peut être trouvée à la racine de ce dépôt [ici](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der).
Si vous souhaitez inscrire cette clé avant l'installation ou le rebasage, téléchargez la clé et exécutez les commandes suivantes :

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

Pour les utilisateurs déjà sur une image Universal Blue, vous pouvez plutôt exécuter `ujust enroll-secure-boot-key`.

Si on vous demande un mot de passe, utilisez `universalblue`.

### Métriques des contributeurs

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Image d'analyse Repobeats")

#### Historique des étoiles

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Graphique d'historique des étoiles" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Remerciements spéciaux

Bazzite est un effort communautaire et ne serait pas possible sans le soutien de chacun. Voici quelques personnes qui nous ont aidés tout au long du chemin :

- [rei.svg](https://github.com/reisvg) - Pour la création de notre logo et de notre identité visuelle.
- [SuperRiderTH](https://github.com/SuperRiderTH) - Pour la création de notre vidéo de démarrage du mode jeu Steam.
- [evlaV](https://gitlab.com/evlaV) - Pour avoir rendu le code de Valve disponible et pour être [cette personne](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/) - Pour gamescope-session et pour un soutien précieux tout au long du projet.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - Pour le support technique et la création d'un projet similaire basé sur Nix. Allez voir, sérieusement.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - Pour l'aide avec les correctifs du noyau nécessaires et pour avoir créé le repo [kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) que nous utilisons maintenant.
- [nicknamenamenick](https://github.com/nicknamenamenick) - Pour maintenir quasiment seul notre documentation et notre littérature de support, et pour avoir aidé d'innombrables utilisateurs.
- [Steam Deck Homebrew](https://deckbrew.xyz) - Pour choisir de soutenir des distributions autres que SteamOS malgré le travail supplémentaire, et un merci spécial à [PartyWumpus](https://github.com/PartyWumpus) pour avoir fait fonctionner Decky Loader avec SELinux pour nous.
- [cyrv6737](https://github.com/cyrv6737) - Pour l'inspiration initiale et la base qui est devenue bazzite-arch.

## Construisez le vôtre

Bazzite est entièrement construit sur GitHub et créer votre propre version personnalisée est aussi simple que de forker ce dépôt, ajouter une clé de signature privée et activer les actions GitHub.

[Familiarisez-vous](https://docs.github.com/en/actions/security-guides/encrypted-secrets) sur la gestion des secrets dans GitHub. Vous devrez [générer une nouvelle paire de clés](https://docs.sigstore.dev/cosign/overview/) avec cosign. La clé publique peut être dans votre repo public <sub><sup>(Vos utilisateurs en ont besoin pour vérifier les signatures)</sup></sub>, et vous pouvez coller la clé privée dans `Paramètres -> Secrets -> Actions` avec le nom `SIGNING_SECRET`.

Nous expédions également une configuration pour l'application populaire [pull app](https://github.com/apps/pull) si vous souhaitez synchroniser votre fork avec l'original. Activez cette application sur votre repo pour suivre les modifications de Bazzite tout en apportant vos propres modifications.

## Rejoignez la communauté

Vous pouvez nous trouver sur le [Discord Universal Blue](https://discord.gg/f8MUghG5PB) et consulter les [archives](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) des discussions de support sans compte.

Discutez et créez des guides utilisateur sur les [forums Universal Blue Discourse](https://universal-blue.discourse.group/c/bazzite/5).

Suivez Universal Blue sur [Mastodon](https://fosstodon.org/@UniversalBlue).
