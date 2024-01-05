%define _legacy_common_support 1

Name:           duperemove
Version:        0.14.1
Release:        5%{?dist}
Summary:        Tools for deduping file systems
License:        GPL-2.0-only
URL:            https://github.com/markfasheh/%{name}
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(sqlite3)
BuildRequires:  pkgconfig(uuid)
BuildRequires:  libgcrypt-devel
BuildRequires:  xxhash-devel
BuildRequires:  libatomic
BuildRequires:  gcc
BuildRequires:  git
BuildRequires:  pandoc
# Enable devtoolset so we get libatomic in EPEL-7
%if 0%{?el7}
BuildRequires:  devtoolset-7-toolchain, devtoolset-7-libatomic-devel
%endif
BuildRequires: make

%description
Duperemove is a simple tool for finding duplicated extents and
submitting them for deduplication. When given a list of files it will
hash their contents on a block by block basis and compare those hashes
to each other, finding and categorizing extents that match each other.

When given the -d option, duperemove will submit those extents for
deduplication using the btrfs-extent-same ioctl.

%prep
git init .
git remote add -t \* -f origin %{url}.git
git checkout v%{version}

%build
make

%install
make install DESTDIR=%{buildroot} PREFIX=%{_prefix} BINDIR=%{_sbindir}

%files
%doc README.md
%license LICENSE
%{_mandir}/man8/btrfs-extent-same*.8*
%{_mandir}/man8/%{name}*.8*
%{_mandir}/man8/hashstats*.8*
%{_mandir}/man8/show-shared-extents*.8*
%{_sbindir}/btrfs-extent-same
%{_sbindir}/%{name}
%{_sbindir}/hashstats

%changelog
* Wed Jul 19 2023 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.3-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Thu Jan 19 2023 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.3-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Thu Jul 21 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.3-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Thu Jan 20 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Wed Sep  8 2021 Jonathan Dieter <jdieter@gmail.com> - 0.11.3-1
- Update to 0.11.3 with bug fixes
- Remove patch to use system xxhash since upstream does that by default now

* Wed Jul 21 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.1-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Tue Jan 26 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.1-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Mon Jul 27 2020 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.1-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Mon Feb 03 2020 Jonathan Dieter <jdieter@gmail.com> - 0.11.1-3
- Work around GCC 10 build failure

* Tue Jan 28 2020 Fedora Release Engineering <releng@fedoraproject.org> - 0.11.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Tue Dec 10 2019 Jonathan Dieter <jdieter@gmail.com> - 0.11.1-1.1
- Fix build for EPEL-8

* Sun Dec 08 2019 Jonathan Dieter <jdieter@gmail.com> - 0.11.1-1
- New release

* Wed Jul 24 2019 Fedora Release Engineering <releng@fedoraproject.org> - 0.11-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Thu Jan 31 2019 Fedora Release Engineering <releng@fedoraproject.org> - 0.11-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Sat Oct 20 2018 Jonathan Dieter <jdieter@gmail.com> - 0.11-3
- Add devsettool BR and build for EPEL

* Fri Oct 19 2018 Jonathan Dieter <jdieter@gmail.com> - 0.11-2
- Add missing BR
- Fix build to use build flags

* Sat Oct 13 2018 Jonathan Dieter <jdieter@gmail.com> - 0.11-1
- Bump to 0.11
- Unbundle xxhash

* Fri Nov 13 2015 Francesco Frassinelli <fraph24@gmail.com> - 0.10-1
- Version bump; license and minor packaging issues fixed

* Thu Jul 30 2015 Francesco Frassinelli <fraph24@gmail.com> - 0.09.5-2
- %%license macro added

* Sun Jul 19 2015 Francesco Frassinelli <fraph24@gmail.com> - 0.09.5-1
- Initial build

