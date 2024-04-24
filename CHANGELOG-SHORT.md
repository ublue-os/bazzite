# Changelog

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

## [2.5.0](https://github.com/ublue-os/bazzite/compare/v2.4.0...v2.5.0) (2024-04-14)


### Features

* New ISO install experience with Flatpaks now included.
* Removal of initramfs building at first boot thanks to new in-image generation. Existing users who haven't customized initramfs can run `rpm-ostree initramfs --disable` after updating to speed up future updates.
* Add auto-vram kargs for Legion GO and ASUS Ally ([d8f450c](https://github.com/ublue-os/bazzite/commit/d8f450c4dc6bf0c0345826291a9c801f775a8a90))
* Add copr helper ([df62cd6](https://github.com/ublue-os/bazzite/commit/df62cd604aba1dd7329a56c17ddba164ac63ea53))
* Add ISO torrents via archive.org, huge thanks to [@qoijjj](https://github.com/qoijjj) for all the work on this ([#933](https://github.com/ublue-os/bazzite/issues/933)) ([022bf16](https://github.com/ublue-os/bazzite/commit/022bf16b7da14001060b8de1e393ce8929a0a665))
* Add Nobara USB Polling Rate Patch ([#964](https://github.com/ublue-os/bazzite/issues/964)) ([f349a39](https://github.com/ublue-os/bazzite/commit/f349a396daa18716aab40c739278165af6e221cb))
* Add pre-image initramfs generation, preload fido2, tpm2-tss, and clevis ([f9b4ef9](https://github.com/ublue-os/bazzite/commit/f9b4ef92c9800487a7ea4ecce285967561292884))
* add readme for how to trigger initramfs rebuild ([6834f49](https://github.com/ublue-os/bazzite/commit/6834f49cd588ac89b879ec001e3f59db8ea9d429))
* Add setroubleshoot by default, with alerts disabled ([142e573](https://github.com/ublue-os/bazzite/commit/142e5732a6b734a5eacc50e5236f71ea73d0bd91))
* Add support for midi in Lutris ([5403679](https://github.com/ublue-os/bazzite/commit/540367916c6b07f5581936d46cbb57a659ea5e6d))
* Add udica for generating SELinux policies for containers ([b18c31b](https://github.com/ublue-os/bazzite/commit/b18c31b44a35006b0308e68ae090919bd557716f))
* **deck:** add tdpfix for cards that has 15W TDP on boot due to writable sysfs on boot ([#892](https://github.com/ublue-os/bazzite/issues/892)) ([0bbd9a5](https://github.com/ublue-os/bazzite/commit/0bbd9a53d9fe0247d6c96a2c5f0728fbdba3d8a5))
* **gamescope:** Add HDR patch for Kernel 6.8 ([f8ad9ab](https://github.com/ublue-os/bazzite/commit/f8ad9ab8f3dadf13d0b64d49d65c0b9b59356530))
* **just:** add warning message for looking-glass shm creation. ([1700ea7](https://github.com/ublue-os/bazzite/commit/1700ea7ab320cc10f516a005e1a942d757d64bfc))
* **just:** Enable virtualization for deck hardware ([#895](https://github.com/ublue-os/bazzite/issues/895)) ([2139735](https://github.com/ublue-os/bazzite/commit/21397351e7267fcc58731a698b7b19747034ed4c))
* **just:** update recipe to edit tuned default profile using ppd.conf ([#907](https://github.com/ublue-os/bazzite/issues/907)) ([eed757d](https://github.com/ublue-os/bazzite/commit/eed757d5004b6c2892d64ec2d391648436ec0193))
* remove custom rpm-ostree initramfs arg support ([c8dc6d8](https://github.com/ublue-os/bazzite/commit/c8dc6d8f32efb2142226d50a42bfdd3e4317620c))
* Remove initramfs step that takes a long time on first startup ([b48a3ec](https://github.com/ublue-os/bazzite/commit/b48a3ec7265139afbdd016337f0b80a4dfcf9eb6))
* Switch yafti to use the new Solaar flatpak ([020060e](https://github.com/ublue-os/bazzite/commit/020060e4570609a95842b890a9b56b4aadb06b6c))
* update image label with actual kernel version ([#924](https://github.com/ublue-os/bazzite/issues/924)) ([2bbdf25](https://github.com/ublue-os/bazzite/commit/2bbdf25f2aa10bbfdb21c7d7d4dd708cae415a1a))
* Use new https://github.com/ublue-os/hwe Nvidia install script ([a692a2f](https://github.com/ublue-os/bazzite/commit/a692a2faa08de3a586a9a998792eb9753ab9d643))
* Use zstd compression for initramfs ([6592377](https://github.com/ublue-os/bazzite/commit/65923774b2c7efd8625861118fd161d2fa2df0d4))


### Bug Fixes

* Add lsb_release package for EmuDeck ([2c8bfc3](https://github.com/ublue-os/bazzite/commit/2c8bfc371b6a5e93364a5680ca6d6333b4d0b6fd))
* Add missing sqlite package for duperemove, fixes [#959](https://github.com/ublue-os/bazzite/issues/959) ([5403679](https://github.com/ublue-os/bazzite/commit/540367916c6b07f5581936d46cbb57a659ea5e6d))
* **ally:** Fix a bug where the power drains when the device is fully powered off caused by the fingerprint reader. ([f5f0334](https://github.com/ublue-os/bazzite/commit/f5f033424281f88f0a132ec0561a5a5f002faf24))
* Correct issue with hhd being enabled on root, add HHD adjustor package. ([929cee4](https://github.com/ublue-os/bazzite/commit/929cee487d31ebc400f94485b974748465df9bea))
* Correct issues with newest version of distrobox ([bae2fae](https://github.com/ublue-os/bazzite/commit/bae2fae95b7adcaf2309f9c98637efac3f51c65d))
* **deck:** Restore all settings in restore-gnome-de-settings ujust command on deck images ([89ca085](https://github.com/ublue-os/bazzite/commit/89ca085912f0896c26577a4bce0d83a3bb31da10))
* **deck:** Skip the first update in gaming mode on new installs ([5eede45](https://github.com/ublue-os/bazzite/commit/5eede4578872b43cebbafda5f1925cb1b5bcedd6))
* **gamescope:** add 3.13.16.9 backport ([#967](https://github.com/ublue-os/bazzite/issues/967)) ([45a8e4a](https://github.com/ublue-os/bazzite/commit/45a8e4ab6be1c02483b0684fd6cb1e3ee711a5ed))
* **gnome:** Disable joystickwake on GNOME until lock screen issue can be triaged and fixed. ([57f144f](https://github.com/ublue-os/bazzite/commit/57f144fd858cbccd9aabbece2d65ed1c6e0a78c6))
* Install firmware on all images, allows desktop images to be used on some handhelds (with caveats) ([a5a7b95](https://github.com/ublue-os/bazzite/commit/a5a7b952453aa84a9f277e5739e5e9f31a6e1f50))
* **kde:** Update gtk4 package for Ptyxis ([0109f9a](https://github.com/ublue-os/bazzite/commit/0109f9af67b89fe7535bbc01267654d58b3d88b1))
* Pull in s76 scheduler fixes from fruitchewy ([b60b1e6](https://github.com/ublue-os/bazzite/commit/b60b1e621fb643c4ea59a8254ca5bc0250637367))
* **readme:** Remove Dual Boot documentation ([#969](https://github.com/ublue-os/bazzite/issues/969)) ([5bd73aa](https://github.com/ublue-os/bazzite/commit/5bd73aa4d609ad32d71aea8f4ad7df10c5527764))
* remove clevis from dracut.conf.d ([977321b](https://github.com/ublue-os/bazzite/commit/977321b5097b59bfe4ee8eb032c4a32fcbea7ecd))
* Remove unneeded file checks from hardware setup ([7133fc7](https://github.com/ublue-os/bazzite/commit/7133fc773a5c600290d6f9f492a638a23b851cb2))
* Remove unneeded secure boot message ([7a3a9c1](https://github.com/ublue-os/bazzite/commit/7a3a9c13627bba4ba2fb5cc1f9bb48817486ba97))
* Use balanced-no-pstate profile on CPUs that don't support a pstate governor. ([1dcda86](https://github.com/ublue-os/bazzite/commit/1dcda86fe048a269ee1a79eacbb18377fc27379f))
* Use Ptyxis from ublue-os/staging copr ([a1d47b0](https://github.com/ublue-os/bazzite/commit/a1d47b006c6cdeaa8edd5c4083c7da9519a47eb6))
* Use xone driver as canary for secure boot check ([6113650](https://github.com/ublue-os/bazzite/commit/61136504b97255352ce8c38cdf30ea1f09e9e534))

