"""
Configuration and state management for Luna.
Handles user preferences, recently played games, and first-boot state.
"""

import json
import os
from PySide6.QtCore import QObject, Property, Signal, Slot


CONFIG_DIR = os.path.expanduser("~/.config/luna")
CONFIG_FILE = os.path.join(CONFIG_DIR, "config.json")
RECENT_FILE = os.path.join(CONFIG_DIR, "recent.json")

MAX_RECENT = 6

DEFAULT_CONFIG = {
    "setup_complete": False,
    "user_name": "",
    "volume": 80,
}


class ConfigManager(QObject):
    configChanged = Signal()
    recentGamesChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        os.makedirs(CONFIG_DIR, exist_ok=True)
        self._config = self._load_config()
        self._recent = self._load_recent()

    def _load_config(self):
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, "r") as f:
                    data = json.load(f)
                merged = dict(DEFAULT_CONFIG)
                merged.update(data)
                return merged
            except (json.JSONDecodeError, IOError):
                pass
        return dict(DEFAULT_CONFIG)

    def _save_config(self):
        with open(CONFIG_FILE, "w") as f:
            json.dump(self._config, f, indent=2)

    def _load_recent(self):
        if os.path.exists(RECENT_FILE):
            try:
                with open(RECENT_FILE, "r") as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                pass
        return []

    def _save_recent(self):
        with open(RECENT_FILE, "w") as f:
            json.dump(self._recent, f, indent=2)

    @Property(bool, notify=configChanged)
    def setupComplete(self):
        return self._config.get("setup_complete", False)

    @Property(str, notify=configChanged)
    def userName(self):
        return self._config.get("user_name", "")

    @Slot(str)
    def setUserName(self, name):
        self._config["user_name"] = name
        self._save_config()
        self.configChanged.emit()

    @Slot()
    def completeSetup(self):
        self._config["setup_complete"] = True
        self._save_config()
        self.configChanged.emit()

    @Slot(result="QVariantList")
    def getRecentGames(self):
        return self._recent

    @Slot(str, str, str, str)
    def addRecentGame(self, game_id, name, source, art_path):
        entry = {
            "id": game_id,
            "name": name,
            "source": source,
            "art": art_path,
        }
        self._recent = [g for g in self._recent if g["id"] != game_id]
        self._recent.insert(0, entry)
        self._recent = self._recent[:MAX_RECENT]
        self._save_recent()
        self.recentGamesChanged.emit()
