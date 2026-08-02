# vim: set ft=make :

update-nvidia-runtime ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    get_status_token() {
        local service_state
        service_state="$(/usr/libexec/ublue-nvidia-flatpak-runtime-sync check)"
        if ! service_state; then
            echo "upgraded"
        else
            echo "mismatch"
        fi
    }
    OPTION="{{ ACTION }}"
    if [[ "$OPTION" == "help" ]]; then
        echo "Usage: ujust update-nvidia-runtime <option>"
        echo "  <option>: Specify the quick option to skip the prompt"
        echo "  Use 'status' to print the current portal token"
        echo "  Use 'upgrade' to upgrade"
        exit 0
    elif [[ "$OPTION" == "status" ]]; then
        get_status_token
        exit $?
    elif [[ "$OPTION" == "upgrade" ]]; then
        /usr/libexec/ublue-nvidia-flatpak-runtime-sync sync
    elif [[ -z "$OPTION" ]]; then
        echo "${bold}No option specified.${normal}"
        exit 0
    fi

    exit 0
