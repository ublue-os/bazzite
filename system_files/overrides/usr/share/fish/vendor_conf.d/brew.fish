#!/usr/bin/fish
#shellcheck disable=all
if status --is-interactive
    if [ -d /home/linuxbrew/.linuxbrew ]
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        if [ -w /home/linuxbrew/.linuxbrew ]
            if  [ ! -L (brew --prefix)/share/fish/vendor_completions.d/brew.fish ]
                brew completions link > /dev/null
            end
        end
        if test -d (brew --prefix)/share/fish/completions
            set -p fish_complete_path (brew --prefix)/share/fish/completions
        end
        if test -d (brew --prefix)/share/fish/vendor_completions.d
            set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
        end
    end
end
