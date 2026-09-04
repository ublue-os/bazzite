command_not_found_handle() {
    {
        local \
            cmd \
            message \
            max_lines=4 \
            completions \
            suggestions \
            key \
            value \
            comment \
            ;

        cmd="$1${2:+ $2}" # We include $2 because of ujust <recipe_name>

        # Associative array for all completions.
        # We will populate it in order of precedence (last one wins).
        declare -A all_completions

        # System commands (lowest precedence)
        while read -r c; do
            [[ "$c" == _* || -z "$c" ]] && continue
            all_completions["$c"]=""
        done < <(compgen -c 2>/dev/null | sort -u)

        #  Ujust commands
        while IFS=$'\t' read -r key value; do
            # Make sure key is not empty
            [[ -n "$key" ]] && all_completions["$key"]="$value"
        done < <(ujust --dump-format=json --dump 2>/dev/null |
            jq -r '.recipes | to_entries | .[] | select(.key | startswith("_") | not) | "ujust \(.key)\t\(.value.doc // "")"')

        # Custom suggestions (highest precedence)
        declare -A custom_suggestions
        custom_suggestions=(
            ["rpm-ostree"]="Use instead of apt, pacman, yum, dnf."
        )
        for key in "${!custom_suggestions[@]}"; do
            all_completions["$key"]="${custom_suggestions["$key"]}"
        done

        # Format the unified completions list for fzf
        local completions_list=()
        for key in "${!all_completions[@]}"; do
            comment="${all_completions[$key]}"
            if [[ -n "$comment" && "$comment" != "null" ]]; then
                completions_list+=("$key # $comment")
            else
                completions_list+=("$key")
            fi
        done
        printf -v completions '%s\n' "${completions_list[@]}"

        # Run fzf and get suggestions
        readarray -t suggestions <<<"$(echo "$completions" | fzf --no-extended -i --filter="$cmd" --tiebreak=length,begin -0 2>/dev/null | head -n $max_lines)"

        if [[ ${#suggestions[@]} -eq 0 || ${suggestions[0]} == "" ]]; then
            printf >&2 '%s\n' "command not found: $1${2:+ $2}"
            return 127
        fi

        { message="$(</dev/stdin)"; } <<EOF
command not found: $1
Maybe you meant one of the following:
$(printf -- '  - %s\n' "${suggestions[@]}")
EOF

        printf >&2 '%s\n' "$message"
        return 127
    } >&2
}
