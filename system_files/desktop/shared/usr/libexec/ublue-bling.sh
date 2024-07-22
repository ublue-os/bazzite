#!/usr/bin/bash
#shellcheck disable=SC2154

set -eou pipefail

# Source libujust for colors/ugum
source /usr/lib/ujust/ujust.sh

# Exit Handling
function Exiting(){
    printf "%s%sExiting...%s\n" "${red}" "${bold}" "${normal}"
    printf "Rerun script with %s%sujust bluefin-cli%s\n" "${blue}" "${bold}" "${normal}"
    exit 0
}

# Trap function
function ctrl_c(){
    printf "\nSignal SIGINT caught\n"
    Exiting
}

# Brew Bundle Install
function brew-bundle(){
echo 'Installing bling from Homebrew 🍻🍻🍻'
brew bundle --file /usr/share/ublue-os/homebrew/bluefin-cli.Brewfile --no-lock
}

# Check if bling is already sourced
function check-bling() {
shell="$1"
if [[ "${shell}" == "fish" ]]; then
    line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.fish" \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
        | grep -Eo '^[^:]+')
    if [[ -n "${line}" ]]; then
        return 1;
    fi
    return 0;
elif [[ "${shell}" == "zsh" ]]; then
    line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
        "${ZDOTDIR:-$HOME}/.zshrc" \
        | grep -Eo '^[^:]+')
    if [[ -n "${line}" ]]; then
        return 1;
    fi
    return 0;
elif [[ "${shell}" == "bash" ]]; then
    line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
        "${HOME}/.bashrc" \
        | grep -Eo '^[^:]+')
    if [[ -n "${line}" ]]; then
        return 1;
    fi
    return 0;
else
    echo 'Unknown Shell ... You are on your own'
    exit 1;
fi
}

# Add Bling
function add-bling(){
shell="$1"
if ! brew-bundle; then
    Exiting
fi
echo 'Setting up your Shell 🐚🐚🐚'
if [[ "${shell}" == "fish" ]]; then
    echo 'Adding bling to your config.fish 🐟🐟🐟'
    cat<<-EOF >> "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
### bling.fish source start
test -f /usr/share/ublue-os/bluefin-cli/bling.fish && source /usr/share/ublue-os/bluefin-cli/bling.fish
### bling.fish source end
EOF
elif [[ "${shell}" == "zsh" ]]; then
    echo 'Adding bling to your .zshrc 💤💤💤'
    cat<<-EOF >> "${ZDOTDIR:-$HOME}/.zshrc"
### bling.sh source start
test -f /usr/share/ublue-os/bluefin-cli/bling.sh && source /usr/share/ublue-os/bluefin-cli/bling.sh
### bling.sh source end
EOF
elif [[ "${shell}" == "bash" ]]; then
    echo 'Adding bling to your .bashrc 💥💥💥'
    cat<<-EOF >> "${HOME}/.bashrc"
### bling.sh source start
test -f /usr/share/ublue-os/bluefin-cli/bling.sh && source /usr/share/ublue-os/bluefin-cli/bling.sh
### bling.sh source end
EOF
else
    echo 'Unknown Shell ... You are on your own'
fi
}

# Remove bling, handle if old method
function remove-bling(){
shell="$1"
if [[ "${shell}" == "fish" ]]; then
    sed -i '/### bling.fish source start/,/### bling.fish source end/d' \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
        || \
        line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.fish" \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" \
        | grep -Eo '^[^:]+') && sed -i "${line}"d \
        "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
elif [[ "${shell}" == "zsh" ]]; then
    sed -i '/### bling.sh source start/,/### bling.sh source end/d' \
        "${ZDOTDIR:-$HOME}/.zshrc" \
        || \
        line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
        "${ZDOTDIR:-$HOME}/.zshrc" \
        | grep -Eo '^[^:]+') && sed -i "${line}"d \
        "${ZDOTDIR:-$HOME}/.zshrc"
elif [[ "${shell}" == "bash" ]]; then
    sed -i '/### bling.sh source start/,/### bling.sh source end/d' \
        "${HOME}/.bashrc" \
        || \
        line=$(grep -n "source /usr/share/ublue-os/bluefin-cli/bling.sh" \
        "${HOME}/.bashrc" \
        | grep -Eo '^[^:]+') && sed -i "${line}"d \
        "${HOME}/.bashrc"
fi
}

# Main function.
function main(){

# Get Shell
shell=$(basename "$SHELL")
reentry="$1"
clear
if [[ -n "${reentry:-}" ]]; then
    printf "%s%s%s\n\n" "${bold}" "$reentry" "$normal"
fi

# Check if bling is enabled and display
printf "Shell:\t%s%s%s%s\n" "${green}" "${bold}" "${shell}" "${normal}"
if ! check-bling "${shell}"; then
    printf "Bling:\t%s%sEnabled%s\n" "${green}" "${bold}" "${normal}"
else
    printf "Bling:\t%s%sDisabled%s\n" "${red}" "${bold}" "${normal}"
fi

# ugum enable/disable
CHOICE=$(Choose enable disable cancel)

# Enable/Disable. Recurse if bad option.
if [[ "${CHOICE}" == "enable" ]]; then
    if check-bling "${shell}"; then
        trap ctrl_c SIGINT
        add-bling "${shell}"
        printf "%s%sInstallation Complete%s ... please close and reopen your terminal!" "${green}" "${bold}" "${normal}"
    else
        main "Bling is already configured ..."
    fi
elif [[ "${CHOICE}" == "disable" ]]; then
    if check-bling "${shell}"; then
        main "Bling is not yet configured ..."
    else
        remove-bling "${shell}"
        trap ctrl_c SIGINT
        printf "%s%sBling Removed%s ... please close and reopen your terminal\n" "${red}" "${bold}" "${normal}"
    fi
else
    Exiting
fi
}

# Entrypoint
main ""