import os
import re
import json
from pathlib import Path
from core.game_model import Game, GameSource

STEAM_DEFAULT = Path.home() / '.local/share/Steam'
HEROIC_CONFIG = Path.home() / '.config/heroic'


def scan_all_games() -> list[Game]:
    """Run all scanners and return combined, sorted game list."""
    games = []
    games.extend(scan_steam())
    games.extend(scan_heroic())
    # Sort alphabetically by name
    games.sort(key=lambda g: g.name.lower())
    return games


def scan_steam() -> list[Game]:
    """Scan all Steam library folders for installed games."""
    games = []
    library_paths = _get_steam_library_paths()
    for lib_path in library_paths:
        steamapps = lib_path / 'steamapps'
        if not steamapps.exists():
            continue
        for manifest in steamapps.glob('appmanifest_*.acf'):
            game = _parse_appmanifest(manifest, steamapps)
            if game:
                games.append(game)
    return games


def _get_steam_library_paths() -> list[Path]:
    """Read libraryfolders.vdf to find all Steam library locations."""
    paths = [STEAM_DEFAULT]
    vdf_path = STEAM_DEFAULT / 'steamapps' / 'libraryfolders.vdf'
    if not vdf_path.exists():
        return paths
    # Parse the simple key-value format
    with open(vdf_path) as f:
        for line in f:
            # Lines like:  "path"  "/mnt/games"
            match = re.match(r'\s*"path"\s*"(.+?)"', line)
            if match:
                p = Path(match.group(1))
                if p.exists():
                    paths.append(p)
    return paths


def _parse_appmanifest(path: Path, steamapps: Path) -> Game | None:
    """Parse a single appmanifest file into a Game object."""
    data = {}
    with open(path) as f:
        for line in f:
            match = re.match(r'\s*"(\w+)"\s*"(.+?)"', line)
            if match:
                data[match.group(1)] = match.group(2)
    if 'appid' not in data or 'name' not in data:
        return None
    install_dir = steamapps / 'common' / data.get('installdir', '')
    if not install_dir.exists():
        return None  # Listed but not actually installed
    return Game(
        name=data['name'],
        source=GameSource.STEAM,
        app_id=data['appid'],
        install_path=str(install_dir),
        executable='',  # Steam handles launching via app_id
    )


def scan_heroic() -> list[Game]:
    """Scan Heroic Games Launcher library for Epic and Xbox games."""
    games = []
    games_config_dir = HEROIC_CONFIG / 'GamesConfig'
    if not games_config_dir.exists():
        return games
    for config_file in games_config_dir.glob('*.json'):
        game = _parse_heroic_game(config_file)
        if game:
            games.append(game)
    return games


def _parse_heroic_game(path: Path) -> Game | None:
    """Parse a Heroic game config JSON into a Game object."""
    try:
        with open(path) as f:
            data = json.load(f)
        # Heroic stores the store source in the config
        store = data.get('store', 'epic')
        source = GameSource.XBOX if store == 'gog' or 'xbox' in store.lower() else GameSource.EPIC
        install_path = Path(data.get('install_path', ''))
        if not install_path.exists():
            return None
        return Game(
            name=data.get('game_title', path.stem),
            source=source,
            app_id=data.get('app_key', path.stem),
            install_path=str(install_path),
            executable=data.get('native_exe', ''),
        )
    except (json.JSONDecodeError, KeyError):
        return None
