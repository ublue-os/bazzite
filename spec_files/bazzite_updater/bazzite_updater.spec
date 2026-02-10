%global orgname io.github.rfrench3.bazzite_updater

Name:           bazzite_updater
Version:        0.4.2
Release:        1%{?dist}
Summary:        Update your Bazzite system

License:        GPL-2.0-or-later
URL:            https://github.com/rfrench3/%{name}
Source0:        %{url}/archive/refs/tags/%{version}.tar.gz

BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib

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

Requires:       kf6-kuserfeedback%{?_isa}
Requires:       kf6-kirigami%{?_isa}
Requires:       kf6-kirigami-addons%{?_isa}
Requires:       kf6-qqc2-desktop-style%{?_isa}

Provides:       bazzite_updater = %{version}-%{release}

%description
This is a convenient, easy-to-use interface for updating your Bazzite system.
- Simple and powerful
- Full support for all input types (keyboard/mouse, controller, touchscreen)

%prep
%autosetup

%build
%cmake
%cmake_build

%install
%cmake_install

%check
appstream-util validate-relax --nonet %{buildroot}%{_kf6_metainfodir}/%{orgname}.*.xml || :
desktop-file-validate %{buildroot}%{_kf6_datadir}/applications/%{orgname}.desktop

%files
%license LICENSES/{BSD-3-Clause.txt,CC0-1.0.txt,GPL-2.0-or-later.txt,FSFAP.txt}
%doc README.md
%{_kf6_bindir}/bazzite_updater
%{_kf6_datadir}/applications/%{orgname}.desktop
%{_kf6_metainfodir}/%{orgname}.*.xml
%{_kf6_datadir}/icons/hicolor/scalable/apps/%{orgname}.svg



%changelog
* Thu Feb 05 2026 Robert French
- Initial rpm build of Bazzite Updater
