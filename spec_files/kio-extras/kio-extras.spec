Name:    kio-extras
Version: 26.08.0
Release: 2%{?dist}
Summary: Additional components to increase the functionality of KIO Framework

# Automatically converted from old format: GPLv2+ - review is highly recommended.
License: GPL-2.0-or-later
URL:     https://invent.kde.org/network/kio-extras

Source0: https://download.kde.org/%{stable_kf6}/release-service/%{version}/src/%{name}-%{version}.tar.xz

## upstramable patches
Patch0: 0001-kio-extras-directory-thumbnailing-fallback.patch

## upstream patches

BuildRequires:  bzip2-devel
BuildRequires:  gperf

BuildRequires:  extra-cmake-modules
BuildRequires:  kf6-rpm-macros

BuildRequires:  cmake(Qt6)
BuildRequires:  cmake(Qt6Core5Compat)
BuildRequires:  cmake(Qt6Qml)
BuildRequires:  cmake(Qt6Svg)
BuildRequires:  cmake(QCoro6)
BuildRequires:  cmake(KF6Archive)
BuildRequires:  cmake(KF6Config)
BuildRequires:  cmake(KF6ConfigWidgets)
BuildRequires:  cmake(KF6CoreAddons)
BuildRequires:  cmake(KF6DBusAddons)
BuildRequires:  cmake(KF6DNSSD)
BuildRequires:  cmake(KF6DocTools)
BuildRequires:  cmake(KF6GuiAddons)
BuildRequires:  cmake(KF6I18n)
BuildRequires:  cmake(KF6KCMUtils)
BuildRequires:  cmake(KF6KIO)
BuildRequires:  cmake(KF6Solid)
BuildRequires:  cmake(KF6SyntaxHighlighting)
BuildRequires:  cmake(KF6TextWidgets)
BuildRequires:  cmake(KF6Notifications)

BuildRequires:  cmake(PlasmaActivities)
BuildRequires:  cmake(PlasmaActivitiesStats)

BuildRequires:  cmake(KDSoap) >= 1.9
BuildRequires:  cmake(KDSoapWSDiscoveryClient)
BuildRequires:  cmake(KExiv2Qt6)
BuildRequires:  pkgconfig(libproxy-1.0)

BuildRequires:  libjpeg-devel
BuildRequires:  libmtp-devel
BuildRequires:  libsmbclient-devel
BuildRequires:  libssh-devel
BuildRequires:  cmake(OpenEXR)
BuildRequires:  perl-generators
BuildRequires:  phonon-qt6-devel
BuildRequires:  pkgconfig(libimobiledevice-1.0)
BuildRequires:  pkgconfig(libplist-2.0)
BuildRequires:  pkgconfig(libtirpc)
BuildRequires:  pkgconfig(shared-mime-info)
BuildRequires:  pkgconfig(xcursor)
BuildRequires:  taglib-devel > 1.11

# This package provides plugins for KIO
Supplements:    kf6-kio-core

%description
%{summary}.

%package info
Summary: Info kioslave
%description info
Kioslave for reading info pages.

%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}
%description devel
%{summary}.


%prep
%autosetup -p1


%build
%cmake_kf6 -DLIBSSH_LIBRARIES="$(pkg-config --libs libssh)"
%cmake_build


%install
%cmake_install
%find_lang %{name} --all-name --with-html


%files -f %{name}.lang
%license LICENSES/*

%{_kf6_plugindir}/kded/
%exclude %{_kf6_plugindir}/kio/info.so
%{_kf6_plugindir}/kio/
%{_kf6_plugindir}/kiod/
%{_kf6_plugindir}/thumbcreator/
%{_kf6_plugindir}/kfileitemaction/
%{_datadir}/config.kcfg/jpegcreatorsettings5.kcfg
%{_datadir}/dbus-1/services/org.kde.kmtpd5.service
%{_datadir}/applications/kcm_*
%{_datadir}/mime/packages/org.kde.kio.smb.xml
%{_datadir}/remoteview/
%{_datadir}/konqueror/
%dir %{_kf6_datadir}/kio_filenamesearch/
%{_kf6_datadir}/kio_filenamesearch/kio-filenamesearch-grep
%{_kf6_datadir}/qlogging-categories6/kio-extras*
%{_kf6_datadir}/solid/actions/solid_afc.desktop
%{_kf6_datadir}/solid/actions/solid_mtp.desktop
%{_kf6_libdir}/libkioarchive6.so.6{,.*}
%{_kf6_libexecdir}/smbnotifier
%{_libexecdir}/wpad-detector-helper
%{_kf6_qtplugindir}/kcm_trash.so
%{_kf6_qtplugindir}/plasma/kcms/systemsettings_qwidgets/kcm_*.so

%files info
%{_kf6_plugindir}/kio/info.so
# perl deps, but required at runtime for the info kioslave to actually work:
%dir %{_datadir}/kio_info/
%{_datadir}/kio_info/kde-info2html*

%files devel
%{_includedir}/KioArchive6/*.h
%{_kf6_libdir}/cmake/KioArchive6/


%changelog
* Fri Aug 14 2026 Steve Cossette <farchord@gmail.com> - 26.08.0-1
- 26.08.0

* Fri Jul 31 2026 Steve Cossette <farchord@gmail.com> - 26.07.90-1
- 26.07.90

* Wed Jul 29 2026 Steve Cossette <farchord@gmail.com> - 26.07.80-1
- 26.07.80

* Thu Jul 16 2026 Fedora Release Engineering <releng@fedoraproject.org> - 26.04.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_45_Mass_Rebuild

* Tue Jun 30 2026 Steve Cossette <farchord@gmail.com> - 26.04.3-1
- 26.04.3

* Tue Jun 02 2026 Steve Cossette <farchord@gmail.com> - 26.04.2-1
- 26.04.2

* Mon May 25 2026 Richard Shaw <hobbes1069@gmail.com> - 26.04.1-2
- Rebuild for OpenEXR 3.4.12.

* Wed May 06 2026 Steve Cossette <farchord@gmail.com> - 26.04.1-1
- 26.04.1

* Sat Apr 11 2026 Steve Cossette <farchord@gmail.com> - 26.04.0-1
- 26.04.0

* Mon Mar 16 2026 Steve Cossette <farchord@gmail.com> - 26.03.80-1
- 26.03.80

* Sun Mar 08 2026 Steve Cossette <farchord@gmail.com> - 25.12.3-1
- 25.12.3

* Thu Feb 12 2026 Steve Cossette <farchord@gmail.com> - 25.12.2-2
- Full Stack Rebuild (kio abi break)

* Wed Feb 04 2026 Steve Cossette <farchord@gmail.com> - 25.12.2-1
- 25.12.2

* Sun Jan 25 2026 Yaakov Selkowitz <yselkowi@redhat.com> - 25.12.1-3
- Rebuilt for https://fedoraproject.org/wiki/Changes/TagLib2

* Fri Jan 16 2026 Fedora Release Engineering <releng@fedoraproject.org> - 25.12.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_44_Mass_Rebuild

* Wed Jan 07 2026 farchord@gmail.com - 25.12.1-1
- 25.12.1

* Sat Dec 06 2025 Steve Cossette <farchord@gmail.com> - 25.12.0-1
- 25.12.0

* Fri Nov 28 2025 Steve Cossette <farchord@gmail.com> - 25.11.90-1
- 25.11.90

* Sat Nov 15 2025 Steve Cossette <farchord@gmail.com> - 25.11.80-1
- 25.11.80

* Tue Nov 04 2025 Steve Cossette <farchord@gmail.com> - 25.08.3-1
- 25.08.3

* Wed Oct 29 2025 Steve Cossette <farchord@gmail.com> - 25.08.2-2
- Bump for rebuild for plasma 6.5 + PackageKit-Qt

* Wed Oct 08 2025 Steve Cossette <farchord@gmail.com> - 25.08.2-1
- 25.08.2

* Fri Oct 03 2025 Steve Cossette <farchord@gmail.com> - 25.08.1-2
- Rebuild for plasma-activities

* Sun Sep 21 2025 Steve Cossette <farchord@gmail.com> - 25.08.1-1
- 25.08.1

* Fri Aug 08 2025 Steve Cossette <farchord@gmail.com> - 25.08.0-1
- 25.08.0

* Fri Jul 25 2025 Steve Cossette <farchord@gmail.com> - 25.07.90-1
- 25.07.90

* Thu Jul 24 2025 Fedora Release Engineering <releng@fedoraproject.org> - 25.07.80-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_43_Mass_Rebuild

* Fri Jul 11 2025 Steve Cossette <farchord@gmail.com> - 25.07.80-1
- 25.07.80

* Thu Jul 03 2025 Steve Cossette <farchord@gmail.com> - 25.04.3-1
- 25.04.3

* Wed Jun 04 2025 Steve Cossette <farchord@gmail.com> - 25.04.2-1
- 25.04.2

* Wed May 14 2025 Steve Cossette <farchord@gmail.com> - 25.04.1-1
- 25.04.1

* Wed Apr 16 2025 Jan Grulich <jgrulich@redhat.com> - 25.04.0-2
- Rebuild (qt6)

* Sat Apr 12 2025 Steve Cossette <farchord@gmail.com> - 25.04.0-1
- 25.04.0

* Thu Mar 20 2025 Steve Cossette <farchord@gmail.com> - 25.03.80-1
- 25.03.80 (Beta)

* Tue Mar 04 2025 Steve Cossette <farchord@gmail.com> - 24.12.3-1
- 24.12.3

* Fri Feb 21 2025 Steve Cossette <farchord@gmail.com> - 24.12.2-2
- Rebuild for ppc64le enablement

* Wed Feb 05 2025 Steve Cossette <farchord@gmail.com> - 24.12.2-1
- 24.12.2

* Fri Jan 17 2025 Fedora Release Engineering <releng@fedoraproject.org> - 24.12.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_42_Mass_Rebuild

* Tue Jan 07 2025 Steve Cossette <farchord@gmail.com> - 24.12.1-1
- 24.12.1

* Sat Dec 07 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.12.0-1
- 24.12.0

* Fri Nov 29 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.11.90-1
- 24.11.90

* Fri Nov 15 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.11.80-1
- 24.11.80

* Tue Nov 05 2024 Steve Cossette <farchord@gmail.com> - 24.08.3-1
- 24.08.3

* Tue Oct 08 2024 Steve Cossette <farchord@gmail.com> - 24.08.2-1
- 24.08.2

* Wed Sep 25 2024 Alessandro Astone <ales.astone@gmail.com> - 24.08.1-1
- 24.08.1

* Sun Sep 15 2024 Yaakov Selkowitz <yselkowi@redhat.com> - 24.08.0-3
- Revert "Include kio_info in main package"

* Sat Sep 14 2024 Pavel Solovev <daron439@gmail.com> - 24.08.0-2
- Fix SFTP file corruption
- Include kio_info in main package (rhbz#1697318)

* Thu Aug 22 2024 Steve Cossette <farchord@gmail.com> - 24.08.0-1
- 24.08.0

* Fri Jul 26 2024 Miroslav Suchý <msuchy@redhat.com> - 24.05.2-3
- convert license to SPDX

* Thu Jul 18 2024 Fedora Release Engineering <releng@fedoraproject.org> - 24.05.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_41_Mass_Rebuild

* Sun Jul 07 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.05.2-1
- 24.05.2

* Sun Jun 16 2024 Robert-André Mauchin <zebob.m@gmail.com> - 24.05.1-2
- Rebuilt for exiv2 0.28.2

* Fri Jun 14 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.05.1-1
- 24.05.1

* Fri May 17 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.05.0-1
- 24.05.0

* Wed Apr 24 2024 Benjamin A. Beasley <code@musicinmybrain.net> - 24.02.2-2
- Rebuilt for openexr 3.2.4

* Fri Apr 12 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.02.2-1
- 24.02.2

* Fri Mar 29 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.02.1-1
- 24.02.1

* Wed Feb 21 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.02.0-1
- 24.02.0

* Wed Jan 31 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.01.95-1
- 24.01.95

* Thu Jan 25 2024 Fedora Release Engineering <releng@fedoraproject.org> - 24.01.90-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Sun Jan 21 2024 Fedora Release Engineering <releng@fedoraproject.org> - 24.01.90-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Thu Jan 11 2024 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 24.01.90-1
- 24.01.90

* Sat Dec 23 2023 ales.astone@gmail.com - 24.01.85-1
- 24.01.85

* Sun Dec 03 2023 Alessandro Astone <ales.astone@gmail.com> - 24.01.80-1
- Update to 24.01.80

* Tue Nov 14 2023 Alessandro Astone <ales.astone@gmail.com> - 24.01.75-1
- 24.01.75
- Targets KF6

* Tue Nov 14 2023 Alessandro Astone <ales.astone@gmail.com> - 23.08.2-2
- Provide support for extracting JPEG thumbnails

* Thu Oct 12 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.08.2-1
- 23.08.2

* Sat Sep 16 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.08.1-1
- 23.08.1

* Thu Sep 07 2023 Neal Gompa <ngompa@fedoraproject.org> - 23.08.0-2
- Enable Apple File Conduit (AFC) support

* Sat Aug 26 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.08.0-1
- 23.08.0

* Thu Jul 20 2023 Fedora Release Engineering <releng@fedoraproject.org> - 23.04.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Sat Jul 08 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.04.3-1
- 23.04.3

* Tue Jun 06 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.04.2-1
- 23.04.2

* Sat May 13 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.04.1-1
- 23.04.1

* Fri Apr 14 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.04.0-1
- 23.04.0

* Fri Mar 31 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.03.90-1
- 23.03.90

* Mon Mar 20 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 23.03.80-1
- 23.03.80

* Thu Mar 02 2023 Marc Deop i Argemí <marcdeop@fedoraproject.org> - 22.12.3-1
- 22.12.3

* Tue Jan 31 2023 Marc Deop <marcdeop@fedoraproject.org> - 22.12.2-1
- 22.12.2

* Thu Jan 19 2023 Fedora Release Engineering <releng@fedoraproject.org> - 22.12.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Wed Jan 04 2023 Justin Zobel <justin@1707.io> - 22.12.1-1
- Update to 22.12.1

* Mon Dec 19 2022 Marc Deop <marcdeop@fedoraproject.org> - 22.12.0-1
- 22.12.0

* Fri Nov 04 2022 Marc Deop i Argemí (Private) <marc@marcdeop.com> - 22.08.3-1
- 22.08.3

* Fri Oct 14 2022 Marc Deop <marcdeop@fedoraproject.org> - 22.08.2-1
- 22.08.2

* Thu Sep 08 2022 Marc Deop <marcdeop@fedoraproject.org> - 22.08.1-1
- 22.08.1

* Fri Aug 19 2022 Marc Deop <marcdeop@fedoraproject.org> - 22.08.0-1
- 22.08.0

* Thu Jul 21 2022 Fedora Release Engineering <releng@fedoraproject.org> - 22.04.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Mon Jul 18 2022 Than Ngo <than@redhat.com> - 22.04.3-1
- 22.04.3

* Thu May 12 2022 Justin Zobel <justin@1707.io> - 22.04.1-1
- Update to 22.04.1

* Mon May 09 2022 Justin Zobel <justin@1707.io> - 22.04.0-1
- Update to 22.04.0

* Wed Mar 02 2022 Marc Deop <marcdeop@fedoraproject.org> - 21.12.3-1
- 21.12.3

* Wed Feb 23 2022 Rex Dieter <rdieter@fedoraproject.org> - 21.12.2-3
- Recommends: (icoutils if wine-core)

* Wed Feb 23 2022 Rex Dieter <rdieter@fedoraproject.org> - 21.12.2-2
- Recommends: (icoutils if wine)

* Fri Feb 04 2022 Rex Dieter <rdieter@fedoraproject.org> - 21.12.2-1
- 21.12.2

* Thu Jan 20 2022 Fedora Release Engineering <releng@fedoraproject.org> - 21.12.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Fri Jan 07 2022 Adam Williamson <awilliam@redhat.com> - 21.12.2-1
- Rebuild for kdsoap soname bump

* Thu Jan 06 2022 Rex Dieter <rdieter@fedoraproject.org> - 21.12.1-1
- 21.12.1

* Mon Dec 27 2021 Rex Dieter <rdieter@fedoraproject.org> - 21.12.0-1
- 21.12.0

* Tue Nov 02 2021 Rex Dieter <rdieter@fedoraproject.org> - 21.08.3-1
- 21.08.3

* Thu Oct 21 2021 Rex Dieter <rdieter@fedoraproject.org> - 21.08.2-1
- 21.08.2

* Sun Aug 22 2021 Richard Shaw <hobbes1069@gmail.com> - 21.04.3-2
- Rebuild for OpenEXR/Imath 3.1.

* Wed Jul 28 2021 Rex Dieter <rdieter@fedoraproject.org> - 21.04.3-1
- 21.04.3

* Thu Jul 22 2021 Fedora Release Engineering <releng@fedoraproject.org> - 21.04.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Thu Jun 10 2021 Rex Dieter <rdieter@fedoraproject.org> - 21.04.2-1
- 21.04.2

* Tue May 11 2021 Rex Dieter <rdieter@fedoraproject.org> - 21.04.1-1
- 21.04.1

* Mon Apr 19 2021 Rex Dieter <rdieter@fedoraproject.org> - 21.04.0-1
- 21.04.0

* Wed Mar 31 2021 Jonathan Wakely <jwakely@redhat.com> - 20.12.3-2
- Rebuilt for removed libstdc++ symbols (#1937698)

* Wed Mar 03 2021 Rex Dieter <rdieter@fedoraproject.org> - 20.12.3-1
- 20.12.3

* Thu Feb 04 2021 Rex Dieter <rdieter@fedoraproject.org> - 20.12.2-1
- 20.12.2

* Tue Jan 26 2021 Fedora Release Engineering <releng@fedoraproject.org> - 20.08.3-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Fri Jan 01 2021 Richard Shaw <hobbes1069@gmail.com> - 20.08.3-3
- Rebuild for OpenEXR 2.5.3.

* Tue Dec 29 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.08.3-2
- rebuild (kdsoap)
- update URL
- .spec cosmetics

* Fri Nov  6 15:19:21 CST 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.08.3-1
- 20.08.3

* Tue Sep 15 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.08.1-1
- 20.08.1

* Tue Aug 18 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.08.0-1
- 20.08.0

* Tue Jul 28 2020 Fedora Release Engineering <releng@fedoraproject.org> - 20.04.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Fri Jul 10 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.04.3-1
- 20.04.3

* Fri Jun 12 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.04.2-1
- 20.04.2

* Wed May 27 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.04.1-1
- 20.04.1

* Sat May 02 2020 Rex Dieter <rdieter@fedoraproject.org> - 20.04.0-1
- 20.04.0
- fix Recommends: qtimageformts dep

* Fri Apr 17 2020 Sandro Mani <manisandro@gmail.com> - 19.12.3-2
- Add patch to skip huge images in thumbnailer

* Sat Mar 07 2020 Rex Dieter <rdieter@fedoraproject.org> - 19.12.3-1
- 19.12.3

* Tue Feb 04 2020 Rex Dieter <rdieter@fedoraproject.org> - 19.12.2-1
- 19.12.2

* Wed Jan 29 2020 Fedora Release Engineering <releng@fedoraproject.org> - 19.12.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Mon Jan 13 2020 Rex Dieter <rdieter@fedoraproject.org> - 19.12.1-1
- 19.12.1

* Tue Nov 12 2019 Rex Dieter <rdieter@fedoraproject.org> - 19.08.3-1
- 19.08.3
- hack around cmake/libssh bogosity (sftp kioslave FTBFS)

* Thu Oct 17 2019 Rex Dieter <rdieter@fedoraproject.org> - 19.08.2-1
- 19.08.2

* Fri Oct 04 2019 Rex Dieter <rdieter@fedoraproject.org> - 19.08.1-1
- 19.08.1

* Thu Jul 25 2019 Fedora Release Engineering <releng@fedoraproject.org> - 19.04.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Fri Jul 12 2019 Rex Dieter <rdieter@fedoraproject.org> - 19.04.3-1
- 19.04.3

* Tue Jun 04 2019 Rex Dieter <rdieter@fedoraproject.org> - 19.04.2-1
- 19.04.2

* Wed May 08 2019 Rex Dieter <rdieter@fedoraproject.org> - 19.04.1-1
- 19.04.1
- -info subpkg (#1697318)

* Thu Apr 11 2019 Richard Shaw <hobbes1069@gmail.com> - 18.12.3-3
- Rebuild for OpenEXR 2.3.0.

* Tue Apr 09 2019 Kevin Kofler <Kevin@tigcc.ticalc.org> - 18.12.3-2
- move kio_info/kde-info2html perl script back to the main package (#1697318)

* Fri Mar 08 2019 Rex Dieter <rdieter@fedoraproject.org> - 18.12.3-1
- 18.12.3

* Tue Feb 05 2019 Rex Dieter <rdieter@fedoraproject.org> - 18.12.2-1
- 18.12.2

* Fri Feb 01 2019 Fedora Release Engineering <releng@fedoraproject.org> - 18.12.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Tue Jan 08 2019 Rex Dieter <rdieter@fedoraproject.org> - 18.12.1-1
- 18.12.1

* Mon Jan 07 2019 Rex Dieter <rdieter@fedoraproject.org> - 18.12.0-2
- drop BR: lzma-devel, seems no longer needed or used

* Sun Dec 16 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.12.0-1
- 18.12.0

* Tue Nov 13 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.08.3-1
- 18.08.3
- drop -htmlthumbnail: CVE-2018-19120 kio-extras: HTML Thumbnailer automatic remote file access (#1649421)

* Wed Oct 17 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.08.2-2
- pull in upstream crash fix, use %%make_build

* Wed Oct 10 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.08.2-1
- 18.08.2

* Mon Oct 01 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.08.1-1
- 18.08.1

* Tue Aug 21 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.04.3-2
- move kio_info/kde-info2html perl script to -devel

* Fri Jul 13 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.04.3-1
- 18.04.3

* Fri Jul 13 2018 Fedora Release Engineering <releng@fedoraproject.org> - 18.04.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Wed Jun 06 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.04.2-1
- 18.04.2

* Wed May 09 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.04.1-1
- 18.04.1

* Thu Apr 19 2018 Rex Dieter <rdieter@fedoraproject.org> - 18.04.0-1
- 18.04.0

* Mon Apr 02 2018 Rex Dieter <rdieter@fedoraproject.org> - 17.12.3-1
- 17.12.3
- %%check: skip tests, seem to be hanging despite setting 10s timeout
- use %%ldconfig_scriptlets

* Thu Feb 08 2018 Rex Dieter <rdieter@fedoraproject.org> - 17.12.2-1
- 17.12.2

* Wed Feb 07 2018 Fedora Release Engineering <releng@fedoraproject.org> - 17.12.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Thu Jan 11 2018 Rex Dieter <rdieter@fedoraproject.org> - 17.12.1-1
- 17.12.1

* Wed Jan 10 2018 Kevin Kofler <Kevin@tigcc.ticalc.org> - 17.12.0-2
- Build against libtirpc (#1532944), patch from Cygwin Ports

* Thu Dec 28 2017 Rex Dieter <rdieter@fedoraproject.org> - 17.12.0-1
- 17.12.0

* Mon Nov 06 2017 Rex Dieter <rdieter@fedoraproject.org> - 17.08.2-2
- pull in smb-related upstream fixes

* Wed Oct 11 2017 Rex Dieter <rdieter@fedoraproject.org> - 17.08.2-1
- 17.08.2

* Thu Sep 28 2017 Rex Dieter <rdieter@fedoraproject.org> - 17.08.1-1
- 17.08.1

* Thu Aug 03 2017 Rex Dieter <rdieter@fedoraproject.org> - 17.04.3-1
- 17.04.3

* Thu Aug 03 2017 Fedora Release Engineering <releng@fedoraproject.org> - 17.04.2-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Wed Jul 26 2017 Fedora Release Engineering <releng@fedoraproject.org> - 17.04.2-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Thu Jun 15 2017 Rex Dieter <rdieter@fedoraproject.org> - 17.04.2-1
- 17.04.2

* Sun Jun 04 2017 Rex Dieter <rdieter@fedoraproject.org> - 17.04.1-1
- 17.04.1, move -docs content to main pkg

* Tue May 02 2017 Rex Dieter <rdieter@fedoraproject.org> - 16.12.3-2
- rebuild (exiv2)

* Thu Mar 09 2017 Rex Dieter <rdieter@fedoraproject.org> - 16.12.3-1
- 16.12.3

* Thu Feb 09 2017 Rex Dieter <rdieter@fedoraproject.org> - 16.12.2-1
- 16.12.2

* Wed Jan 11 2017 Rex Dieter <rdieter@fedoraproject.org> - 16.12.1-2
- -htmlthumbnail subpkg

* Tue Jan 10 2017 Rex Dieter <rdieter@fedoraproject.org> - 16.12.1-1
- 16.12.1

* Mon Jan 02 2017 Rex Dieter <rdieter@fedoraproject.org> - 16.08.3-2
- filter plugin provides

* Mon Dec 05 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.08.3-1
- 16.08.3

* Thu Oct 13 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.08.2-1
- 16.08.2

* Wed Sep 07 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.08.1-1
- 16.08.1

* Sat Aug 13 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.08.0-1
- 16.08.0

* Fri Aug 12 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.07.90-2
- Recommends: qt5-qtimageformats (#1366585)

* Sat Aug 06 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.07.90-1
- 16.07.90

* Sun Jul 31 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.07.80-1
- 16.07.80

* Sat Jul 09 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.04.3-1
- 16.04.3

* Sun Jun 12 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.04.2-1
- 16.04.2

* Sun May 08 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.04.1-1
- 16.04.1

* Fri Apr 29 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.04.0-2
- support bootstrap/tests

* Tue Apr 19 2016 Rex Dieter <rdieter@fedoraproject.org> - 16.04.0-1
- 16.04.0

* Tue Mar 15 2016 Rex Dieter <rdieter@fedoraproject.org> - 15.12.3-1
- 15.12.3

* Mon Feb 15 2016 Rex Dieter <rdieter@fedoraproject.org> - 15.12.2-1
- 15.12.2

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 15.12.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Sun Jan 10 2016 Rex Dieter <rdieter@fedoraproject.org> - 15.12.1-1
- 15.12.1

* Tue Dec 22 2015 Rex Dieter <rdieter@fedoraproject.org> - 15.12.0-1
- 15.12.0

* Thu Dec 03 2015 Rex Dieter <rdieter@fedoraproject.org> - 15.08.3-1
- 15.08.3

* Thu Dec 03 2015 Rex Dieter <rdieter@fedoraproject.org> 15.08.1-2
- .spec cosmetics, update URL, use %%license

* Sat Sep 12 2015 Rex Dieter <rdieter@fedoraproject.org> - 15.08.1-1
- 15.08.1

* Thu Aug 20 2015 Than Ngo <than@redhat.com> - 15.08.0-1
- 15.08.0

* Thu Jun 25 2015 Daniel Vrátil <dvratil@redhat.com> - 5.3.2-1
- Plasma 5.3.2

* Wed Jun 24 2015 Rex Dieter <rdieter@fedoraproject.org> - 5.3.1-3
- rebuild (exiv2)

* Wed Jun 17 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 5.3.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Tue May 26 2015 Daniel Vrátil <dvratil@redhat.com> - 5.3.1-1
- Plasma 5.3.1

* Mon Apr 27 2015 Daniel Vrátil <dvratil@redhat.com> - 5.3.0-1
- Plasma 5.3.0

* Fri Apr 24 2015 Daniel Vrátil <dvratil@redhat.com> - 5.2.95-2
- BR libsmbclient-devel

* Wed Apr 22 2015 Daniel Vrátil <dvratil@redhat.com> - 5.2.95-1
- Plasma 5.2.95

* Wed Apr 08 2015 Rex Dieter <rdieter@fedoraproject.org> 5.2.2-5
- drop Conflicts: kio_mtp (no longer needed with renamed catalog)

* Tue Apr 07 2015 Rex Dieter <rdieter@fedoraproject.org> 5.2.2-4
- temporarily adjust kio_mtp catalog until kde4 updates hit stable

* Tue Apr 07 2015 Rex Dieter <rdieter@fedoraproject.org> 5.2.2-3
- drop mtp-common subpkg

* Fri Apr 03 2015 Rex Dieter <rdieter@fedoraproject.org> - 5.2.2-2
- drop Obsoletes/Provides: kio_mtp (#1208601)
- add mimetype scriptlets
- s/libjpeg-turbo-devel/libjpeg-devel/
- minor .spec cleanup
- doc: noarch
- BR: libmtp-devel

* Fri Mar 20 2015 Daniel Vrátil <dvratil@redhat.com> - 5.2.2-1
- Plasma 5.2.2


* Fri Feb 27 2015 Daniel Vrátil <dvratil@redhat.com> - 5.2.1-2
- Rebuild (GCC 5)

* Tue Feb 24 2015 Daniel Vrátil <dvratil@redhat.com> - 5.2.1-1
- Plasma 5.2.1

* Thu Jan 29 2015 Daniel Vrátil <dvratil@redhat.com> - 5.2.0-2
- Obsoletes/Provides kio_mtp

* Mon Jan 26 2015 Daniel Vrátil <dvratil@redhat.com> - 5.2.0-1
- Plasma 5.2.0

* Mon Jan 12 2015 Daniel Vrátil <dvratil@redhat.com> - 5.1.95-1.beta
- Plasma 5.1.95 Beta

* Wed Dec 17 2014 Daniel Vrátil <dvratil@redhat.com> - 5.1.2-2
- Plasma 5.1.2

* Fri Nov 07 2014 Daniel Vrátil <dvratil@redhat.com> - 5.1.1-1
- Plasma 5.1.1

* Tue Oct 14 2014 Daniel Vrátil <dvratil@redhat.com> - 5.1.0.1-1
- Plasma 5.1.0.1

* Thu Oct 09 2014 Daniel Vrátil <dvratil@redhat.com> - 5.1.0-1
- Plasma 5.1.0

* Tue Sep 16 2014 Daniel Vrátil <dvratil@redhat.com> - 5.0.2-1
- Plasma 5.0.2

* Sun Aug 10 2014 Daniel Vrátil <dvratil@redhat.com> - 5.0.1-1
- Plasma 5.0.1

* Tue Jul 29 2014 Daniel Vrátil <dvratil@redhat.cim> - 5.0.0-2
- Split -docs to improve coinstallability with KDE 4

* Wed Jul 16 2014 Daniel Vrátil <dvratil@redhat.com> - 5.0.0-1
- Plasma 5.0.0

* Wed May 14 2014 Daniel Vrátil <dvratil@redhat.com> - 4.90.1-1.20140514gitf7a2bbe
- Initial version
