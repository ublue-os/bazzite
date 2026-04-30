Name:          xwiimote-ng
Summary:       An open-source device driver for Nintendo Wii / Wii U remotes.

Version:       3.0.1
Release:       1%{?dist}

License:       XWiimote License
URL:           https://github.com/dev-0x7C6/xwiimote-ng
Source:        %{url}/archive/refs/tags/v%{version}.tar.gz

ExclusiveArch: x86_64

BuildRequires: cmake
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: ninja-build
BuildRequires: systemd-devel

Requires:      ncurses
Requires:      systemd-udev

%description
An open-source device driver for Nintendo Wii / Wii U remotes.

%prep
%autosetup -p1 -n %{name}-%{version}

%build
%cmake
%cmake_build

%install
%cmake_install

%files
%license LICENSE
%{_libdir}/lib%{name}.so.3.0.1
%{_libdir}/lib%{name}.so.3
%{_libdir}/lib%{name}.so
%{_includedir}/%{name}.h
%{_datadir}/pkgconfig/lib%{name}.pc

%changelog
%autochangelog
