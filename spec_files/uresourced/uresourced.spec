Name:           uresourced
Version:        0.5.5
Release:        %autorelease
Summary:        Dynamically allocate resources to the active user

License:        LGPL-2.1-or-later
URL:            https://github.com/KyleGospo/uresourced-dmemcg
Source0:        %{url}/archive/refs/tags/%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  meson
BuildRequires:  pkgconfig(gio-2.0)
BuildRequires:  pkgconfig(libpipewire-0.3)
BuildRequires:  pkgconfig(libsystemd)
BuildRequires:  pkgconfig(systemd)
BuildRequires:  systemd-rpm-macros

%description
This daemon dynamically assigns a resource allocation to the active
graphical user. If the user has an active graphical session managed
using systemd (e.g. GNOME), then the memory allocation will be used
to protect the sessions core processes (session.slice).

%prep
%autosetup -n %{name}-dmemcg-%{version} -p1

%build
%meson -Dappmanagement=true
%meson_build

%install
%meson_install

%post
%systemd_post uresourced.service
%systemd_user_post uresourced.service

%preun
%systemd_preun uresourced.service
%systemd_user_preun uresourced.service

%postun
%systemd_postun uresourced.service
%systemd_user_postun uresourced.service

%files
%license COPYING
%doc README
%doc NEWS.md
%config(noreplace) %{_sysconfdir}/uresourced.conf
%{_datadir}/dbus-1/system.d/org.freedesktop.UResourced.conf
%{_libexecdir}/uresourced
%{_libexecdir}/cgroupify
%{_unitdir}/*
%{_userunitdir}/*

%changelog
%autochangelog
