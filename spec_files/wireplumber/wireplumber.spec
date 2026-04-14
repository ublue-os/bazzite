Name:       wireplumber
Version:    0.5.14
Release:    1%{?dist}.bazzite.{{{ git_dir_version }}}
Summary:    A modular session/policy manager for PipeWire

License:    MIT
URL:        https://pipewire.pages.freedesktop.org/wireplumber/
Source0:    https://gitlab.freedesktop.org/pipewire/%{name}/-/archive/%{version}/%{name}-%{version}.tar.bz2

Patch10:        block_steam_clear_default.patch

## upstream patches

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

%package        doc
Summary:        Documentation for %{name}
Recommends:     %{name}%{?_isa} = %{version}-%{release}

%description doc
This package contains the documentation for WirePlumber.

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

# Create missing empty system config dirs for other packages to drop files in
mkdir -p %{buildroot}%{_datadir}/wireplumber/wireplumber.conf.d

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
%{_datadir}/bash-completion/completions/wpctl
%{_userunitdir}/wireplumber.service
%{_userunitdir}/wireplumber@.service

%files libs -f %{name}.lang
%license LICENSE
%dir %{_libdir}/wireplumber-0.5/
%{_libdir}/wireplumber-0.5/libwireplumber-*.so
%{_libdir}/libwireplumber-0.5.so.*
%{_libdir}/girepository-1.0/Wp-0.5.typelib

%files devel
%{_includedir}/wireplumber-0.5/
%{_libdir}/libwireplumber-0.5.so
%{_libdir}/pkgconfig/wireplumber-0.5.pc
%{_datadir}/gir-1.0/Wp-0.5.gir

%files doc
%{_datadir}/doc/wireplumber/

%changelog
%autochangelog
