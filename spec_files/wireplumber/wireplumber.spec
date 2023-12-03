Name:       wireplumber
Version:    0.4.16
Release:    1%{?dist}.bazzite.{{{ git_dir_version }}}
Summary:    A modular session/policy manager for PipeWire

License:    MIT
URL:        https://pipewire.pages.freedesktop.org/wireplumber/
Source0:    https://gitlab.freedesktop.org/pipewire/%{name}/-/archive/%{version}/%{name}-%{version}.tar.bz2

## upstream patches
Patch0:     steamdeck.patch

## upstreamable patches

## fedora patches

BuildRequires:  gettext
BuildRequires:  meson gcc pkgconfig
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(gobject-2.0)
BuildRequires:  pkgconfig(gmodule-2.0)
BuildRequires:  pkgconfig(gio-unix-2.0)
BuildRequires:  pkgconfig(libspa-0.2) >= 0.2
BuildRequires:  pkgconfig(libpipewire-0.3) >= 0.3.26
BuildRequires:  pkgconfig(systemd)
BuildRequires:  systemd-devel >= 184
BuildRequires:  pkgconfig(lua)
BuildRequires:  gobject-introspection-devel
BuildRequires:  python3-lxml doxygen
BuildRequires:  systemd-rpm-macros
%{?systemd_ordering}

# Make sure that we have -libs package in the same version
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

Provides:       pipewire-session-manager
Conflicts:      pipewire-session-manager

%package        libs
Summary:        Libraries for WirePlumber clients
Recommends:     %{name}%{?_isa} = %{version}-%{release}

%description libs
This package contains the runtime libraries for any application that wishes
to interface with WirePlumber.

%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%description
WirePlumber is a modular session/policy manager for PipeWire and a
GObject-based high-level library that wraps PipeWire's API, providing
convenience for writing the daemon's modules as well as external tools for
managing PipeWire.

%prep
%autosetup -p1

%build
%meson -Dsystem-lua=true \
       -Ddoc=disabled \
       -Dsystemd=enabled \
       -Dsystemd-user-service=true \
       -Dintrospection=enabled \
       -Delogind=disabled
%meson_build

%install
%meson_install

# Create local config skeleton
mkdir -p %{buildroot}%{_sysconfdir}/wireplumber/{bluetooth.lua.d,common,main.lua.d,policy.lua.d}

%find_lang %{name}

%posttrans
%systemd_user_post %{name}.service

%preun
%systemd_user_preun %{name}.service

%triggerun -- fedora-release < 35
# When upgrading to Fedora Linux 35, transition to WirePlumber by default
if [ -x "/bin/systemctl" ]; then
    /bin/systemctl --no-reload preset --global %{name}.service || :
fi

%files
%license LICENSE
%{_bindir}/wireplumber
%{_bindir}/wpctl
%{_bindir}/wpexec
%dir %{_sysconfdir}/wireplumber
%dir %{_sysconfdir}/wireplumber/bluetooth.lua.d
%dir %{_sysconfdir}/wireplumber/common
%dir %{_sysconfdir}/wireplumber/main.lua.d
%dir %{_sysconfdir}/wireplumber/policy.lua.d
%{_datadir}/wireplumber/
%{_datadir}/zsh/site-functions/_wpctl
%{_userunitdir}/wireplumber.service
%{_userunitdir}/wireplumber@.service

%files libs -f %{name}.lang
%license LICENSE
%dir %{_libdir}/wireplumber-0.4/
%{_libdir}/wireplumber-0.4/libwireplumber-*.so
%{_libdir}/libwireplumber-0.4.so.*
%{_libdir}/girepository-1.0/Wp-0.4.typelib

%files devel
%{_includedir}/wireplumber-0.4/
%{_libdir}/libwireplumber-0.4.so
%{_libdir}/pkgconfig/wireplumber-0.4.pc
%{_datadir}/gir-1.0/Wp-0.4.gir

%changelog
* Thu Nov 23 2023 Wim Taymans <wtaymans@redhat.com> - 0.4.16-1
- wireplumber 0.4.16

* Tue Nov 7 2023 Hector Martin <marcan@fedoraproject.org> - 0.4.15-2
- Add upstream patch to enable node hiding

* Thu Oct 12 2023 Wim Taymans <wtaymans@redhat.com> - 0.4.15-1
- wireplumber 0.4.15

* Fri Sep 08 2023 Peter Hutterer <peter.hutterer@redhat.com>
- SPDX migration: mark as done

* Sat Jul 22 2023 Fedora Release Engineering <releng@fedoraproject.org> - 0.4.14-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Thu Mar 9 2023 Wim Taymans <wim.taymans@redhat.com> - 0.4.14-1
- wireplumber 0.4.14

* Sat Jan 21 2023 Fedora Release Engineering <releng@fedoraproject.org> - 0.4.13-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Tue Dec 13 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.13-1
- wireplumber 0.4.13

* Fri Oct 07 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.12-1
- wireplumber 0.4.12

* Thu Aug 04 2022 Ville-Pekka Vainio <vpvainio@iki.fi> - 0.4.11-4
- Add two patches to fix a rescan loop with Bluetooth

* Sat Jul 23 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.4.11-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Wed Jul 13 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.11-2
- Add patch to avoid crashes in VM
- Add patch to avoid dbus crash
- Resolves: rhbz#2104986

* Tue Jul 5 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.11-1
- wireplumber 0.4.11

* Tue May 10 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.10-1
- wireplumber 0.4.10

* Tue Mar 22 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.9-1
- wireplumber 0.4.9

* Wed Mar 16 2022 Frantisek Zatloukal <fzatlouk@redhat.com> - 0.4.8-3
- Backport e429db7e8c266045aee25e153fb2308bd61fe233 to fix sound on aarch64

* Mon Mar 7 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.8-2
- Add patch to fix openal and WINE format negotiation.

* Mon Feb 7 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.8-1
- wireplumber 0.4.8

* Sat Jan 22 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.4.7-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Fri Jan 14 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.7-2
- Add patch to fix default device.

* Thu Jan 13 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.7-1
- wireplumber 0.4.7

* Fri Jan 07 2022 Wim Taymans <wim.taymans@redhat.com> - 0.4.6-1
- wireplumber 0.4.6

* Fri Nov 19 2021 Wim Taymans <wim.taymans@redhat.com> - 0.4.5-3
- Add some upstream patches for OBS audio output capture and
  device switching.

* Wed Nov 17 2021 Peter Hutterer <peter.hutterer@redhat.com> - 0.4.5-2
- Move the systemd scriptlet to posttrans so we can dnf swap with
  media-session (#2022584)

* Thu Nov 11 2021 Wim Taymans <wim.taymans@redhat.com> - 0.4.5-1
- wireplumber 0.4.5

* Tue Nov 02 2021 Neal Gompa <ngompa@fedoraproject.org> - 0.4.4-3
- Try again for WirePlumber preset upgrades to F35+ (#2016253)

* Sun Oct 24 2021 Neal Gompa <ngompa@fedoraproject.org> - 0.4.4-2
- Ensure WirePlumber activates on upgrade to F35+ (#2016253)

* Fri Oct 15 2021 Wim Taymans <wim.taymans@redhat.com> - 0.4.4-1
- wireplumber 0.4.4

* Wed Oct 13 2021 Neal Gompa <ngompa@fedoraproject.org> - 0.4.3-3
- Fix config setup in file list (#2013861)

* Mon Oct 11 2021 Peter Hutterer <peter.hutterer@redhat.com> - 0.4.3-2
- Fix segfault due to a typo (#2012606)

* Fri Oct 08 2021 Wim Taymans <wim.taymans@redhat.com> - 0.4.3-1
- wireplumber 0.4.3

* Wed Sep 01 2021 Peter Hutterer <peter.hutterer@redhat.com> - 0.4.2-1
- wireplumber 0.4.2

* Fri Jul 23 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.4.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Tue Jul 06 2021 Peter Hutterer <peter.hutterer@redhat.com> 0.4.1-1
- Initial package (#1976012)
