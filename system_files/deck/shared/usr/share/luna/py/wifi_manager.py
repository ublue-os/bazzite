"""
WiFi manager for Luna first-boot setup.
Uses NetworkManager (nmcli) for network operations.
"""

import subprocess
import re
from threading import Thread

from PySide6.QtCore import QObject, Signal, Slot, Property


class WiFiManager(QObject):
    networksChanged = Signal()
    connectionStatusChanged = Signal()
    connectResult = Signal(bool, str)  # success, message

    def __init__(self, parent=None):
        super().__init__(parent)
        self._networks = []
        self._connected = False
        self._scanning = False
        self._check_connection()

    @Property("QVariantList", notify=networksChanged)
    def networks(self):
        return self._networks

    @Property(bool, notify=connectionStatusChanged)
    def connected(self):
        return self._connected

    def _check_connection(self):
        try:
            result = subprocess.run(
                ["nmcli", "-t", "-f", "TYPE,STATE", "device"],
                capture_output=True, text=True, timeout=5
            )
            for line in result.stdout.strip().split("\n"):
                if "wifi" in line and "connected" in line and "disconnected" not in line:
                    self._connected = True
                    self.connectionStatusChanged.emit()
                    return
            # Also check for wired connection
            for line in result.stdout.strip().split("\n"):
                if "ethernet" in line and "connected" in line and "disconnected" not in line:
                    self._connected = True
                    self.connectionStatusChanged.emit()
                    return
        except (subprocess.SubprocessError, FileNotFoundError):
            pass
        self._connected = False
        self.connectionStatusChanged.emit()

    @Slot()
    def scan(self):
        if self._scanning:
            return
        self._scanning = True
        thread = Thread(target=self._do_scan, daemon=True)
        thread.start()

    def _do_scan(self):
        networks = []
        try:
            subprocess.run(
                ["nmcli", "device", "wifi", "rescan"],
                capture_output=True, timeout=10
            )
            result = subprocess.run(
                ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list"],
                capture_output=True, text=True, timeout=10
            )
            seen = set()
            for line in result.stdout.strip().split("\n"):
                parts = line.split(":")
                if len(parts) >= 3:
                    ssid = parts[0].strip()
                    if not ssid or ssid in seen:
                        continue
                    seen.add(ssid)
                    signal = int(parts[1]) if parts[1].isdigit() else 0
                    security = parts[2].strip()
                    networks.append({
                        "ssid": ssid,
                        "signal": signal,
                        "secure": bool(security and security != "--"),
                    })
            networks.sort(key=lambda n: -n["signal"])
        except (subprocess.SubprocessError, FileNotFoundError):
            pass
        self._networks = networks
        self._scanning = False
        self.networksChanged.emit()

    @Slot(str, str)
    def connect_to(self, ssid, password):
        thread = Thread(target=self._do_connect, args=(ssid, password), daemon=True)
        thread.start()

    def _do_connect(self, ssid, password):
        try:
            cmd = ["nmcli", "device", "wifi", "connect", ssid]
            if password:
                cmd += ["password", password]
            result = subprocess.run(
                cmd, capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0:
                self._connected = True
                self.connectionStatusChanged.emit()
                self.connectResult.emit(True, "Connected successfully")
            else:
                msg = result.stderr.strip() or "Connection failed"
                self.connectResult.emit(False, msg)
        except subprocess.TimeoutExpired:
            self.connectResult.emit(False, "Connection timed out")
        except Exception as e:
            self.connectResult.emit(False, str(e))
