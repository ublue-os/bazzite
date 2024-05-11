%global framework kio

%global stable_kf6 stable
%global majmin_ver_kf6 6.1

Name:    kf6-%{framework}
Version: %{majmin_ver_kf6}.0
Release: 2%{?dist}.bazzite.{{{ git_dir_version }}}
Summary: KDE Frameworks 6 Tier 3 solution for filesystem abstraction

License: BSD-2-Clause AND BSD-3-Clause AND CC0-1.0 AND GPL-2.0-only AND GPL-2.0-or-later AND GPL-3.0-only AND LGPL-2.0-only AND LGPL-2.0-or-later AND LGPL-2.1-only AND LGPL-2.1-or-later AND LGPL-3.0-only AND (GPL-2.0-only OR GPL-3.0-only) AND (LGPL-2.1-only OR LGPL-3.0-only) AND MIT
URL:     https://invent.kde.org/frameworks/%{framework}

Source0: https://download.kde.org/%{stable_kf6}/frameworks/%{majmin_ver_kf6}/%{framework}-%{version}.tar.xz

# https://invent.kde.org/frameworks/kio/-/issues/26
# I'm not sending this upstream because I'm not sure it's really
# exactly what upstream will want, but it solves the practical
# issue for us for now
Patch0:  0001-Give-the-kuriikwsfiltereng_private-a-VERSION-and-SOV.patch

%if 0%{?flatpak}
# Disable the help: and ghelp: protocol for Flatpak builds, to avoid depending
# on the docbook stack.
Patch101: kio-no-help-protocol.patch
%endif

# https://invent.kde.org/frameworks/kio/-/merge_requests/1556
Patch201: 1556.patch

BuildRequires:  extra-cmake-modules >= %{version}
BuildRequires:  gcc-c++
BuildRequires:  kf6-rpm-macros
BuildRequires:  cmake
BuildRequires:  cmake(KF6Archive)
BuildRequires:  cmake(KF6Crash)
BuildRequires:  cmake(KF6Solid)
BuildRequires:  switcheroo-control
BuildRequires:  cmake(KF6ColorScheme)
BuildRequires:  cmake(KF6Config)
BuildRequires:  cmake(KF6CoreAddons)
BuildRequires:  cmake(KF6DBusAddons)
BuildRequires:  cmake(KF6DocTools)
BuildRequires:  cmake(KF6GuiAddons)
BuildRequires:  cmake(KF6I18n)
BuildRequires:  cmake(KF6Service)
BuildRequires:  qt6-qtbase-private-devel
BuildRequires:  cmake(KF6Bookmarks)
BuildRequires:  cmake(KF6Completion)
BuildRequires:  cmake(KF6ConfigWidgets)
BuildRequires:  cmake(KF6IconThemes)
BuildRequires:  cmake(KF6ItemViews)
BuildRequires:  cmake(KF6JobWidgets)
BuildRequires:  cmake(KF6WindowSystem)
BuildRequires:  cmake(KF6Notifications)
BuildRequires:  cmake(KF6Wallet)
BuildRequires:  cmake(KF6WidgetsAddons)
BuildRequires:  cmake(KF6XmlGui)

BuildRequires:  libacl-devel
%if !0%{?flatpak}
BuildRequires:  libxml2-devel
BuildRequires:  libxslt-devel
%endif
BuildRequires:  pkgconfig(blkid)
BuildRequires:  pkgconfig(mount)
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  zlib-devel

BuildRequires:  qt6-qtbase-devel
BuildRequires:  cmake(Qt6UiPlugin)
BuildRequires:  cmake(Qt6Qml)

BuildRequires:  cmake(KF6KDED)
BuildRequires:  cmake(Qt6Core5Compat)

Requires:       %{name}-core%{?_isa} = %{version}-%{release}
Requires:       %{name}-widgets%{?_isa} = %{version}-%{release}
Requires:       %{name}-file-widgets%{?_isa} = %{version}-%{release}
Requires:       %{name}-gui%{?_isa} = %{version}-%{release}

Requires: kf6-kded

%description
KDE Frameworks 6 Tier 3 solution for filesystem abstraction

%package        devel
Summary:        Development files for %{name}
Requires:       %{name} = %{version}-%{release}
Requires:       kf6-kbookmarks-devel
Requires:       cmake(KF6Completion)
Requires:       cmake(KF6Config)
Requires:       cmake(KF6CoreAddons)
Requires:       cmake(KF6ItemViews)
Requires:       cmake(KF6JobWidgets)
Requires:       cmake(KF6Service)
Requires:       cmake(KF6Solid)
Requires:       cmake(KF6XmlGui)
Requires:       cmake(KF6WindowSystem)
Requires:       qt6-qtbase-devel
%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%package        doc
Summary:        Documentation files for %{name}
Requires:       %{name}-core = %{version}-%{release}
BuildArch:      noarch
%description    doc
Documentation for %{name}.

%package        core
Summary:        Core components of the KIO Framework
%{?kf6_kinit_requires}
Requires:       %{name}-core-libs%{?_isa} = %{version}-%{release}
Requires:       %{name}-doc = %{version}-%{release}
Requires:       kf6-filesystem
Recommends:     switcheroo-control
%description    core
KIOCore library provides core non-GUI components for working with KIO.

%package        core-libs
Summary:        Runtime libraries for KIO Core
Requires:       %{name}-core%{?_isa} = %{version}-%{release}
%description    core-libs
%{summary}.

%package        widgets
Summary:        Widgets for KIO Framework
## org.kde.klauncher6 service referenced from : widgets/krun.cpp
## included here for completeness, even those -core already has a dependency.
%{?kf6_kinit_requires}
Requires:       %{name}-core%{?_isa} = %{version}-%{release}
%description    widgets
KIOWidgets contains classes that provide generic job control, progress
reporting, etc.

%package        widgets-libs
Summary:        Runtime libraries for KIO Widgets library
Requires:       %{name}-widgets%{?_isa} = %{version}-%{release}
%description    widgets-libs
%{summary}.

%package        file-widgets
Summary:        Widgets for file-handling for KIO Framework
Requires:       %{name}-widgets%{?_isa} = %{version}-%{release}
%description    file-widgets
The KIOFileWidgets library provides the file selection dialog and
its components.

%package        gui
Summary:        Gui components for the KIO Framework
Requires:       %{name}-core%{?_isa} = %{version}-%{release}
%description    gui
%{summary}.

%package        qch-doc
Summary:        Developer Documentation files for %{name}
BuildArch:      noarch
%description    qch-doc
Developer Documentation files for %{name} for use with KDevelop or QtCreator.


%prep
%autosetup -n %{framework}-%{version} -p1


%build
%cmake_kf6
%cmake_build


%install
%cmake_install
%find_lang %{name} --all-name --with-man --with-html

%files
%license LICENSES/*.txt
%doc README.md

%files core
%{_kf6_libexecdir}/kioexec
%{_kf6_libexecdir}/kiod6
%{_kf6_libexecdir}/kioworker
%{_kf6_bindir}/ktelnetservice6
%{_kf6_bindir}/ktrash6
%{_kf6_plugindir}/kio/
%{_kf6_plugindir}/kded/
%{_kf6_plugindir}/kiod/
%{_kf6_datadir}/kf6/searchproviders/*.desktop
%{_kf6_datadir}/applications/*.desktop
%{_datadir}/dbus-1/services/org.kde.*.service
%{_kf6_datadir}/qlogging-categories6/*categories

%files core-libs
%{_kf6_libdir}/libKF6KIOCore.so.*

%files doc -f %{name}.lang

%files gui
%{_kf6_libdir}/libKF6KIOGui.so.*

%files widgets
%dir %{_kf6_plugindir}/urifilters/
%{_kf6_plugindir}/urifilters/*.so
%{_kf6_libdir}/libkuriikwsfiltereng_private.so.*

%files widgets-libs
%{_kf6_libdir}/libKF6KIOWidgets.so.*

%files file-widgets
%{_kf6_libdir}/libKF6KIOFileWidgets.so.*

%files devel
%{_kf6_includedir}/*
%{_kf6_libdir}/*.so
%{_kf6_libdir}/cmake/KF6KIO/
%{_kf6_datadir}/kdevappwizard/templates/kioworker6.tar.bz2
%{_kf6_qtplugindir}/designer/kio6widgets.so
%{_qt6_docdir}/*.tags
 
%files qch-doc
%{_qt6_docdir}/*.qch

%changelog
* Thu Apr 18 2024 Jan Grulich <jgrulich@redhat.com> - 6.1.0-2
- Rebuild (qt6)

* Wed Apr 10 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 6.1.0-1
- 6.1.0

* Thu Apr 04 2024 Jan Grulich <jgrulich@redhat.com> - 6.0.0-7
- Re-enable docs

* Thu Apr 04 2024 Jan Grulich <jgrulich@redhat.com> - 6.0.0-6
- Rebuild (qt6)

* Fri Mar 15 2024 Marie Loise Nolden <loise@kde.org> - 6.0.0-5
- add 6e7775d315f389df0a440ed62b842ce83dc9a27e.patch
[kterminallauncherjob] Inherit default process environment from parent 

* Mon Mar 11 2024 Yaakov Selkowitz <yselkowi@redhat.com> - 6.0.0-4
- Soften switcheroo-control dependency

* Sat Mar 09 2024 Marie Loise Nolden <loise@kde.org> - 6.0.0-3
- add missing BuildArch: noarch to -doc package

* Sat Mar 2 2024 Marie Loise Nolden <loise@kde.org> - 6.0.0-2
- move qt designer plugin to -devel

* Wed Feb 21 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 6.0.0-1
- 6.0.0

* Fri Feb 16 2024 Jan Grulich <jgrulich@redhat.com> - 5.249.0-2
- Rebuild (qt6)

* Wed Jan 31 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 5.249.0-1
- 5.249.0

* Thu Jan 25 2024 Fedora Release Engineering <releng@fedoraproject.org> - 5.248.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Sun Jan 21 2024 Fedora Release Engineering <releng@fedoraproject.org> - 5.248.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Wed Jan 10 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 5.248.0-1
- 5.248.0

* Tue Jan 09 2024 Marie Loise Nolden <loise@kde.org> - 5.247.0-2
- add doc package for KF6 API

* Wed Dec 20 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 5.247.0-1
- 5.247.0

* Sat Dec 02 2023 Justin Zobel <justin.zobel@gmail.com> - 5.246.0-1
- Update to 5.246.0

* Wed Nov 29 2023 Jan Grulich <jgrulich@redhat.com> - 5.245.0-3
- Rebuild (qt6)

* Mon Nov 20 2023 Alessandro Astone <ales.astone@gmail.com> - 5.245.0-2
- Add back kuriikwsfiltereng SOVERSION patch

* Thu Nov 09 2023 Steve Cossette <farchord@gmail.com> - 5.245.0-1
- 5.245.0

* Tue Oct 17 2023 Jan Grulich <jgrulich@redhat.com> - 5.240.0^20231010.060359.1c34fd4-4
- Rebuild (qt6)

* Mon Oct 16 2023 Adam Williamson <awilliam@redhat.com> - 5.240.0^20231010.060359.1c34fd4-3
- Give kuriikwsfiltereng_private library a proper soname to fix deps

* Mon Oct 09 2023 Steve Cossette <farchord@gmail.com> - 5.240.0^20231010.060359.1c34fd4-2
- Fixed a problem with the -doc subpackage building differently on different arches.

* Mon Oct 09 2023 Steve Cossette <farchord@gmail.com> - 5.240.0^20231010.060359.1c34fd4-1
- Initial Release
