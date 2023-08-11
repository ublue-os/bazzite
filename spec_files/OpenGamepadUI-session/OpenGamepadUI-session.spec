Name:           OpenGamepadUI-session
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Gamescope session for OpenGamepadUI

URL:            https://github.com/ublue-os/bazzite

License:        GPL-3.0-only
Source:        	https://github.com/ShadowBlip/OpenGamepadUI-session/archive/refs/heads/main.tar.gz
BuildArch:      noarch

Requires:       OpenGamepadUI
Requires:       gamescope
Requires:       python3

BuildRequires:  systemd-rpm-macros

%description
Gamescope session for OpenGamepadUI

%prep
%autosetup -n %{name}-main

%install
mkdir -p %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_datadir}/
mkdir -p %{buildroot}%{_userunitdir}/
cp -rv usr/bin/* %{buildroot}%{_bindir}
cp -rv usr/share/* %{buildroot}%{_datadir}
cp -v usr/lib/systemd/user/* %{buildroot}%{_userunitdir}

%files
%doc README.md
%{_bindir}/gamepadui-with-qam-session
%{_bindir}/opengamepadui-session
%{_bindir}/opengamepadui-session-select
%{_userunitdir}/gamepadui-with-qam-session.service
%{_userunitdir}/opengamepadui-session.service
%{_datadir}/opengamepadui-session/device-quirks
%{_datadir}/opengamepadui-session/gamepadui-with-qam-session
%{_datadir}/opengamepadui-session/gamescope-session-script
%{_datadir}/polkit-1/actions/org.shadowblip.opengamepadui-session.policy
%{_datadir}/wayland-sessions/gamepadui-with-qam-session.desktop
%{_datadir}/wayland-sessions/opengamepadui-session.desktop

%changelog
{{{ git_dir_changelog }}}
