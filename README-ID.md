<p align="center">
  <img src="/repo_content/Bazzite_Tagline.svg?raw=true" alt="Bazzite"/>
</p>

[![build-bazzite](https://github.com/ublue-os/bazzite/actions/workflows/build.yml/badge.svg)](https://github.com/ublue-os/bazzite/actions/workflows/build.yml)

# [🇺🇸](https://github.com/ublue-os/bazzite/blob/main/README.md) [🇪🇸](https://github.com/ublue-os/bazzite/blob/main/README-SPA.md) [🇮🇩](https://github.com/ublue-os/bazzite/blob/main/README-ID.md) [🇫🇷](https://github.com/ublue-os/bazzite/blob/main/README-FR.md) [🇧🇷](https://github.com/ublue-os/bazzite/blob/main/README-BR.md) [🇳🇱](https://github.com/ublue-os/bazzite/blob/main/README-NL.md)


<p align="center">
  <a href="https://bazzite.gg/#image-picker"><img src="/repo_content/download.png?raw=true" alt="Download Bazzite"/></a>
</p>

---

# Daftar Isi
- [🇺🇸 🇪🇸 🇮🇩 🇫🇷 🇧🇷 🇳🇱](#-----)
- [Daftar Isi](#daftar-isi)
  - [Tentang \& Fitur](#tentang--fitur)
    - [Desktop](#desktop)
    - [Steam Deck/Home Theater PCs (HTPCs)](#steam-deckhome-theater-pcs-htpcs)
    - [GNOME](#gnome)
    - [Fitur dari Upstream](#fitur-dari-upstream)
      - [Universal Blue](#universal-blue)
      - [Fitur dari Fedora Linux (Kinoite \& Silverblue)](#fitur-dari-fedora-linux-kinoite--silverblue)
  - [Alasan](#alasan)
  - [Pameran](#pameran)
  - [Dokumentasi \& Buletin](#dokumentasi--buletin)
  - [Verifikasi](#verifikasi)
  - [Secure Boot](#secure-boot)
    - [Metrik Kontribusi](#metrik-kontribusi)
  - [Ucapan Terimakasih](#ucapan-terimakasih)
  - [Membuat Image Anda Sendiri](#membuat-image-anda-sendiri)
  - [Bergabung Dengan Komunitas](#bergabung-dengan-komunitas)
---

## Tentang & Fitur

Bazzite dibentuk dari [ublue-os/main](https://github.com/ublue-os/main) and [ublue-os/nvidia](https://github.com/ublue-os/nvidia) menggunakan teknologi dari [Fedora](https://fedoraproject.org/), yang berarti dukungan perangkat keras dan driver lebih lengkap. Dan Bazzite menambah fitur ini:

- Pra-install driver proprietary Nvidia
- Dukungan penuh untuk kodek H264 yang diakselerasi perangkat keras
- Dukungan penuh untuk runtime AMD ROCM OpenCL/HIP.
- [xone](https://github.com/medusalix/xone), [xpadneo](https://github.com/atar-axis/xpadneo), dan [xpad-noone](https://github.com/ublue-os/xpad-noone) driver untuk Kontroller Xbox.
- Dukungan penuh untuk [DisplayLink](https://www.synaptics.com/products/displaylink-graphics).
- Menyertakan Tema KDE Valve dari SteamOS.
- [LatencyFleX](https://github.com/ishitatsuyuki/LatencyFleX), [vkBasalt](https://github.com/DadSchoorse/vkBasalt), [MangoHud](https://github.com/flightlessmango/Mangohud), dan [OBS VkCapture](https://github.com/nowrep/obs-vkcapture) terinstall dan tersedia secara bawaan.
- Dukungan untuk [Wallpaper Engine](https://www.wallpaperengine.io/en). <sub><sup>(Hanya ada di KDE)</sup></sub>
- Disediakan [Ekstensi shell untuk ROM Properties Page ](https://github.com/GerbilSoft/rom-properties).
- Dukungan penuh untuk [Winesync/Fastsync/NTsync](https://github.com/Frogging-Family/wine-tkg-git/issues/936).
- Pra-install [Distrobox](https://github.com/89luca89/distrobox) dengan update otomatis untuk kontainer yang dibuat.
- Otomatisasi layanan `duperemove` dan `rmlint`untuk mengurangi penggunaan penyimpanan yang digunakan prefix wine.
- Dukungan untuk HDMI CEC dengan [libCEC](https://libcec.pulse-eight.com/).
- Pra-install [System76-Scheduler](https://github.com/pop-os/system76-scheduler), menyediakan otomatisasi dan oprekan untuk proses yang berjalan dilatar belakang, serta meminimalkan CPU untuk proses latar belakang.
- Menkustomisasi konfigurasi System76-Scheduler dengan aturan tambahan.
- Menggunakan [Google's BBR TCP congestion control](https://github.com/google/bbr) secara bawaan.
- Pra-install [Input Remapper](https://github.com/sezanzeb/input-remapper) dan diaktifkan secara bawaan. <sub><sup>(Dinonaktifkan secara bawaan di varian Deck tapi tersedia dan dapat diaktifkan dengan `ujust _restore-input-remapper`)</sup></sub>
- Portal Bazzite menyediakan cara mudah untuk menginstall berbagai macam aplikasi dan oprekan, termasuk menginstall [LACT](https://github.com/ilya-zlobintsev/LACT) dan [GreenWithEnvy](https://gitlab.com/leinardi/gwe).
- Manajemen paket [Nix](https://nixos.org/) dengan [Fleek](https://getfleek.dev/) tersedia secara optional dan dapat diinstall dengan `ujust`.
- Manajemen paket [Brew](https://brew.sh/) tersedia secara optional dan dapat diinstall dengan Portal Bazzite.
- Pra-install [Waydroid](https://waydro.id/) untuk menjalankan aplikasi Android. Dapat diatur dengan mengikuti [panduan cepat](https://universal-blue.discourse.group/docs?topic=32).
- Mengatur aplikasi dengan [Flatseal](https://github.com/tchx84/Flatseal), [Warehouse](https://github.com/flattool/warehouse), dan [Gear Lever](https://github.com/mijorus/gearlever).
- [OpenRGB](https://gitlab.com/CalcProgrammer1/OpenRGB) driver i2c-piix4 dan i2c-nct6775 untuk mengatur RGB di beberapa jenis motherboard.
- Disediakan secara bawaan driver [OpenRazer](https://openrazer.github.io), Pilih OpenRazer di portal bazzite atau jalankan perintah `ujust install-openrazer` diterminal untuk menggunakannya.
- Disediakan secara bawaan [OpenTabletDriver](https://opentabletdriver.net/) udev rules, dengan perangkat lunaknya yang dapat dipasang dengan portal bazzite atau dengan mengetikkan `ujust install-opentabletdriver` di terminal.
- Driver [GCAdapter_OC](https://github.com/hannesmann/gcadapter-oc-kmod) untuk men-overclocking Kontroller Nintendo Gamecube sampai dengan 1000hz polling.
- Dukungan untuk keyboard [Wooting](https://wooting.io/).
- Dukungan untuk kartu grafis Southern Islands <sub><sup>(HD 7000)</sup></sub> and Sea Islands <sub><sup>(HD 8000)</sup></sub> dengan driver `amdgpu`.
- Memperbaiki masalah untuk [game yang menggunakan engine Source 1 <sub><sup>(Contoh: TF2)</sup></sub>](https://github.com/ValveSoftware/Source-1-Games/issues/5043) yang membuat game-nya crash saat dijalankan `ujust fix-source1-tcmalloc`
- [XwaylandVideoBridge](https://invent.kde.org/system/xwaylandvideobridge) untuk Discord screensharing di Wayland.
- [Webapp Manager](https://github.com/linuxmint/webapp-manager) tersedia untuk membuat aplikasi dari situs web dengan berbagai macam peramban, termasuk Firefox.

### Desktop

Varian umum yang tersedia sebagai `bazzite`, cocok untuk komputer desktop.
- Pembaruan otomatis untuk Sistem Operasi,Flatpak,Nix package <sup><sub>(dengan Fleek)</sub></sup>, dan semua kontainer Distrobox.

> [!IMPORTANT]
> **ISO bisa diunduh dari halaman rilis kami [disini](https://github.com/ublue-os/bazzite/releases), dan berbagai macam panduan instalasi dapat ditemukan [disini](https://universal-blue.discourse.group/docs?topic=30).**

Jika anda telah menggunakan image dari Universal Blue anda dapat mengikuti [instruksi ini](https://universal-blue.org/images/#image-list). Untuk berganti image dari image upstream Fedora Silverblue/Kinoite ostree anda dapat mengikuti perintah ini:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite:stable
```

atau perangkat dengan kartu grafis Nvidia:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-nvidia:stable
```

**Untuk pengguna dengan Secure Boot aktif:** Jalankan `ujust enroll-secure-boot-key` dan masukan password `universalblue` jika diperintahkan untuk menenroll kunci yang dibutuhkan.

### Steam Deck/Home Theater PCs (HTPCs)
> [!IMPORTANT]
Perangkat yang bukan Steam Deck masih bisa menggunakan image bazzite-deck, tetapi harus menggunakan Kartu grafis dari AMD/Intel.

Varian `bazzite-deck` ini didesain untuk digunakan sebagai alternatif untuk SteamOS di perangkat Steam Deck dan HTPC dengan pengalaman seperti konsol:

- Langsung boot ke Gamemode seperti SteamOS.
- **`duperemove` secara otomatis yang berguna untuk mengurangi ukuran folder compatdata.**
- **Versi terbaru dari Mesa yang menghasilkan ukuran shaders cache yang lebih kecil dan tidak diperlukan lagi untuk mencegah stutter.**
- **Langsung bisa booting walaupun diska penuh.**
- **Dukungan untuk setiap bahasa yang disupport oleh Fedora.**
- **Menggunakan Wayland di desktop dengan [dukungan untuk Steam input](https://github.com/Supreeeme/extest).**
- Fitur yang diporting dari SteamOS meliputi driver, pembaruan perangkat tegar, dan pengatur kecepatan kipas [dari repositori evlaV ](https://gitlab.com/evlaV).
- Mesa yang dipatch untuk mengatur framerate di Gamescope.
- Hadir dengan patch dari [SteamOS BTRFS](https://gitlab.com/popsulfr/steamos-btrfs) untuk dukungan BTRFS di SD Card secara bawaan.
- [SDGyroDSU](https://github.com/kmicki/SteamDeckGyroDSU) tersedia dan diaktifkan secara bawaan.
- Pilihan untuk menginstall [Decky Loader](https://github.com/SteamDeckHomebrew/decky-loader), [EmuDeck](https://www.emudeck.com/), [RetroDECK](https://retrodeck.net/), dan [ProtonUp-Qt](https://davidotek.github.io/protonup-qt/), serta berbagai macam paket/aplikasi yang berguna selama pemasangan.
- Sistem pembaruan kustom memungkinkan Sistem Operasi,Flatpak,Paket Nix<sup><sub>(dengan fleek)</sub></sup>, dan Distrobox image untuk diupdate dari Gamemode UI.
- Dukungan untuk dual-boot dengan Windows karena GRUB dari Fedora.
- Pembaruan merusak sesuatu? tinggal rollback ke versi sebelumnya berkat fitur rollback `rpm-ostree`. Anda bisa memilih versi image sebelumnya di boot menu.
- Pra-install Steam dan Lutris sebagai paket sistem.
- Pra-install [Discover Overlay](https://github.com/trigg/Discover) untuk Discord dan otomatis diluncurkan di Gamemode,dan di desktop jika Discord terinstall, [Lihat dokumentasinya disini](https://trigg.github.io/Discover/bazzite).
- Menggunakan ZRAM<sub><sup>(4GB)</sup></sub> dengan kompresi ZSTD secara bawaan dengan opsi untuk menggunakan 1GB swap file dan bisa diatur sesuai kebutuhan.
- Penjadwal I/O untuk mencegah I/O starvation ketika memasang game atau ketika proses latar belakang `duperemove` dan `rmlint` bekerja.
- Mengaplikasikan parameter kernel dari SteamOS.
- Kalibrasi Warna Layar untuk layar matte dan reflektif Steam Deck.
- Fitur-fitur pengguna advance yang tidak diaktifkan secara bawaan seperti:
    - Service untuk undervolting Steam Deck yang beresiko rendah dengan [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) dan [Ryzen SMU](https://gitlab.com/leogx9r/ryzen_smu), anda bisa mengecek `ryzenadj.service` dan `/etc/default/ryzenadj`.
    - Service untuk membatasi kapasitas maksimal saat mengisi ulang, anda bisa mengeceknya di `batterylimit.service` dan `/etc/default/batterylimit`. <sup><sub>(Bekerja walaupun perangkat dalam posisi non aktif)</sub></sup>
    - Dukungan bawaan untuk overclocking layar. Contohnya seperti ini, anda menambahkan `GAMESCOPE_OVERRIDE_REFRESH_RATE=40,70` di `/etc/environment`.
    - Anda bisa menggunakan X11 jika diperlukan dengan mengedit `/etc/default/desktop-wayland`.
    - Lu punya RAM 32 GB? anda bisa memakai 2x lipat VRAM yang diaplikasikan secara otomatis!. <sup><sub>(Coba bagikan skill ngesolder lu dong)</sub></sup>
- Service yang spesifik ke Steam Deck dapat dimatikan dengan menjalankan `ujust disable-deck-services` di terminal, berguna untuk menjalankan image ini di konsol Handheld lain dan HTPC.
- Informasi tambahan dapat ditemukan [disini](https://universal-blue.discourse.group/docs?topic=37) dibagian Bazzite Steam Deck Images.

> [!WARNING]
> **Dikarenakan ada bug/kutu dari upstream,Bazzite tidak bisa digunakan pada perangkat SteamDeck yang memiliki penyimpanan 64GB eMMC. meningkatkan penyimpanan menyelesaikan masalah ini.**

> [!IMPORTANT]
> **ISO bisa diunduh dari halaman rilis kami [disini](https://github.com/ublue-os/bazzite/releases), dan berbagai macam panduan instalasi dapat ditemukan [disini](https://universal-blue.discourse.group/docs?topic=30).**

Jika anda telah menggunakan image dari Universal Blue anda dapat mengikuti [instruksi ini](https://universal-blue.org/images/#image-list). Untuk berganti image dari image upstream Fedora Silverblue/Kinoite ostree anda dapat mengikuti perintah ini:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck:stable
```

### GNOME

Varian desktop GNOME tersedia dalam versi desktop dan deck.varian ini memiliki beberapa fitur tambahan seperti :

- [Dukungan untuk Variable refresh rate dan fractional scaling di sesi wayland secara bawaan](https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1154).
- Menu kustom di bar atas untuk kembali ke game mode, meluncurkan Steam, dan membuka berbagai macam peralatan yang berguna.
- Pra-install [GSConnect](https://extensions.gnome.org/extension/1319/gsconnect/).
- Fitur opsional seperti tema yang terinspirasi Valve yang menyamai Vapor dan VGUI2 dari SteamOS.
- Tersedia secara bawaan [Ekstensi Hanabi](https://github.com/jeffshee/gnome-ext-hanabi) untuk fitur Wallpaper Engine seperti di KDE.
- Pra-install ekstensi opsional, seperti [ekstensi untuk pengalaman pengguna yang lebih baik](https://www.youtube.com/watch?v=nbCg9_YgKgM).
- Pembaruan otomatis untuk [Firefox GNOME theme](https://github.com/rafaelmardojai/firefox-gnome-theme) dan [Thunderbird GNOME theme](https://github.com/rafaelmardojai/thunderbird-gnome-theme). <sup><sub>(jika terinstall)</sub></sup>

> [!IMPORTANT]
> **ISO bisa diunduh dari halaman rilis kami [disini](https://github.com/ublue-os/bazzite/releases), dan berbagai macam panduan instalasi dapat ditemukan [disini](https://universal-blue.discourse.group/docs?topic=30).**

Untuk rebase dari sistem ostree yang ada ke varian **desktop**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome:stable
```

Untuk rebase dari sistem ostree yang ada ke varian **desktop dengan driver Nvidia** release:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

> [!WARNING]
> **Dikarenakan ada bug/kutu dari upstream,Bazzite tidak bisa digunakan pada perangkat SteamDeck yang memiliki penyimpanan 64GB eMMC saat ini.**


Untuk rebase dari sistem ostree yang ada ke varian **Steam Deck/HTPC**:

```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/ublue-os/bazzite-deck-gnome:stable
```

### Fitur dari Upstream

#### Universal Blue

- Flathub diaktifkan secara bawaan
- Perintah [`ujust`](https://github.com/casey/just) untuk kemudahan.
- Kodek Multimedia secara bawaan.
- Rollback Bazzite dari build apapun dalam periode 90 hari.

#### Fitur dari Fedora Linux (Kinoite & Silverblue)

- Base sistem yang stabil dan kuat.
- Paket sistem yang terbarukan.
- Layer paket fedora tanpa perlu takut paket tersebut hilang saat memperbarui sistem.
- Pra-install [SELinux](https://github.com/SELinuxProject/selinux) untuk keamanan dan telah dikonfigurasi secara bawaan.
- Bisa rebase ke image Fedora ostree yang lain jika mau,tanpa kehilangan data pengguna.
- Dukungan printing berkat [CUPS](https://www.cups.org/) yang terinstall secara bawaan.

## Alasan

Bazzite dimulai sebagai proyek untuk menyelesaikan berbagai masalah yang ada di SteamOS, terutama paket-paket yang tidak terbarukan (walaupun menggunakan ArchLinux sebagai base) dan tidak ada manajemen paket yang fungsional.

Walaupun proyek ini juga menggunakan image. anda masih bisa menginstall berbagai macam paket Fedora dari perintah shell. Paket-paket ini akan tetap bertahan setelah pembaruan <sub><sup>(Jadi anda bisa install aplikasi VPN yang anda g bisa install di SteamOS)<sub><sup>.
Sebagai tambahan, Bazzite sering diupdate beberapa kali dalam satu minggu dengan paket-paket dari upstream Fedora, memberikan anda performa terbaik dan fitur-fitur terbaru di base yang stabil.

Bazzite hadir dengan versi Linux kernel yang terbaru dan SELinux diaktifkan secara bawaan dengan dukungan penuh untuk secure boot <sub><sup>(Jalankan `ujust enroll-secure-boot-key` dan masukan password `universalblue` jika diperintahkan untuk menroll key dari kita)</sup></sub>
dan enkripsi disk membuat ini aman dan sempurna untuk komputasi general. <sup><sub>(Yes, anda bisa ngeprint dari Bazzite!)</sub></sup>.

Baca [FAQ](https://universal-blue.discourse.group/docs?topic=33) untuk tahu apa saja yang membuat Bazzite beda dari Sistem Operasi Linux yang lain.

## Pameran

![KDE Vapor Theme](/repo_content/desktop1.png?raw=true "KDE Vapor Theme")
![KDE VGUI2 Theme](/repo_content/desktop2.png?raw=true "KDE VGUI2 Theme")
![Steam Game Mode](/repo_content/gamemode.png?raw=true "Steam Game Mode")
![Waydroid](/repo_content/waydroid.png?raw=true "Waydroid")
![Distrobox Terminals](/repo_content/distrobox.png?raw=true "Distrobox Terminals")
![GNOME Vapor Theme](/repo_content/gnome1.png?raw=true "GNOME Vapor Theme")
![GNOME VGUI2 Theme](/repo_content/gnome2.png?raw=true "GNOME VGUI2 Theme")

## Dokumentasi & Buletin

- [Menginstall dan memanajamen aplikasi](https://universal-blue.discourse.group/docs?topic=35)
- [Updates, Rollbacks, and Rebasing](https://universal-blue.discourse.group/docs?topic=36)
- [Panduan Gim](https://universal-blue.discourse.group/docs?topic=31)
- [Panduan dual booting](https://universal-blue.discourse.group/docs?topic=129)

Temukan dokumentasi tambahan project ini [disini](http://docs.bazzite.gg/).

Cek [buletin](https://universal-blue.discourse.group/tag/bazzite-buzz) kami yang selalu update secara regular tentang proyek ini.

## Verifikasi

Image berikut ini telah disigned oleh sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). Anda bisa menverifikasi signature dengan mengunduh key `cosign.pub` dari repo ini dan menjalankan perintah ini:

```bash
cosign verify --key cosign.pub ghcr.io/ublue-os/bazzite
```

## Secure Boot

Secure boot didukung dengan key dari kami. Pub key dapat ditemukan di root repositori [ini](https://github.com/ublue-os/bazzite/blob/main/secure_boot.der).
Jika anda ingin menenroll key ini sebelum instalasi, unduh key ini dan jalankan:

```bash
sudo mokutil --timeout -1
sudo mokutil --import secure_boot.der
```

### Metrik Kontribusi

![Bazzite](https://repobeats.axiom.co/api/embed/86b500d79c613015ad16f56df76c8e13f3fd98ae.svg "Repobeats analytics image")

## Ucapan Terimakasih
Bazzite merupakan upaya dari komunitas dan tidak akan pernah ada tanpa dukungan dari semua orang. berikut ini merupakan orang-orang yang telah membantu kami:

- [rei.svg](https://github.com/reisvg) - Yang membuat logo dan branding.
- [evlaV](https://gitlab.com/evlaV) - Untuk membuat kode dari Valve tersedia dan menjadi [orang ini](https://xkcd.com/2347/).
- [ChimeraOS](https://chimeraos.org/) - Untuk gamescope-sesion dan mendukung kami diperjalanan ini.
- [Jovian-NixOS](https://github.com/Jovian-Experiments) - Untuk mendukung kami dengan menyelesaikan masalah teknis kami dan membuat project yang mirip. Serius bro coba cek proyek mereka. Mereka pakai Nix!.
- [sentry](https://copr.fedorainfracloud.org/coprs/sentry/) - Untuk membantu dengan patch kernel dan membuat repo [kernel-fsync repo](https://copr.fedorainfracloud.org/coprs/sentry/kernel-fsync/) yang kami gunakan.
- [nicknamenamenick](https://github.com/nicknamenamenick) - Untuk menjadi orang yang paling berharga, yang selalu menulis dokumentasi dan dukungan, dan selalu membantu pengguna.
- [Steam Deck Homebrew](https://deckbrew.xyz) - Untuk memilih distribusi lain selain SteamOS walaupun butuh kerja ekstra, dan terimakasih yang spesial untuk [PartyWumpus](https://github.com/PartyWumpus) yang membuat Decky Loader bekerja dengan SELinux untuk kami.
- [cyrv6737](https://github.com/cyrv6737) - Untuk inspirasi dan base yang akan menjadi bazzite.

## Membuat Image Anda Sendiri

Bazzite dibuat secara penuh di Github dan membuat versi anda sendiri sangat mudah, anda hanya perlu menfork repositori ini, menambahkan private sigining key, dan mengaktifkan Github actions.


[Membiasakan anda sendiri dengan](https://docs.github.com/en/actions/security-guides/encrypted-secrets) untuk menyimpan secret di Github. Anda perlu membuat [keypair baru](https://docs.sigstore.dev/cosign/overview/) dengan cosign. Public key bisa anda teruh di repo publik anda. <sub><sup>(Pengguna anda perlu ini untuk mencek signature)</sup></sub>, dan anda bisa mempaste Secret key di  `Settings -> Secrets -> Actions` dengan nama `SIGNING_SECRET`.

Kami juga membawakan konfigurasi untuk [pull app](https://github.com/apps/pull) jika anda ingin fork anda selalu up to date dengan upstream. Aktifkan ini di repo anda untuk melacak perubahan dari Bazzite ketika anda membuat modifikasi anda sendiri.

## Bergabung Dengan Komunitas
Anda bisa menemukan kami di [Discord Universal Blue](https://discord.gg/f8MUghG5PB) dan melihat arsip dari utas bantuan di [Answer Overflow](https://www.answeroverflow.com/c/1072614816579063828/1143023993041993769).

Berdiskusi dan membuat panduan untuk pengguna di [Forum Discourse Universal Blue](https://universal-blue.discourse.group/c/bazzite/5).

Ikuti Universal Blue di [Mastodon](https://fosstodon.org/@UniversalBlue).
