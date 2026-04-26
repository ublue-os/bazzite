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
BuildRequires: systemd-devel

Requires:      ncurses
Requires:      systemd-udev

%description
An open-source device driver for Nintendo Wii / Wii U remotes.

%prep
%autosetup -p1 -n %{name}-%{version}

%build
%cmake -DCMAKE_INSTALL_PREFIX=/usr -B . .
%make_build

%install
mkdir -p %{buildroot}%{_libdir}
mkdir -p %{buildroot}%{_includedir}
mkdir -p %{buildroot}%{_datadir}/pkgconfig
install -D -m 755 lib%{name}.so.3.0.1 %{buildroot}%{_libdir}/lib%{name}.so.3.0.1
install -D -m 755 lib%{name}.so.3 %{buildroot}%{_libdir}/lib%{name}.so.3
install -D -m 755 lib%{name}.so %{buildroot}%{_libdir}/lib%{name}.so
install -D -m 755 lib/%{name}.h %{buildroot}%{_includedir}/%{name}.h
install -D -m 755 lib%{name}.pc %{buildroot}%{_datadir}/pkgconfig/lib%{name}.pc

%files
%license LICENSE
%{_libdir}/lib%{name}.so.3.0.1
%{_libdir}/lib%{name}.so.3
%{_libdir}/lib%{name}.so
%{_includedir}/%{name}.h
%{_datadir}/pkgconfig/lib%{name}.pc

%changelog
%autochangelog
