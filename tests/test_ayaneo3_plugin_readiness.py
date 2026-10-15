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
            "usr/bin/powerstation": (
                "org.shadowblip.Fan.Device org.shadowblip.Fan.Sensor EnumerateSensors "
                "LoadProfileJson CurrentProfileName PercentValid --record-fan-startup untrusted fan startup attempt"
            ),
            "usr/bin/inputplumber": "org.shadowblip.Input.Source.LEDDevice SetConfig unconfigured",
            "usr/lib/systemd/system/inputplumber.service": "StateDirectory=inputplumber\nStateDirectoryMode=0700\n",
            "usr/share/polkit-1/actions/org.shadowblip.InputPlumber.policy": '<action id="org.shadowblip.Input.Source.LEDDevice.SetConfig"/>',
            "usr/share/powerstation/platform/fan-ayaneo-3.yaml": "ayaneo_ec k10temp ayaneo-3 system cpu",
            "usr/powerstation/platform/fan_curves/quiet.yaml": "ayaneo-3/system software_curve ayaneo-3/system/cpu",
            "usr/share/dbus-1/system.d/org.shadowblip.PowerStation.conf": '<policy user="root"><allow own="org.shadowblip.PowerStation"/></policy>',
            "usr/share/dbus-1/system-services/org.shadowblip.PowerStation.service": (
                "Name=org.shadowblip.PowerStation\nUser=root\n"
                "SystemdService=powerstation.service\nExec=/usr/bin/powerstation\n"
            ),
            "usr/lib/systemd/system/powerstation.service": (
                "ExecStopPost=/usr/bin/powerstation --restore-fans-auto\nWatchdogSec=5s\n"
                "ExecStartPre=/usr/bin/powerstation --record-fan-startup\n"
                "RuntimeDirectory=powerstation-fan-startup\nRuntimeDirectoryMode=0700\nRuntimeDirectoryPreserve=yes\n"
            ),
            "usr/share/inputplumber/devices/50-ayaneo_3.yaml": (
                "product_name: AYANEO 3\ngroup: gamepad\ngroup: imu\ngroup: led\n"
                "*:rgb:joystick_rings\npersistent_id: ayaneo-3-joystick-rings\nhardware_cycle_only: true\n"
            ),
            "usr/lib/udev/rules.d/70-steam-jupiter-leds.rules": (
                Path(__file__).parents[1] / "system_files/deck/shared/usr/lib/udev/rules.d/70-steam-jupiter-leds.rules"
            ).read_text(),
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
        with self.assertRaisesRegex(ValueError, "fan API marker"):
            readiness.check_image(self.root)

    def test_missing_startup_safeguard_is_rejected(self):
        path = self.root / "usr/lib/systemd/system/powerstation.service"
        path.write_text(path.read_text().replace("RuntimeDirectoryPreserve=yes", "RuntimeDirectoryPreserve=restart"))
        with self.assertRaisesRegex(ValueError, "startup safeguard"):
            readiness.check_image(self.root)

    def test_startup_helper_without_precreation_fence_is_rejected(self):
        path = self.root / "usr/bin/powerstation"
        path.write_text(path.read_text().replace("untrusted fan startup attempt", ""))
        with self.assertRaisesRegex(ValueError, "fan API marker"):
            readiness.check_image(self.root)

    def test_missing_quiet_profile_or_policy_is_rejected(self):
        (self.root / "usr/powerstation/platform/fan_curves/quiet.yaml").unlink()
        with self.assertRaisesRegex(ValueError, "Missing required image file"):
            readiness.check_image(self.root)

    def test_automatic_first_use_change_is_rejected(self):
        with (self.root / "usr/share/inputplumber/devices/50-ayaneo_3.yaml").open("a") as stream:
            stream.write("initial_config: {}\n")
        with self.assertRaisesRegex(ValueError, "First-use"):
            readiness.check_image(self.root)

    def test_missing_managed_profile_or_api_is_rejected(self):
        self.write("usr/share/inputplumber/devices/50-ayaneo_3.yaml", "product_name: AYANEO 3\ngroup: gamepad\ngroup: imu\n")
        with self.assertRaisesRegex(ValueError, "managed lighting profile"):
            readiness.check_image(self.root)

    def test_old_inputplumber_is_rejected(self):
        self.write("usr/bin/inputplumber", "org.shadowblip.Input.Source.LEDDevice")
        with self.assertRaisesRegex(ValueError, "managed lighting support"):
            readiness.check_image(self.root)

    def test_ownership_exception_cannot_follow_the_generic_rule(self):
        path = self.root / "usr/lib/udev/rules.d/70-steam-jupiter-leds.rules"
        rules = path.read_text().splitlines()
        managed = next(line for line in rules if 'KERNEL=="*:rgb:joystick_rings"' in line)
        rules.remove(managed)
        rules.insert(-1, managed)
        path.write_text("\n".join(rules))
        with self.assertRaisesRegex(ValueError, "bypass"):
            readiness.check_image(self.root)

    def test_permission_exception_must_match_ayaneo_usb_identity(self):
        path = self.root / "usr/lib/udev/rules.d/70-steam-jupiter-leds.rules"
        path.write_text(path.read_text().replace('ATTRS{idVendor}=="1c4f", ', ""))
        with self.assertRaisesRegex(ValueError, "ownership rule"):
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
