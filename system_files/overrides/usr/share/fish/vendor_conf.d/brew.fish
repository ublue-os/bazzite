#!/usr/bin/fish
#shellcheck disable=all
set -g __brew_instance_initialize 0
set -g __brew_binary /home/linuxbrew/.linuxbrew/bin/brew

function brew_new_instance
  alias brew=$__brew_binary
  if test $__brew_instance_initialize = 0
    if status --is-interactive
      if [ -d /home/linuxbrew/.linuxbrew ]
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        if [ -w /home/linuxbrew/.linuxbrew ]
          if  [ ! -L (brew --prefix)/share/fish/vendor_completions.d/brew ]
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
    set __brew_instance_initialize 1
    brew $argv
  end
end

alias brew=brew_new_instance


