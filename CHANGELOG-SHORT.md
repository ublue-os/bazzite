# Changelog

## [3.0.1](https://github.com/ublue-os/bazzite/compare/v3.0.0...v3.0.1) (2024-05-02)


### Features

* Add `ujust setup-luks-tpm-unlock` ([5402f53](https://github.com/ublue-os/bazzite/commit/5402f530ef2cfe9403fc0baee79c664699a811d2))
* Add new ublue wallpaper as the default ([3c79d31](https://github.com/ublue-os/bazzite/commit/3c79d312556f3d8ec87fa804dcc4d4cc91a4db83))
* Add new version of gamescope ([60a94cd](https://github.com/ublue-os/bazzite/commit/60a94cd5173cc8bb6545a149ea553ab47dfb7c3a))
* Add Steam Deck SD card mounting to desktop images ([a683b3b](https://github.com/ublue-os/bazzite/commit/a683b3bc97063394eebea183605c63a5115262c6))
* **deck:** Add Handheld Controller Glyphs... ([#1059](https://github.com/ublue-os/bazzite/issues/1059)) ([e1f026e](https://github.com/ublue-os/bazzite/commit/e1f026ee6f3d107ced604e0324e86264c3b59ba2))
* Deprecate looking-glass shm in favor of kvmfr module ([#1013](https://github.com/ublue-os/bazzite/issues/1013)) ([8f7bb0b](https://github.com/ublue-os/bazzite/commit/8f7bb0bd6854c1d6a67f30903161a5f870c9e3d0))
* **framework:** Add needed kargs and extensions to setup scripts ([96f1be0](https://github.com/ublue-os/bazzite/commit/96f1be0198e890d9a2979a61650fa004c5c5725e))
* **framework:** Use Framework logo in logo menu by default &lt;3 ([4a8e70b](https://github.com/ublue-os/bazzite/commit/4a8e70bf7f199816507a232787fb9796475befb6))
* **gnome:** Add compiz alike magic lamp effect extension, default disabled ([dbc7862](https://github.com/ublue-os/bazzite/commit/dbc7862607eb97ab62615fa5fff447a79814242c))
* **gnome:** Add power profile switcher extension (pre-configured, but disabled by default) ([fb006c2](https://github.com/ublue-os/bazzite/commit/fb006c2fb7b8302053d17a9490342aed78b74464))
* **gnome:** Restore xwayland fractional scaling ([dbc7862](https://github.com/ublue-os/bazzite/commit/dbc7862607eb97ab62615fa5fff447a79814242c))
* remove root password option from installer ([ad9ec40](https://github.com/ublue-os/bazzite/commit/ad9ec4011ee0d07d97107e992e8a884864af6e8d))


### Bug Fixes

* Always install jupiter-sd-mounting-btrfs ([821e9ea](https://github.com/ublue-os/bazzite/commit/821e9ea6a104f1ae6811255e50525446ae6b4e77))
* bazzite-user-setup should only run when needed ([#1020](https://github.com/ublue-os/bazzite/issues/1020)) ([f33d1e7](https://github.com/ublue-os/bazzite/commit/f33d1e799a090693c3adb3bbbdf2577975515fb2))
* **bazzite-user-setup:** include  in file check and move  after first if statement ([#1023](https://github.com/ublue-os/bazzite/issues/1023)) ([c4670d2](https://github.com/ublue-os/bazzite/commit/c4670d271d3b97740b6b6ffdb128e9f8668661a4))
* **ci:** set image version to match source ([#1031](https://github.com/ublue-os/bazzite/issues/1031)) ([57b0d1f](https://github.com/ublue-os/bazzite/commit/57b0d1f2461b402bba106d153bc397c77bd7b060))
* Correct issue with Steam refusing to launch on some multi-gpu hardware when launched on the dGPU. ([0c1a55c](https://github.com/ublue-os/bazzite/commit/0c1a55c629c3a12bd42818f3a487f897a9d6115f))
* disable requirement for testing branch ([224e883](https://github.com/ublue-os/bazzite/commit/224e8838454267fd3e195c35da4c6124fdb1cb36))
* Drop patched bluez ([857f933](https://github.com/ublue-os/bazzite/commit/857f933088d18f3341037faff3089e74fb9e6059))
* fix typo ([f49e0c0](https://github.com/ublue-os/bazzite/commit/f49e0c0f2512ba83b525291a34dffdc186c7ee60))
* fully qualify path ([e1cbc25](https://github.com/ublue-os/bazzite/commit/e1cbc25b8ff4d07b614ac85f08cf714b82e1025f))
* **kde:** Fix issue with theme picker under KDE6 for Vapor and VGUI2. ([3c79d31](https://github.com/ublue-os/bazzite/commit/3c79d312556f3d8ec87fa804dcc4d4cc91a4db83))
* no longer tell people to configure grub when showing virtualization helptext ([#1042](https://github.com/ublue-os/bazzite/issues/1042)) ([3457926](https://github.com/ublue-os/bazzite/commit/3457926faa785a6d8d66f3286703156d64e1bcdd))
* simplify code and add if back for testing ([ca44343](https://github.com/ublue-os/bazzite/commit/ca4434389e3762f1af878c10d25494d1a3e502a2))


### Miscellaneous Chores

* release 3.0.1 ([2370baa](https://github.com/ublue-os/bazzite/commit/2370baa1db1ceda0b6bfb6252758ecb58b32a0ff))

## [3.0.0](https://github.com/ublue-os/bazzite/compare/v2.5.0...v3.0.0) (2024-04-24)


### Features

* Upgrade to Fedora 40 base
* add bazzite-rollback-helper util ([#1002](https://github.com/ublue-os/bazzite/issues/1002)) ([1d146d6](https://github.com/ublue-os/bazzite/commit/1d146d6bbc7ce57bac7fef9b8b0734af07641f1f))
* add command to support rebasing ([#989](https://github.com/ublue-os/bazzite/issues/989)) ([c96bc6f](https://github.com/ublue-os/bazzite/commit/c96bc6fb6985365d569f1f157b8d640c45607779))
* Add framework-laptop kmod ([1ab933c](https://github.com/ublue-os/bazzite/commit/1ab933cb4b705c174ddab37ffc53db25a6ac58ec))
* Add kmod for cdemu ([c789ce2](https://github.com/ublue-os/bazzite/commit/c789ce2db5cb27051181c1fad0c3240d0ae72b25))
* Add kmod for looking glass client ([049912f](https://github.com/ublue-os/bazzite/commit/049912f67aa9f8079a4161e47259d5735dbd3733))
* Add option to ujust to control background transparency of the Ptyxis terminal ([0767471](https://github.com/ublue-os/bazzite/commit/0767471c3d57926610df81a8835a1bc20959d8e5))
* Add option to ujust to disable swipe gestures in gaming mode (Thanks [@nicknamenamenick](https://github.com/nicknamenamenick)) ([94334a0](https://github.com/ublue-os/bazzite/commit/94334a07b6af1741c5cdfca63409044e4354ac90))
* Add ujust command to optionally install CDEmu for handling disk-based games without a CD drive. ([3c38bd3](https://github.com/ublue-os/bazzite/commit/3c38bd32be1cdb1654aca2e7a96e53611a9aa70c))
* **deck:** Automatically hide HHD-UI desktop icon on Steam Deck hardware where it's not applicable. ([59e4c38](https://github.com/ublue-os/bazzite/commit/59e4c38ce8fb2446652283253007281d0d9e6dfa))
* **deck:** End X11 support ([21e5f14](https://github.com/ublue-os/bazzite/commit/21e5f14fcffe0d38788a5cc9ec1c3b4efabc5044))
* **deck:** Remove nested desktop support. This has been broken under GNOME since launch, and is now broken under KDE as of KDE6. ([3032dae](https://github.com/ublue-os/bazzite/commit/3032dae4d77465acd3e7d93a4b4cdd53f027a9d6))
* **desktop:** add an action to install ollama on a Bazzite system ([#994](https://github.com/ublue-os/bazzite/issues/994)) ([2dba9b1](https://github.com/ublue-os/bazzite/commit/2dba9b14e54ea94865fa60f2e6b5738e5c6563c8))
* **gnome:** Add patched mutter with triple buffering and nvidia secondary gpu copy acceleration ([4889453](https://github.com/ublue-os/bazzite/commit/4889453f1648192017e0430b640a9f2b6b40ccb7))
* Include zoxide by default ([8ae44a7](https://github.com/ublue-os/bazzite/commit/8ae44a7b63d9461b10fa2d6f3d61c20054db4dff))
* New fetch logo ([b9419a9](https://github.com/ublue-os/bazzite/commit/b9419a9badb156ee3b25b6d9a9152ff6e35c4641))
* **nvidia:** Restore X11 support on KDE until Nvidia successfully moves on from 80s Deco ([4885be3](https://github.com/ublue-os/bazzite/commit/4885be3b92e7f56ba7579e4f96818f93a7e20831))
* Switch to fastfetch from hyfetch ([8c921a5](https://github.com/ublue-os/bazzite/commit/8c921a5780a86d3b4e3f0a29f0618bac54e3d5ae))
* **ujust:** add ujust for disabling/enabling swipe gestures ([#1005](https://github.com/ublue-os/bazzite/issues/1005)) ([1ecb734](https://github.com/ublue-os/bazzite/commit/1ecb734b1026da62224d0934d8a2841a6bbc93e7))


### Bug Fixes

* **ci:** extract digest output from retry action ([#1003](https://github.com/ublue-os/bazzite/issues/1003)) ([a8675e9](https://github.com/ublue-os/bazzite/commit/a8675e9904d2ae3e5e01216e0d837a0cb11e67a5))
* Correct BLEND_TF support in gamescope AMD HDR patch ([5538873](https://github.com/ublue-os/bazzite/commit/5538873299a2e9773f487dc0db0a88d6d8fbc8da))
* Correctly apply vfio after initramfs changes ([#987](https://github.com/ublue-os/bazzite/issues/987)) ([79146b8](https://github.com/ublue-os/bazzite/commit/79146b86fce6a12483b3990d2d5715e882f83536))
* **deck:** Use new rotation system based on Valve's bootstrap. ([c16afeb](https://github.com/ublue-os/bazzite/commit/c16afeb71e0d51a036ca840b83ccd3bdb44e288b))
* **ds-inhibit:** autoload hid-playstation to avoid hook conflicts ([#991](https://github.com/ublue-os/bazzite/issues/991)) ([a771bf7](https://github.com/ublue-os/bazzite/commit/a771bf7950d922833e8864336e84081877c891c0))
* Fix issue with Waydroid due to apparmor entry in LXC config ([baf680d](https://github.com/ublue-os/bazzite/commit/baf680da7c40fac5cb9a88e9bce1e4a54e884d00))
* **just:** correctly set default powerprofile to power-saver when selected ([e189885](https://github.com/ublue-os/bazzite/commit/e18988554a5b98546c3c7e11b5c929920fccd381))
* move custom-device-pollrates.conf ([#975](https://github.com/ublue-os/bazzite/issues/975)) ([18132ea](https://github.com/ublue-os/bazzite/commit/18132ea9177f0d0d1c5143ab51074fa4da2e5180))


### Miscellaneous Chores

* release 3.0.0 ([f138206](https://github.com/ublue-os/bazzite/commit/f138206ef72bddb81138d4a24ab2654d46aa0769))

