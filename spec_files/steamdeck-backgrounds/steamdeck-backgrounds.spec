Name:           steamdeck-backgrounds
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Backgrounds from Valve's SteamOS 3.0
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/steamdeck-kde-presets/-/archive/master/steamdeck-kde-presets-master.tar.gz

BuildArch:      noarch

Requires:       kde-filesystem

Conflicts:      steamdeck-kde-presets

%description
Backgrounds from Valve's SteamOS 3.0

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n steamdeck-kde-presets-master

%build

%install
mkdir -p %{buildroot}%{_datadir}/backgrounds/steamdeck
cp -rv usr/share/wallpapers/* %{buildroot}%{_datadir}/backgrounds/steamdeck

# Do post-installation
%post

# Do before uninstallation
%preun

# Do after uninstallation
%postun

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%{_datadir}/backgrounds/steamdeck/*

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
