# AYANEO 3 plugin installation readiness

This candidate adds an opt-in static image inspection tool and fixture CI. It does not declare an image ready for public distribution. Run the tool against an extracted official testing image filesystem:

```sh
python3 tests/ayaneo3-plugin-readiness.py /path/to/image/root
```

The tool reads files only. It never starts services, calls device D-Bus methods or writes sysfs. Its output always records device_validation=required and public_release_qualified=false. Byte markers and file presence are a preliminary packaging check, not proof of runtime D-Bus behavior.

As of 2026-10-14, official stable 44.20261012.1 has kernel 7.2.9-ogc3.1, InputPlumber 0.82.0-2 and PowerStation 0.8.4-1. The kernel includes OGC #123; stable still needs the PowerStation fan subsystem/CustomCurve/activation assets and removal of InputPlumber's AYANEO LED entries.

## Delivery dependencies

- [PowerStation #54](https://github.com/ShadowBlip/PowerStation/pull/54): AYANEO fan YAML, API 1 with CustomCurve, D-Bus activation, systemd watchdog and ExecStopPost recovery.
- [InputPlumber #735](https://github.com/ShadowBlip/InputPlumber/pull/735): remove only AYANEO LED entries, preserving gamepad/IMU/DMI configuration.
- [OGC #123](https://github.com/OpenGamingCollective/linux/pull/123): AYANEO HID/EC support. The generic device-generated RGB name must first be tested with Steam. An OGC-only name compatibility patch is conditional on discovery failure; it is not required by this checker.
- Existing generic 70-steam-jupiter-leds.rules permissions should cover RGB brightness/effects. No device-specific udev ownership exception is introduced.

After these sources have been reviewed and packaged, pin their actual RPM versions and an official testing image digest in the coordinated release record. Validate the testing image on the device, promote through normal Bazzite delivery, and repeat the clean-install check on official stable. Package release numbers and accepted image digests remain unset until those artifacts exist.

## Attended acceptance

Check native fan modes, saved custom curve versus Quiet, thresholds, telemetry failure, suspend, reboot and automatic recovery; Steam lighting discovery/effects/persistence on both rings; normal input/IMU and module detach/refit/recovery; plugin upgrade/removal and rollback. A clean supported stable image must require only Decky and the plugin ZIP after its normal OS update. Separate device variants require separate thermal acceptance.

There is no official image build or device acceptance in this PR. Public plugin visibility remains gated on those results.
