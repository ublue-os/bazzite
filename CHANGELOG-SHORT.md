# Changelog

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

## [3.5.1](https://github.com/ublue-os/bazzite/compare/v3.5.0...v3.5.1) (2024-07-03)


### Bug Fixes

* **mesa:** Add missing patches from upstream ([c50dc8e](https://github.com/ublue-os/bazzite/commit/c50dc8ee9eb570ad15e4cf59f0b06125f2e75a15))

