# vim: set ft=make :

alias upgrade := update

# Update system, flatpaks, and containers all at once
[group("system")]
update:
    #!/usr/bin/bash
    # uupd-manual.service logs at debug level, which includes the raw bootc progress
    # JSON and "scanned progress" traces. Hide those and, on newer uupd versions,
    # show the text of "Command output" records instead of the literal message.
    /usr/libexec/uupd-update | jq -r -R '
        fromjson?
        | select(.msg != "scanned progress")
        | [(.title, (if .msg == "Command output" then .output else .msg end), .description) | select(.)]
        | join(" ")
        | select(. != "")
        | select(((try fromjson catch null) | type) != "object")
    '

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
