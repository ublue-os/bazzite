%global glib2_version                   2.50
%global gobject_introspection_version   1.30.0
%global polkit_version                  0.102
%global systemd_version                 208
%global libatasmart_version             0.17
%global dbus_version                    1.4.0
%global with_gtk_doc                    1
%global libblockdev_version             2.25

%define with_bcache                     1
%define with_btrfs                      1
%define with_lsm                        1
%define with_zram                       1
%define with_lvmcache                   1

# valid options are 'luks1' or 'luks2'
%define default_luks_encryption         luks2

%define is_fedora                       0%{?rhel} == 0
%define is_git                          %(git show > /dev/null 2>&1 && echo 1 || echo 0)
%define git_hash                        %(git log -1 --pretty=format:"%h" || true)
%define build_date                      %(date '+%Y%m%d')


# bcache and zram are not available on RHEL
%if (0%{?rhel})
%define with_bcache 0
%define with_zram 0
%endif

# btrfs is not available on RHEL > 7
%if 0%{?rhel} > 7
%define with_btrfs 0
%endif

# feature parity with existing RHEL 7 packages
%if (0%{?rhel}) && (0%{?rhel} <= 7)
%define with_lsm 0
%define with_lvmcache 0
%endif


Name:    udisks2
Summary: Disk Manager
%define upstream_version 2.9.4
Version: %{upstream_version}.bazzite.{{{ git_dir_version }}}
Release: 7%{?dist}
License: GPLv2+
URL:     https://github.com/storaged-project/udisks
Source: https://github.com/storaged-project/udisks/releases/download/udisks-%{upstream_version}/udisks-%{upstream_version}.tar.bz2
Patch0:  ignore-apple-boot-part.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2001549
Patch1:  udisks-2.10.0-static_daemon_resources_free.patch
Patch2:  udisks-2.10.0-lvm2_teardown_tests.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2030916
Patch3:  udisks-2.10.0-vdo_test_writeAmplificationRatio.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2120329
Patch4:  udisks-2.10.0-block_format_ata_secure_erase.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=1983602
Patch5:  udisks-2.10.0-iscsi-auth-info.patch
Patch6:  udisks-2.10.0-doc_annotations.patch

# https://bugzilla.redhat.com/show_bug.cgi?id=2136557
Patch10: udisks-2.10.0-iscsi_test_01_badauth.patch
Patch11: udisks-2.10.0-iscsi_test_02_lio_target_conf.patch
Patch12: udisks-2.10.0-iscsi_test_03_iscsid_cache_clean.patch
Patch13: udisks-2.10.0-iscsi_test_04_fix_test_login_chap_auth.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=1958932
Patch14: udisks-2.10.0-iscsi_test_05_restart_iscsid.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2188916
Patch15: udisks-2.10.0-iscsi-CHAP-auth-algs.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2188750
# https://bugzilla.redhat.com/show_bug.cgi?id=2188752
Patch16: udisks-2.9.4-FIPS_LUKS_fixes.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2211191
Patch17: udisks-2.10.0-integration_test_force_readonly.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2031673
Patch18: udisks-2.10.0-lvm2_update_epoch.patch
Patch19: udisks-2.10.0-lvm2_vgcreate_uevent_sync.patch
# https://bugzilla.redhat.com/show_bug.cgi?id=2148844
Patch20: udisks-2.9.4-tests_job_unstable.patch

# Bazzite
Patch21: sanitize-mount-point.patch
Patch22: mount-other-user.patch

BuildRequires: make
BuildRequires: glib2-devel >= %{glib2_version}
BuildRequires: gobject-introspection-devel >= %{gobject_introspection_version}
BuildRequires: libgudev1-devel >= %{systemd_version}
BuildRequires: libatasmart-devel >= %{libatasmart_version}
BuildRequires: polkit-devel >= %{polkit_version}
BuildRequires: systemd >= %{systemd_version}
BuildRequires: systemd-devel >= %{systemd_version}
BuildRequires: libacl-devel
BuildRequires: chrpath
BuildRequires: gtk-doc
BuildRequires: gettext-devel
BuildRequires: redhat-rpm-config
BuildRequires: libblockdev-devel        >= %{libblockdev_version}
BuildRequires: libblockdev-part-devel   >= %{libblockdev_version}
BuildRequires: libblockdev-loop-devel   >= %{libblockdev_version}
BuildRequires: libblockdev-swap-devel   >= %{libblockdev_version}
BuildRequires: libblockdev-mdraid-devel >= %{libblockdev_version}
BuildRequires: libblockdev-fs-devel     >= %{libblockdev_version}
BuildRequires: libblockdev-crypto-devel >= %{libblockdev_version}
BuildRequires: libmount-devel
BuildRequires: libuuid-devel

Requires: libblockdev        >= %{libblockdev_version}
Requires: libblockdev-part   >= %{libblockdev_version}
Requires: libblockdev-loop   >= %{libblockdev_version}
Requires: libblockdev-swap   >= %{libblockdev_version}
Requires: libblockdev-mdraid >= %{libblockdev_version}
Requires: libblockdev-fs     >= %{libblockdev_version}
Requires: libblockdev-crypto >= %{libblockdev_version}

# Needed for the systemd-related macros used in this file
%{?systemd_requires}
BuildRequires: systemd

# Needed to pull in the system bus daemon
Requires: dbus >= %{dbus_version}
# Needed to pull in the udev daemon
Requires: udev >= %{systemd_version}
# We need at least this version for bugfixes/features etc.
Requires: libatasmart >= %{libatasmart_version}
# For mount, umount, mkswap
Requires: util-linux
# For mkfs.ext3, mkfs.ext3, e2label
Requires: e2fsprogs
# For mkfs.xfs, xfs_admin
Requires: xfsprogs
# For mkfs.vfat
Requires: dosfstools
Requires: gdisk
# For ejecting removable disks
Requires: eject
# For utab monitor
Requires: libmount

%if ! (0%{?rhel} && 0%{?rhel} < 8)
# Not really needed but doesn't make much sense to use UDisks without polkit
# (weak deps don't work on older versions of RHEL)
Recommends: polkit
%endif

Requires: lib%{name}%{?_isa} = %{version}-%{release}

# For mkntfs (not available on rhel or on ppc/ppc64)
%if ! 0%{?rhel}
Requires: ntfsprogs
Requires: ntfs-3g
%endif

Provides:  storaged = %{version}-%{release}
Obsoletes: storaged

%description
The Udisks project provides a daemon, tools and libraries to access and
manipulate disks, storage devices and technologies.

%package -n lib%{name}
Summary: Dynamic library to access the udisksd daemon
License: LGPLv2+
Provides:  libstoraged = %{version}-%{release}
Obsoletes: libstoraged

%description -n lib%{name}
This package contains the dynamic library, which provides
access to the udisksd daemon.

%package -n %{name}-iscsi
Summary: Module for iSCSI
Requires: %{name}%{?_isa} = %{version}-%{release}
License: LGPLv2+
Requires: iscsi-initiator-utils
BuildRequires: iscsi-initiator-utils-devel
Provides:  storaged-iscsi = %{version}-%{release}
Obsoletes: storaged-iscsi

%description -n %{name}-iscsi
This package contains module for iSCSI configuration.

%package -n %{name}-lvm2
Summary: Module for LVM2
Requires: %{name}%{?_isa} = %{version}-%{release}
License: LGPLv2+
Requires: lvm2
Requires: libblockdev-lvm >= %{libblockdev_version}
BuildRequires: lvm2-devel
BuildRequires: libblockdev-lvm-devel >= %{libblockdev_version}
Provides:  storaged-lvm2 = %{version}-%{release}
Obsoletes: storaged-lvm2

%description -n %{name}-lvm2
This package contains module for LVM2 configuration.

%package -n lib%{name}-devel
Summary: Development files for lib%{name}
Requires: lib%{name}%{?_isa} = %{version}-%{release}
License: LGPLv2+
Provides:  libstoraged-devel = %{version}-%{release}
Obsoletes: libstoraged-devel

%description -n lib%{name}-devel
This package contains the development files for the library lib%{name}, a
dynamic library, which provides access to the udisksd daemon.

%if 0%{?with_bcache}
%package -n %{name}-bcache
Summary: Module for Bcache
Requires: %{name}%{?_isa} = %{version}-%{release}
License: LGPLv2+
Requires: libblockdev-kbd >= %{libblockdev_version}
BuildRequires: libblockdev-kbd-devel >= %{libblockdev_version}
Provides:  storaged-bcache = %{version}-%{release}
Obsoletes: storaged-bcache

%description -n %{name}-bcache
This package contains module for Bcache configuration.
%endif

%if 0%{?with_btrfs}
%package -n %{name}-btrfs
Summary: Module for BTRFS
Requires: %{name}%{?_isa} = %{version}-%{release}
License: LGPLv2+
Requires: libblockdev-btrfs >= %{libblockdev_version}
BuildRequires: libblockdev-btrfs-devel >= %{libblockdev_version}
Provides:  storaged-btrfs = %{version}-%{release}
Obsoletes: storaged-btrfs

%description -n %{name}-btrfs
This package contains module for BTRFS configuration.
%endif

%if 0%{?with_lsm}
%package -n %{name}-lsm
Summary: Module for LSM
Requires: %{name}%{?_isa} = %{version}-%{release}
License: LGPLv2+
Requires: libstoragemgmt
BuildRequires: libstoragemgmt-devel
BuildRequires: libconfig-devel
Provides:  storaged-lsm = %{version}-%{release}
Obsoletes: storaged-lsm

%description -n %{name}-lsm
This package contains module for LSM configuration.
%endif

%if 0%{?with_zram}
%package -n %{name}-zram
Summary: Module for ZRAM
Requires: %{name}%{?_isa} = %{version}-%{release}
License: LGPLv2+
Requires: libblockdev-kbd >= %{libblockdev_version}
Requires: libblockdev-swap >= %{libblockdev_version}
BuildRequires: libblockdev-kbd-devel >= %{libblockdev_version}
BuildRequires: libblockdev-swap-devel
Provides:  storaged-zram = %{version}-%{release}
Obsoletes: storaged-zram

%description -n %{name}-zram
This package contains module for ZRAM configuration.
%endif

%prep
%autosetup -p1 -n udisks-%{upstream_version}
sed -i udisks/udisks2.conf.in -e "s/encryption=luks1/encryption=%{default_luks_encryption}/"
rm -f src/tests/dbus-tests/config_h.py

%build
autoreconf -ivf
# modules need to be explicitly enabled
%configure            \
%if %{with_gtk_doc}
    --enable-gtk-doc  \
%else
    --disable-gtk-doc \
%endif
%if 0%{?with_bcache}
    --enable-bcache   \
%endif
%if 0%{?with_btrfs}
    --enable-btrfs    \
%endif
    --disable-vdo      \
%if 0%{?with_zram}
    --enable-zram     \
%endif
%if 0%{?with_lsm}
    --enable-lsm      \
%endif
%if 0%{?with_lvmcache}
    --enable-lvmcache \
%endif
    --enable-lvm2     \
    --enable-iscsi
make %{?_smp_mflags}

%install
make install DESTDIR=%{buildroot}
%if %{with_gtk_doc} == 0
rm -fr %{buildroot}/%{_datadir}/gtk-doc/html/udisks2
%endif

find %{buildroot} -name \*.la -o -name \*.a | xargs rm

chrpath --delete %{buildroot}/%{_sbindir}/umount.udisks2
chrpath --delete %{buildroot}/%{_bindir}/udisksctl
chrpath --delete %{buildroot}/%{_libexecdir}/udisks2/udisksd

%find_lang udisks2

%post -n %{name}
%systemd_post udisks2.service
# skip retriggering if udevd isn't even accessible, e.g. containers or
# rpm-ostree-based systems
if [ -S /run/udev/control ]; then
    udevadm control --reload
    udevadm trigger
fi

%preun -n %{name}
%systemd_preun udisks2.service

%postun -n %{name}
%systemd_postun_with_restart udisks2.service

%ldconfig_scriptlets -n lib%{name}

%if 0%{?with_zram}
%post -n %{name}-zram
%systemd_post udisks2-zram-setup@.service
if [ -S /run/udev/control ]; then
    udevadm control --reload
    udevadm trigger
fi

%preun -n %{name}-zram
%systemd_preun udisks2-zram-setup@.service

%postun -n %{name}-zram
%systemd_postun udisks2-zram-setup@.service
%endif

%files -f udisks2.lang
%doc README.md AUTHORS NEWS HACKING
%license COPYING

%dir %{_sysconfdir}/udisks2
%if %{is_fedora}
%dir %{_sysconfdir}/udisks2/modules.conf.d
%endif
%{_sysconfdir}/udisks2/udisks2.conf
%{_sysconfdir}/udisks2/mount_options.conf.example

%{_datadir}/dbus-1/system.d/org.freedesktop.UDisks2.conf
%{_datadir}/bash-completion/completions/udisksctl
%{_tmpfilesdir}/%{name}.conf
%{_unitdir}/udisks2.service
%{_udevrulesdir}/80-udisks2.rules
%{_sbindir}/umount.udisks2


%dir %{_libdir}/udisks2
%dir %{_libdir}/udisks2/modules
%dir %{_libexecdir}/udisks2
%{_libexecdir}/udisks2/udisksd

%{_bindir}/udisksctl

%{_mandir}/man1/udisksctl.1*
%{_mandir}/man5/udisks2.conf.5*
%{_mandir}/man8/udisksd.8*
%{_mandir}/man8/udisks.8*
%{_mandir}/man8/umount.udisks2.8*

%{_datadir}/polkit-1/actions/org.freedesktop.UDisks2.policy
%{_datadir}/dbus-1/system-services/org.freedesktop.UDisks2.service

# Permissions for local state data are 0700 to avoid leaking information
# about e.g. mounts to unprivileged users
%attr(0700,root,root) %dir %{_localstatedir}/lib/udisks2

%files -n lib%{name}
%{_libdir}/libudisks2.so.*
%{_libdir}/girepository-1.0/UDisks-2.0.typelib

%files -n %{name}-lvm2
%{_libdir}/udisks2/modules/libudisks2_lvm2.so
%{_datadir}/polkit-1/actions/org.freedesktop.UDisks2.lvm2.policy

%files -n %{name}-iscsi
%{_libdir}/udisks2/modules/libudisks2_iscsi.so
%{_datadir}/polkit-1/actions/org.freedesktop.UDisks2.iscsi.policy

%files -n lib%{name}-devel
%{_libdir}/libudisks2.so
%dir %{_includedir}/udisks2
%dir %{_includedir}/udisks2/udisks
%{_includedir}/udisks2/udisks/*.h
%{_datadir}/gir-1.0/UDisks-2.0.gir
%if %{with_gtk_doc}
%dir %{_datadir}/gtk-doc/html/udisks2
%{_datadir}/gtk-doc/html/udisks2/*
%endif
%{_libdir}/pkgconfig/udisks2.pc
%{_libdir}/pkgconfig/udisks2-lvm2.pc
%{_libdir}/pkgconfig/udisks2-iscsi.pc
%if 0%{?with_bcache}
%{_libdir}/pkgconfig/udisks2-bcache.pc
%endif
%if 0%{?with_btrfs}
%{_libdir}/pkgconfig/udisks2-btrfs.pc
%endif
%if 0%{?with_lsm}
%{_libdir}/pkgconfig/udisks2-lsm.pc
%endif
%if 0%{?with_zram}
%{_libdir}/pkgconfig/udisks2-zram.pc
%endif

%if 0%{?with_bcache}
%files -n %{name}-bcache
%{_libdir}/udisks2/modules/libudisks2_bcache.so
%{_datadir}/polkit-1/actions/org.freedesktop.UDisks2.bcache.policy
%endif

%if 0%{?with_btrfs}
%files -n %{name}-btrfs
%{_libdir}/udisks2/modules/libudisks2_btrfs.so
%{_datadir}/polkit-1/actions/org.freedesktop.UDisks2.btrfs.policy
%endif

%if 0%{?with_lsm}
%files -n %{name}-lsm
%dir %{_sysconfdir}/udisks2/modules.conf.d
%{_libdir}/udisks2/modules/libudisks2_lsm.so
%{_mandir}/man5/udisks2_lsm.conf.*
%{_datadir}/polkit-1/actions/org.freedesktop.UDisks2.lsm.policy
%attr(0600,root,root) %{_sysconfdir}/udisks2/modules.conf.d/udisks2_lsm.conf
%endif

%if 0%{?with_zram}
%files -n %{name}-zram
%dir %{_sysconfdir}/udisks2/modules.conf.d
%{_libdir}/udisks2/modules/libudisks2_zram.so
%{_datadir}/polkit-1/actions/org.freedesktop.UDisks2.zram.policy
%{_unitdir}/udisks2-zram-setup@.service
%{_udevrulesdir}/90-udisks2-zram.rules
%endif

%changelog
* Thu Jun 29 2023 Tomas Bzatek <tbzatek@redhat.com> - 2.9.4-7
- iscsi: CHAP auth algorithm selection fixes (#2188916)
- tests: Use stronger passphrases for LUKS tests (#2188750,#2188752)
- integration-test: Fix scsi_debug cd drive read-only detection (#2211191)
- lvm2: Improve uevent processing (#2031673)
- tests: Mark test_job.UdisksJobTest.test_job as unstable (#2148844)
- Fix iscsi test auth failures (#1958932)
- Fix iscsi test LIO target config (#2136557)
- Fix iscsi authentication info override (#1983602)
- Restrict ATA Secure Erase Format() options (#2120329)
- Fix LVM-VDO statistics tests (#2030916)
- Fix double free on daemon exit (unaligned fastbin chunk) (#2001549)

* Sat Jan 21 2023 Fedora Release Engineering <releng@fedoraproject.org> - 2.9.4-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Sat Jul 23 2022 Fedora Release Engineering <releng@fedoraproject.org> - 2.9.4-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Thu Mar 03 2022 Tomas Bzatek <tbzatek@redhat.com> - 2.9.4-4
- Fix gtk-doc annotations

* Thu Mar 03 2022 Tomas Bzatek <tbzatek@redhat.com> - 2.9.4-3
- Require ntfs-3g (#2058506)

* Sat Jan 22 2022 Fedora Release Engineering <releng@fedoraproject.org> - 2.9.4-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Mon Oct 04 2021 Tomas Bzatek <tbzatek@redhat.com> - 2.9.4-1
- Version 2.9.4
- Fixes CVE-2021-3802 (#2003650)

* Thu Aug 05 2021 Tomas Bzatek <tbzatek@redhat.com> - 2.9.3-1
- Version 2.9.3

* Fri Jul 23 2021 Fedora Release Engineering <releng@fedoraproject.org> - 2.9.2-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Fri Jun 18 2021 Tomas Bzatek <tbzatek@redhat.com> - 2.9.2-5
- Switch the default encryption to LUKS2

* Mon Apr 19 2021 Tomas Bzatek <tbzatek@redhat.com> - 2.9.2-4
- Fix a couple of issues found by Coverity
- Ignore systemd "Extended Boot Loader" GPT partition

* Fri Mar 26 2021 Tomas Bzatek <tbzatek@redhat.com> - 2.9.2-3
- Fix FAT mkfs with dosfstools >= 4.2
- udiskslinuxdriveata: Use GTask to apply configuration in a thread
- Limit allowed module names
- 80-udisks2.rules: Ignore Apple boot partition from livecd-tools

* Tue Mar 02 2021 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> - 2.9.2-2
- Rebuilt for updated systemd-rpm-macros
  See https://pagure.io/fesco/issue/2583.

* Thu Feb 04 2021 Tomas Bzatek <tbzatek@redhat.com> - 2.9.2-1
- Version 2.9.2

* Wed Jan 27 2021 Fedora Release Engineering <releng@fedoraproject.org> - 2.9.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Mon Sep 07 2020 Neal Gompa <ngompa13@gmail.com> - 2.9.1-2
- Fix conditional around polkit Recommends for building on EL7

* Wed Aug 12 2020 Tomas Bzatek <tbzatek@redhat.com> - 2.9.1-1
- Version 2.9.1
- Renamed zram-setup@.service to udisks2-zram-setup@.service

* Wed Jul 29 2020 Fedora Release Engineering <releng@fedoraproject.org> - 2.9.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Tue May 26 2020 Tomas Bzatek <tbzatek@redhat.com> - 2.9.0-1
- Version 2.9.0

* Fri Jan 31 2020 Fedora Release Engineering <releng@fedoraproject.org> - 2.8.4-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Tue Oct 01 2019 Jonathan Lebon <jonathan@jlebon.com> - 2.8.4-3
- Don't trigger udev if socket is not accessible

* Sat Jul 27 2019 Fedora Release Engineering <releng@fedoraproject.org> - 2.8.4-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Mon Jul 22 2019 Tomas Bzatek <tbzatek@redhat.com> - 2.8.4-1
- Version 2.8.4

* Thu Jun 13 2019 Tomas Bzatek <tbzatek@redhat.com> - 2.8.3-1
- Version 2.8.3

* Fri Mar 15 2019 Debarshi Ray <rishi@fedoraproject.org> - 2.8.2-2
- Update for tmpfiles.d snippet

* Mon Mar 04 2019 Tomas Bzatek <tbzatek@redhat.com> - 2.8.2-1
- Version 2.8.2

* Sun Feb 03 2019 Fedora Release Engineering <releng@fedoraproject.org> - 2.8.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Wed Sep 26 2018 Vojtech Trefny <vtrefny@redhat.com> - 2.8.1-1
- Version 2.8.1

* Fri Sep 14 2018 Adam Williamson <awilliam@redhat.com> - 2.8.0-2
- Backport PR #576 to fix udev multipath device check (see RHBZ#1628192)

* Mon Aug 13 2018 Tomas Bzatek <tbzatek@redhat.com> - 2.8.0-1
- Version 2.8.0

* Tue Jul 24 2018 Adam Williamson <awilliam@redhat.com> - 2.7.7-3
- Rebuild for new libconfig

* Sat Jul 14 2018 Fedora Release Engineering <releng@fedoraproject.org> - 2.7.7-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Wed Jul 04 2018 Vojtech Trefny <vtrefny@redhat.com> - 2.7.7-1
- Version 2.7.7

* Thu Feb 08 2018 Vojtech Trefny <vtrefny@redhat.com> - 2.7.6-1
- Version 2.7.6

* Fri Feb 02 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 2.7.5-2
- Switch to %%ldconfig_scriptlets

* Mon Dec 04 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.5-1
- Version 2.7.5

* Wed Nov 01 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.4-1
- Version 2.7.4

* Thu Aug 31 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.3-1
- Version 2.7.3

* Thu Aug 03 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.2-1
- Version 2.7.2

* Thu Aug 03 2017 Fedora Release Engineering <releng@fedoraproject.org> - 2.7.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Thu Jul 27 2017 Fedora Release Engineering <releng@fedoraproject.org> - 2.7.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Mon Jul 03 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.1-1
- Version 2.7.1

* Tue Jun 20 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.0-3
- Do not try to remove changed_blacklist hash table in finalize

* Mon Jun 19 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.0-2
- Fix how UDisksClient filters property changes

* Fri Jun 02 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.7.0-1
- Version 2.7.0

* Mon May 15 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.6.5-1
- Version 2.6.5

* Tue Mar 14 2017 Vojtech Trefny <vtrefny@redhat.com> - 2.6.4-1
- Version 2.6.4

* Mon Nov 14 2016 Tomas Smetana <tsmetana@redhat.com> - 2.6.3-1
- Version 2.6.3

* Thu Jun 16 2016 Tomas Smetana <tsmetana@redhat.com> - 2.6.2-1
- Version 2.6.2; aimed to replace udisks2

* Wed Apr 27 2016 Peter Hatina <phatina@redhat.com> - 2.6.0-3
- Add support for libblockdev-part plugin which replaces
  parted calls

* Wed Mar 16 2016 Peter Hatina <phatina@redhat.com> - 2.6.0-2
- Fix permissions set for storaged_lsm.conf so it is readable only by root

* Mon Mar 14 2016 Peter Hatina <phatina@redhat.com> - 2.6.0-1
- Upgrade to 2.6.0

* Wed Feb 10 2016 Peter Hatina <phatina@redhat.com> - 2.5.0-3
- Package template zram-setup@.service file

* Wed Feb 10 2016 Peter Hatina <phatina@redhat.com> - 2.5.0-2
- Add udisksd configuration file and its man page

* Thu Jan 28 2016 Peter Hatina <phatina@redhat.com> - 2.5.0-1
- UDisks2 drop-in replacement

* Thu Jan 21 2016 Peter Hatina <phatina@redhat.com> - 2.4.0-3
- Redesign subpackage dependencies
- Make GTK documentation generation configurable

* Wed Jan 20 2016 Peter Hatina <phatina@redhat.com> - 2.4.0-2
- Reload udev rules and trigger events when installed

* Wed Jan 13 2016 Peter Hatina <phatina@redhat.com> - 2.4.0-1
- Upgrade to 2.4.0

* Wed Sep 30 2015 Peter Hatina <phatina@redhat.com> - 2.3.0-2
- Add Fedora/RHEL package configuration options

* Mon Sep 14 2015 Peter Hatina <phatina@redhat.com> - 2.3.0-1
- Change BuildRequires from pkgconfig macro to -devel packages
- Upgrade to 2.3.0

* Mon Aug 24 2015 Peter Hatina <phatina@redhat.com> - 2.2.0-1
- Upgrade to 2.2.0

* Fri Jul  3 2015 Peter Hatina <phatina@redhat.com> - 2.1.1-1
- Upgrade to 2.1.1

* Wed Jun 24 2015 Peter Hatina <phatina@redhat.com> - 2.1.0-4
- Add Requires for storaged modules

* Wed Jun 24 2015 Peter Hatina <phatina@redhat.com> - 2.1.0-3
- Changes for EPEL-7
  - Lower systemd required version to 208
  - Rewrite BuildRequires for systemd-devel

* Fri Jun 19 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 2.1.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Thu Jun 11 2015 Peter Hatina <phatina@redhat.com> - 2.1.0-1
- Update to upstream 2.1.0

* Thu Apr 02 2015 Peter Hatina <phatina@redhat.com> - 2.0.0-1
- Rebase to the new Storaged implementation
- Upstream: https://storaged.org

* Tue Sep 16 2014 Stef Walter <stefw@redhat.com> - 0.3.1-1
- Update to upstream 0.3.1

* Mon Aug 18 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.3.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Sun Jun 08 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 0.3.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue Apr 08 2014 Patrick Uiterwijk <puiterwijk@redhat.com> - 0.3.0-1
- Update to upstream 0.3.0

* Fri Jan 31 2014 Patrick Uiterwijk <puiterwijk@redhat.com> - 0.2.0-1
- Update to upstream 0.2.0

* Thu Jan 16 2014 Patrick Uiterwijk <puiterwijk@redhat.com> - 0.1.0-2
- Removed double systemd BuildRequire
- Rewritten summary and description

* Sun Jan 12 2014 Patrick Uiterwijk <puiterwijk@redhat.com> - 0.1.0-1
- Rename from udisks2-lvm
