if [[ $- == *i* ]]; then
    # /usr/bin/dnf is a dummy wrapper that opens docs
    alias pacman='/usr/bin/dnf'
    alias apt='/usr/bin/dnf'
    alias yum='/usr/bin/dnf'
fi
