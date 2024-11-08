<p align="center">
  <a href="https://bazzite.gg/"><img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/></a>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml) [![build-bazzite-isos](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build_iso.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [:cn:](https://github.com/ublue-os/bazzite/blob/main/README-zh-cn.md) [🇫🇷](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md)

<p align="center">
  <a href="https://download.bazzite.gg/"><img src="/repo_content/download.png?raw=true" alt="Download Bazzite"/></a>
</p>

---

# Índice
- [Sobre \& Recursos](#sobre--recursos)
  - [Desktops](#desktops)
  - [Steam Deck/PCs Centros de Mídia (HTPCs)](#steam-deckpcs-centros-de-mídia-htpcs)
    - [Portáteis Alternativos](#portáteis-alternativos)
  - [GNOME](#gnome)
  - [Recursos Upstream](#recursos-upstream)
    - [Universal Blue](#universal-blue)
    - [Recursos do Fedora Linux (Kinoite \& Silverblue)](#recursos-do-fedora-linux-kinoite--silverblue)
- [Porquê](#porquê)
- [Imagens](#imagens)
- [Documentação](#documentação)
- [Pacotes Customizados](#pacotes-customizados)
- [Verificação](#verificação)
- [Secure Boot](#secure-boot)
- [Métricas de Contribuição](#métricas-de-contribuição)
- [Histórico de Estrelas](#histórico-de-estrelas)
- [Agradecimentos Especiais](#agradecimentos-especiais)
- [Faça Sua Própria](#faça-sua-própria)
- [Junte-se à Comunidade](#junte-se-à-comunidade)
---

## Sobre & Recursos

[Entre no nosso site](https://bazzite.gg/) para ler uma explicação do Bazzite mais amigável a iniciantes. Este README é uma explicação aprofundada.

[Bazzite](https://bazzite.gg/) é uma imagem OCI que serve como sistema operacional alternativo para o [Steam Deck](https://www.steamdeck.com/), e um parecido com o SteamOS e pronto pra jogar para computadores desktop e PCs centros de mídia.

O Bazzite é feito a partir do [ublue-os/main](https://github.com/ublue-os/main) e do [ublue-os/nvidia](https://github.com/ublue-os/nvidia) utilizando tecnologia [Fedora](https://fedoraproject.org/), o que significa que suporte expandido a hardware e drivers estão inclusos. Suplementarmente, o Bazzite traz os seguintes recursos:

- Usa o [kernel fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) para suportar mais hardware e HDR, dentre outros vários patches.
- HDR disponível no Game mode.
- NVK disponível em versões não-Nvidia.
- Suporte completo à decodificação de hardware em codecs H264.
- Suporte completo aos run-times OpenCL/HIP ROCM da AMD.
- Driver [xone](https://github.com/medusalix/xone) para controles de Xbox.
- Suporte completo a [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Inclui os temas do SteamOS para KDE da Valve.
- Inclui temas GTK3/4 semelhantes ao Vapor e VGUI2 do SteamOS. Instale o [Gradience](https://flathub.org/apps/com.github.GradienceTeam.Gradience) para usá-los.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), e [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) instalados e disponíveis por padrão
- Utiliza o [TuneD](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/monitoring_and_managing_system_status_and_performance/getting-started-with-tuned_monitoring-and-managing-system-status-and-performance) no lugar do PPD, integrado totalmente com o GNOME, KDE, e o Game mode. Esta é uma ferramenta incrivelmente poderosa que RedHat chega a [oferecer aulas sobre](https://www.redhat.com/en/services/training/rh442-red-hat-enterprise-performance-tuning).
- [Switcheroo-Control com patches](https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/) que consertam a troca entre iGPU/dGPU em casos em que é quebrada por padrão.
- Suporte a [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Só no KDE)</sup></sub>
- [Extensão do shell ROM Properties Page](https://github.com/GerbilSoft/rom-properties) inclusa.
- Suporte completo a [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- [Distrobox](https://github.com/89luca89/distrobox) pré-instalado com atualizações automáticas pra containers criados pelo usuário.
- Instalação simplificada do Davinci Resolve usando o [davincibox](https://github.com/zelikos/davincibox) (`ujust install-resolve`)
- [Ptyxis Terminal](https://gitlab.gnome.org/chergert/ptyxis) é utilizado como terminal padrão em todas as imagens. Esse terminal é feito especialmente para o workflow em containers que você deve usar no Bazzite. Se quiser utilizar o KDE Konsole ou o GNOME Console, eles podem ser instalados via Flatpak.
- Serviço `duperemove` automatizado para reduzir o espaço em disco usado por arquivos em prefixos do wine.
- Suporte a HDMI CEC via [libCEC](https://libcec.pulse-eight.com/).
- Usa o [controle de congestionamento TCP BBR da Google](https://github.com/google/bbr) por padrão.
- [Input Remapper](https://github.com/sezanzeb/input-remapper) pré-instalado e habilitado. <sub><sup>(Disponível mas desabilitado por padrão na versão Deck, ative executando `ujust _restore-input-remapper`)</sup></sub>
- O Bazzite Portal traz um jeito simples de instalar múltiplos aplicativos e ajustes, incluindo a instalação do [LACT](https://github.com/ilya-zlobintsev/LACT).
- [Waydroid](https://waydro.id/) pré-instalado para rodar aplicativos Android. Confira esse [guia rápido](https://docs.bazzite.gg/Installing_and_Managing_Software/Waydroid_Setup_Guide/) para configurá-lo.
- Gerencie aplicativos usando o [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), e [Gear Lever](https://github.com/mijorus/gearlever).
- Drivers i2c-piix4 e i2c-nct6775 pra [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) para controlar o RGB em certas placas-mãe.
- Drivers [OpenRazer](https://openrazer.github.io) inclusos, Selecione OpenRazer no Bazzite Portal ou rode `ujust install-openrazer` no terminal para começar a usá-lo.
- Regras de udev para [OpenTabletDriver](https://opentabletdriver.net/) inclusas, com a instalalção completa disponível via Bazzite Portal ou rodando `ujust install-opentabletdriver` no terminal.
- Suporte por padrão a teclados [Wooting](https://wooting.io/).
- Suporte por padrão a GPUs Southern Islands <sub><sup>(HD 7000)</sup></sub> e Sea Islands <sub><sup>(HD 8000)</sup></sub> da AMD por meio do driver `amdgpu`.
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) disponível pra compartilhamento de tela no Discord em Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) incluso para criar aplicativos a partir de sites com vários browsers, inclusive o Firefox.

### Desktops

Imagem genérica disponível como `bazzite`, própria para computadores desktop.

- Atualiza automaticamente o sistema, Flatpaks, e todos os containers Distrobox - via [ublue-update](https://github.com/ublue-os/ublue-update) e [topgrade](https://github.com/topgrade-rs/topgrade).

> [!IMPORTANT]  
> **ISOs podem ser baixadas do nosso [site](https://download.bazzite.gg), com um guia de instalação conveniente disponível [aqui](https://docs.bazzite.gg/General/Installation_Guide/).**

Rebaseie de uma instalação existente de Fedora Atômico para esta imagem se você quiser **Drivers de GPU Open Source**:
(Nota: A solução Open Source Mesa para GPUs NVIDIA, NVK ainda é propensa a erros quando esta orientação é redigida, pra qualquer problema pertinente à NVK [por favor mande um relatório ao projeto Mesa]([url](https://docs.mesa3d.org/bugs.html)), não ao Ublue/Bazzite)

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

ou para dispositivos com GPUs Nvidia caso os **Drivers Proprietários da NVIDIA** convirem:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**Usuários com o Secure Boot ativado:** Sigam nossa [documentação para secure boot](#secure-boot) antes do rebase.

### Steam Deck/PCs Centros de Mídia (HTPCs)
> [!IMPORTANT]  
Dispositivos que NÃO SÃO o Steam Deck também podem usar as imagens `bazzite-deck`, mas precisam ter uma GPU recente da AMD. GPUs Arc da Intel também foram confirmadas como funcionando.

Imagem feita pra ser utilizada como alternativa ao SteamOS no Steam Deck, e para uma experiência semelhante a consoles em HTPCs, disponível como `bazzite-deck`:

- Inicializa diretamente no Game mode, assim como o SteamOS.
- **`duperemove` automático reduz bastante o tamanho da compatdata.**
- **A última versão do Mesa cria caches de shader menores e não requer seu uso pra prevenir travamentos.**
- **Inicia mesmo se o disco estiver  cheio.**
- **Suporte a todos os idiomas suportados pelo Fedora.**
- **Usa o desktop em Wayland com [suporte a Steam Input](https://github.com/Supreeeme/extest).**
- Inclui o [HHD](https://github.com/hhd-dev/hhd) para suporte expandido de entrada pra portáteis que não são da Valve.
- Contém versões da maioria dos pacotes nativos do SteamOS, incluindo drivers, atualizadores de firmware, e controladores de ventoinha [do repositório evlav](https://gitlab.com/evlaV).
- Mesa com patches pra suportar controle de taxa de quadros via Gamescope.
- Vem com patches do [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) pra suporte completo a BTRFS no cartão SD por padrão.
- Inclui uma versão do [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU), habilitada por padrão.
- Opções pra instalar o [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), e [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), entre outros vários programas úteis na instalação.
- Um sistema de atualização customizado permite que o sistema, Flatpaks e imagens Distrobox sejam atualizados diretamente pela interface do Game mode via [ublue-update](https://github.com/ublue-os/ublue-update) e [topgrade](https://github.com/topgrade-rs/topgrade).
- Suporte padrão a dual-boot com Windows já que a instalação de GRUB do Fedora é mantida intacta.
- Uma atualização quebrou alguma coisa? Volte facilmente pra versão anterior do Bazzite graças à funcionalidade de rollback do `rpm-ostree`. Você pode até selecionar imagens anteriores na sequência de boot.
- Steam e Lutris pré-instalados via pacotes sobrepostos na imagem.
- [Discover Overlay](https://github.com/trigg/Discover) pra Discord pré-instalado e iniciado automaticamente tanto no Game mode quanto no Desktop se o Discord estiver instalado. [Confira a documentação oficial aqui](https://trigg.github.io/Discover/bazzite).
- Usa ZRAM<sub><sup>(4GB)</sup></sub> com o algoritmo de compressão ZSTD por padrão com a opção de trocar de volta para um arquivo de swap de 1GB e definir um tamanho arbitrário pra ele se desejado.
- Inclui os schedulers de CPU [BORE](https://github.com/firelzrd/bore-scheduler) e [LAVD](https://crates.io/crates/scx_lavd) para uma experiência de gameplay suave e responsiva.
- Scheduler de I/O Kyber para prevenir inanição de I/O ao instalar jogos ou durante o processo de `duperemove` rodando em segundo plano.
- Aplica os parâmetros de kernel do SteamOS.
- Perfis de cor calibrada para as telas padrão e antirreflexo do Steam Deck inclusos.
- Recursos para usuários avançados e desabilitados por padrão, incluindo:
    - Um serviço para undervolt de baixo risco do Steam Deck assim como laptops Framework com AMD via [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) e [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), vide `ryzenadj.service` e `/etc/default/ryzenadj`.
    - Um serviço para limitar o nível máximo da carga da bateria, vide `batterylimit.service` e `/etc/default/batterylimit`. <sup><sub>(Funciona mesmo se o dispositivo estiver desligado)</sub></sup>
    - Suporte a overclocking de tela. Por exemplo, escreva `CUSTOM_REFRESH_RATES=30-68` em `/etc/environment`. Taxas de atualização mínima e máxima mudam de portátil pra portátil!
    - Modificou seu Steam Deck pra ter 32GB de RAM? Aproveite o dobro da quantia máxima de VRAM, aplicada automaticamente. <sup><sub>(Quer emprestar esse talento com solda?)</sub></sup>
- Serviços específicos para o hardware do Steam Deck podem ser desabilitados rodando `ujust disable-bios-updates` e `ujust disable-firmware-updates` no terminal. Eles são desabilitados automaticamente em hardware que não seja o Deck, e em Decks com telas DeckHD ou mods de 32GB de RAM.
- Mais informações sobre as imagens Bazzite Steam Deck podem ser encontradas [aqui](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Steam_Gaming_Mode/).

> [!WARNING]  
> **Devido a um bug upstream, o Bazzite não pode ser utilizado em Steam Decks com 64GB de armazenamento eMMC no momento. Fazer um upgrade de armazenamento resolve o problema.**

> [!IMPORTANT]  
> **ISOs podem ser baixadas do nosso [site](https://download.bazzite.gg), com um guia de instalação conveniente disponível [aqui](https://docs.bazzite.gg/General/Installation_Guide/).**

Pra fazer rebase de uma instalação existente de Fedora Atômico para esta imagem:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

#### Portáteis Alternativos

Por favor confira nossa [wiki pra portáteis](https://docs.bazzite.gg/Handheld_and_HTPC_edition/Handheld_Wiki/) pras mudanças de configuração necessárias e plugins do Decky Loader pro Steam Gaming Mode do seu portátil específico.

**Certifique-se de ler a [documentação do hhd](https://github.com/hhd-dev/hhd#after-install), alguns portáteis requerem mudanças de configuração/ajustes específicos pra funcionar corretamente.**

Nós também incluímos comandos `ujust` para instalar vários temas pra [CSS Loader](https://docs.deckthemes.com/CSSLoader/Install/#linux-or-steam-deck) que não se encontram na loja do CSS Loader. Esses temas são atualizados automaticamente com o Bazzite se instalados.
```bash
# Para instalar o tema Handheld Controller (https://github.com/victor-borges/handheld-controller-glyphs)
ujust install-hhd-controller-glyph-theme
```

### GNOME

Imagens com o ambiente desktop GNOME estão disponíveis pra ambas as versões desktop & deck. Estas variantes trazem os seguintes recursos adicionais:

- [Suporte a taxa de atualização variável e escala fracionada de aplicativos habilitadas em Wayland](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Menu customizado no painel para retornar ao game mode, iniciar a Steam, e abrir alguns utilitários.
- [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/) pré-instalado e pronto pra usar.
- [Extensão Hanabi](https://github.com/jeffshee/gnome-ext-hanabi) inclusa pra obter funcionalidades semelhantes ao Wallpaper Engine pro KDE.
- Várias extensões opcionais pré-instaladas, incluindo [correções importantes para a experiência de usuário](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Atualizações automáticas para o [tema GNOME pro Firefox](https://github.com/rafaelmardojai/firefox-gnome-theme) e o [tema GNOME pro Thunderbird](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(Se instalados)</sub></sup>

> [!IMPORTANT]  
> **ISOs podem ser baixadas do nosso [site](https://download.bazzite.gg), com um guia de instalação conveniente disponível [aqui](https://docs.bazzite.gg/General/Installation_Guide/).**

Pra fazer rebase de uma instalação existente de Fedora Atômico para esta imagem:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

Pra fazer rebase de um sistema ostree existente para uma versão com Ambiente Desktop e os **Drivers Proprietários da NVIDIA**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

> [!WARNING]  
> **Devido a um bug upstream, o Bazzite não pode ser utilizado em Steam Decks com 64GB de armazenamento eMMC no momento.**

Pra fazer rebase de um sistema ostree existente para a versão **Steam Deck/HTPC**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

**Usuários com o Secure Boot ativado:** Sigam nossa [documentação para secure boot](#secure-boot) antes do rebase.

### Recursos Upstream

#### Universal Blue

- Drivers proprietários da Nvidia pré-instalados. <sub><sup>(Apenas nas imagens Nvidia)</sup></sub>
- Flathub habilitado por padrão.
- Comandos [`ujust`](https://github.com/casey/just) pra sua conveniência.
- Codecs multimídia inclusos.
- Faça rollback para qualquer versão do Bazzite dos últimos 90 dias.

#### Recursos do Fedora Linux (Kinoite & Silverblue)

- Base bastante sólida e estável.
- Pacotes do sistema relativamente atualizados.
- Capacidade de sobrepor pacotes Fedora sobre a imagem sem perdê-los em atualizações.
- Focado em segurança com o [SELinux](https://github.com/SELinuxProject/selinux) pré-instalado e configurado por padrão.
- Capacidade de mudar a base do sistema entre imagens diferentes de Fedora Atômico, se desejado, sem perder dados de usuário.
- Suporte a impressora graças ao [CUPS](https://www.cups.org/) pré-instalado.

## Porquê

O Bazzite começou como um projeto pra resolver alguns dos problemas que afligem o SteamOS, particularmente pacotes desatualizados (apesar da base Arch) e a falta de um gerenciamento de pacotes funcional.

Apesar deste projeto também ser baseado em imagens, você pode instalar qualquer pacote Fedora direto do terminal. Estes pacotes vão persistir entre atualizações <sub><sup>(Então vá em frente e instale aquele software desconhecido de VPN que você gastou meia-hora tentando fazer funcionar no SteamOS)</sup></sub>. Inclusive, o Bazzite é atualizado várias vezes por semana com os pacotes dos repositórios Fedora, trazendo a melhor peformance possível e os últimos recursos - tudo numa base estável.

O Bazzite inclui a versão mais recente do kernel Linux e vem com SELinux habilitado por padrão com suporte total a secure boot <sub><sup>(Execute `ujust enroll-secure-boot-key` e insira a senha `universalblue` se requisitada para adicionar a nossa chave)</sup></sub> e criptografia de disco, fazendo dele uma solução razoável pra computação em geral. <sup><sub>(Sim, você pode usar sua impressora no Bazzite)</sub></sup>

Confira o [FAQ](https://docs.bazzite.gg/General/FAQ/) para mais detalhes no que faz o Bazzite ser diferente de outros sistemas operacionais Linux.

## Imagens

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Documentação

- [Instalando e Gerenciando Programas](https://docs.bazzite.gg/Installing_and_Managing_Software/)
- [Atualizações, Rollbacks, e Rebase](https://docs.bazzite.gg/Installing_and_Managing_Software/Updates_Rollbacks_and_Rebasing/)
- [Guia pra Gaming](https://docs.bazzite.gg/Gaming/)

Leia [documentação adicional](http://docs.bazzite.gg/) ao redor do projeto.

## Pacotes Customizados

Pacotes vindos do SteamOS e ChimeraOS, dentre outros usados pelo Bazzite, são construídos no Copr em [bazzite](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/) e [bazzite-multilib](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/).

| Pacote                                                                                             | Status                                                                                                                                                      |
| --------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ds-inhibit                                                                                          | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ds-inhibit/status_image/last_build.png?)                                  |
| [extest](https://github.com/Supreeeme/extest)                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/extest/status_image/last_build.png?)                             |
| gamescope                                                                                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/gamescope/status_image/last_build.png?)                          |
| [gamescope-session-plus](https://github.com/ChimeraOS/gamescope-session)                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-plus/status_image/last_build.png?)                      |
| [gamescope-session-steam](https://github.com/ChimeraOS/gamescope-session-steam)                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-session-steam/status_image/last_build.png?)                     |
| gamescope-shaders                                                                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gamescope-shaders/status_image/last_build.png?)                           |
| galileo-mura                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/galileo-mura/status_image/last_build.png?)                                |
| [gnome-randr-rust](https://github.com/maxwellainatchi/gnome-randr-rust)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-randr-rust/status_image/last_build.png?)                            |
| gnome-shell                                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/gnome-shell/status_image/last_build.png?)                                  |
| gnome-shell-extension-bazzite-menu                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-bazzite-menu/status_image/last_build.png?)          |
| [gnome-shell-extension-caribou-blocker](https://extensions.gnome.org/extension/1326/block-caribou/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-caribou-blocker/status_image/last_build.png?)       |
| [gnome-shell-extension-compiz-windows-effect](https://github.com/hermes83/compiz-windows-effect)    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-compiz-windows-effect/status_image/last_build.png?) |
| [gnome-shell-extension-hanabi](https://github.com/jeffshee/gnome-ext-hanabi)                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hanabi/status_image/last_build.png?)                |
| [gnome-shell-extension-hotedge](https://github.com/jdoda/hotedge)                                   | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/gnome-shell-extension-hotedge/status_image/last_build.png?)               |
| [joystickwake](https://github.com/foresto/joystickwake)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/joystickwake/status_image/last_build.png?)                                |
| jupiter-fan-control                                                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-fan-control/status_image/last_build.png?)                         |
| jupiter-hw-support-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| jupiter-sd-mounting-[btrfs](https://gitlab.com/popsulfr/steamos-btrfs)                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/jupiter-hw-support-btrfs/status_image/last_build.png?)                    |
| kf6-kio                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/kf6-kio/status_image/last_build.png?)                                      |
| [mangohud](https://github.com/flightlessmango/MangoHud)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mangohud/status_image/last_build.png?)                           |
| mesa                                                                                                | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/mesa/status_image/last_build.png?)                               |
| pipewire                                                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite-multilib/package/pipewire/status_image/last_build.png?)                           |
| powerbuttond                                                                                        | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/powerbuttond/status_image/last_build.png?)                                |
| [python3-hid](https://github.com/apmorton/pyhidapi)                                                 | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/python3-hid/status_image/last_build.png?)                                 |
| [ryzenadj](https://github.com/FlyGoat/RyzenAdj)                                                     | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ryzenadj/status_image/last_build.png?)                                    |
| [scx-scheds](https://github.com/sched-ext/scx)                                                      | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/scx-scheds/status_image/last_build.png?)                                  |
| [sdgyrodsu](https://github.com/kmicki/SteamDeckGyroDSU)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/sdgyrodsu/status_image/last_build.png?)                                   |
| steamdeck-dsp                                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-dsp/status_image/last_build.png?)                               |
| steamdeck-gnome-presets                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-gnome-presets/status_image/last_build.png?)                     |
| steamdeck-kde-presets                                                                               | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets/status_image/last_build.png?)                       |
| steamdeck-kde-presets-desktop                                                                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steamdeck-kde-presets-desktop/status_image/last_build.png?)               |
| steam_notif_daemon                                                                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/steam_notif_daemon/status_image/last_build.png?)                          |
| [ublue-update](https://github.com/ublue-os/ublue-update)                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/ublue-update/status_image/last_build.png?)                                |
| udisks2                                                                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/udisks2/status_image/last_build.png?)                                     |
| [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher)                                | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/umu-launcher/status_image/last_build.png?)                                |
| upower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/upower/status_image/last_build.png?)                                      |
| vpower                                                                                              | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/vpower/status_image/last_build.png?)                                      |
| [xwiimote-ng](https://github.com/dev-0x7C6/xwiimote-ng)                                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/bazzite/package/xwiimote-ng/status_image/last_build.png?)                                 |

Adicionalmente, os seguintes pacotes são utilizados de outros repositórios Copr:

| Pacote                                                                                                       | Status                                                                                                                                                          |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [discover-overlay](https://github.com/trigg/Discover)                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/mavit/discover-overlay/package/discover-overlay/status_image/last_build.png?)                           |
| [hhd](https://github.com/hhd-dev/hhd)                                                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/hhd-dev/hhd/package/hhd/status_image/last_build.png?)                                                   |
| [kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/)                                  | ![Build Status](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/package/kernel/status_image/last_build.png?)                                        |
| [latencyflex-vulkan-layer](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/)                    | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/LatencyFleX/package/latencyflex-vulkan-layer/status_image/last_build.png?)                    |
| [nerd-fonts](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/)                                         | ![Build Status](https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/package/nerd-fonts/status_image/last_build.png?)                                         |
| [noise-suppression-for-voice](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/)                       | ![Build Status](https://copr.fedorainfracloud.org/coprs/ycollet/audinux/package/noise-suppression-for-voice/status_image/last_build.png?)                       |
| [obs-vkcapture](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/)                             | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/obs-vkcapture/package/obs-vkcapture/status_image/last_build.png?)                             |
| [ptyxis](https://gitlab.gnome.org/chergert/ptyxis)                                                            | ![Build Status](https://copr.fedorainfracloud.org/coprs/ublue-os/staging/package/ptyxis/status_image/last_build.png?)                                           |
| [rom-properties](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/package/rom-properties/status_image/last_build.png?)                           |
| [wallpaper-engine-kde-plugin](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/) | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/wallpaper-engine-kde-plugin/package/wallpaper-engine-kde-plugin/status_image/last_build.png?) |
| [webapp-manager](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/)                           | ![Build Status](https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/package/webapp-manager/status_image/last_build.png?)                           |

## Verificação

As imagens são assinadas com o [cosign](https://docs.sigstore.dev/cosign/overview/) da sigstore. Você pode verificar essa assinatura baixando a chave `cosign.pub` deste repositório ao rodar o seguinte comando:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

> [!WARNING]  
> **Usuários do Steam Deck: O Steam Deck não habilita o secure boot e não vem com quaisquer chaves inclusas por padrão. Não ative se não tiver certeza absoluta de que sabe o que está fazendo.**

Secure boot é suportado com a nossa chave própria. A chave pública se encontra [aqui](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der) na raiz deste repositório. Se você quiser adicionar a nossa chave antes da instalação ou rebase, baixe a chave e execute o seguinte:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

Para usuários que já estão numa imagem Universal Blue, é só rodar `ujust enroll-secure-boot-key`.

Se uma senha for pedida, insira `universalblue`.

### Métricas de Contribuição

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

#### Histórico de Estrelas

<a href="https://star-history.com/#ublue-os/bazzite&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=ublue-os/bazzite&type=Date" />
  </picture>
</a>

## Agradecimentos Especiais

O Bazzite é um esforço comunitário e não existiria sem o apoio de todos. Listados abaixo estão algumas das pessoas que nos ajudaram pelo caminho:

- [rei.svg](https://github.com/reisvg) - Por criar nossa logo e branding no geral.
- [SuperRiderTH](https://github.com/SuperRiderTH) - Por criar o nosso vídeo de inicialização pro Steam game mode.
- [evlaV](https://gitlab.com/evlaV) - Por disponibilizar o código da Valve e por ser [essa pessoa](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/) - Pelo gamescope-session e pela valiosa ajuda ao longo do caminho.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - Por nos ajudar com problemas técnicos e por criar um projeto similar. Sério, vai lá conferir. É o nosso primo baseado em Nix.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - Por ajudar com patches de kernel necessários e por criar o [repositório kernel-fsync](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) que nós usamos agora.
- [nicknamenamenick](https://github.com/nicknamenamenick) - Por ser o MVP mantendo toda a nossa documentação e biblioteca de suporte quase sozinho, e ajudar usuários inúmeras vezes.
- [Steam Deck Homebrew](https://deckbrew.xyz) - Por escolher suportar distribuições além do SteamOS apesar do trabalho adicional, e um agradecimento especial ao [PartyWumpus](https://github.com/PartyWumpus) por fazer o Decky Loader funcionar com o SELinux pra gente.
- [cyrv6737](https://github.com/cyrv6737) - Pela inspiração inicial e a base que se tornou o bazzite-arch.

## Faça Sua Própria

O Bazzite é construído inteiramente no GitHub e criar sua própria versão customizada é tão simples quanto fazer um fork deste repositório, adicionar uma chave privada pra assinatura, e habilitar as GitHub actions.

[Se familiarize](https://docs.github.com/en/actions/security-guides/encrypted-secrets) com o uso de segredos no github. Você vai precisar [gerar um novo par de chaves](https://docs.sigstore.dev/cosign/overview/) com o cosign. A chave pública pode ficar no seu repositório público <sub><sup>(Seus usuários precisam dela pra verificar a assinatura)</sup></sub>, e você pode colar a chave privada em `Settings -> Secrets -> Actions` com o nome `SIGNING_SECRET`.

Nós também incluímos uma configuração pro app popular [pull](https://github.com/apps/pull) se você quiser manter seu fork sincronizado com o upstream. Habilite esse app no seu repositório pra ficar a par das mudanças no Bazzite enquando mantém suas próprias modificações.

## Junte-se à Comunidade

- Você pode falar conosco no [Discord do Universal Blue](https://discord.gg/f8MUghG5PB)
  - Visualize o [acervo](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769) de postagens de suporte, sem precisar de uma conta.

- Discuta e crie guias de usuário nos [Fóruns Discourse do Universal Blue](https://universal-blue.discourse.group/c/bazzite/5).

- Siga o Universal Blue no [Mastodon](https://fosstodon.org/@UniversalBlue).

[**Veja a lista completa das mídias sociais e documentação do Bazzite**](https://docs.bazzite.gg/Resources/).
