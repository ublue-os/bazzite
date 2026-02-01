from dataclasses import dataclass
from enum import Enum

class GameSource(Enum):
    STEAM = 'steam'
    EPIC = 'epic'
    XBOX = 'xbox'
    NATIVE = 'native'

@dataclass
class Game:
    name: str                    # Display name
    source: GameSource           # Where it came from
    app_id: str                  # Steam appid, Heroic app key, or exe path
    install_path: str            # Root install directory
    executable: str              # Full path to the game executable
    art_path: str = ''           # Path to poster/cover art (empty = use placeholder)
