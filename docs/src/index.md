---
title: Home
hide:
  - navigation
---

# Getting started

A quick list of stuff you might be interested in checking out:

<div class="grid cards _bz" markdown>

- [:material-harddisk: **Installing Bazzite**](General/Installation_Guide/index.md){ style="font-size: 1.1rem" }

  From [desktop/laptops][install_pc_laptop], <br>Framework [13][frame_13]/[16][frame_16], to a multitude of handhelds:

  - [Steam Deck (and OLED)][install_handheld]
  - [Asus ROG Ally (X)][install_handheld]
  - [Lenovo Legion Go][install_handheld]
  - [Ayaneo][install_handheld]
  - [GPD][install_handheld]
  - [Ayn][install_handheld]

- [:material-download-circle: **Install software**][installing_software]{ style="font-size: 1.1rem" }

  <small>Order reflects the recommendation degree</small>

  1. [Flatpak][flatpak] for graphical apps
     {style="list-style-type: decimal;"}
  2. [ujust][ujust] to use bazzite tailored installers
     {style="list-style-type: decimal;"}
  3. [Homebrew][homebrew] for CLI apps
     {style="list-style-type: decimal;"}
  4. [Distrobox][distrobox] for containerized apps
     {style="list-style-type: decimal;"}
  5. [Appimage][appimage]
     {style="list-style-type: decimal;"}

  You can as well install regular Fedora packages with [`rpm-ostree`][rpm-ostree] but we [advise avoiding it if possible][rpm-ostree_caveats].

- [:fontawesome-brands-windows: **Run Windows games**][run_win_game]{ style="font-size: 1.1rem" }

  Bazzite comes bundled with :fontawesome-brands-steam: Steam\* and [Lutris](Gaming/Game_Launchers.md#lutris-setup).

  As well, compatible with other tools:

  - [Heroic](https://heroicgameslauncher.com/) for Epic Games, GOG, and Amazon Games integration.
  - [Bottles](https://usebottles.com/) for general-purpose applications or as an alternative to Lutris.
  - ... And [more][run_win_game].

  <small>\* In desktop images, you might need to [enable Proton for all Steam games][enable_proton].</small>

- [:fontawesome-solid-handshake: **Contribute to the project**][contrib]{ style="font-size: 1.1rem" }

  One of the strengths of Bazzite (inherited from [Universal Blue](https://universal-blue.org/)) is how easy is to contribute.

  - Something seems broken? You might want to [report a bug](General/reporting_bugs.md).
  - You can help us adding more translations to our READMEs.

</div>

[install_pc_laptop]: General/Installation_Guide/Installing_Bazzite_for_Desktop_or_Laptop_Hardware.md
[install_handheld]: General/Installation_Guide/Installing_Bazzite_for_Steam_Deck.md#installation-guide
[frame_13]: General/Installation_Guide/Installing_Bazzite_Framework_Laptop_13.md
[frame_16]: General/Installation_Guide/Installing_Bazzite_for_Framework_Laptop_16.md
[run_win_game]: Installing_and_Managing_Software/index.md#how-do-i-run-windows-applications
[enable_proton]: Gaming/Game_Launchers.md#enabling-proton-for-all-steam-games
[flatpak]: Installing_and_Managing_Software/Flatpak.md
[ujust]: Installing_and_Managing_Software/ujust.md
[rpm-ostree]: Installing_and_Managing_Software/rpm-ostree.md
[distrobox]: Installing_and_Managing_Software/Distrobox.md
[installing_software]: Installing_and_Managing_Software/index.md
[contrib]: General/Contributing_to_Bazzite.md
[homebrew]: Installing_and_Managing_Software/Homebrew.md
[rpm-ostree_caveats]: Installing_and_Managing_Software/rpm-ostree.md#major-caveats-using-rpm-ostree
[steam_game_mode]: Handheld_and_HTPC_edition/Steam_Gaming_Mode.md#what-is-steam-gaming-mode
[appimage]: Installing_and_Managing_Software/AppImage.md
