nicknamenamenick | 2024-07-26 13:41:48 UTC | #1

# What is `ujust`?

![Shell Scripts (.sh)|96x96, 100%](../img/Shell_Scripts_.sh.png)

Technically `ujust` is **not** a package format, but are convenience commands that automate tasks using scripts which can be utilized to install specific software. There are also commands for system configuration and maintenance too included here, so run `ujust` commands **at your own risk.**

## Using `ujust`

Open a host terminal and **enter**:

![ujust command list|690x411](../img/ujust_command_list.png)

```
ujust
```

This will output a list of available commands.

![ujust TUI|690x403](../img/ujust_TUI.png)

```
ujust --choose
```

This will show a terminal user interface of `ujust` commands that you can choose to execute with arrow keys or mouse input.

> **Note**: Commands that require values or flags do not function with this method.

## Manually Entering Commands

**Find the command you want to use and enter**:

```
ujust <command>
```

You can search for specific commands by **entering**:

```
ujust | grep "<search keyword(s)>"
```

- `install-`: Install program, there is no configuration or uninstall commands at this time
- `get-`: Install an "extension" like Decky plugins, and if it is an extension then it can use `get-` too
- `setup-`: Install program, provides uninstall and configuration options for after install
- `configure-`: Configure something that came by default on the image
  - If it must be installed first, then it will be in `setup-`
- `toggle-`: Turns something on/off
  - Selection might be automatic or manual depending on implementation
- `fix-`: Fixes, patches or works around an issue
- `distrobox-`: Distrobox exclusive verb for useful Distrobox stuff
- `foo`: Replace this with whatever the command is called
  - These are shortcuts that we have deemed necessary to not have a verb
    - **Examples**: `ujust update` and `ujust enroll-secureboot-key`

# View each `ujust` script's source code

If you would like to see what each script does for each command then open a host terminal and **enter**:

```
ujust --show <command>
```

Alternatively, you can find the `ujust` commands locally in:
`/usr/share/ublue-os/just`

> This directory also shows **hidden** `ujust` commands.

# Uninstalling Applications Installed Through `ujust`

Most applications installed via a `ujust` script would have to be uninstalled manually. Follow the instructions found on the project's website or repository online to uninstall it properly.

This **command** Shows layered packages that may be installed from the Bazzite Portal / `ujust`:

```command
rpm-ostree status
```

# Project Website

https://just.systems/

<hr>

**See also**: https://universal-blue.discourse.group/docs?topic=42

[**<-- Back to Installing and Managing Software on Bazzite**](index.md)