"""
Game launcher for Luna.
Handles launching games from Steam, Heroic, and native installs.
"""

import subprocess
import os
import time

from PySide6.QtCore import QObject, Signal, Slot, QProcess


class GameLauncher(QObject):
    gameLaunched = Signal(str)  # game_id
    gameExited = Signal(str, int)  # game_id, exit_code

    def __init__(self, config_manager, parent=None):
        super().__init__(parent)
        self._config = config_manager
        self._current_process = None
        self._current_game_id = None

    @Slot(str, str, str, str, str)
    def launch(self, game_id, name, source, art, launch_cmd):
        """Launch a game and track it as recently played."""
        self._config.addRecentGame(game_id, name, source, art)

        if source == "Steam":
            self._launch_steam(game_id, launch_cmd)
        elif source in ("Epic", "Xbox", "GOG", "Sideload"):
            self._launch_heroic(game_id, launch_cmd, name)
        else:
            self._launch_native(game_id, launch_cmd)

    def _launch_steam(self, game_id, steam_url):
        """Launch via Steam client protocol."""
        try:
            subprocess.Popen(
                ["xdg-open", steam_url],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            self.gameLaunched.emit(game_id)
        except Exception as e:
            print(f"Failed to launch Steam game: {e}")

    def _launch_heroic(self, game_id, executable, title):
        """Launch via Heroic Games Launcher CLI."""
        try:
            app_name = game_id.replace("heroic_", "").replace("xbox_", "")
            subprocess.Popen(
                ["flatpak", "run", "com.heroicgameslauncher.hgl", "--no-gui", "launch", app_name],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            self.gameLaunched.emit(game_id)
        except FileNotFoundError:
            # Try system heroic
            try:
                subprocess.Popen(
                    ["heroic", "--no-gui", "launch", app_name],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                self.gameLaunched.emit(game_id)
            except Exception as e:
                print(f"Failed to launch Heroic game: {e}")

    def _launch_native(self, game_id, launch_cmd):
        """Launch a native executable."""
        try:
            subprocess.Popen(
                [launch_cmd],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                cwd=os.path.dirname(launch_cmd),
            )
            self.gameLaunched.emit(game_id)
        except Exception as e:
            print(f"Failed to launch native game: {e}")
