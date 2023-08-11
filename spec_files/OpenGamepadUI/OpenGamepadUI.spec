Name:           OpenGamepadUI
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        A free and open source game launcher and overlay written using the Godot Game Engine 4 designed with a gamepad native experience in mind

URL:            https://github.com/ublue-os/bazzite

License:        GPL-3.0-only
Source:         https://github.com/ShadowBlip/OpenGamepadUI/archive/refs/heads/main.tar.gz
BuildArch:	x86_64

BuildRequires:  jq
BuildRequires:  wget
Requires:       gamescope

BuildRequires:  systemd-rpm-macros

%define debug_package %{nil}

%description
A free and open source game launcher and overlay written using the Godot Game Engine 4 designed with a gamepad native experience in mind

%prep
rm -rf main.tar.gz
wget $(curl -s https://api.github.com/repos/ShadowBlip/OpenGamepadUI/releases/latest | jq -r ".assets[] | select(.name | test(\"opengamepadui.tar.gz\")) | .browser_download_url")
tar xvfz opengamepadui.tar.gz --strip-components 1
rm -rf opengamepadui.tar.gz

%install
mkdir -p %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_datadir}/
mkdir -p %{buildroot}%{_userunitdir}/
cp -rv usr/* %{buildroot}/%{_exec_prefix}

%files
%{_bindir}/opengamepadui
%{_datadir}/opengamepadui/*.so
%{_datadir}/opengamepadui/scripts/system_profiler.py
%{_datadir}/opengamepadui/scripts/powertools
%{_datadir}/opengamepadui/scripts/manage_input
%{_datadir}/opengamepadui/opengamepad-ui.x86_64
%{_datadir}/applications/opengamepadui.desktop
%{_datadir}/icons/hicolor/scalable/apps/opengamepadui.svg
%{_datadir}/polkit-1/actions/org.shadowblip.manage_input.policy
%{_datadir}/polkit-1/actions/org.shadowblip.powertools.policy
%{_exec_prefix}/lib/udev/hwdb.d/59-opengamepadui-handheld.hwdb
%{_exec_prefix}/lib//udev/rules.d/61-opengamepadui-handheld.rules
%{_userunitdir}/systemd-sysext-updater.service
%{_userunitdir}/ogui-qam.service

%changelog
