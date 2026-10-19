#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Inspect an image filesystem without activating services or touching hardware."""
import argparse
import json
from pathlib import Path


def read(root, relative, binary=False):
    target = root / relative
    if not target.is_file():
        raise ValueError("Missing required image file: " + relative)
    return target.read_bytes() if binary else target.read_text()


def check_powerstation(root):
    executable = read(root, "usr/bin/powerstation", binary=True)
    for marker in (
        b"org.shadowblip.Fan.Device", b"org.shadowblip.Fan.Sensor", b"EnumerateSensors",
        b"LoadProfileJson", b"CurrentProfileName", b"PercentValid", b"profile descriptor must be a readable regular file",
    ):
        if marker not in executable:
            raise ValueError("PowerStation lacks the required fan API marker: " + marker.decode())
    platform = read(root, "usr/share/powerstation/platform/fan-ayaneo-3.yaml")
    if "ayaneo_ec" not in platform or "k10temp" not in platform or "ayaneo-3" not in platform or "system" not in platform or "cpu" not in platform:
        raise ValueError("The AYANEO fan platform definition is incomplete")
    quiet = read(root, "usr/powerstation/platform/fan_curves/quiet.yaml")
    if "ayaneo-3/system" not in quiet or "software_curve" not in quiet or "ayaneo-3/system/cpu" not in quiet:
        raise ValueError("The packaged Quiet fan profile is missing or incomplete")
    check_powerstation_service(root)


def check_powerstation_service(root):
    activation = read(root, "usr/share/dbus-1/system-services/org.shadowblip.PowerStation.service")
    for setting in ("Name=org.shadowblip.PowerStation", "User=root", "SystemdService=powerstation.service", "Exec=/usr/bin/powerstation"):
        if setting not in activation.splitlines():
            raise ValueError("PowerStation D-Bus activation lacks " + setting)
    service = read(root, "usr/lib/systemd/system/powerstation.service")
    if "ExecStopPost=/usr/bin/powerstation --restore-fans-auto" not in service or "WatchdogSec=5s" not in service:
        raise ValueError("PowerStation fan recovery and supervision are missing")
    policy = read(root, "usr/share/dbus-1/system.d/org.shadowblip.PowerStation.conf")
    if 'user="root"' not in policy or 'own="org.shadowblip.PowerStation"' not in policy:
        raise ValueError("PowerStation D-Bus ownership policy is missing")


def check_managed_lighting(root):
    profile = read(root, "usr/share/inputplumber/devices/50-ayaneo_3.yaml")
    for marker in ("group: led", "*:rgb:joystick_rings", "settings_id: ayaneo-3-joystick-rings", "hardware_cycle_only: true"):
        if marker not in profile:
            raise ValueError("InputPlumber managed lighting profile is incomplete")
    if "initial_config:" in profile:
        raise ValueError("First-use lighting must remain unchanged until the user selects an effect")
    lighting = read(root, "usr/bin/inputplumber", binary=True)
    for marker in (b"org.shadowblip.Input.Source.LEDDevice", b"SetConfig", b"unconfigured"):
        if marker not in lighting:
            raise ValueError("InputPlumber lacks managed lighting support")
    policy = read(root, "usr/share/polkit-1/actions/org.shadowblip.InputPlumber.policy")
    if 'id="org.shadowblip.Input.Source.LEDDevice.SetConfig"' not in policy:
        raise ValueError("InputPlumber lighting authorization is missing")
    lighting_service = read(root, "usr/lib/systemd/system/inputplumber.service")
    if "StateDirectory=inputplumber" not in lighting_service or "StateDirectoryMode=0700" not in lighting_service:
        raise ValueError("InputPlumber managed state directory is missing")
    if "product_name: AYANEO 3" not in profile or "group: gamepad" not in profile or "group: imu" not in profile:
        raise ValueError("AYANEO input/IMU configuration is missing")


def check_rgb_permissions(root):
    rule = read(root, "usr/lib/udev/rules.d/70-steam-jupiter-leds.rules")
    if 'KERNEL=="*:rgb:*"' not in rule or "brightness" not in rule or "effect" not in rule:
        raise ValueError("The existing Steam RGB permission rule is missing")
    managed_rule = next((line for line in rule.splitlines() if 'KERNEL=="*:rgb:joystick_rings"' in line), "")
    for marker in ('ACTION=="add|change"', 'SUBSYSTEM=="leds"', 'ATTRS{idVendor}=="1c4f"', 'ATTRS{idProduct}=="0002"',
                   'chmod 0644', '/brightness', '/multi_intensity', '/effect', '/trigger', 'GOTO="bazzite_rgb_permissions_end"'):
        if marker not in managed_rule:
            raise ValueError("AYANEO managed lighting ownership rule is incomplete")
    generic_rule = next(line for line in rule.splitlines() if 'KERNEL=="*:rgb:*"' in line)
    if rule.index(managed_rule) >= rule.index(generic_rule) or rule.index('LABEL="bazzite_rgb_permissions_end"') <= rule.index(generic_rule):
        raise ValueError("AYANEO ownership must bypass the generic writable RGB rule")


def check_kernel_modules(root):
    modules = root / "usr/lib/modules"
    if not list(modules.glob("*/kernel/drivers/hid/hid-ayaneo.ko*")):
        raise ValueError("The image lacks the AYANEO HID driver")
    if not list(modules.glob("*/kernel/drivers/platform/x86/ayaneo-ec.ko*")):
        raise ValueError("The image lacks the AYANEO EC driver")


def check_image(root):
    root = Path(root)
    check_powerstation(root)
    check_managed_lighting(root)
    check_rgb_permissions(root)
    check_kernel_modules(root)
    return {"static_image_checks": "passed", "device_validation": "required", "public_release_qualified": False}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default="/", help="Image root or isolated fixture root")
    arguments = parser.parse_args()
    try:
        print(json.dumps(check_image(arguments.root)))
    except (ValueError, OSError) as error:
        parser.exit(1, str(error) + "\n")
