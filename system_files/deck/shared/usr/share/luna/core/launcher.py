import subprocess
from core.game_model import Game, GameSource


def launch_game(game: Game):
    """Launch a game. Gamescope handles the rest."""
    if game.source == GameSource.STEAM:
        _launch_steam_game(game)
    elif game.source in (GameSource.EPIC, GameSource.XBOX):
        _launch_heroic_game(game)
    elif game.source == GameSource.NATIVE:
        _launch_native_game(game)


def _launch_steam_game(game: Game):
    # Tell the Steam client to launch this game.
    # Steam handles Proton, DRM, and compatibility automatically.
    subprocess.Popen(['steam', '-applaunch', game.app_id])


def _launch_heroic_game(game: Game):
    # Use Heroic's CLI to launch, or run the native executable directly.
    if game.executable:
        subprocess.Popen([game.executable])
    else:
        # Fallback: tell Heroic to launch by app key
        subprocess.Popen(['heroic', 'launch', game.app_id])


def _launch_native_game(game: Game):
    subprocess.Popen([game.executable])
