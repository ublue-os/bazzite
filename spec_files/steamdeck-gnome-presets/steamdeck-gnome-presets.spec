Name:           steamdeck-gnome-presets
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Portions of steamdeck-kde-presets reconfigured for use in GNOME
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite

VCS:            {{{ git_dir_vcs }}}
Source:         {{{ git_dir_pack }}}
BuildArch:      noarch

Requires:       steamdeck-backgrounds
Requires:       dbus-x11
Requires:       xorg-x11-server-Xephyr
Requires:       nautilus-python

Conflicts:      steamdeck-kde-presets
Conflicts:      steamdeck-kde-presets-desktop

%description
Portions of steamdeck-kde-presets reconfigured for use in GNOME

# Disable debug packages
%define debug_package %{nil}

%prep
{{{ git_dir_setup_macro }}}

%install
mkdir -p %{buildroot}%{_datadir}/
mkdir -p %{buildroot}%{_bindir}/
cp -rv usr/share/* %{buildroot}%{_datadir}
cp -rv usr/bin/* %{buildroot}%{_bindir}

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%{_bindir}/steamos-add-to-steam
%{_datadir}/nautilus-python/extensions/steamos-add-to-steam.py

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}