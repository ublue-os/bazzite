# vim: set ft=make :

alias upgrade := update

# Update system, flatpaks, and containers all at once
[group("system")]
update:
    #!/usr/bin/bash
    uupd --hw-check=false --json --log-level=debug | jq -r '[(.title, .msg, .description) | select(.)] | join(" ")'

alias changelog := changelogs

# Show the stable changelog
[group("system")]
changelogs:
    #!/usr/bin/bash
    CONTENT=$(curl -s https://api.github.com/repos/ublue-os/bazzite/releases/latest | jq -r '.body')
      echo "$CONTENT" | glow -

# Show the testing (pre-release) changelog
[group("system")]
changelogs-testing:
    #!/usr/bin/bash
    CONTENT=$(curl -s https://api.github.com/repos/ublue-os/bazzite/releases | jq -r 'map(select(.prerelease)) | .[0].body')
       echo "$CONTENT" | glow -
