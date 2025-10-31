Name:           steamdeck-gnome-presets
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Portions of steamdeck-kde-presets reconfigured for use in GNOME
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite

Source0:        steamos-add-to-steam
Source1:        steamos-add-to-steam.py

BuildArch:      noarch
BuildRequires:  coreutils

Requires:       steamdeck-backgrounds
Requires:       dbus-x11
Requires:       xorg-x11-server-Xephyr
Requires:       nautilus-python

Conflicts:      steamdeck-kde-presets
Conflicts:      steamdeck-kde-presets-desktop

# Disable automatic debuginfo subpackage
%global debug_package %{nil}

%description
This package provides GNOME desktop presets and integration for the Steam Deck,
adapted from the steamdeck-kde-presets package. It includes utilities and
Nautilus extensions for adding SteamOS-style behavior to GNOME.

%prep
# Nothing to prep

%install
install -Dpm0755 %{SOURCE0} %{buildroot}%{_bindir}/steamos-add-to-steam
install -Dpm0644 %{SOURCE1} %{buildroot}%{_datadir}/nautilus-python/extensions/steamos-add-to-steam.py

%files
%{_bindir}/steamos-add-to-steam
%{_datadir}/nautilus-python/extensions/steamos-add-to-steam.py

%changelog
{{{ git_dir_changelog }}}
