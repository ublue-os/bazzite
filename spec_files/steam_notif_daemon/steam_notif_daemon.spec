Name:           steam_notif_daemon
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Simple XDG D-Bus Notification wrapper
License:        MIT
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/%{name}/-/archive/steam/%{name}-steam.tar.gz

Requires:       curl
Requires:       systemd-libs

BuildRequires:  systemd-rpm-macros
BuildRequires:  gcc
BuildRequires:  meson >= 0.54.0
BuildRequires:  ninja-build
BuildRequires:  pkgconfig(libsystemd)
BuildRequires:  pkgconfig(libcurl)

%description
Simple XDG D-Bus Notification wrapper

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n %{name}-steam

%build
%meson -Dsd-bus-provider=libsystemd
%meson_build

%install
%meson_install

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%license LICENSE
%{_bindir}/%{name}

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
