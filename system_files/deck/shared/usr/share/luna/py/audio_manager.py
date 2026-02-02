"""
Audio manager for Luna UI sounds.
Plays navigation and selection feedback sounds.
"""

import os
from PySide6.QtCore import QObject, Slot, QUrl
from PySide6.QtMultimedia import QSoundEffect


class AudioManager(QObject):
    def __init__(self, luna_dir, parent=None):
        super().__init__(parent)
        self._sounds_dir = os.path.join(luna_dir, "sounds")
        self._effects = {}

    def _get_effect(self, name):
        if name not in self._effects:
            path = os.path.join(self._sounds_dir, f"{name}.wav")
            if os.path.exists(path):
                effect = QSoundEffect(self)
                effect.setSource(QUrl.fromLocalFile(path))
                effect.setVolume(0.5)
                self._effects[name] = effect
            else:
                return None
        return self._effects.get(name)

    @Slot(str)
    def play(self, sound_name):
        """Play a UI sound by name (navigate, select, back, transition)."""
        effect = self._get_effect(sound_name)
        if effect:
            effect.play()
