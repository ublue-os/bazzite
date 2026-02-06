# Announcements files

## File naming

Announcements files must have the suffix `.msg.json`.

## Structure

These are JSON files with the following fields:

- `title`: The title of the announcement.
  - Should be 1~2 words long maximum. Valid examples are: "Breaking change", "Announcement".
  - Avoid using too many variations of titles across announcements.
  - It is meant to categorize the gravity of the announcement.
- `body`: Body of the announcement. It should be a short paragraph explaining the announcement.
- `seeMoreUrl`: An URL that will be opened when the user clicks the "See more" button. Should be used instead of long announcement bodies.
- `if`: Shell line that can be used to conditionally skip the announcement.
  - To skip an announcement, the shell line should resolve to an exit code 1.
  - If should not be skipped, ommit the field or have it resolve to an exit code 0.

One can use the `if` field to trigger an announcement using a image version, in order to setup an announcement beforehand.
An example:

```json
{
  "if": "systemd-analyze compare-versions 43 \\< $(rpm-ostree status -v --json | jq -r '.deployments[]|select(.booted==true)|.version')"
}
```

In this example, the announcement will trigger when our system updates to 43 or greater.


## Tooling
Use `prepare_msg.sh` to create an announcement json interactively. Useful when dealing with multiline fields.
