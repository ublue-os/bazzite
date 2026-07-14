%global majmin_ver 1.0.0

Name:           gnome-search-yafti
Version:        %{majmin_ver}
Release:        1%{?dist}
Summary:        GNOME Shell Search Provider for Bazzite Portal

License:        GPLv3
URL:            https://github.com/ykshek/gnome-search-yafti
Source0:        %{url}/archive/refs/tags/v%{version}.tar.gz

BuildArch:      noarch

# Runtime dependencies required by the Python script
Requires:       python3
Requires:       python3-gobject
Requires:       python3-pydbus
Requires:       python3-pyyaml

%description
A GNOME Shell Search Provider that integrates Yafti (Bazzite Portal) actions
directly into the GNOME Shell overview.

%prep
%autosetup

%build

%install
# Create destination directories in the buildroot
install -d -m 0755 %{buildroot}%{_libexecdir}
install -d -m 0755 %{buildroot}%{_datadir}/dbus-1/services
install -d -m 0755 %{buildroot}%{_datadir}/gnome-shell/search-providers

# Install the Python executable
install -p -m 0755 src/yafti-search-provider.py %{buildroot}%{_libexecdir}/yafti-search-provider.py

# Install the D-Bus and GNOME Search Provider
install -p -m 0644 src/io.github.ublue_os.yafti.SearchProvider.service %{buildroot}%{_datadir}/dbus-1/services/
install -p -m 0644 src/io.github.ublue_os.yafti.search-provider.ini %{buildroot}%{_datadir}/gnome-shell/search-providers/

%files
%{_libexecdir}/yafti-search-provider.py
%{_datadir}/dbus-1/services/io.github.ublue_os.yafti.SearchProvider.service
%{_datadir}/gnome-shell/search-providers/io.github.ublue_os.yafti.search-provider.ini

%changelog
* Tue Jul 14 2026 Alex Shek <hms.starryfish@gmail.com> - 1.0.0-1
- Bump version to release as 1.0.0

* Tue Jul 14 2026 Alex Shek <hms.starryfish@gmail.com> - 0.0.3-1
- Reference main yafti_gtk desktop entry instead of providing one.

* Fri Jul 10 2026 Alex Shek <hms.starryfish@gmail.com> - 0.0.2-1
- Fix the dbus ini.

* Fri Jul 10 2026 Alex Shek <hms.starryfish@gmail.com> - 0.0.1-1
- Initial package for GNOME Shell Search Provider
