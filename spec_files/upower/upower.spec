%global _default_patch_fuzz 2

Summary:        Power Management Service
Name:           upower
Version:        1.90.9
Release:        1000.bazzite.{{{ git_dir_version }}}
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

%package tests
Summary: Test files for Upower
Requires: %{name}%{?_isa} = %{version}-%{release}

%description tests
Test files for Upower

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

mkdir -p $RPM_BUILD_ROOT%{_libexecdir}/installed-tests
mv $RPM_BUILD_ROOT%{_libexecdir}/upower $RPM_BUILD_ROOT%{_libexecdir}/installed-tests

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
%doc NEWS AUTHORS HACKING.md README.md
%{_datadir}/dbus-1/system.d/*.conf
%{_udevrulesdir}/*.rules
%{_udevhwdbdir}/*.hwdb
%ghost %dir %{_localstatedir}/lib/upower
%dir %{_sysconfdir}/UPower
%config %{_sysconfdir}/UPower/UPower.conf
%{_bindir}/*
%{_libexecdir}/upowerd
%{_mandir}/man1/*
%{_mandir}/man7/*
%{_mandir}/man8/*
%{_datadir}/dbus-1/system-services/*.service
%{_unitdir}/*.service
%{_datadir}/polkit-1/actions/org.freedesktop.upower.policy
%{_datadir}/zsh/*

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

%files tests
%{_libexecdir}/installed-tests/upower
%{_datadir}/installed-tests/upower/upower-integration.test

%changelog
%autochangelog
