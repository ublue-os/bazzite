#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
"""Inspect an image filesystem without activating services or touching hardware."""
import argparse
import json
from pathlib import Path


def check_image(root):
    root = Path(root)
    def read(relative, binary=False):
        target = root / relative
        if not target.is_file():
            raise ValueError("Missing required image file: " + relative)
        return target.read_bytes() if binary else target.read_text()

    executable = read("usr/bin/powerstation", binary=True)
    for marker in (b"org.shadowblip.Fan.Device", b"EnumerateFans", b"CustomCurve"):
        if marker not in executable:
            raise ValueError("PowerStation lacks the required fan API marker: " + marker.decode())
    platform = read("usr/share/powerstation/platform/fan-ayaneo-3.yaml")
    if "ayaneo_ec" not in platform or "k10temp" not in platform or "Quiet:" not in platform:
        raise ValueError("The AYANEO fan platform definition is incomplete")
    activation = read("usr/share/dbus-1/system-services/org.shadowblip.PowerStation.service")
    for setting in ("Name=org.shadowblip.PowerStation", "User=root", "SystemdService=powerstation.service", "Exec=/usr/bin/powerstation"):
        if setting not in activation.splitlines():
            raise ValueError("PowerStation D-Bus activation lacks " + setting)
    service = read("usr/lib/systemd/system/powerstation.service")
    if "ExecStopPost=/usr/bin/powerstation --restore-fans-auto" not in service or "WatchdogSec=5s" not in service:
        raise ValueError("PowerStation fan recovery and supervision are missing")
    profile = read("usr/share/inputplumber/devices/50-ayaneo_3.yaml")
    if "group: led" in profile or "multicolor:chassis" in profile or "*:rgb:joystick_rings" in profile:
        raise ValueError("InputPlumber still owns the AYANEO joystick rings")
    if "product_name: AYANEO 3" not in profile or "group: gamepad" not in profile or "group: imu" not in profile:
        raise ValueError("AYANEO input/IMU configuration is missing")
    rule = read("usr/lib/udev/rules.d/70-steam-jupiter-leds.rules")
    if 'KERNEL=="*:rgb:*"' not in rule or "brightness" not in rule or "effect" not in rule:
        raise ValueError("The existing Steam RGB permission rule is missing")
    modules = root / "usr/lib/modules"
    if not list(modules.glob("*/kernel/drivers/hid/hid-ayaneo.ko*")):
        raise ValueError("The image lacks the AYANEO HID driver")
    if not list(modules.glob("*/kernel/drivers/platform/x86/ayaneo-ec.ko*")):
        raise ValueError("The image lacks the AYANEO EC driver")
    return {"static_image_checks": "passed", "device_validation": "required", "public_release_qualified": False}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default="/", help="Image root or isolated fixture root")
    arguments = parser.parse_args()
    try:
        print(json.dumps(check_image(arguments.root)))
    except (ValueError, OSError) as error:
        parser.exit(1, str(error) + "\n")
