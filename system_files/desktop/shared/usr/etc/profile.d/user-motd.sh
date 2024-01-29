if test -d "$HOME"; then
  if test ! -e "$HOME"/.config/no-show-user-motd; then
    if test -x "/usr/libexec/ublue-motd"; then
      /usr/libexec/ublue-motd
    fi
  fi
fi
