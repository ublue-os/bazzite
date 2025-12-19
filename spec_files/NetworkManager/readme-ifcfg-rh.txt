NetworkManager stores new network profiles in keyfile format in the
/etc/NetworkManager/system-connections/ directory.

Previously, NetworkManager stored network profiles in ifcfg format
in this directory (/etc/sysconfig/network-scripts/). However, the ifcfg
format is deprecated. By default, NetworkManager no longer creates
new profiles in this format.

Connection profiles in keyfile format have many benefits. For example,
this format is INI file-based and can easily be parsed and generated.

Each section in NetworkManager keyfiles corresponds to a NetworkManager
setting name as described in the nm-settings(5) and nm-settings-keyfile(5)
man pages. Each key-value-pair in a section is one of the properties
listed in the settings specification of the man page.

If you still use network profiles in ifcfg format, consider migrating
them to keyfile format. To migrate all profiles at once, enter:

# nmcli connection migrate

This command migrates all profiles from ifcfg format to keyfile
format and stores them in /etc/NetworkManager/system-connections/.

Alternatively, to migrate only a specific profile, enter:

# nmcli connection migrate <profile_name|UUID|D-Bus_path>

For further details, see:
* nm-settings-keyfile(5)
* nmcli(1)

Interface renaming
==================

Connection profiles stored in ifcfg-rh format support the renaming of
interfaces via udev. This is done via a helper tool
/usr/lib/udev/rename_device that is invoked by udev to parse the files
in /etc/sysconfig/network-scripts; when the HWADDR and DEVICE
variables are set, the interface that matches the MAC address in
HWADDR is renamed to the name specified in DEVICE.

Connections in keyfile format don't provide the same integration with
udev. The renaming of interfaces must be configured directly in udev,
for example by creating a file:

  /etc/systemd/network/70-rename.link

with content:

  [Match]
  MACAddress=00:11:22:33:44:56

  [Link]
  Name=ethernet1

Alternatively, a udev rule can also be used, such as:

  /etc/udev/rules.d/70-interface-names.rules

with content:

  SUBSYSTEM=="net",ACTION=="add",ATTR{address}=="00:11:22:33:44:56",ATTR{type}=="1",NAME="ethernet1"
