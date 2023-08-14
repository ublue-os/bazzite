Name:           OpenGamepadUI
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        A free and open source game launcher and overlay written using the Godot Game Engine 4 designed with a gamepad native experience in mind
License:        GPL-3.0-only
URL:            https://github.com/ShadowBlip/OpenGamepadUI

Source:         https://github.com/KyleGospo/OpenGamepadUI/archive/refs/heads/main.tar.gz
BuildArch:      x86_64

Requires:       gamescope
Requires:       python3
Requires:       firejail

BuildRequires:  systemd-rpm-macros
BuildRequires:  godot
BuildRequires:  pkgconf
BuildRequires:  gcc
BuildRequires:  libXcursor-devel
BuildRequires:  libXinerama-devel
BuildRequires:  libXi-devel
BuildRequires:  libXrandr-devel
BuildRequires:  mesa-libGLU-devel
BuildRequires:  libglvnd-devel
BuildRequires:  alsa-lib-devel
BuildRequires:  make
BuildRequires:  unzip
BuildRequires:  wget
BuildRequires:  git

%description
A free and open source game launcher and overlay written using the Godot Game Engine 4 designed with a gamepad native experience in mind

%define debug_package %{nil}

%prep
%autosetup -p1 -n %{name}-main

%install
%make_install PREFIX=%{buildroot}%{_prefix} INSTALL_PREFIX=%{_prefix}

%files
%{_bindir}/opengamepadui
%{_datadir}/opengamepadui/*.so
%{_datadir}/opengamepadui/scripts/powertools
%{_datadir}/opengamepadui/opengamepad-ui.x86_64
%{_datadir}/applications/opengamepadui.desktop
%{_datadir}/icons/hicolor/scalable/apps/opengamepadui.svg
%{_datadir}/polkit-1/actions/org.shadowblip.powertools.policy
%{_prefix}/lib/udev/hwdb.d/59-opengamepadui-handheld.hwdb
%{_udevrulesdir}/61-opengamepadui-handheld.rules
%{_userunitdir}/systemd-sysext-updater.service
%{_userunitdir}/ogui-qam.service

%changelog
%autochangelog
