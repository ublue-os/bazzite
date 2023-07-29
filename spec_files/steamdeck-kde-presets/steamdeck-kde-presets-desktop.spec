Name:           steamdeck-kde-presets-desktop
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        KDE Presets from Valve's SteamOS 3.0 for desktops
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/steamdeck-kde-presets/-/archive/master/steamdeck-kde-presets-master.tar.gz
Patch0:         multiuser.patch
Patch1:         lockscreen.patch

BuildArch:      noarch

Requires:       kde-filesystem

Conflicts:      steamdeck-kde-presets

%description
KDE Presets from Valve's SteamOS 3.0 for desktops

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -p1 -n steamdeck-kde-presets-master

%build

%install
mkdir -p %{buildroot}%{_datadir}/
mkdir -p %{buildroot}%{_sysconfdir}/
cp -rv usr/share/* %{buildroot}%{_datadir}
cp -rv etc/* %{buildroot}%{_sysconfdir}
mv %{buildroot}%{_sysconfdir}/skel %{buildroot}%{_sysconfdir}/skel.d
# Remove unneeded files
rm %{buildroot}%{_datadir}/applications/org.mozilla.firefox.desktop
rm %{buildroot}%{_datadir}/kservices5/ServiceMenus/steam.desktop
rm %{buildroot}%{_datadir}/X11/xorg.conf.d/99-pointer.conf
rm %{buildroot}%{_sysconfdir}/profile.d/kde.sh
rm %{buildroot}%{_sysconfdir}/sddm.conf.d/steamdeck.conf
rm %{buildroot}%{_sysconfdir}/skel.d/Desktop/Return.desktop
rm %{buildroot}%{_sysconfdir}/X11/Xsession.d/50rotate-screen
rm %{buildroot}%{_sysconfdir}/xdg/autostart/ibus.desktop
rm %{buildroot}%{_sysconfdir}/xdg/autostart/jupiter-plasma-bootstrap.desktop
rm %{buildroot}%{_sysconfdir}/xdg/autostart/steam.desktop
rm %{buildroot}%{_sysconfdir}/xdg/kcminputrc
rm %{buildroot}%{_sysconfdir}/xdg/kwinrc
rm %{buildroot}%{_sysconfdir}/xdg/kwinrulesrc
rm %{buildroot}%{_sysconfdir}/xdg/plasma-workspace/env/ibus.sh
rm %{buildroot}%{_sysconfdir}/xdg/powermanagementprofilesrc

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
%{_datadir}/icons/*
%{_datadir}/konsole/*
%{_datadir}/plasma/avatars/*
%{_datadir}/plasma/desktoptheme/*
%{_datadir}/plasma/kickeractions/steam.desktop
%{_datadir}/plasma/look-and-feel/com.valve.vapor.desktop/*
%{_datadir}/plasma/look-and-feel/com.valve.vgui.desktop/*
%{_datadir}/themes/*
%{_datadir}/wallpapers/*
%{_sysconfdir}/xdg/gtk-2.0/gtkrc
%{_sysconfdir}/xdg/gtk-3.0/settings.ini
%{_sysconfdir}/xdg/baloofilerc
%{_sysconfdir}/xdg/kdeglobals
%{_sysconfdir}/xdg/kscreenlockerrc
%{_sysconfdir}/xdg/ktrashrc
%{_sysconfdir}/xdg/plasma-nm

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
