# Set Game Mode as the default deck login session
set-default-game-mode:
    steamosctl set-default-login-mode game

# Set Desktop Mode as the default deck login session
set-default-desktop:
    steamosctl set-default-login-mode desktop

# Get currently set default session
get-deck-session-status:
    steamosctl get-default-login-mode
