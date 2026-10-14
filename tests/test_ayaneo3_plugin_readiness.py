# SPDX-License-Identifier: Apache-2.0
import importlib.util
from pathlib import Path
import tempfile
import unittest

spec = importlib.util.spec_from_file_location("readiness", Path(__file__).with_name("ayaneo3-plugin-readiness.py"))
readiness = importlib.util.module_from_spec(spec)
spec.loader.exec_module(readiness)


class ReadinessTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        files = {
            "usr/bin/powerstation": "org.shadowblip.Fan.Device EnumerateFans CustomCurve",
            "usr/share/powerstation/platform/fan-ayaneo-3.yaml": "ayaneo_ec k10temp Quiet:",
            "usr/share/dbus-1/system-services/org.shadowblip.PowerStation.service": "Name=org.shadowblip.PowerStation\nUser=root\nSystemdService=powerstation.service\nExec=/usr/bin/powerstation\n",
            "usr/lib/systemd/system/powerstation.service": "ExecStopPost=/usr/bin/powerstation --restore-fans-auto\nWatchdogSec=5s\n",
            "usr/share/inputplumber/devices/50-ayaneo_3.yaml": "product_name: AYANEO 3\ngroup: gamepad\ngroup: imu\n",
            "usr/lib/udev/rules.d/70-steam-jupiter-leds.rules": 'KERNEL=="*:rgb:*" brightness effect',
            "usr/lib/modules/fixture/kernel/drivers/hid/hid-ayaneo.ko": "",
            "usr/lib/modules/fixture/kernel/drivers/platform/x86/ayaneo-ec.ko": "",
        }
        for relative, text in files.items():
            self.write(relative, text)

    def write(self, relative, text):
        target = self.root / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text)

    def test_ready_files_never_claim_device_acceptance(self):
        report = readiness.check_image(self.root)
        self.assertEqual(report["static_image_checks"], "passed")
        self.assertFalse(report["public_release_qualified"])

    def test_old_powerstation_is_rejected(self):
        self.write("usr/bin/powerstation", "org.shadowblip.Fan.Device EnumerateFans")
        with self.assertRaisesRegex(ValueError, "CustomCurve"):
            readiness.check_image(self.root)

    def test_competing_lighting_ownership_is_rejected(self):
        with (self.root / "usr/share/inputplumber/devices/50-ayaneo_3.yaml").open("a") as stream:
            stream.write("group: led\n")
        with self.assertRaisesRegex(ValueError, "still owns"):
            readiness.check_image(self.root)

    def test_placeholder_activation_service_is_rejected(self):
        self.write("usr/share/dbus-1/system-services/org.shadowblip.PowerStation.service", "Name=com.github.guelfey.Demo")
        with self.assertRaisesRegex(ValueError, "activation"):
            readiness.check_image(self.root)

    def test_missing_module_driver_is_rejected(self):
        (self.root / "usr/lib/modules/fixture/kernel/drivers/hid/hid-ayaneo.ko").unlink()
        with self.assertRaisesRegex(ValueError, "HID driver"):
            readiness.check_image(self.root)

    def test_missing_recovery_hook_is_rejected(self):
        self.write("usr/lib/systemd/system/powerstation.service", "ExecStart=/usr/bin/powerstation")
        with self.assertRaisesRegex(ValueError, "recovery"):
            readiness.check_image(self.root)


if __name__ == "__main__":
    unittest.main()
