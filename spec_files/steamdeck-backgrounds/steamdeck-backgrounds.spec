Name:           steamdeck-backgrounds
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Backgrounds from Valve's SteamOS 3.0
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite

Source:         {{{ git_dir_pack }}}
Source1:        https://gitlab.com/evlaV/steamdeck-kde-presets/-/archive/master/steamdeck-kde-presets-master.tar.gz?path=usr/share/wallpapers

BuildArch:      noarch

Conflicts:      steamdeck-kde-presets
Conflicts:      steamdeck-kde-presets-desktop

%description
Backgrounds from Valve's SteamOS 3.0

# Disable debug packages
%define debug_package %{nil}

%prep
{{{ git_dir_setup_macro }}}
gzip -dc %{SOURCE1} | tar -xvvf -

%build

%install
mkdir -p %{buildroot}%{_datadir}/backgrounds/steamdeck
mkdir -p %{buildroot}%{_datadir}/gnome-background-properties
cp -rv steamdeck-kde-presets-master-usr-share-wallpapers/usr/share/wallpapers/*.jpg %{buildroot}%{_datadir}/backgrounds/steamdeck
cp -rv *.xml %{buildroot}%{_datadir}/gnome-background-properties

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
%{_datadir}/gnome-background-properties/*

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
