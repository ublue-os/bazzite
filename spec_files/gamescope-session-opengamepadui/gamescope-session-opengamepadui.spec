Name:           gamescope-session-opengamepadui
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Gamescope session for OpenGamepadUI

URL:            https://github.com/ublue-os/bazzite

License:        GPLv3
Source:        	https://github.com/ShadowBlip/OpenGamepadUI-session/archive/refs/heads/main.tar.gz
Patch0:         session-select.patch
BuildArch:      noarch

Requires:       gamescope-session-plus

BuildRequires:  systemd-rpm-macros

%description
Gamescope session for OpenGamepadUI

%prep
%autosetup -p1 -n %{name}-main

%install
mkdir -p %{buildroot}%{_datadir}/
cp -rv usr/share/* %{buildroot}%{_datadir}

%files
%doc README.md
%{_datadir}/gamescope-session-plus/sessions.d/opengamepadui
%{_datadir}/polkit-1/actions/org.shadowblip.opengamepadui-session.policy
%{_datadir}/wayland-sessions/gamescope-session-opengamepadui.desktop

%changelog
{{{ git_dir_changelog }}}
