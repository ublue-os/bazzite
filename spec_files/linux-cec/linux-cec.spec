# Upstream has no release tarballs, build from a pinned commit
%global commit          218fd8194fbf2641b1646ed44d69ef76eb6c57fd
%global shortcommit     %(c=%{commit}; echo ${c:0:7})
%global commitdate      20260515

Name:           linux-cec
Version:        0.2.1
Release:        1.%{commitdate}git%{shortcommit}%{?dist}
Summary:        Consumer Electronics Control (CEC) daemon and tools for Linux
License:        LGPL-2.1-or-later
URL:            https://gitlab.steamos.cloud/holo/linux-cec
Source0:        %{url}/-/archive/%{commit}/%{name}-%{commit}.tar.gz

BuildRequires:  cargo
BuildRequires:  rust
BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  pkgconf-pkg-config
BuildRequires:  pkgconfig(dbus-1)
BuildRequires:  pkgconfig(libsystemd)
BuildRequires:  pkgconfig(libudev)
BuildRequires:  systemd-rpm-macros

Requires:       dbus-common
Requires:       systemd-udev

%description
linux-cec is a collection of Rust crates for interfacing with Linux's
Consumer Electronics Control userspace subsystem, providing cecd, a daemon
that exposes high level control for CEC over D-Bus and optionally exposes an
input device for the remote control via uinput, along with the cectool
command line utility.

# Upstream's release profile strips symbols, so there is nothing to extract
%global debug_package %{nil}

%prep
%autosetup -n %{name}-%{commit}

%build
# Note: cargo fetches crates from crates.io, this requires network access
%make_build

%install
%make_install \
    PREFIX=%{_prefix} \
    BINDIR=%{_bindir} \
    UDEV_RULES_DIR=%{_udevrulesdir} \
    SYSTEMD_USER_UNIT_DIR=%{_userunitdir} \
    DBUS_INTERFACES_DIR=%{_datadir}/dbus-1/interfaces \
    DBUS_SESSION_BUS_SERVICES_DIR=%{_datadir}/dbus-1/services

# Do post-installation
%post
%systemd_user_post cecd.service

# Do before uninstallation
%preun
%systemd_user_preun cecd.service

# Do after uninstallation
%postun
%systemd_user_postun_with_restart cecd.service

%files
%license cecd/LICENSE
%doc README.md
%{_bindir}/cecd
%{_bindir}/cectool
%{_udevrulesdir}/60-cec-uaccess.rules
%{_udevrulesdir}/60-cecd-uinput.rules
%{_userunitdir}/cecd.service
%{_datadir}/dbus-1/services/com.steampowered.CecDaemon1.service
%{_datadir}/dbus-1/interfaces/com.steampowered.CecDaemon1.CecDevice1.xml
%{_datadir}/dbus-1/interfaces/com.steampowered.CecDaemon1.Config1.xml
%{_datadir}/dbus-1/interfaces/com.steampowered.CecDaemon1.Daemon1.xml
%{_datadir}/dbus-1/interfaces/com.steampowered.CecDaemon1.MessageHandler1.xml

%changelog
%autochangelog
