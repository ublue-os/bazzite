Name:           steamdeck-gnome-presets
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Portions of steamdeck-kde-presets reconfigured for use in GNOME
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/%{name}/-/archive/master/%{name}-master.tar.gz
BuildArch:      noarch
Patch0:         fedora.patch

Requires:       steamdeck-backgrounds
Requires:       zenity

Conflicts:      steamdeck-kde-presets
Conflicts:      steamdeck-kde-presets-desktop

%description
Portions of steamdeck-kde-presets reconfigured for use in GNOME

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -p1 -n %{name}-master

%build

%install
mkdir -p %{buildroot}%{_datadir}/
mkdir -p %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_prefix}/lib/
mkdir -p %{buildroot}%{_sysconfdir}/
cp -rv usr/share/* %{buildroot}%{_datadir}
cp -rv usr/bin/* %{buildroot}%{_bindir}
cp -rv usr/lib/* %{buildroot}%{_prefix}/lib
cp -rv etc/* %{buildroot}%{_sysconfdir}
mv %{buildroot}%{_sysconfdir}/skel %{buildroot}%{_sysconfdir}/skel.d
mv %{buildroot}%{_datadir}/icons/hicolor/scalable/places/distributor-logo-steamdeck.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/places/steamdeck.svg
# Remove unneeded files
rm %{buildroot}%{_datadir}/icons/hicolor/scalable/places/distributor-logo.svg
rm %{buildroot}%{_sysconfdir}/xdg/autostart/steam.desktop
rm %{buildroot}%{_datadir}/applications/org.mozilla.firefox.desktop
rm %{buildroot}%{_sysconfdir}/profile.d/kde.sh
rm %{buildroot}%{_sysconfdir}/xdg/kcm-about-distrorc
rm %{buildroot}%{_sysconfdir}/X11/Xsession.d/50rotate-screen

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%{_bindir}/steamos-add-to-steam
%{_bindir}/steamos-nested-desktop
%{_datadir}/applications/steam/steamos-nested-desktop

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}