Summary:        Power Management Service
Name:           upower
Version:        1.90.5
Release:        %autorelease.bazzite.{{{ git_dir_version }}}
License:        GPL-2.0-or-later
URL:            http://upower.freedesktop.org/
Source0:        https://gitlab.freedesktop.org/upower/%{name}/-/archive/v%{version}/%{name}-v%{version}.tar.bz2

BuildRequires:  meson
BuildRequires:  git
BuildRequires:  gettext
BuildRequires:  libgudev1-devel
%define idevice disabled
%ifnarch s390 s390x
%if ! 0%{?rhel}
%define idevice enabled
BuildRequires:  libimobiledevice-devel
%endif
%endif
BuildRequires:  glib2-devel >= 2.6.0
BuildRequires:  gobject-introspection-devel
BuildRequires:  gtk-doc
BuildRequires:  polkit-devel
BuildRequires:  systemd

Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
Requires:       udev

Patch0:         valve.patch

# https://gitlab.freedesktop.org/upower/upower/-/commit/b26c8c79c9ff7fd0ba63e893171c6d5b164fda82.patch
Patch1001:      0001-ci-Add-polkit-dependency.patch
# https://gitlab.freedesktop.org/upower/upower/-/commit/f55641cd4335997bffd2a662de84c69a45ce9394.patch
Patch1002:      0002-Revert-Remove-polkit-tests.patch
# https://gitlab.freedesktop.org/upower/upower/-/commit/b71996a526a73a18ae5e66ad6ce52c297a458df9.patch
Patch1003:      0003-linux-integration-test-Add-polkit-test.patch
# https://gitlab.freedesktop.org/upower/upower/-/commit/b4697dbc626ced1a456bcb4aba8dca2fe1efa901.patch
Patch10004:     0004-up-polkit-Add-G_ADD_PRIVATE-UpPolkit.patch
# https://gitlab.freedesktop.org/upower/upower/-/commit/7db90b28d842744f135114b3e90e6bded4ac6fbb.patch
Patch10005:     0008-up-polkit-remove-global-variable-and-remove-g_object.patch
# https://gitlab.freedesktop.org/upower/upower/-/commit/131ab3a9d51ca14914a693e18f7f2961efba911e.patch
Patch10006:     0009-up-polkit-Replace-with-G_DEFINE_TYPE_WITH_PRIVATE.patch

%description
UPower (formerly DeviceKit-power) provides a daemon, API and command
line tools for managing power devices attached to the system.

%package libs
Summary: Client libraries for UPower
Requires: gobject-introspection
Recommends: %{name}%{?_isa} = %{version}-%{release}
Conflicts: %{name} < 0.99.20-4

%description libs
Client libraries for UPower.

%package devel
Summary: Headers and libraries for UPower
Requires: %{name}-libs%{?_isa} = %{version}-%{release}

%description devel
Headers and libraries for UPower.

%package devel-docs
Summary: Developer documentation for for libupower-glib
Requires: %{name}-libs = %{version}-%{release}
BuildArch: noarch

%description devel-docs
Developer documentation for for libupower-glib.

%prep
%autosetup -n %{name}-v%{version} -p1 -S git

%build
%meson \
  -Didevice=%{idevice} \
  -Dman=true \
  -Dgtk-doc=true \
  -Dintrospection=enabled

%meson_build

%install
%meson_install

%find_lang upower

%ldconfig_scriptlets

%post
%systemd_post upower.service

%preun
%systemd_preun upower.service

%postun
%systemd_postun_with_restart upower.service

%files -f upower.lang
%{!?_licensedir:%global license %%doc}
%license COPYING
%doc NEWS AUTHORS HACKING README
%{_datadir}/dbus-1/system.d/*.conf
%{_udevrulesdir}/*.rules
%{_udevhwdbdir}/*.hwdb
%ghost %dir %{_localstatedir}/lib/upower
%dir %{_sysconfdir}/UPower
%config %{_sysconfdir}/UPower/UPower.conf
%{_bindir}/*
%{_libexecdir}/*
%{_mandir}/man1/*
%{_mandir}/man7/*
%{_mandir}/man8/*
%{_datadir}/dbus-1/system-services/*.service
%{_unitdir}/*.service
%{_datadir}/installed-tests/upower/upower-integration.test
%{_datadir}/polkit-1/actions/org.freedesktop.upower.policy

%files libs
%license COPYING
%{_libdir}/libupower-glib.so.3{,.*}
%{_libdir}/girepository-1.0/*.typelib

%files devel
%{_datadir}/dbus-1/interfaces/*.xml
%{_libdir}/libupower-glib.so
%{_libdir}/pkgconfig/*.pc
%{_datadir}/gir-1.0/*.gir
%dir %{_includedir}/libupower-glib
%{_includedir}/libupower-glib/up-*.h
%{_includedir}/libupower-glib/upower.h

%files devel-docs
%dir %{_datadir}/gtk-doc
%dir %{_datadir}/gtk-doc/html/UPower
%{_datadir}/gtk-doc/html/UPower/*

%changelog
%autochangelog
