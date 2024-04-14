# Changelog

## [2.5.0](https://github.com/ublue-os/bazzite/compare/v2.4.0...v2.5.0) (2024-04-14)


### Features

* Add auto-vram kargs for Legion GO and ASUS Ally ([d8f450c](https://github.com/ublue-os/bazzite/commit/d8f450c4dc6bf0c0345826291a9c801f775a8a90))
* Add copr helper ([df62cd6](https://github.com/ublue-os/bazzite/commit/df62cd604aba1dd7329a56c17ddba164ac63ea53))
* Add copr helper ([036687d](https://github.com/ublue-os/bazzite/commit/036687d43f5f947e346ee127fb26ef73e6422b5d))
* Add ISO torrents via archive.org, huge thanks to [@qoijjj](https://github.com/qoijjj) for all the work on this ([#933](https://github.com/ublue-os/bazzite/issues/933)) ([022bf16](https://github.com/ublue-os/bazzite/commit/022bf16b7da14001060b8de1e393ce8929a0a665))
* Add Nobara USB Polling Rate Patch ([#964](https://github.com/ublue-os/bazzite/issues/964)) ([f349a39](https://github.com/ublue-os/bazzite/commit/f349a396daa18716aab40c739278165af6e221cb))
* Add pre-image initramfs generation, preload fido2, tpm2-tss, and clevis ([f9b4ef9](https://github.com/ublue-os/bazzite/commit/f9b4ef92c9800487a7ea4ecce285967561292884))
* add readme for how to trigger initramfs rebuild ([6834f49](https://github.com/ublue-os/bazzite/commit/6834f49cd588ac89b879ec001e3f59db8ea9d429))
* Add setroubleshoot by default, with alerts disabled ([142e573](https://github.com/ublue-os/bazzite/commit/142e5732a6b734a5eacc50e5236f71ea73d0bd91))
* Add setroubleshoot by default, with alerts disabled ([748e7d9](https://github.com/ublue-os/bazzite/commit/748e7d9f25339cce586dcc090c6ae903879cb361))
* Add support for midi in Lutris ([5403679](https://github.com/ublue-os/bazzite/commit/540367916c6b07f5581936d46cbb57a659ea5e6d))
* Add support for midi in Lutris ([4707bc4](https://github.com/ublue-os/bazzite/commit/4707bc4a15661c0b9853050708faf2da54f05a0d))
* Add udica for generating SELinux policies for containers ([b18c31b](https://github.com/ublue-os/bazzite/commit/b18c31b44a35006b0308e68ae090919bd557716f))
* Add wl-clipboard ([ecc8f10](https://github.com/ublue-os/bazzite/commit/ecc8f10ec29ad1c0c6ae0e3313b8e719da0f9322))
* Add wl-clipboard ([adc2f11](https://github.com/ublue-os/bazzite/commit/adc2f1154d516de9dd7ca59e77fd9766d1218459))
* **deck:** add tdpfix for cards that has 15W TDP on boot due to writable sysfs on boot ([#892](https://github.com/ublue-os/bazzite/issues/892)) ([0bbd9a5](https://github.com/ublue-os/bazzite/commit/0bbd9a53d9fe0247d6c96a2c5f0728fbdba3d8a5))
* **gamescope:** Add HDR patch for Kernel 6.8 ([f8ad9ab](https://github.com/ublue-os/bazzite/commit/f8ad9ab8f3dadf13d0b64d49d65c0b9b59356530))
* **just:** add warning message for looking-glass shm creation. ([1700ea7](https://github.com/ublue-os/bazzite/commit/1700ea7ab320cc10f516a005e1a942d757d64bfc))
* **just:** Enable virtualization for deck hardware ([#895](https://github.com/ublue-os/bazzite/issues/895)) ([2139735](https://github.com/ublue-os/bazzite/commit/21397351e7267fcc58731a698b7b19747034ed4c))
* **just:** update recipe to edit tuned default profile using ppd.conf ([#907](https://github.com/ublue-os/bazzite/issues/907)) ([eed757d](https://github.com/ublue-os/bazzite/commit/eed757d5004b6c2892d64ec2d391648436ec0193))
* remove custom rpm-ostree initramfs arg support ([c8dc6d8](https://github.com/ublue-os/bazzite/commit/c8dc6d8f32efb2142226d50a42bfdd3e4317620c))
* Remove initramfs step that takes a long time on first startup ([b48a3ec](https://github.com/ublue-os/bazzite/commit/b48a3ec7265139afbdd016337f0b80a4dfcf9eb6))
* Switch yafti to use the new Solaar flatpak ([020060e](https://github.com/ublue-os/bazzite/commit/020060e4570609a95842b890a9b56b4aadb06b6c))
* Switch yafti to use the new Solaar flatpak ([c0c616b](https://github.com/ublue-os/bazzite/commit/c0c616b232898590551e1236b518b9c3d7811eba))
* update image label with actual kernel version ([#924](https://github.com/ublue-os/bazzite/issues/924)) ([2bbdf25](https://github.com/ublue-os/bazzite/commit/2bbdf25f2aa10bbfdb21c7d7d4dd708cae415a1a))
* Use new https://github.com/ublue-os/hwe Nvidia install script ([a692a2f](https://github.com/ublue-os/bazzite/commit/a692a2faa08de3a586a9a998792eb9753ab9d643))
* Use zstd compression for initramfs ([6592377](https://github.com/ublue-os/bazzite/commit/65923774b2c7efd8625861118fd161d2fa2df0d4))


### Bug Fixes

* Add lsb_release package for EmuDeck ([2c8bfc3](https://github.com/ublue-os/bazzite/commit/2c8bfc371b6a5e93364a5680ca6d6333b4d0b6fd))
* Add missing sqlite package for duperemove, fixes [#959](https://github.com/ublue-os/bazzite/issues/959) ([5403679](https://github.com/ublue-os/bazzite/commit/540367916c6b07f5581936d46cbb57a659ea5e6d))
* Add missing sqlite package for duperemove, fixes [#959](https://github.com/ublue-os/bazzite/issues/959) ([4707bc4](https://github.com/ublue-os/bazzite/commit/4707bc4a15661c0b9853050708faf2da54f05a0d))
* **ally:** Fix a bug where the power drains when the device is fully powered off caused by the fingerprint reader. ([f5f0334](https://github.com/ublue-os/bazzite/commit/f5f033424281f88f0a132ec0561a5a5f002faf24))
* Correct issue with hhd being enabled on root, add HHD adjustor package. ([929cee4](https://github.com/ublue-os/bazzite/commit/929cee487d31ebc400f94485b974748465df9bea))
* Correct issues with newest version of distrobox ([bae2fae](https://github.com/ublue-os/bazzite/commit/bae2fae95b7adcaf2309f9c98637efac3f51c65d))
* **deck:** Restore all settings in restore-gnome-de-settings ujust command on deck images ([89ca085](https://github.com/ublue-os/bazzite/commit/89ca085912f0896c26577a4bce0d83a3bb31da10))
* **deck:** Restore all settings in restore-gnome-de-settings ujust command on deck images ([41483ae](https://github.com/ublue-os/bazzite/commit/41483ae865c1c3500a9d3547b21694be731f20ee))
* **deck:** Skip the first update in gaming mode on new installs ([5eede45](https://github.com/ublue-os/bazzite/commit/5eede4578872b43cebbafda5f1925cb1b5bcedd6))
* **gamescope:** add 3.13.16.9 backport ([#967](https://github.com/ublue-os/bazzite/issues/967)) ([45a8e4a](https://github.com/ublue-os/bazzite/commit/45a8e4ab6be1c02483b0684fd6cb1e3ee711a5ed))
* **gnome:** Disable joystickwake on GNOME until lock screen issue can be triaged and fixed. ([57f144f](https://github.com/ublue-os/bazzite/commit/57f144fd858cbccd9aabbece2d65ed1c6e0a78c6))
* **gnome:** Restore joystickwake functionality with caffeine extension ([057fcac](https://github.com/ublue-os/bazzite/commit/057fcac22b80453b9834e0f063f142c845c50cdc))
* **gnome:** Restore joystickwake functionality with caffeine extension ([3e0b130](https://github.com/ublue-os/bazzite/commit/3e0b13014a71af7bc36ad1f03c7a67eb0556f469))
* **gnome:** Restore joystickwake with another command to prevent unlock ([87ce229](https://github.com/ublue-os/bazzite/commit/87ce229341f80ba63244306fdc89ebdafff1f272))
* **gnome:** Restore joystickwake with another command to prevent unlock bug (https://gitlab.gnome.org/GNOME/gnome-shell/-/issues/7530) ([3472b9b](https://github.com/ublue-os/bazzite/commit/3472b9bd8d557805d219dda39d21c848a46c87df))
* Install firmware on all images, allows desktop images to be used on some handhelds (with caveats) ([a5a7b95](https://github.com/ublue-os/bazzite/commit/a5a7b952453aa84a9f277e5739e5e9f31a6e1f50))
* Install firmware on all images, allows desktop images to be used on some handhelds (with caveats) ([969202e](https://github.com/ublue-os/bazzite/commit/969202e4c48caabb42bd04ba3e46b0c7909b21b1))
* **kde:** Update gtk4 package for Ptyxis ([0109f9a](https://github.com/ublue-os/bazzite/commit/0109f9af67b89fe7535bbc01267654d58b3d88b1))
* **kde:** Update gtk4 package for Ptyxis ([d57cfb4](https://github.com/ublue-os/bazzite/commit/d57cfb47dfb7971664cb8a825e9efbb8900a8693))
* Pull in s76 scheduler fixes from fruitchewy ([b60b1e6](https://github.com/ublue-os/bazzite/commit/b60b1e621fb643c4ea59a8254ca5bc0250637367))
* **readme:** Remove Dual Boot documentation ([#969](https://github.com/ublue-os/bazzite/issues/969)) ([5bd73aa](https://github.com/ublue-os/bazzite/commit/5bd73aa4d609ad32d71aea8f4ad7df10c5527764))
* remove clevis from dracut.conf.d ([977321b](https://github.com/ublue-os/bazzite/commit/977321b5097b59bfe4ee8eb032c4a32fcbea7ecd))
* Remove unneeded file checks from hardware setup ([7133fc7](https://github.com/ublue-os/bazzite/commit/7133fc773a5c600290d6f9f492a638a23b851cb2))
* Remove unneeded secure boot message ([7a3a9c1](https://github.com/ublue-os/bazzite/commit/7a3a9c13627bba4ba2fb5cc1f9bb48817486ba97))
* Use balanced-no-pstate profile on CPUs that don't support a pstate governor. ([1dcda86](https://github.com/ublue-os/bazzite/commit/1dcda86fe048a269ee1a79eacbb18377fc27379f))
* Use balanced-no-pstate profile on CPUs that don't support a pstate governor. ([5e04d6b](https://github.com/ublue-os/bazzite/commit/5e04d6b731edf53a0419cf677a1f4a335dbf2111))
* Use Ptyxis from ublue-os/staging copr ([a1d47b0](https://github.com/ublue-os/bazzite/commit/a1d47b006c6cdeaa8edd5c4083c7da9519a47eb6))
* Use xone driver as canary for secure boot check ([6113650](https://github.com/ublue-os/bazzite/commit/61136504b97255352ce8c38cdf30ea1f09e9e534))
* Use xone driver as canary for secure boot check ([4691307](https://github.com/ublue-os/bazzite/commit/46913077868cdc16defbf151645af407b8e6b15d))

## [2.4.0](https://github.com/ublue-os/bazzite/compare/v2.3.0...v2.4.0) (2024-03-14)


### Features

* Add ujust command to install CoolerControl, an excellent GUI for controlling fan speeds on a wide array of hardware ([30eac4a](https://github.com/ublue-os/bazzite/commit/30eac4aae913e8b3eacdac9571efa102ea9aeb8f))
* **amd:** Add LACT to topgrade ([cf5e0f0](https://github.com/ublue-os/bazzite/commit/cf5e0f0f3d06bba93adc6653c3f4493a1e250d78))
* **deck:** Add HHD-UI ([a8f5feb](https://github.com/ublue-os/bazzite/commit/a8f5febcb282d2290b444ce4b014a7b8cd82957b))
* **just:** add option to add user to libvirt group ([#865](https://github.com/ublue-os/bazzite/issues/865)) ([36388bc](https://github.com/ublue-os/bazzite/commit/36388bc8ada8ae6b7b9f0c71f2388d4f2bf44a2e))
* **just:** add option to disable vfio ([#830](https://github.com/ublue-os/bazzite/issues/830)) ([c86a56a](https://github.com/ublue-os/bazzite/commit/c86a56aee547b43f3990e6b010befa41299d85b6))
* **nvidia:** Update to Nvidia 550 drivers ([95123e0](https://github.com/ublue-os/bazzite/commit/95123e0d5d855e3c25790be440192343b4cb1e90))
* Update isogenerator to latest version ([#822](https://github.com/ublue-os/bazzite/issues/822)) ([fe48ae0](https://github.com/ublue-os/bazzite/commit/fe48ae09067b44493e643a7ff905c07c4cab7098))


### Bug Fixes

* Add patch to avoid conflicts with Fedora's trim service ([ed02a65](https://github.com/ublue-os/bazzite/commit/ed02a6526c2a49baa6f142702d44d451dca96624))
* Add version gating for the fsync kernel ([07e0e33](https://github.com/ublue-os/bazzite/commit/07e0e33efa7484be0d4aea9d6f5241861671812a)), closes [#873](https://github.com/ublue-os/bazzite/issues/873)
* **ci:** issues with enrollment password ([#823](https://github.com/ublue-os/bazzite/issues/823)) ([1e26697](https://github.com/ublue-os/bazzite/commit/1e26697007dfd22903d627bec1a3006c4ff26400))
* Correct issue with user setup script execution check ([93bc12f](https://github.com/ublue-os/bazzite/commit/93bc12f3044b0e559f7edc3188d375521f238db8))
* correct orientation for GPD Win Max 2 (2022) ([#819](https://github.com/ublue-os/bazzite/issues/819)) ([0f2fb7d](https://github.com/ublue-os/bazzite/commit/0f2fb7daee3b6cfc0b342c608a8d4e920a278049))
* custom initramfs args actually get applied ([2bef48a](https://github.com/ublue-os/bazzite/commit/2bef48a149944a62e0f854f35b1dfc58b3032758))
* **deck:** Correct the default display scale on KDE images ([c86fc7d](https://github.com/ublue-os/bazzite/commit/c86fc7dbd7274c9277b4675390469a2e75f2a049))
* **deck:** Ensure the detected branch name is always lowercase ([26b1d53](https://github.com/ublue-os/bazzite/commit/26b1d533b93e09bdbd052cde6a6e9d1d00b56001))
* **deck:** Replace die with finish 0, may correct update errors some users have been experiencing ([e980853](https://github.com/ublue-os/bazzite/commit/e980853e3cce651e3476f5046784163ebd3d546e))
* **desktop:** Correct missing steamos-add-to-steam executable in KDE ([a8e77d1](https://github.com/ublue-os/bazzite/commit/a8e77d1731021fff27bf6b90a0a500783f880677))
* distrobox-export ([#803](https://github.com/ublue-os/bazzite/issues/803)) ([55cf1cb](https://github.com/ublue-os/bazzite/commit/55cf1cb3b5df85b4f1845ed7293f2da0e5842811))
* dont remove waydroid-choose-gpu ([#856](https://github.com/ublue-os/bazzite/issues/856)) ([d58a511](https://github.com/ublue-os/bazzite/commit/d58a511a0e023dcc5ab81b7bb131357f858e277b))
* **just:** Add missing description ([#834](https://github.com/ublue-os/bazzite/issues/834)) ([0805791](https://github.com/ublue-os/bazzite/commit/080579142775482ca5e3930a4b8dfd7985795717))
* **just:** Create repo file with sudo ([ba72610](https://github.com/ublue-os/bazzite/commit/ba7261081a6e333e2c2cc293ad4b58b460d9307b))
* make sure custom initramfs args are set ([6bd4949](https://github.com/ublue-os/bazzite/commit/6bd4949a87287327e443074e973c64e91bab2724))
* **nvidia:** Always reboot at the end of bazzite-hardware-setup, potentially fixes frozen screen that makes kargs appear to take an infinite amount of time. NVK soon? I want off Mr. Nvidia's wild ride. ([c267cbe](https://github.com/ublue-os/bazzite/commit/c267cbe82e7dbae8844b1fccee01d702028cb0da))
* **readme:** Bold ([7c35c11](https://github.com/ublue-os/bazzite/commit/7c35c11ebe9624309ea1cedea6efa0d8b24db74f))

