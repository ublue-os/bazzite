%global appid io.github.rfrench3.bazzite-updater

Name:           bazzite-updater
Version:        0.7.3
Release:        1%{?dist}
Summary:        Update your Bazzite system

License:        GPL-2.0-or-later AND BSD-3-Clause AND CC0-1.0
URL:            https://github.com/rfrench3/bazzite-updater
Source0:        %{url}/archive/refs/tags/%{version}.tar.gz

Packager:       Robert French <frenchrobertm@outlook.com>

BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib
BuildRequires:  systemd-rpm-macros

BuildRequires:  cmake
BuildRequires:  extra-cmake-modules
BuildRequires:  kf6-rpm-macros
BuildRequires:  cmake(SDL3)
BuildRequires:  cmake(Qt6Core)
BuildRequires:  cmake(Qt6Gui)
BuildRequires:  cmake(Qt6Qml)
BuildRequires:  cmake(Qt6QuickControls2)
BuildRequires:  cmake(Qt6Svg)
BuildRequires:  cmake(Qt6Widgets)

BuildRequires:  cmake(KF6Kirigami)
BuildRequires:  cmake(KF6CoreAddons)
BuildRequires:  cmake(KF6Config)
BuildRequires:  cmake(KF6I18n)
BuildRequires:  cmake(KF6IconThemes)
BuildRequires:  cmake(KF6KirigamiAddons)

Requires:       kf6-kirigami%{?_isa}
Requires:       kf6-kirigami-addons%{?_isa}
Requires:       kf6-qqc2-desktop-style%{?_isa}
Requires:       which%{?_isa}
Requires:       qt6-controllable%{?_isa}
Requires:       uupd%{?_isa}
Requires:       hicolor-icon-theme

Provides:       bazzite-updater = %{?epoch:%{epoch}:}%{version}-%{release}

%description
This is a convenient, easy-to-use interface for updating your Bazzite system.
- Simple and powerful
- Full support for all input types (keyboard/mouse, controller, touchscreen)

%prep
%autosetup

%conf
%cmake

%build
%cmake_build

%install
%cmake_install

%check
appstream-util validate-relax --nonet %{buildroot}%{_kf6_metainfodir}/%{appid}.*.xml || :
desktop-file-validate %{buildroot}%{_kf6_datadir}/applications/%{appid}.desktop

%files
%license LICENSES/{BSD-3-Clause.txt,CC0-1.0.txt,GPL-2.0-or-later.txt}
%doc README.md
%{_bindir}/bazzite-updater
%{_datadir}/applications/%{appid}.desktop
%{_metainfodir}/%{appid}.*.xml
%{_iconsdir}/hicolor/scalable/apps/%{appid}.svg

%changelog
* Thu Feb 05 2026 Robert French
- Initial rpm build of Bazzite Updater
