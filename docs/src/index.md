---
title: Home
hide:
  - navigation
---

# Getting started

A quick list of stuff you might be interested in checking out:

<div class="grid cards _bz" markdown>

- [:material-harddisk: **Installing Bazzite**](General/Installation_Guide/index.md){ style="font-size: 1.1rem" }

  From [desktop/laptops][install_pc_laptop], <br>Framework [13][frame_13]/[16][frame_16], to a [multitude of handhelds][install_handheld]:

  - [Steam Deck (and OLED)][deck]
  - [Asus ROG Ally (X)][ally]
  - [Lenovo Legion Go][legion_go]
  - [GPD Handhelds][gpd]
  - [Ayn Handhelds][ayn]
  - [Ayaneo Handhelds][ayaneo]

- [:material-download-circle: **Install Software**][installing_software]{ style="font-size: 1.1rem" }

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

- [:fontawesome-brands-windows: **Run Windows Games**][run_win_game]{ style="font-size: 1.1rem" }

  Bazzite comes bundled with :fontawesome-brands-steam: Steam\* and [Lutris](Gaming/Game_Launchers.md#lutris-setup).

  Compatible with other tools as well:

  - [Heroic](https://heroicgameslauncher.com/) for Epic Games, GOG, and Amazon Games integration.
  - [Bottles](https://usebottles.com/) for general-purpose applications or as an alternative to Lutris.
  - ...And [more][run_win_game]!

  <small>\* Desktop images require [**enabling Proton for all Steam games**][enable_proton].</small>

- [:fontawesome-solid-circle-arrow-down: **Updates, Rollbacks, and Rebasing**][updateindex]{ style="font-size: 1.1rem" }

  - [Updating Guide][updates]
  - [Rollback System Updates][rollbacks]
  - [Rebasing to Other Images][rebasing]
  - [`bazzite-rollback-helper`][rollback-helper]

- [:fontawesome-brands-android: **Android Applications**][waydroid]{ style="font-size: 1.1rem" }

  Run Android applications in a container using [Waydroid](https://waydro.id/)!

  - Launch anything from productivity software to games!
  - Support for the Google Play Store and [F-Droid](https://f-droid.org/).

- [:fontawesome-solid-handshake: **Contribute**][contrib]{ style="font-size: 1.1rem" }

  One of the strengths of Bazzite (inherited from [Universal Blue](https://universal-blue.org/)) is how easy is to contribute.

  - Something seems broken? You might want to [report a bug](General/reporting_bugs.md).
  - You can help us adding more translations to our READMEs.

</div>

[install_pc_laptop]: General/Installation_Guide/Installing_Bazzite_for_Desktop_or_Laptop_Hardware.md
[install_handheld]: General/Installation_Guide/Installing_Bazzite_for_Handheld_PCs.md
[deck]: General/Installation_Guide/Installing_Bazzite_for_Steam_Deck.md
[frame_13]: General/Installation_Guide/Installing_Bazzite_Framework_Laptop_13.md
[frame_16]: General/Installation_Guide/Installing_Bazzite_for_Framework_Laptop_16.md
[htpc]: General/Installation_Guide/Installing_Bazzite_for_HTPC_Setups.md
[ally]: Handheld_and_HTPC_edition/Handheld_Wiki/ASUS_ROG_Ally.md
[legion_go]: Handheld_and_HTPC_edition/Handheld_Wiki/Lenovo_Legion_Go.md
[ayn]: Handheld_and_HTPC_edition/Handheld_Wiki/Ayn_Handhelds.md
[gpd]: Handheld_and_HTPC_edition/Handheld_Wiki/GPD_Handhelds.md
[ayaneo]: Handheld_and_HTPC_edition/Handheld_Wiki/Ayaneo_Handhelds.md
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
[updateindex]: Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/index.md
[updates]: Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/updating_guide.md
[rollbacks]: Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/rolling_back_system_updates.md
[rebasing]: Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/rebase_guide.md
[rollback-helper]: Installing_and_Managing_Software/Updates_Rollbacks_&_Rebasing/bazzite_rollback_helper.md
[waydroid]: Installing_and_Managing_Software/Waydroid_Setup_Guide.md
