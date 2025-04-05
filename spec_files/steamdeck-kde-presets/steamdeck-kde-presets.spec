%define packagename steamdeck-kde-presets
%define packagever 0.23
%global _default_patch_fuzz 2

Name:           steamdeck-kde-presets
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        KDE Presets from Valve's SteamOS 3.0
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite

Source0:        https://gitlab.com/evlaV/%{packagename}/-/archive/%{packagever}/%{packagename}-%{packagever}.tar.gz
Source1:        steamdeck-le.svg
Source2:        bazzite_logo.svgz
Source3:        metadata_vapor.json
Source4:        metadata_vgui2.json
Source5:        plasmarc
BuildArch:      noarch
Patch0:         fedora.patch
Patch1:         nested-desktop-resolution.patch
Patch2:         kdeglobals.patch
Patch3:         bazzite_logo.patch
Patch4:         ublue.patch
Patch5:         wayland-remove-env.patch
Patch6:         splash.patch

Requires:       kde-filesystem

Conflicts:      steamdeck-kde-presets-desktop
Conflicts:      steamdeck-backgrounds
Conflicts:      steameck-gnome-presets

%description
KDE Presets from Valve's SteamOS 3.0

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -p1 -n %{packagename}-%{packagever}

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
mv %{buildroot}%{_datadir}/icons/hicolor/scalable/places/distributor-logo-steamdeck.svg %{buildroot}%{_datadir}/icons/hicolor/scalable/places/steamdeck.svg
cp %{SOURCE1} %{buildroot}%{_datadir}/icons/hicolor/scalable/places/steamdeck-le.svg
cp %{SOURCE5} %{buildroot}%{_datadir}/plasma/desktoptheme/Vapor/plasmarc
# Remove unneeded files
rm %{buildroot}%{_sysconfdir}/sddm.conf.d/steamdeck.conf
rm %{buildroot}%{_datadir}/icons/hicolor/scalable/places/distributor-logo.svg
rm %{buildroot}%{_sysconfdir}/xdg/autostart/steam.desktop
rm %{buildroot}%{_datadir}/applications/org.mozilla.firefox.desktop
rm %{buildroot}%{_sysconfdir}/profile.d/kde.sh
rm %{buildroot}%{_sysconfdir}/xdg/kcm-about-distrorc
rm %{buildroot}%{_sysconfdir}/X11/Xsession.d/50rotate-screen
rm %{buildroot}%{_datadir}/plasma/look-and-feel/com.valve.vapor.desktop/contents/splash/images/deck_logo.svgz
rm %{buildroot}%{_datadir}/plasma/look-and-feel/com.valve.vgui.desktop/contents/splash/images/deck_logo.svgz
rm %{buildroot}%{_sysconfdir}/xdg/autostart/jupiter-plasma-bootstrap.desktop
rm %{buildroot}%{_bindir}/jupiter-plasma-bootstrap
cp %{SOURCE2} %{buildroot}%{_datadir}/plasma/look-and-feel/com.valve.vapor.desktop/contents/splash/images/bazzite_logo.svgz
cp %{SOURCE2} %{buildroot}%{_datadir}/plasma/look-and-feel/com.valve.vgui.desktop/contents/splash/images/bazzite_logo.svgz
cp %{SOURCE3} %{buildroot}%{_datadir}/plasma/look-and-feel/com.valve.vapor.desktop/metadata.json
cp %{SOURCE4} %{buildroot}%{_datadir}/plasma/look-and-feel/com.valve.vgui.desktop/metadata.json
mkdir -p %{buildroot}%{_datadir}/kio/servicemenus
mv %{buildroot}%{_datadir}/kservices5/ServiceMenus/steam.desktop %{buildroot}%{_datadir}/kio/servicemenus/steam.desktop
rm -rf %{buildroot}%{_datadir}/kservices5

# Do post-installation
%post

# Do before uninstallation
%preun

# Do after uninstallation
%postun

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%{_datadir}/color-schemes/Vapor.colors
%{_datadir}/color-schemes/VGUI.colors
%{_sysconfdir}/skel/Desktop/Return.desktop
%{_sysconfdir}/xdg/autostart/ibus.desktop
%{_sysconfdir}/xdg/gtk-2.0/gtkrc
%{_sysconfdir}/xdg/gtk-3.0/settings.ini
%{_sysconfdir}/xdg/baloofilerc
%{_sysconfdir}/xdg/kcminputrc
%{_sysconfdir}/xdg/kdeglobals
%{_sysconfdir}/xdg/kscreenlockerrc
%{_sysconfdir}/xdg/ktrashrc
%{_sysconfdir}/xdg/kwinrc
%{_sysconfdir}/xdg/kwinrulesrc
%{_sysconfdir}/xdg/plasma-nm
%{_sysconfdir}/xdg/plasma-workspace/env/ibus.sh
%{_sysconfdir}/xdg/powermanagementprofilesrc
%{_bindir}/steamos-add-to-steam
%{_bindir}/steamos-nested-desktop
%{_prefix}/lib/udev/rules.d/99-kwin-ignore-tablet-mode.rules
%{_datadir}/applications/steam/steamos-nested-desktop
%{_datadir}/X11/xorg.conf.d/99-pointer.conf
%{_datadir}/icons/*
%{_datadir}/konsole/*
%{_datadir}/kio/servicemenus/steam.desktop
%{_datadir}/plasma/avatars/*
%{_datadir}/plasma/desktoptheme/*
%{_datadir}/plasma/kickeractions/steam.desktop
%{_datadir}/plasma/look-and-feel/com.valve.vapor.desktop/*
%{_datadir}/plasma/look-and-feel/com.valve.vgui.desktop/*
%{_datadir}/themes/*
%{_datadir}/wallpapers/*

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}