"""
Game library scanner for Luna.
Detects installed games from Steam, Heroic Games Launcher (Epic/Xbox), and native installs.
"""

import json
import os
import re
import glob
from pathlib import Path
from threading import Thread

from PySide6.QtCore import QObject, Signal, Slot, Property


class GameScanner(QObject):
    scanComplete = Signal()
    scanStarted = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._games = []
        self._scanning = False

    @Property("QVariantList", notify=scanComplete)
    def games(self):
        return self._games

    @Property(bool, notify=scanStarted)
    def scanning(self):
        return self._scanning

    @Slot()
    def scan_all(self):
        if self._scanning:
            return
        self._scanning = True
        self.scanStarted.emit()
        thread = Thread(target=self._do_scan, daemon=True)
        thread.start()

    def _do_scan(self):
        games = []
        games.extend(self._scan_steam())
        games.extend(self._scan_heroic())
        games.extend(self._scan_native())
        games.sort(key=lambda g: g["name"].lower())
        self._games = games
        self._scanning = False
        self.scanComplete.emit()

    def _scan_steam(self):
        games = []
        steam_paths = [
            os.path.expanduser("~/.steam/steam"),
            os.path.expanduser("~/.local/share/Steam"),
        ]

        for steam_root in steam_paths:
            libraryfolders = os.path.join(steam_root, "steamapps", "libraryfolders.vdf")
            if not os.path.exists(libraryfolders):
                continue

            lib_paths = self._parse_library_folders(libraryfolders)
            for lib_path in lib_paths:
                steamapps = os.path.join(lib_path, "steamapps")
                if not os.path.isdir(steamapps):
                    continue

                for acf in glob.glob(os.path.join(steamapps, "appmanifest_*.acf")):
                    game = self._parse_acf(acf, steamapps)
                    if game:
                        games.append(game)
            break

        return games

    def _parse_library_folders(self, vdf_path):
        paths = []
        try:
            with open(vdf_path, "r") as f:
                content = f.read()
            for match in re.finditer(r'"path"\s+"([^"]+)"', content):
                paths.append(match.group(1))
        except IOError:
            pass
        return paths

    def _parse_acf(self, acf_path, steamapps_dir):
        try:
            with open(acf_path, "r") as f:
                content = f.read()

            app_id_m = re.search(r'"appid"\s+"(\d+)"', content)
            name_m = re.search(r'"name"\s+"([^"]+)"', content)

            if not app_id_m or not name_m:
                return None

            app_id = app_id_m.group(1)
            name = name_m.group(1)

            # Skip Proton, Steam Linux Runtime, etc.
            skip_prefixes = ["Proton ", "Steam Linux Runtime", "Steamworks Common"]
            if any(name.startswith(p) for p in skip_prefixes):
                return None

            art_path = self._find_steam_art(app_id)

            return {
                "id": f"steam_{app_id}",
                "name": name,
                "source": "Steam",
                "app_id": app_id,
                "art": art_path,
                "launch_cmd": f"steam://rungameid/{app_id}",
            }
        except IOError:
            return None

    def _find_steam_art(self, app_id):
        steam_paths = [
            os.path.expanduser("~/.steam/steam"),
            os.path.expanduser("~/.local/share/Steam"),
        ]
        for steam_root in steam_paths:
            grid_dir = os.path.join(steam_root, "appcache", "librarycache")
            for suffix in ["_header.jpg", "_header.png", "_library_600x900.jpg", "_library_hero.jpg"]:
                art = os.path.join(grid_dir, f"{app_id}{suffix}")
                if os.path.exists(art):
                    return art

            grid_dir2 = os.path.join(steam_root, "userdata")
            if os.path.isdir(grid_dir2):
                for user_dir in os.listdir(grid_dir2):
                    grid = os.path.join(grid_dir2, user_dir, "config", "grid")
                    if os.path.isdir(grid):
                        for f in os.listdir(grid):
                            if f.startswith(app_id):
                                return os.path.join(grid, f)
        return ""

    def _scan_heroic(self):
        games = []
        heroic_config = os.path.expanduser("~/.config/heroic")

        # Heroic stores game info in library JSON files
        for store_type, source_name in [("legendary", "Epic"), ("gog", "GOG"), ("sideload", "Sideload")]:
            lib_file = os.path.join(heroic_config, store_type + "GamesConfig.json")
            installed_file = os.path.join(heroic_config, store_type, "installed.json")

            installed_games = {}
            if os.path.exists(installed_file):
                try:
                    with open(installed_file, "r") as f:
                        data = json.load(f)
                    if isinstance(data, dict) and "installed" in data:
                        for g in data["installed"]:
                            installed_games[g.get("appName", "")] = g
                    elif isinstance(data, list):
                        for g in data:
                            installed_games[g.get("appName", "")] = g
                except (json.JSONDecodeError, IOError):
                    pass

            # Also check Heroic's library.json for game metadata
            lib_json = os.path.join(heroic_config, store_type, "library.json")
            if os.path.exists(lib_json):
                try:
                    with open(lib_json, "r") as f:
                        data = json.load(f)
                    game_list = data if isinstance(data, list) else data.get("library", [])
                    for entry in game_list:
                        app_name = entry.get("app_name", "")
                        if app_name not in installed_games:
                            continue
                        title = entry.get("title", app_name)
                        art = entry.get("art_cover", entry.get("art_square", ""))

                        install_info = installed_games[app_name]
                        exe = install_info.get("executable", "")

                        games.append({
                            "id": f"heroic_{app_name}",
                            "name": title,
                            "source": source_name,
                            "app_id": app_name,
                            "art": art,
                            "launch_cmd": exe,
                            "heroic": True,
                        })
                except (json.JSONDecodeError, IOError):
                    pass

        # Xbox / Game Pass via Heroic
        nile_installed = os.path.join(heroic_config, "nile", "installed.json")
        if os.path.exists(nile_installed):
            try:
                with open(nile_installed, "r") as f:
                    data = json.load(f)
                entries = data if isinstance(data, list) else data.get("installed", [])
                for entry in entries:
                    app_name = entry.get("appName", entry.get("app_name", ""))
                    title = entry.get("title", entry.get("name", app_name))
                    games.append({
                        "id": f"xbox_{app_name}",
                        "name": title,
                        "source": "Xbox",
                        "app_id": app_name,
                        "art": entry.get("art_cover", ""),
                        "launch_cmd": entry.get("executable", ""),
                        "heroic": True,
                    })
            except (json.JSONDecodeError, IOError):
                pass

        return games

    def _scan_native(self):
        games = []
        native_dirs = [
            os.path.expanduser("~/Games"),
            "/usr/local/games",
        ]
        for d in native_dirs:
            if not os.path.isdir(d):
                continue
            for entry in os.listdir(d):
                full = os.path.join(d, entry)
                if os.path.isfile(full) and os.access(full, os.X_OK):
                    games.append({
                        "id": f"native_{entry}",
                        "name": entry.replace("-", " ").replace("_", " ").title(),
                        "source": "Native",
                        "app_id": entry,
                        "art": "",
                        "launch_cmd": full,
                    })
                elif os.path.isdir(full):
                    # Look for common launch scripts
                    for launcher in ["start.sh", "launch.sh", "run.sh", entry, entry.lower()]:
                        launch_path = os.path.join(full, launcher)
                        if os.path.isfile(launch_path) and os.access(launch_path, os.X_OK):
                            games.append({
                                "id": f"native_{entry}",
                                "name": entry.replace("-", " ").replace("_", " ").title(),
                                "source": "Native",
                                "app_id": entry,
                                "art": "",
                                "launch_cmd": launch_path,
                            })
                            break
        return games
