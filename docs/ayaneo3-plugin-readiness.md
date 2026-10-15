# AYANEO 3 plugin image readiness

The public installation target is a normal Bazzite update, Decky if absent, and the plugin ZIP. No manual kernel/package/service installation is part of that flow. The coordinated dependencies are PowerStation #54, revised InputPlumber #734 and the targeted RGB permission exception in this PR. Closed #735 and the OGC naming experiment are not dependencies; Steam lighting is deferred.

## Preliminary image checks

Run python3 tests/ayaneo3-plugin-readiness.py IMAGE_ROOT. It reads files only and never activates services or writes hardware. It checks fan API/activation/recovery assets, the AYANEO kernel modules and input mappings, managed lighting profile/API/authorization/state-directory assets, and the AYANEO USB-matched ownership exception before the unchanged generic RGB rule. Its result always retains device_validation=required and public_release_qualified=false. Byte markers cannot establish runtime correctness.

The managed source uses persistent identity ayaneo-3-joystick-rings and requires native firmware effects. A missing saved setting leaves lighting untouched until Apply. Native monocolor/breathe/rainbow modes supply Solid/Breathing/Rainbow; speed is fixed. InputPlumber owns writes and settings. Decky has no direct sysfs or settings-file writer. Other LEDs retain their existing writable rule and controller-output paths.

## Packaging and acceptance

Bazzite 44.20261012.1 contains kernel interfaces but ships InputPlumber 0.82.0-2 and PowerStation 0.8.4-1 without the complete candidate features. Do not claim that image is qualified. Record actual official testing/stable package versions and image digest after maintainer delivery; none is guessed in advance.

PowerStation #54 at cb75669e488784d095229c0681b332809b1698c2 now proposes API v2 and removes the preset/custom-curve contract used by the private dev.3 fan client. This lighting change preserves that client's API v1 behavior. A separate fan-client, persistence and readiness-check migration to the accepted upstream contract is required before public delivery; these preliminary checks intentionally reject incompatible API v2 assets. The physical lighting evidence uses the previously validated private API v1 fan runtime and does not qualify API v2.

Test the private candidate with backups, then an official testing image, and finally a clean supported stable installation without private namespaces, replacement packages or legacy fan prerequisites. Verify every native effect/transition, colours/brightness/Off, five-minute Breathing/Rainbow observations on both rings, persistence, restart, reconnect, suspend/reboot, denied/failed/uncertain requests, input/motion/rumble/module recovery, plugin upgrade/removal and rollback. Existing whole-plugin thermal and recovery gates remain required.

Target both 8840U and HX 370. Physical acceptance uses the available 8840U; the user explicitly accepts assumed HX 370 compatibility from the shared interfaces. Documentation must distinguish that assumption from separate HX 370 physical testing.

Keep the repository private until all applicable release gates pass. Only then publish the qualified ZIP, corresponding GPL source and checksums. Static checker success, an open/merged PR, or a private patched runtime cannot qualify stock installation.
