#!/usr/bin/env sh

# ls aliases
if [ "$(command -v eza)" ]; then
    alias ll='eza -l --icons=auto --group-directories-first'
    alias l.='eza -d .*'
    alias ls='eza'
    alias l1='eza -1'
fi

# ugrep for grep
if [ "$(command -v ug)" ]; then
    alias grep='ug'
    alias egrep='ug -E'
    alias fgrep='ug -F'
    alias xzgrep='ug -z'
    alias xzegrep='ug -zE'
    alias xzfgrep='ug -zF'
fi

if [ "$(basename "$SHELL")" = "bash" ]; then
    #shellcheck disable=SC1091
    . /usr/share/bash-prexec
    [ "$(command -v atuin)" ] && eval "$(atuin init bash)"
    [ "$(command -v zoxide)" ] && eval "$(zoxide init bash)"
elif [ "$(basename "$SHELL")" = "zsh" ]; then
    [ "$(command -v atuin)" ] && eval "$(atuin init zsh)"
    [ "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
fi