export PATH := justfile_directory() + "/utils:" + env("PATH")

_default:
    just --list

# Install dependencies required for documentation stuff
install_dependencies:
    bash ./utils/install-deps.sh

_build_messages_pot:
    #!/usr/bin/bash
    DEBUG=1 ./utils/pre-build.py -s src -o src.tmp
    MDBOOK_BOOK__SRC="src.tmp" \
    MDBOOK_OUTPUT='{"xgettext": {}}' \
        mdbook build -d po
    rm -r src.tmp

# Check that a translation file exists, otherwise exit with 1
_is_translation LANG:
    [[ -f po/{{LANG}}.po ]] || { \
        echo "ERROR: 'po/{{LANG}}.po' does not exist."; \
        echo "Use 'just add_translation {{LANG}}' to create a new translation file"; \
        exit 1; }

# Add a language to translate
add_translation LANG: _build_messages_pot
    msginit -i po/messages.pot -l {{LANG}} -o po/{{LANG}}.po

# Flatten a directory containing multiple mdbook outputs
_flatten_outputs OUTPUTS_DIR="./book":
    #!/usr/bin/bash
    cd {{ OUTPUTS_DIR }}
    to_flatten=( \
        # Add here directories you want to flatten
        $(ls -d "html" "pdf") \
    ) || true
    for dir in "${to_flatten[@]}"; do
        (
            shopt -s dotglob
            mv $dir/* ./
        )
    done

# Update a language with a fresh messages.pot
update_translation LANG: (_is_translation LANG) _build_messages_pot
    msgmerge --update po/{{LANG}}.po po/messages.pot

# Equivalent to 'mdbook build'
mdbook_build LANG="":
    #!/usr/bin/bash
    mdbook clean
    mdbook build -d ./book && just _flatten_outputs
    if [[ -n "{{LANG}}" ]]; then
        MDBOOK_BOOK__LANGUAGE={{LANG}} mdbook build -d book/{{LANG}} && \
            just _flatten_outputs book/{{LANG}}
    fi

_serve_http DIR="./book":
    python -m http.server -d {{DIR}} -b 127.0.0.1 3000

# Start a lightweight web server with a preview of the mdbook
mdbook_serve LANG="":
    #!/usr/bin/bash
    set -meo pipefail
    just mdbook_build {{LANG}}
    just _serve_http &
    sleep 1
    printf '\n\n\n\n'
    echo "Page ready at 'http://127.0.0.1:3000/{{LANG}}'"
    fg

# Same as 'mdbook_serve' but for a specific language
preview_translation LANG: (_is_translation LANG)
    just mdbook_serve {{LANG}}