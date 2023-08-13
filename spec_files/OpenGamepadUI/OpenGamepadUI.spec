Name:           OpenGamepadUI
Version:        0.19.7
Release:        1%{?dist}
Summary:        A free and open source game launcher and overlay written using the Godot Game Engine 4 designed with a gamepad native experience in mind
License:        GPL-3.0-only
URL:            https://github.com/ShadowBlip/OpenGamepadUI

Source:         https://github.com/ShadowBlip/OpenGamepadUI/releases/download/v%{version}/opengamepadui.tar.gz
BuildArch:      x86_64

Patch0:         fedora.patch

Requires:       gamescope
Requires:       python3

BuildRequires:  make
BuildRequires:  systemd-rpm-macros

%description
A free and open source game launcher and overlay written using the Godot Game Engine 4 designed with a gamepad native experience in mind

%define debug_package %{nil}
%define _build_id_links none

%prep
%autosetup -p1 -n opengamepadui

%install
make install PREFIX=%{buildroot}%{_prefix} INSTALL_PREFIX=%{_prefix}

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
