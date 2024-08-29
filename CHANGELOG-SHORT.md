# Changelog

## 3.7.0 (2024-08-28)


### Features

* **rechunker:** Images are now 1GB smaller and updates are up to 85% smaller thanks to the addition of [rechunker](https://github.com/hhd-dev/rechunk).
* Add Discourse forums shortcut ([#1403](https://github.com/ublue-os/bazzite/issues/1403)) ([9b855ea](https://github.com/ublue-os/bazzite/commit/9b855ea499265497af9cfc915d4869687cb7b64b))
* Add gamescope-legacy binary for older GPUs, such as Polaris. ([b98f222](https://github.com/ublue-os/bazzite/commit/b98f22216c19b7f6e6aa0a9a67a4fb8400de6121))
* Add Minisforum V3 as an HHD supported device ([379b7e7](https://github.com/ublue-os/bazzite/commit/379b7e76e3036428097660485a8e22d9de08cbc8))
* Add scx-sheds for optional schedulers, selectable via HHD ([00931b2](https://github.com/ublue-os/bazzite/commit/00931b256b8c798abe798265800f2c6498380a26))
* Add umu-launcher ([1b1ea4a](https://github.com/ublue-os/bazzite/commit/1b1ea4a4fdcff924fc1d5ada4be4e3f0ef685f05))
* allow external scripts to specify nested-desktop/waydroid dimensions ([#1508](https://github.com/ublue-os/bazzite/issues/1508)) ([1d8a8b3](https://github.com/ublue-os/bazzite/commit/1d8a8b31cd52675a39e434b93ddd22f87a725c9a))
* **bazzite-cli:** add tealdeer as tldr ([#1460](https://github.com/ublue-os/bazzite/issues/1460)) ([1161cbb](https://github.com/ublue-os/bazzite/commit/1161cbb12b06cda05c90898e9f27748e1288f3be))
* **cli:** Alias `xdg-open` to `open` ([#1494](https://github.com/ublue-os/bazzite/issues/1494)) ([fa8e619](https://github.com/ublue-os/bazzite/commit/fa8e6198da57a36b9e1038434c5f342fb3eb8ebb))
* **deck:** Improve default CPU frequency behavior on Galileo & Jupiter ([7cd4ea1](https://github.com/ublue-os/bazzite/commit/7cd4ea1e80aaaafc7c1d21a261aaf37c202c495f))
* Disable PPD when enabling HHD ([135513e](https://github.com/ublue-os/bazzite/commit/135513e8270b67c07c88e618df62104ab05e435e))
* **docs:** Replace mdbook with mkdocs workflow ([#1548](https://github.com/ublue-os/bazzite/issues/1548)) ([0e18978](https://github.com/ublue-os/bazzite/commit/0e18978fe1bb58e54b1ff882ee563a18b6fdfe9c))
* Eliminate Steam Download Speed Fix  Game Mode Startup Video ujust commands, these are now handled by the bazzite-steam wrapper. ([373a73d](https://github.com/ublue-os/bazzite/commit/373a73da8232589cb7cf57d4e0fd5764d67d5142))
* Enable faster QAM in HHD ([9b345e0](https://github.com/ublue-os/bazzite/commit/9b345e05a81af8b5a5df517758e2aea8fc7dd4ce))
* **gnome:** Add Tiling Shell extension ([aa8ae93](https://github.com/ublue-os/bazzite/commit/aa8ae933b4084633fa20441158f2efd51443bd9e))
* **gnome:** increase check-alive-timeout ([733d73a](https://github.com/ublue-os/bazzite/commit/733d73a6823ba25ed7cf0e5387a870408c1027cb))
* **just:** add decky prerelease option ([#1425](https://github.com/ublue-os/bazzite/issues/1425)) ([d901c49](https://github.com/ublue-os/bazzite/commit/d901c49e03b204078b75133eb70470ff621ce318))
* **just:** add ujust to reset steam ([#1411](https://github.com/ublue-os/bazzite/issues/1411)) ([b3a0658](https://github.com/ublue-os/bazzite/commit/b3a06586739938b58d1e1ce2637b1f3e97610e0a))
* **kde:** add fcitx5-hangul for Korean input ([#1399](https://github.com/ublue-os/bazzite/issues/1399)) ([858f6bf](https://github.com/ublue-os/bazzite/commit/858f6bfc826ae4ff83f92eb2a9432b44a202c6e2))
* **kde:** Add krdp ([e5feab3](https://github.com/ublue-os/bazzite/commit/e5feab396008b467d60d0161f823a4dbb2247cd5))
* **kernel:** Enable full preemption by default, reduces latency in certain workloads. ([6fcd085](https://github.com/ublue-os/bazzite/commit/6fcd085db4cf5d2a42440439588e703ce82aea1e))
* **nvidia:** add script check for legacy nvidia hardware ([#1428](https://github.com/ublue-os/bazzite/issues/1428)) ([d88b9bc](https://github.com/ublue-os/bazzite/commit/d88b9bcbeda114f043d994fc51997c622c7fe0e3))
* Prepare mdBook workflow for documentation ([#1441](https://github.com/ublue-os/bazzite/issues/1441)) ([181497b](https://github.com/ublue-os/bazzite/commit/181497bc1741418ad580f5f464f5e6916d22d4f4))
* **rechunk:** enable previous layer checks to improve successive downloads and version bump ([#1443](https://github.com/ublue-os/bazzite/issues/1443)) ([11b1eba](https://github.com/ublue-os/bazzite/commit/11b1ebaa8336196f12dd6f2bd503def49ff41e7d))
* **rechunk:** Introduce image rechunking to lower update sizes ([#1439](https://github.com/ublue-os/bazzite/issues/1439)) ([54fad61](https://github.com/ublue-os/bazzite/commit/54fad6162643d3f9d5e4cf04e9118534c82e59c2))
* standardize versioning across OSTree and os-release ([#1442](https://github.com/ublue-os/bazzite/issues/1442)) ([677891a](https://github.com/ublue-os/bazzite/commit/677891a8bb2c1b0b0d2d3ad1212530cb449547f7))
* Switch to scx-scheds package for additional sched_ext schedulers ([ccd7b52](https://github.com/ublue-os/bazzite/commit/ccd7b52221e1a0971aeb9ace17fdc262108d8865))
* **ujust:** add post-gamescope-logs ujust ([#1533](https://github.com/ublue-os/bazzite/issues/1533)) ([0bba7d3](https://github.com/ublue-os/bazzite/commit/0bba7d316b8bd7525bf755dbe3c20ad0e98cfcba))


### Bug Fixes

* Add fix for docking and a crash for certain inputs to Gamescope ([b2f0b55](https://github.com/ublue-os/bazzite/commit/b2f0b558ba9a8bc2e55374d5957ecdaed4dcdd19))
* Add support for AYANEO NEXT series in Anaconda ([b3e9de3](https://github.com/ublue-os/bazzite/commit/b3e9de3d8c81ca9408c59502b88500f7288ebc8c))
* Allow more time for SD card mounting, required by some hardware. ([810b84e](https://github.com/ublue-os/bazzite/commit/810b84e706bd6267085adc224066d8b679f58722))
* **Ally X:** prefer HDMI audio when docked ([#1467](https://github.com/ublue-os/bazzite/issues/1467)) ([398ba21](https://github.com/ublue-os/bazzite/commit/398ba21624ac17e4ef0d6313b73aecaa9168c3ff))
* **ally:** Fix VRR stutter ([8c6379d](https://github.com/ublue-os/bazzite/commit/8c6379dccf2a98e6b364f152405561cd7c6d85a0))
* Always require fuse for AppImage support ([0830b5a](https://github.com/ublue-os/bazzite/commit/0830b5ae68120919e1746382f2d842c5156516fe))
* Correct control+1/control+2 input in gamescope (Thanks [@hhd-dev](https://github.com/hhd-dev)) ([6ef9d14](https://github.com/ublue-os/bazzite/commit/6ef9d14a56d33bee0e9cc39631f098c7da8f7a10))
* Correct default TimeoutStopSec of Decky Loader ([7dec5f9](https://github.com/ublue-os/bazzite/commit/7dec5f93e42953d4665550419ea145c3e5967a0c))
* Correct EFI path issue with fwupd ([ac457f0](https://github.com/ublue-os/bazzite/commit/ac457f07ee458d589261db05f608bd4089ef8cb4))
* Correct missing directory error when running grub2-switch-to-blscfg ([e93fa00](https://github.com/ublue-os/bazzite/commit/e93fa00833104a1a558cca21bc05be2f4bcfd65d))
* **deck:** Ensure the branch is lowercase and trimmed in os-branch-select ([c8bc726](https://github.com/ublue-os/bazzite/commit/c8bc7266914bedb1193060d1122ff52115a3c415))
* **deck:** Remove branch selector mark file on reboot ([ea28269](https://github.com/ublue-os/bazzite/commit/ea2826946280442e93bc06ce0e22b152af936991))
* **deck:** Temporarily drop mura package due to framerate pacing issue introduced by it's application ([78c10a2](https://github.com/ublue-os/bazzite/commit/78c10a2ab9a7ede3833ccc42da2201dbc2b8b885))
* **deck:** Use bootstrap copy of Steam when starting Steam for the first time on the desktop ([0680e56](https://github.com/ublue-os/bazzite/commit/0680e56083475e38d51b60e93c4f1296f89ffd68))
* Disable pipewire camera handling temporarily ([8c1356c](https://github.com/ublue-os/bazzite/commit/8c1356c322463fd27cc7c3966164f23aa08cf581))
* Disable Waydroid updater in topgrade ([ee163e5](https://github.com/ublue-os/bazzite/commit/ee163e5737e23f174d54a837fcb2787b98a15a0b))
* Drop no longer needed OBS_USE_EGL environment variable ([d658a7a](https://github.com/ublue-os/bazzite/commit/d658a7a7c4eb4185e6afbba0afbfff04863371e0))
* **just:** add libvirt package to setup-virtualization ([#1549](https://github.com/ublue-os/bazzite/issues/1549)) ([1cb8555](https://github.com/ublue-os/bazzite/commit/1cb85551d509213614ce21c8af515eb1249d0f03))
* **just:** fix syntax for benchmark ujust ([#1451](https://github.com/ublue-os/bazzite/issues/1451)) ([ecfc56d](https://github.com/ublue-os/bazzite/commit/ecfc56d1fa6b89aa5eb9bbcbe0b8ea2ae7dfab38))
* **kde:** Correct size of ptyxis window ([c27c83e](https://github.com/ublue-os/bazzite/commit/c27c83ea5f0637ca6c47a39207fafe4972b191e9))
* **LGO:** reduce input source priority and add description ([#1452](https://github.com/ublue-os/bazzite/issues/1452)) ([371ff84](https://github.com/ublue-os/bazzite/commit/371ff845a17fd5ed55c5ca92bbc5e4663e29645e))
* Limit BTRFS deduplication to one core. ([bd85e7d](https://github.com/ublue-os/bazzite/commit/bd85e7d33001a8783b8b97984ced138819c52784))
* **nvidia:** Add fix for ALVR (Thanks Crunchn) ([52d6189](https://github.com/ublue-os/bazzite/commit/52d6189e7541caa59bfc90f0119acda06232bc6a))
* **polaris:** Add 720p patch ([9ba34b0](https://github.com/ublue-os/bazzite/commit/9ba34b0fa0dc488527d3801862bb045d4a354af9))
* Prevent bluetooth preventing suspension ([#1446](https://github.com/ublue-os/bazzite/issues/1446)) ([9f2550f](https://github.com/ublue-os/bazzite/commit/9f2550f3982664da6c22e2e4cf32da4d937ca5ff))
* Prevent restoring audio levels on hardware with custom DSPs ([20eb99e](https://github.com/ublue-os/bazzite/commit/20eb99edaaec143e149befb523380a66ba5bd83f))
* **rechunk:** use correct previous ref ([#1509](https://github.com/ublue-os/bazzite/issues/1509)) ([e9a8b79](https://github.com/ublue-os/bazzite/commit/e9a8b793c0cef5c6c66511946c55e4980f7e4322))
* Remove files now handled by steamdeck-dsp ([82f66e8](https://github.com/ublue-os/bazzite/commit/82f66e8da9633acd52bd5ef9529f11f2932bc712))
* Remove pip installed packages and use newly made rpm packages, fixes python errors when layering some packages. ([5ec9e55](https://github.com/ublue-os/bazzite/commit/5ec9e555f8241214333cc28ec697033ae56dc52f))
* Use new Steam bootstrap file from Nobara (Thanks @GloriousEggroll) ([dccb5d2](https://github.com/ublue-os/bazzite/commit/dccb5d2d059416fbea02e4fc0cf48a2ac75bcfb2))


### Miscellaneous Chores

* release 3.7.0 ([3acbbd0](https://github.com/ublue-os/bazzite/commit/3acbbd0c13cb688e53abd2dc0844f8c87ce0b570))


### Miscellaneous Chores

* release 3.7.0 ([3acbbd0](https://github.com/ublue-os/bazzite/commit/3acbbd0c13cb688e53abd2dc0844f8c87ce0b570))

## [3.6.0](https://github.com/ublue-os/bazzite/compare/v3.5.1...v3.6.0) (2024-07-17)


### Features

* Add adaptive brightness script for handhelds other than the deck. Default disabled (Thanks [@corando98](https://github.com/corando98)) ([996d161](https://github.com/ublue-os/bazzite/commit/996d161bfb27432e1bd396236c63e932b5d8e981))
* Add offline documentation (markdown version) ([#1364](https://github.com/ublue-os/bazzite/issues/1364)) ([9889286](https://github.com/ublue-os/bazzite/commit/988928610a37694a5223f7d09499d737af3790c5))
* Add scx_lavd as an optional scheduler ([00931b2](https://github.com/ublue-os/bazzite/commit/00931b256b8c798abe798265800f2c6498380a26))
* **ally-x:** Add Texas Instruments Firmware file from Windows driver. ([ba063de](https://github.com/ublue-os/bazzite/commit/ba063deecf4d55498bb15ed3f94cb42322017b7a))
* **ally:** Add audio improvements from Aru's repo ([245305d](https://github.com/ublue-os/bazzite/commit/245305def4f3a883b762d1168b9ac13b8dea2972))
* **deck:** Use Deck logo in logo menu by default on Valve hardware ([df41081](https://github.com/ublue-os/bazzite/commit/df41081f93fb00459c9eac42d84d605cca622b3e))
* Disable PPD when enabling HHD ([135513e](https://github.com/ublue-os/bazzite/commit/135513e8270b67c07c88e618df62104ab05e435e))
* Install `wqy-zenhei-fonts` for GoldSrc Engine to display Chinese fonts. ([#1367](https://github.com/ublue-os/bazzite/issues/1367)) ([af8d26c](https://github.com/ublue-os/bazzite/commit/af8d26c2bb8af02e9032891f959e2f5aba96a8c1))
* **legion:** Add DSP ([5331671](https://github.com/ublue-os/bazzite/commit/5331671e615e87f701d4f3bf1bfae38cc41aa357))
* **legion:** Add Optional ICC Color Profile ([c87964e](https://github.com/ublue-os/bazzite/commit/c87964e7f4f4cefb8e58a90fbd2392bee2a52438))
* Reduce CPU & IO priority of updates from game mode ([9026ded](https://github.com/ublue-os/bazzite/commit/9026ded109cd2046872d7bc93932570342e6f38d))
* **ujust:** Add install-resolve ([#1336](https://github.com/ublue-os/bazzite/issues/1336)) ([60e76d0](https://github.com/ublue-os/bazzite/commit/60e76d04f94f3794618215a65928f19ff1e1686a))


### Bug Fixes

* Add patch for color issues in the latest Mesa. ([69be913](https://github.com/ublue-os/bazzite/commit/69be913abe8def28eac6b6ed20bf5cbadf4627fb))
* **ally-x:** Disable amd_pmf driver for HHD TDP controls to work ([057aaa4](https://github.com/ublue-os/bazzite/commit/057aaa418b267749b76a6ba98459d7c2cf070146))
* **ally:** Correct issue with audio channels in DSP ([a93037d](https://github.com/ublue-os/bazzite/commit/a93037d5161ed5e93e24c406381a54bde02881f5))
* **Containerfile:** Correct regex when installing fsync kernel ([b24e44b](https://github.com/ublue-os/bazzite/commit/b24e44be7e5351e48472f5e47ad81d7ac2f79126))
* **Containerfile:** Remove duplicate overrides for kernel modules ([9cc2c03](https://github.com/ublue-os/bazzite/commit/9cc2c03af4e57177d7edd44b8f3bfc4a993c61d2))
* **deck:** Add patch to fix some invalid refresh rates (Thanks [@matte](https://github.com/matte)_schwartz) ([3ca09c5](https://github.com/ublue-os/bazzite/commit/3ca09c587dd596d0a9b9be7d60d33a9d82ff5fbb))
* **deck:** Set volume of original output to 100% to fix low volume under DSP ([fe16286](https://github.com/ublue-os/bazzite/commit/fe162863b07bdf7bf29c48278ef2581d65a7f3ad))
* **deck:** Use older pattern matching for priv-write ([96431f3](https://github.com/ublue-os/bazzite/commit/96431f32711fed41a1f1c3361cd7855b15e1f5aa))
* **GPD:** add udev rules for disabling GPD fingerprint sensors ([#1362](https://github.com/ublue-os/bazzite/issues/1362)) ([c0e82bf](https://github.com/ublue-os/bazzite/commit/c0e82bf46d02e255063158139a6f10c7fff3b222))
* Make bazzite-tdpfix never run on deck hardware ([b2aa3b4](https://github.com/ublue-os/bazzite/commit/b2aa3b45baba2ce447a41e3c75fbd3ba17a6d4ee))
* **nvidia:** Disable GSP on -nvidia builds until performance issue is addressed upstream ([a94df08](https://github.com/ublue-os/bazzite/commit/a94df08908b374757e035a4a53996e8984225a50))
* Restore libei in gamescope ([7b57725](https://github.com/ublue-os/bazzite/commit/7b57725d3bf8d6c04027e537ec2338daeb40f9ce))
* **ujust:** Fix faulty ujust install-resolve ([#1342](https://github.com/ublue-os/bazzite/issues/1342)) ([14ee75d](https://github.com/ublue-os/bazzite/commit/14ee75d7c8e8f3116a4ab3388c4f65607997027c))
* **ujust:** set install as the default action for the setup-decky ujust ([#1371](https://github.com/ublue-os/bazzite/issues/1371)) ([825c70f](https://github.com/ublue-os/bazzite/commit/825c70ff38ff7a77655a63c5f047ca352c48d2a8))

