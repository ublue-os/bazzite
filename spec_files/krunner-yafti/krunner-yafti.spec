%global majmin_ver 1.0.3

Name:           krunner-yafti
Version:        %{majmin_ver}
Release:        1%{?dist}
Summary:        KDE KRunner plugin for Bazzite Portal Actions via Yafti

License:        Apache-2.0
URL:            https://github.com/ykshek/krunner-yafti
Source0:        %{url}/archive/refs/tags/v%{version}.tar.gz

BuildRequires:  cmake
BuildRequires:  gcc-c++
BuildRequires:  extra-cmake-modules
BuildRequires:  kf6-kconfig-devel
BuildRequires:  kf6-krunner-devel
BuildRequires:  kf6-ki18n-devel
BuildRequires:  kf6-kcoreaddons-devel
BuildRequires:  qt6-qtbase-devel
BuildRequires:  kf6-rpm-macros
BuildRequires:  gettext
BuildRequires:  yaml-cpp-devel

Requires:       kf6-krunner
Requires:       qt6-qtbase
Requires:       yaml-cpp

%description
A KDE KRunner plugin that integrates with Yafti (Bazzite Portal).
This plugin reads configurations from /usr/share/yafti/yafti.yml and allows users
to search for portal actions directly from KRunner, launching them
via the yafti_gtk.py script.

%prep
%autosetup

%build
%cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=%{_prefix}
%cmake_build

%install
%cmake_install

%check
# Basic smoke test - check if the plugin file was created
test -f %{buildroot}%{_kf6_plugindir}/krunner/krunner-yafti.so

%files
%license LICENSE
%doc README.md
%{_kf6_plugindir}/krunner/krunner-yafti.so

%changelog
* Sun Jun 21 2026 Alex Shek <hms.starryfish@gmail.com> - 1.0.3-1
- Update for 1.0.3.

* Sun Jun 21 2026 Alex Shek <hms.starryfish@gmail.com> - 1.0.2-1
- Update for 1.0.2.

* Sun Jun 21 2026 Alex Shek <hms.starryfish@gmail.com> - 1.0.1-1
- Update for 1.0.1.

* Wed Jun 17 2026 Alex Shek <hms.starryfish@gmail.com> - 1.0.0-1
- Initial RPM package for krunner-yafti.
