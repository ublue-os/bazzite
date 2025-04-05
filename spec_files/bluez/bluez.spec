%if 0%{?fedora} || 0%{?rhel} <= 8
%bcond_without deprecated
%else
%bcond_with deprecated
%endif

Name:    bluez
Version: 5.79
Release: 1%{?dist}.bazzite.{{{ git_dir_version }}}
Summary: Bluetooth utilities
License: GPL-2.0-or-later
URL:     http://www.bluez.org/

Source0: https://www.kernel.org/pub/linux/bluetooth/%{name}-%{version}.tar.xz

# Valve
Patch0: 0001-valve-bluetooth-config.patch
Patch1: 0002-valve-bluetooth-phy.patch
Patch2: 0014-shared-gatt-Add-env-variable-to-prefer-indication-ov.patch
Patch3: 0018-disable-unreliable-vcp-tests.patch
Patch4: 0019-plugins-Add-new-plugin-to-manage-wake-policy.patch
Patch5: 0020-plugins-wake-policy-Only-allow-Peripherals-to-wake-u.patch
Patch6: 0021-valve-bluetooth-ll-privacy.patch

BuildRequires: dbus-devel >= 1.6
BuildRequires: glib2-devel
BuildRequires: libell-devel >= 0.37
BuildRequires: libical-devel
BuildRequires: make
BuildRequires: readline-devel
# For bluetooth mesh
BuildRequires: json-c-devel
# For cable pairing
BuildRequires: systemd-devel
# For udev rules
BuildRequires: systemd
# For printing
BuildRequires: cups-devel
# For autoreconf
BuildRequires: libtool automake autoconf
# For man pages
BuildRequires: python3-docutils
BuildRequires: python3-pygments

Requires: dbus >= 1.6
Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd

%description
Utilities for use in Bluetooth applications:
	- avinfo
	- bluemoon
	- bluetoothctl
	- bluetoothd
	- btattach
	- btmon
	- hex2hcd
	- mpris-proxy

The BLUETOOTH trademarks are owned by Bluetooth SIG, Inc., U.S.A.

%package cups
Summary: CUPS printer backend for Bluetooth printers
Requires: bluez%{?_isa} = %{version}-%{release}
Requires: cups

%description cups
This package contains the CUPS backend

%if %{with deprecated}
%package deprecated
Summary: Deprecated Bluetooth applications
Requires: bluez%{?_isa} = %{version}-%{release}
Obsoletes: bluez < 5.55-2

%description deprecated
Bluetooth applications that have bee deprecated by upstream. They have been
replaced by funcationality in the core bluetoothctl and will eventually
be dropped by upstream. Utilities include:
	- ciptool
	- gatttool
	- hciattach
	- hciconfig
	- hcidump
	- hcitool
	- meshctl
	- rfcomm
	- sdptool
%endif

%package libs
Summary: Libraries for use in Bluetooth applications

%description libs
Libraries for use in Bluetooth applications.

%package libs-devel
Summary: Development libraries for Bluetooth applications
Requires: bluez-libs%{?_isa} = %{version}-%{release}

%description libs-devel
bluez-libs-devel contains development libraries and headers for
use in Bluetooth applications.

%package hid2hci
Summary: Put HID proxying bluetooth HCI's into HCI mode
Requires: bluez%{?_isa} = %{version}-%{release}

%description hid2hci
Most allinone PC's and bluetooth keyboard / mouse sets which include a
bluetooth dongle, ship with a so called HID proxying bluetooth HCI.
The HID proxying makes the keyboard / mouse show up as regular USB HID
devices (after connecting using the connect button on the device + keyboard),
which makes them work without requiring any manual configuration.

The bluez-hid2hci package contains the hid2hci utility and udev rules to
automatically switch supported Bluetooth devices into regular HCI mode.

Install this package if you want to use the bluetooth function of the HCI
with other bluetooth devices like for example a mobile phone.

Note that after installing this package you will first need to pair your
bluetooth keyboard and mouse with the bluetooth adapter before you can use
them again. Since you cannot use your bluetooth keyboard and mouse until
they are paired, this will require the use of a regular (wired) USB keyboard
and mouse.

%package mesh
Summary: Bluetooth mesh
Requires: bluez%{?_isa} = %{version}-%{release}
Requires: bluez-libs%{?_isa} = %{version}-%{release}

%description mesh
Services for bluetooth mesh

%package obexd
Summary: Object Exchange daemon for sharing content
Requires: bluez%{?_isa} = %{version}-%{release}
Requires: bluez-libs%{?_isa} = %{version}-%{release}

%description obexd
Object Exchange daemon for sharing files, contacts etc over bluetooth

%prep
%autosetup -p1

%build
autoreconf -vif
%configure --enable-tools --enable-library \
           --enable-external-ell --disable-optimization \
%if %{with deprecated}
           --enable-deprecated \
%endif
           --enable-sixaxis --enable-cups --enable-nfc --enable-mesh \
           --enable-hid2hci --enable-testing --enable-experimental \
           --enable-bap --enable-bass --enable-mcp --enable-micp \
           --enable-csip --enable-vcp \
           --with-systemdsystemunitdir=%{_unitdir} \
           --with-systemduserunitdir=%{_userunitdir}

%{make_build}

%install
%{make_install}

%if %{with deprecated}
# "make install" fails to install gatttool, necessary for Bluetooth Low Energy
# Red Hat Bugzilla bug #1141909, Debian bug #720486
install -m0755 attrib/gatttool $RPM_BUILD_ROOT%{_bindir}
%endif

# "make install" fails to install avinfo
# Red Hat Bugzilla bug #1699680
install -m0755 tools/avinfo $RPM_BUILD_ROOT%{_bindir}

# btmgmt is not installed by "make install", but it is useful for debugging
# some issues and to set the MAC address on HCIs which don't have their
# MAC address configured 
install -m0755 tools/btmgmt $RPM_BUILD_ROOT%{_bindir}

# Remove libtool archive
find $RPM_BUILD_ROOT -name '*.la' -delete

# Remove the cups backend from libdir, and install it in /usr/lib whatever the install
if test -d ${RPM_BUILD_ROOT}/usr/lib64/cups ; then
	install -D -m0755 ${RPM_BUILD_ROOT}/usr/lib64/cups/backend/bluetooth ${RPM_BUILD_ROOT}%_cups_serverbin/backend/bluetooth
	rm -rf ${RPM_BUILD_ROOT}%{_libdir}/cups
fi

rm -f ${RPM_BUILD_ROOT}/%{_sysconfdir}/udev/*.rules ${RPM_BUILD_ROOT}/usr/lib/udev/rules.d/*.rules
install -D -p -m0644 tools/hid2hci.rules ${RPM_BUILD_ROOT}/%{_udevrulesdir}/97-hid2hci.rules

install -d -m0755 $RPM_BUILD_ROOT/%{_localstatedir}/lib/bluetooth
install -d -m0755 $RPM_BUILD_ROOT/%{_localstatedir}/lib/bluetooth/mesh

mkdir -p $RPM_BUILD_ROOT/%{_libdir}/bluetooth/

#copy bluetooth config files
install -D -p -m0644 src/main.conf ${RPM_BUILD_ROOT}/etc/bluetooth/main.conf
install -D -p -m0644 mesh/mesh-main.conf ${RPM_BUILD_ROOT}/etc/bluetooth/mesh-main.conf
install -D -p -m0644 profiles/input/input.conf ${RPM_BUILD_ROOT}/etc/bluetooth/input.conf
install -D -p -m0644 profiles/network/network.conf ${RPM_BUILD_ROOT}/etc/bluetooth/network.conf

# Install the HCI emulator, useful for testing
install emulator/btvirt ${RPM_BUILD_ROOT}/%{_libexecdir}/bluetooth/

#check
#make check

%ldconfig_scriptlets libs

%post
%systemd_post bluetooth.service

%preun
%systemd_preun bluetooth.service

%postun
%systemd_postun_with_restart bluetooth.service

%post hid2hci
/sbin/udevadm trigger --subsystem-match=usb

%post mesh
%systemd_user_post bluetooth-mesh.service

%preun mesh
%systemd_user_preun bluetooth-mesh.service

%post obexd
%systemd_user_post obex.service

%preun obexd
%systemd_user_preun obex.service

%files
%license COPYING
%doc AUTHORS ChangeLog
# bluetooth.service expects configuraton directory to be read only
# https://github.com/bluez/bluez/issues/329#issuecomment-1102459104
%attr(0555, root, root) %dir %{_sysconfdir}/bluetooth
%config(noreplace) %{_sysconfdir}/bluetooth/main.conf
%config(noreplace) %{_sysconfdir}/bluetooth/input.conf
%config(noreplace) %{_sysconfdir}/bluetooth/network.conf
%{_bindir}/avinfo
%{_bindir}/bluemoon
%{_bindir}/bluetoothctl
%{_bindir}/btattach
%{_bindir}/btmgmt
%{_bindir}/btmon
%{_bindir}/hex2hcd
%{_bindir}/mpris-proxy
%{_mandir}/man1/bluetoothctl.1.*
%{_mandir}/man1/bluetoothctl-*.1.*
%{_mandir}/man1/btmgmt.1.*
%{_mandir}/man1/btattach.1.*
%{_mandir}/man1/btmon.1.*
%{_mandir}/man8/bluetoothd.8.*
%dir %{_libexecdir}/bluetooth
%{_libexecdir}/bluetooth/bluetoothd
%{_libdir}/bluetooth/
# bluetooth.service expects StateDirectoryMode to be 700.
%attr(0700, root, root) %dir %{_localstatedir}/lib/bluetooth
%dir %{_localstatedir}/lib/bluetooth/mesh
%{_datadir}/dbus-1/system.d/bluetooth.conf
%{_datadir}/dbus-1/system-services/org.bluez.service
%{_unitdir}/bluetooth.service
%{_userunitdir}/mpris-proxy.service
%{_datadir}/zsh/site-functions/_bluetoothctl

%if %{with deprecated}
%files deprecated
%{_bindir}/ciptool
%{_bindir}/gatttool
%{_bindir}/hciattach
%{_bindir}/hciconfig
%{_bindir}/hcidump
%{_bindir}/hcitool
%{_bindir}/meshctl
%{_bindir}/rfcomm
%{_bindir}/sdptool
%{_mandir}/man1/ciptool.1.*
%{_mandir}/man1/hciattach.1.*
%{_mandir}/man1/hciconfig.1.*
%{_mandir}/man1/hcidump.1.*
%{_mandir}/man1/hcitool.1.*
%{_mandir}/man1/rfcomm.1.*
%{_mandir}/man1/sdptool.1.*
%endif

%files libs
%{!?_licensedir:%global license %%doc}
%license COPYING
%{_libdir}/libbluetooth.so.*

%files libs-devel
%doc doc/*txt
%{_bindir}/isotest
%{_bindir}/l2test
%{_bindir}/l2ping
%{_bindir}/rctest
%{_mandir}/man1/isotest.1.*
%{_mandir}/man1/l2ping.1.*
%{_mandir}/man1/rctest.1.*
%{_mandir}/man5/org.bluez.*.5.*
%{_mandir}/man7/hci.7.*
%{_mandir}/man7/l2cap.7.*
%{_mandir}/man7/rfcomm.7.*
%{_libdir}/libbluetooth.so
%{_includedir}/bluetooth
%{_libdir}/pkgconfig/bluez.pc
%dir %{_libexecdir}/bluetooth
%{_libexecdir}/bluetooth/btvirt

%files cups
%_cups_serverbin/backend/bluetooth

%files hid2hci
/usr/lib/udev/hid2hci
%{_mandir}/man1/hid2hci.1*
%{_udevrulesdir}/97-hid2hci.rules

%files mesh
%config(noreplace) %{_sysconfdir}/bluetooth/mesh-main.conf
%{_bindir}/mesh-cfgclient
%{_bindir}/mesh-cfgtest
%{_datadir}/dbus-1/system.d/bluetooth-mesh.conf
%{_datadir}/dbus-1/system-services/org.bluez.mesh.service
%{_libexecdir}/bluetooth/bluetooth-meshd
%{_unitdir}/bluetooth-mesh.service
%{_localstatedir}/lib/bluetooth/mesh
%{_mandir}/man8/bluetooth-meshd.8*

%files obexd
%{_libexecdir}/bluetooth/obexd
%{_datadir}/dbus-1/services/org.bluez.obex.service
/usr/lib/systemd/user/dbus-org.bluez.obex.service
%{_userunitdir}/obex.service

%changelog
* Sat Nov 02 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.79-1
- Update to 5.79

* Mon Sep  9 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.78-1
- Update to 5.78

* Wed Jul 17 2024 Fedora Release Engineering <releng@fedoraproject.org> - 5.77-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_41_Mass_Rebuild

* Tue Jul 09 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.77-1
- Update to 5.77

* Thu Jul 04 2024 Bastien Nocera <bnocera@redhat.com> - 5.76-2
- Remove obsolete and ineffective configuration change

* Mon May 20 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.76-1
- Update to 5.76

* Mon Apr 15 2024 Adam Williamson <awilliam@redhat.com> - 5.75-1
- Update to 5.75

* Sun Apr 14 2024 Adam Williamson <awilliam@redhat.com> - 5.74-1
- Update to 5.74
- Drop patches (merged upstream)

* Thu Apr 04 2024 Adam Williamson <awilliam@redhat.com> - 5.73-3
- Backport further upstream fix for connected device checks (#2269516)

* Mon Mar 18 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.73-2
- Upstream fix for connected device checks

* Fri Mar 08 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.73-1
- Update to 5.73

* Tue Jan 23 2024 Fedora Release Engineering <releng@fedoraproject.org> - 5.72-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Fri Jan 19 2024 Fedora Release Engineering <releng@fedoraproject.org> - 5.72-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Sun Jan 14 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.72-1
- Update to 5.72

* Sun Jan 07 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 5.71-3
- Upstream fix for crash on A2DP audio suspend

* Fri Dec 29 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.71-2
- Fix link key address type for old kernels

* Sat Dec 16 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.71-1
- Update to 5.71

* Thu Dec 07 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.70-5
- Install default input.conf/network.conf

* Thu Dec 07 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.70-4
- Add mitigation for CVE-2023-45866

* Sun Nov 19 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.70-3
- Fix some input devices disconnecting right after connecting
- Explicitly enable Bluetooth BAP/BASS/CSIP/MCP/MICP/VCP profiles

* Mon Oct 02 2023 Sandro Bonazzola <sbonazzo@redhat.com> - 5.70-2
- Fix access modes for /etc/bluetooth and /var/lib/bluetooth as expected
  by bluetooth.service.
- Resolves: fedora#2144504

* Fri Sep 29 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.70-1
- Update to 5.70
- Enable some Bluetooth LE features

* Fri Aug 25 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.69-1
- Update to 5.69

* Wed Jul 19 2023 Fedora Release Engineering <releng@fedoraproject.org> - 5.68-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Sat Jul 01 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 5.68-1
- Update to 5.68
- Don't replace modified configs on upgrade (rhbz#2173029)

* Sun Jun 25 2023 Bastien Nocera <bnocera@redhat.com> - 5.66-6
- Add patch that fixes some devices not being discoverable in
  GNOME's Bluetooth Settings

* Wed Jan 18 2023 Fedora Release Engineering <releng@fedoraproject.org> - 5.66-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Thu Nov 17 2022 Peter Robinson <pbrobinson@fedoraproject.org> - 5.66-4
- Move meshctl to deprecated

* Thu Nov 17 2022 Bastien Nocera <bnocera@redhat.com> - 5.66-3
- Fix handling of transient hostnames (#2143488)

* Mon Nov 14 2022 Bastien Nocera <bnocera@redhat.com> - 5.66-2
- Re-add wrongly removed non-upstreamed patch

* Fri Nov 11 2022 Peter Robinson <pbrobinson@fedoraproject.org> - 5.66-1
- Update to 5.66

* Thu Sep 01 2022 Bastien Nocera <bnocera@redhat.com> - 5.65-3
+ bluez-5.65-3
- Update PowerState property patch to upstream version

* Wed Aug 31 2022 Bastien Nocera <bnocera@redhat.com> - 5.65-2
+ bluez-5.65-2
- Add PowerState property implementation

* Thu Jul 28 2022 Peter Robinson <pbrobinson@fedoraproject.org> - 5.65-1
- Update to 5.65

* Wed Jul 20 2022 Fedora Release Engineering <releng@fedoraproject.org> - 5.64-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Mon Mar 21 2022 Peter Robinson <pbrobinson@fedoraproject.org> - 5.64-1
- Update to 5.64

* Wed Jan 19 2022 Fedora Release Engineering <releng@fedoraproject.org> - 5.63-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Thu Jan 13 2022 Adam Williamson <awilliam@redhat.com> - 5.63-2
- Update fix for MX mice to the one merged upstream

* Wed Jan 05 2022 Peter Robinson <pbrobinson@fedoraproject.org> - 5.63-1
- Update to 5.63

* Sun Nov 07 2021 Adam Williamson <awilliam@redhat.com> - 5.62-2
- Revert an upstream change to fix problems with Logitech MX mice (#2019970)

* Wed Oct 13 2021 Peter Robinson <pbrobinson@fedoraproject.org> - 5.62-1
- Update to 5.62

* Sun Aug 22 2021 Peter Robinson <pbrobinson@fedoraproject.org> - 5.61-1
- Update to 5.61

* Tue Jul 27 2021 Bastien Nocera <bnocera@redhat.com> - 5.60-4
+ bluez-5.60-4
- Fix for CVE-2021-3658 (see rhbz#1984728)

* Wed Jul 21 2021 Fedora Release Engineering <releng@fedoraproject.org> - 5.60-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Sat Jul 10 2021 Björn Esser <besser82@fedoraproject.org> - 5.60-2
- Rebuild for versioned symbols in json-c

* Thu Jul 08 2021 Peter Robinson <pbrobinson@fedoraproject.org> - 5.60-1
- Update to 5.60

* Tue Jun 15 2021 Peter Robinson <pbrobinson@fedoraproject.org> - 5.59-1
- Update to 5.59

* Mon May 03 2021 Benjamin Berg <bberg@redhat.com> - 5.58-2
- Fix rfkill reading
  Resolves: #1944482
- Change all g_memdup calls to use g_memdup2

* Sun Apr 04 2021 Peter Robinson <pbrobinson@fedoraproject.org> - 5.58-1
- Update to 5.58

* Sun Mar 14 2021 Peter Robinson <pbrobinson@fedoraproject.org> - 5.56-4
- Fix for avdtp audio disconnexts

* Sun Mar 14 2021 Hans de Goede <hdegoede@redhat.com> - 5.56-3
- Drop obsolete udev rule + systemd service to call btattach on BT-HCIs
  connected via UART from userspace, this is all handled in the kernel now
- Add the btmgmt util to the packaged files

* Tue Mar 02 2021 Zbigniew Jędrzejewski-Szmek <zbyszek@in.waw.pl> - 5.56-2
- Rebuilt for updated systemd-rpm-macros
  See https://pagure.io/fesco/issue/2583.

* Sat Feb 27 2021 Peter Robinson <pbrobinson@fedoraproject.org> - 5.56-1
- Update to 5.56

* Tue Jan 26 2021 Fedora Release Engineering <releng@fedoraproject.org> - 5.55-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Sun Sep 13 2020 Peter Robinson <pbrobinson@fedoraproject.org> - 5.55-2
- Split tools marked as deprecated to separate sub package (rhbz #1887569)

* Sun Sep 06 2020 Peter Robinson <pbrobinson@fedoraproject.org> - 5.55-1
- Update to 5.55

* Sat Aug 01 2020 Fedora Release Engineering <releng@fedoraproject.org> - 5.54-4
- Second attempt - Rebuilt for
  https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Mon Jul 27 2020 Fedora Release Engineering <releng@fedoraproject.org> - 5.54-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Tue Apr 21 2020 Björn Esser <besser82@fedoraproject.org> - 5.54-2
- Rebuild (json-c)

* Sun Mar 15 2020 Peter Robinson <pbrobinson@fedoraproject.org> - 5.54-1
- bluez 5.54

* Sun Feb 16 2020 Peter Robinson <pbrobinson@fedoraproject.org> 5.53-2
- Minor mesh updates

* Sun Feb 16 2020 Peter Robinson <pbrobinson@fedoraproject.org> 5.53-1
- bluez 5.53

* Tue Jan 28 2020 Fedora Release Engineering <releng@fedoraproject.org> - 5.52-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Thu Dec 12 2019 Peter Robinson <pbrobinson@fedoraproject.org> 5.52-3
- Minor bluetooth mesh improvements

* Mon Dec 02 2019 Lubomir Rintel <lkundrak@v3.sk> - 5.52-2
- Package the btvirt binary

* Sun Nov  3 2019 Peter Robinson <pbrobinson@fedoraproject.org> 5.52-1
- bluez 5.52

* Fri Sep 20 2019 Peter Robinson <pbrobinson@fedoraproject.org> 5.51-1
- bluez 5.51

* Wed Jul 24 2019 Fedora Release Engineering <releng@fedoraproject.org> - 5.50-9
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Thu Jun 06 2019 Bastien Nocera <bnocera@redhat.com> - 5.50-8
+ bluez-5.50-8
- Backport loads of fixes from upstream, including:
  - dbus-broker support (#1711594)
  - a2dp codecs discovery
  - discoverability filter support (used in gnome-bluetooth, #1583442)
  - sixaxis pairing fixes

* Tue Apr 16 2019 Eduardo Minguez <edu@linux.com> - 5.50-7
- Added avinfo

* Sun Feb 17 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 5.50-6
- Disable tests temporarily

* Sun Feb 17 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 5.50-5
- Rebuild for readline 8.0

* Thu Jan 31 2019 Fedora Release Engineering <releng@fedoraproject.org> - 5.50-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Thu Jul 12 2018 Fedora Release Engineering <releng@fedoraproject.org> - 5.50-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Wed Jun 27 2018 Bastien Nocera <bnocera@redhat.com> - 5.50-2
+ bluez-5.50-2
- Fix A2DP disconnections with some headsets

* Mon Jun 04 2018 Bastien Nocera <bnocera@redhat.com> - 5.50-1
+ bluez-5.50-1
- Update to 5.50

* Fri Apr 20 2018 Bastien Nocera <bnocera@redhat.com> - 5.49-3
+ bluez-5.49-3
- Fix crash on non-LE adapters (#1567622)

* Tue Mar 27 2018 Björn Esser <besser82@fedoraproject.org> - 5.49-2
- Rebuilt for libjson-c.so.4 (json-c v0.13.1) on fc28

* Tue Mar 20 2018 Peter Robinson <pbrobinson@fedoraproject.org> 5.49-1
- Update to 5.49

* Tue Mar 06 2018 Björn Esser <besser82@fedoraproject.org> - 5.48-5
- Rebuilt for libjson-c.so.4 (json-c v0.13.1)

* Fri Feb 09 2018 Bastien Nocera <bnocera@redhat.com> - 5.48-4
- Fix PulseAudio interaction on resume (#1534857)

* Wed Feb 07 2018 Fedora Release Engineering <releng@fedoraproject.org> - 5.48-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Sat Feb 03 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 5.48-2
- Switch to %%ldconfig_scriptlets

* Thu Dec 28 2017 Pete Walter <pwalter@fedoraproject.org> - 5.48-1
- Update to 5.48

* Sun Dec 10 2017 Björn Esser <besser82@fedoraproject.org> - 5.47-7
- Rebuilt for libjson-c.so.3

* Fri Nov 10 2017 Leigh Scott <leigh123linux@googlemail.com> - 5.47-6
- Rebuild for libical 3.x

* Fri Oct 27 2017 Don Zickus <dzickus@redhat.com> - 5.47-5
- Enable unit tests (Marek Kasik)
- Resolves: #1502677

* Tue Oct 10 2017 Bastien Nocera <bnocera@redhat.com> - 5.47-4
+ bluez-5.47-4
- Fix invalid paths in service file (#1499518)

* Wed Sep 20 2017 Bastien Nocera <bnocera@redhat.com> - 5.47-3
+ bluez-5.47-3
- Fix adapter name not picking up PrettyHostname

* Wed Sep 20 2017 Bastien Nocera <bnocera@redhat.com> - 5.47-2
+ bluez-5.47-2
- Lockdown Bluetooth systemd service

* Thu Sep 14 2017 Peter Robinson <pbrobinson@fedoraproject.org> 5.47-1
- New upstream 5.47 bugfix release
- Initial support for Bluetooth LE mesh
- Blueooth 5 fixes and improvements

* Mon Sep 11 2017 Don Zickus <dzickus@redhat.com> - 5.46-6
- sdpd heap fixes
Resolves: rhbz#1490911

* Thu Sep 07 2017 Hans de Goede <hdegoede@redhat.com> - 5.46-5
- Add scripts to automatically btattach serial-port / uart connected
  Broadcom HCIs found on some Atom based x86 hardware

* Mon Sep 04 2017 Bastien Nocera <bnocera@redhat.com> - 5.46-4
+ bluez-5.46-4
- Patches cleanup
- Add DualShock4 cable pairing support
- BIND_NOW support for RELRO
- iCade autopairing support

* Wed Aug 02 2017 Fedora Release Engineering <releng@fedoraproject.org> - 5.46-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Wed Jul 26 2017 Fedora Release Engineering <releng@fedoraproject.org> - 5.46-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Wed Jul 19 2017 Peter Robinson <pbrobinson@fedoraproject.org> 4.46-1
- Update to 5.46

* Tue May 16 2017 Peter Robinson <pbrobinson@fedoraproject.org> 5.45-1
- Update to 5.45
- Minor spec cleanups
- Include api docs in devel package

* Sun Mar 12 2017 Peter Robinson <pbrobinson@fedoraproject.org> 5.44-1
- Update to 5.44
- Enable deprecated option to keep all usual tools
- Ship btattach tool
- Minor spec cleanups

* Fri Feb 10 2017 Fedora Release Engineering <releng@fedoraproject.org> - 5.43-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Fri Feb 3 2017 Don Zickus <dzickus@redhat.com> 5.43-3
- Configure systemctl settings for bluez-obexd correctly
- Resolves rhbz#1259827

* Thu Jan 12 2017 Igor Gnatenko <ignatenko@redhat.com> - 5.43-2
- Rebuild for readline 7.x

* Mon Oct 31 2016 Don Zickus <dzickus@redhat.com> 5.43-1
- Update to 5.43

* Tue Oct 25 2016 Don Zickus <dzickus@redhat.com> 5.42-2
- Fix OBEX connections

* Wed Oct 19 2016 Peter Robinson <pbrobinson@fedoraproject.org> 5.42-1
- Update to 5.42

* Mon Aug 1 2016 Don Zickus <dzickus@redhat.com> 5.41-1
- Update to 5.41

* Thu Jul 7 2016 Don Zickus <dzickus@redhat.com> 5.40-2
- obexd fixes to prevent crashes
- add /etc/bluetooth/main.conf config file
- set 'AutoEnable=true' in /etc/bluetooth/main.conf file

* Tue May 31 2016 Peter Robinson <pbrobinson@fedoraproject.org> 5.40-1
- Update to 5.40 bugfix relesae

* Fri Apr 15 2016 David Tardon <dtardon@redhat.com> - 5.39-2
- rebuild for ICU 57.1

* Tue Apr 12 2016 Peter Robinson <pbrobinson@fedoraproject.org> 5.39-1
- Update to 5.39 bugfix relesae

* Sun Apr  3 2016 Peter Robinson <pbrobinson@fedoraproject.org> 5.38-1
- Update to 5.38

* Wed Feb 03 2016 Fedora Release Engineering <releng@fedoraproject.org> - 5.37-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Mon Jan 18 2016 David Tardon <dtardon@redhat.com> - 5.37-2
- rebuild for libical 2.0.0

* Tue Dec 29 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.37-1
- Update to 5.37

* Fri Nov 13 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.36-1
- Update to 5.36

* Fri Oct 30 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.35-2
- Split obexd out into a sub package

* Mon Oct  5 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.35-1
- Update to 5.35

* Tue Sep  8 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.34-1
- Update to 5.34

* Fri Jul 31 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.33-1
- Update to 5.33

* Wed Jul  8 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.32-1
- Update to 5.32

* Mon Jun 22 2015 Peter Robinson <pbrobinson@fedoraproject.org> 5.31-1
- Update to 5.31

* Wed Jun 17 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 5.30-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Thu Jun 11 2015 Lubomir Rintel <lkundrak@v3.sk> - 5.30-2
- Fix NAP connections (rh #1230461)

* Wed Apr 29 2015 Peter Robinson <pbrobinson@fedoraproject.org> - 5.30-1
- Update to 5.30
- Use %%license

* Sun Mar 29 2015 David Tardon <dtardon@redhat.com> - 5.29-2
- fix header file

* Wed Mar 25 2015 Don Zickus <dzickus@redhat.com> 5.29-1
- Update to 5.29

* Wed Mar 11 2015 Bastien Nocera <bnocera@redhat.com> 5.28-1
- Update to 5.28

* Thu Nov 20 2014 Bastien Nocera <bnocera@redhat.com> 5.25-1
- Update to 5.25

* Thu Oct 30 2014 Eric Smith <brouhaha@fedorapeople.org> 5.23-2
- Install gatttool and mpris-proxy

* Tue Sep 23 2014 Bastien Nocera <bnocera@redhat.com> 5.23-1
- Update to 5.23

* Fri Aug 15 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 5.18-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 5.18-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Mon Apr 14 2014 Bastien Nocera <bnocera@redhat.com> 5.18-1
- Update to 5.18

* Wed Mar 26 2014 Bastien Nocera <bnocera@redhat.com> 5.17-1
- Update to 5.17

* Thu Mar 13 2014 Bastien Nocera <bnocera@redhat.com> 5.16-1
- Update to 5.16

* Wed Jan 29 2014 Bastien Nocera <bnocera@redhat.com> 5.14-1
- Update to 5.14

* Mon Jan 06 2014 Bastien Nocera <bnocera@redhat.com> 5.13-1
- Update to 5.13
- Enable sixaxis plugin by default

* Thu Dec 12 2013 Bastien Nocera <bnocera@redhat.com> 5.12-2
- This update fixes Sixaxis PS3 joypad detection

* Wed Dec 11 2013 Bastien Nocera <bnocera@redhat.com> 5.12-1
- Update to 5.12
- Sixaxis PS3 joypad support is now upstream

* Tue Dec 10 2013 Bastien Nocera <bnocera@redhat.com> 5.11-2
- Add crasher fixes (rhbz #1027365)

* Mon Nov 18 2013 Bastien Nocera <bnocera@redhat.com> 5.11-1
- Update to 5.11

* Tue Nov 12 2013 Bastien Nocera <bnocera@redhat.com> 5.10-4
- Default to the XDG cache dir for receiving files

* Mon Oct 21 2013 Bastien Nocera <bnocera@redhat.com> 5.10-3
- Remove a few obsolete BRs and deps, thanks to Marcel Holtmann

* Mon Oct 21 2013 Bastien Nocera <bnocera@redhat.com> 5.10-2
- Add non-upstreamable patch to make bluetooth-sendto work again

* Thu Oct 17 2013 Bastien Nocera <bnocera@redhat.com> 5.10-1
- Update to 5.10

* Fri Sep 20 2013 Kalev Lember <kalevlember@gmail.com> 5.9-4
- Obsolete blueman-nautilus as well

* Fri Sep 20 2013 Kalev Lember <kalevlember@gmail.com> 5.9-3
- Obsolete blueman and obex-data-server

* Fri Sep 20 2013 Bastien Nocera <bnocera@redhat.com> 5.9-2
- Fix problem unsetting discoverable

* Fri Sep 20 2013 Bastien Nocera <bnocera@redhat.com> 5.9-1
- Update to 5.9

* Fri Aug 16 2013 Kalev Lember <kalevlember@gmail.com> - 5.8-2
- Don't pull in -libs for the other subpackages
- Remove a stray .la file

* Sat Aug 10 2013 Kalev Lember <kalevlember@gmail.com> - 5.8-1
- Update to 5.8
- Hardened build
- Use systemd rpm macros

* Sat Aug 10 2013 Kalev Lember <kalevlember@gmail.com> - 5.5-1
- Update to 5.5, based on earlier work from
  https://bugzilla.redhat.com/show_bug.cgi?id=974145

* Sat Aug 03 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.101-10
- Rebuilt for https://fedoraproject.org/wiki/Fedora_20_Mass_Rebuild

* Tue Jul 23 2013 Bastien Nocera <bnocera@redhat.com> 4.101-9
- Fix trust setting in Sixaxis devices

* Wed Jun 26 2013 Bastien Nocera <bnocera@redhat.com> 4.101-8
- Another pass at fixing A2DP support (#964031)

* Tue Jun 25 2013 Bastien Nocera <bnocera@redhat.com> 4.101-7
- Remove socket interface enablement for A2DP (#964031)

* Mon Jan 28 2013 Peter Robinson <pbrobinson@fedoraproject.org> 4.101-6
- Add -vif to autoreconf to fix build issues

* Thu Jan 10 2013 Bastien Nocera <bnocera@redhat.com> 4.101-5
- Use git to manage distro patches
- Add numerous upstream and downstream patches (#892929)

* Wed Nov 21 2012 Bastien Nocera <bnocera@redhat.com> 4.101-4
- Clean up requires and build requires
- Use CUPS macro (#772236)
- Enable audio socket so a2dp works in PulseAudio again (#874015)
- Fix hid2hci not working with recent kernels (#877998)

* Wed Aug 15 2012 Bastien Nocera <bnocera@redhat.com> 4.101-3
- Enable pairing Wiimote support (#847481)

* Wed Jul 18 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.101-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Sun Jun 17 2012 Bastien Nocera <bnocera@redhat.com> 4.100-2
- Add PS3 BD Remote patches (power saving)

* Thu Jun 14 2012 Bastien Nocera <bnocera@redhat.com> 4.100-1
- Update to 4.100

* Fri Jun  1 2012 Peter Robinson <pbrobinson@fedoraproject.org> - 4.99-2
- Add patch for udev change to fix FTBFS on rawhide
- Drop sbc patch as fixed in gcc 4.7 final

* Tue Mar 06 2012 Bastien Nocera <bnocera@redhat.com> 4.99-1
- Update to 4.99

* Tue Feb 28 2012 Petr Pisar <ppisar@redhat.com> - 4.98-3
- Make headers compilable with g++ 4.7 (bug #791292)

* Fri Feb 24 2012 Peter Robinson <pbrobinson@fedoraproject.org> 4.98-2
- Add mmx patch to fix build of sbc component
- clean up spec, drop ancient obsoletes

* Fri Jan 13 2012 Bastien Nocera <bnocera@redhat.com> 4.98-1
- Update to 4.98

* Thu Jan 12 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.97-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Fri Dec 30 2011 Bastien Nocera <bnocera@redhat.com> 4.97-1
- Update to 4.97

* Mon Sep  5 2011 Hans de Goede <hdegoede@redhat.com> 4.96-3
- Put hid2hci into its own (optional) subpackage, so that people who
  just want to use their HID proxying HCI with the keyboard and mouse
  it came with, will have things working out of the box.
- Put udev rules in /lib/udev, where package installed udev rules belong

* Mon Aug 29 2011 Hans de Goede <hdegoede@redhat.com> 4.96-2
- hid2hci was recently removed from udev and added to bluez in 4.93,
  udev in Fedora-16 no longer has hid2hci -> enable it in our bluez builds.
  This fixes bluetooth not working on machines where the bluetooth hci
  initially shows up as a hid device, such as with many Dell laptops.

* Mon Aug 01 2011 Bastien Nocera <bnocera@redhat.com> 4.96-1
- Update to 4.96

* Tue Jul 05 2011 Bastien Nocera <bnocera@redhat.com> 4.95-1
- Update to 4.95

* Tue Jun 28 2011 Lennart Poettering <lpoetter@redhat.com> - 4.94-4
- Enable bluetoothd on all upgrades from 4.87-6 and older, in order to fix up broken F15 installations

* Thu Jun 23 2011 Bastien Nocera <bnocera@redhat.com> 4.94-3
- Update patches to apply correctly
- First compilable version with hostnamed support

* Mon Jun 20 2011 Lennart Poettering <lpoetter@redhat.com> - 4.94-2
- Enable bluetoothd by default
- Follow-up on https://bugzilla.redhat.com/show_bug.cgi?id=694519 also fixing upgrades

* Wed Jun 01 2011 Bastien Nocera <bnocera@redhat.com> 4.94-1
- Update to 4.94

* Wed May 25 2011 Bastien Nocera <bnocera@redhat.com> 4.93-1
- Update to 4.93

* Thu Apr  7 2011 Lennart Poettering <lpoetter@redhat.com> - 4.90-2
- Update systemd patch to make it possible to disable bluez

* Thu Mar 17 2011 Bastien Nocera <bnocera@redhat.com> 4.90-1
- Update to 4.90

* Mon Feb 21 2011 Bastien Nocera <bnocera@redhat.com> 4.89-1
- Update to 4.89

* Mon Feb 14 2011 Bastien Nocera <bnocera@redhat.com> 4.88-1
- Update to 4.88

* Mon Feb 07 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.87-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Wed Jan 26 2011 Bastien Nocera <bnocera@redhat.com> 4.87-1
- Update to 4.87

* Thu Jan 20 2011 Bastien Nocera <bnocera@redhat.com> 4.86-1
- Update to 4.86

* Thu Jan 13 2011 Bastien Nocera <bnocera@redhat.com> 4.85-1
- Update to 4.85

* Sun Dec 19 2010 Bastien Nocera <bnocera@redhat.com> 4.82-1
- Update to 4.82

* Wed Dec 01 2010 Bastien Nocera <bnocera@redhat.com> 4.81-1
- Update to 4.81

* Mon Nov 22 2010 Bastien Nocera <bnocera@redhat.com> 4.80-1
- Update to 4.80

* Tue Nov 09 2010 Bastien Nocera <bnocera@redhat.com> 4.79-1
- Update to 4.79

* Sat Nov 06 2010 Bastien Nocera <bnocera@redhat.com> 4.78-1
- Update to 4.78

* Wed Oct 27 2010 Bastien Nocera <bnocera@redhat.com> 4.77-1
- Update to 4.77

* Sat Oct 16 2010 Bastien Nocera <bnocera@redhat.com> 4.76-1
- Update to 4.76

* Tue Oct 05 2010 Bastien Nocera <bnocera@redhat.com> 4.74-1
- Update to 4.74

* Mon Oct 04 2010 Bastien Nocera <bnocera@redhat.com> 4.73-1
- Update to 4.73

* Wed Sep 29 2010 jkeating - 4.72-2
- Rebuilt for gcc bug 634757

* Wed Sep 22 2010 Bastien Nocera <bnocera@redhat.com> 4.72-1
- Update to 4.72

* Fri Sep 17 2010 Bill Nottingham <notting@redhat.com> 4.71-4
- sync release number (but not package) with F-14

* Tue Sep 14 2010 Bastien Nocera <bnocera@redhat.com> 4.71-3
- systemd hookup and cleanups from Lennart

* Thu Sep 09 2010 Bastien Nocera <bnocera@redhat.com> 4.71-1
- Update to 4.71

* Thu Aug 26 2010 Bastien Nocera <bnocera@redhat.com> 4.70-1
- Update to 4.70

* Sat Jul 31 2010 Orcan Ogetbil <oget[dot]fedora[at]gmail[dot]com> 4.69-4
- Re-add Requires: dbus-bluez-pin-helper, since blueman is now in

* Sat Jul 31 2010 Orcan Ogetbil <oget[dot]fedora[at]gmail[dot]com> 4.69-3
- Comment out Requires: dbus-bluez-pin-helper for bootstrapping. Otherwise
  it drags in the old blueman, built against python-2.6
* Fri Jul 23 2010 Bastien Nocera <bnocera@redhat.com> 4.69-2
- Don't allow installing bluez-compat on its own

* Fri Jul 16 2010 Bastien Nocera <bnocera@redhat.com> 4.69-1
- Update to 4.69

* Sun Jul 11 2010 Dan Horák <dan[at]danny.cz> 4.66-3
- don't require the pin helper on s390(x) now, we can disable the whole
  bluetooth stack in the future

* Mon Jun 21 2010 Bastien Nocera <bnocera@redhat.com> 4.66-2
- Move hidd, pand and dund man pages to the -compat
  sub-package (#593578)

* Mon Jun 14 2010 Bastien Nocera <bnocera@redhat.com> 4.66-1
- Update to 4.66

* Mon May 24 2010 Bastien Nocera <bnocera@redhat.com> 4.65-1
- Update to 4.65

* Thu Apr 29 2010 Bastien Nocera <bnocera@redhat.com> 4.64-1
- Update to 4.64

* Mon Apr 12 2010 Bastien Nocera <bnocera@redhat.com> 4.63-3
- And actually apply the aforementioned patch

* Mon Apr 12 2010 Bastien Nocera <bnocera@redhat.com> 4.63-2
- Fix pairing and using mice, due to recent BtIO changes

* Fri Mar 26 2010 Bastien Nocera <bnocera@redhat.com> 4.63-1
- Update to 4.63

* Mon Mar 08 2010 Bastien Nocera <bnocera@redhat.com> 4.62-1
- Update to 4.62

* Mon Feb 15 2010 Bastien Nocera <bnocera@redhat.com> 4.61-1
- Update to 4.61
- Remove Wacom tablet enabler, now in the kernel
- Fix linking with new DSO rules (#564799)

* Mon Feb 15 2010 Bastien Nocera <bnocera@redhat.com> 4.60-2
- Fix typo in init script (#558993)

* Sun Jan 10 2010 Bastien Nocera <bnocera@redhat.com> 4.60-1
- Update to 4.60

* Fri Dec 25 2009 Bastien Nocera <bnocera@redhat.com> 4.59-1
- Update to 4.59

* Mon Nov 16 2009 Bastien Nocera <bnocera@redhat.com> 4.58-1
- Update to 4.58

* Mon Nov 02 2009 Bastien Nocera <bnocera@redhat.com> 4.57-2
- Move the rfcomm.conf to the compat package, otherwise
  the comments at the top of it are confusing

* Sat Oct 31 2009 Bastien Nocera <bnocera@redhat.com> 4.57-1
- Update to 4.57

* Sat Oct 10 2009 Bastien Nocera <bnocera@redhat.com> 4.56-1
- Update to 4.56

* Fri Oct 09 2009 Bastien Nocera <bnocera@redhat.com> 4.55-2
- Update cable pairing plugin to use libudev

* Mon Oct 05 2009 Bastien Nocera <bnocera@redhat.com> 4.55-1
- Update to 4.55
- Add libcap-ng support to drop capabilities (#517660)

* Thu Sep 24 2009 Bastien Nocera <bnocera@redhat.com> 4.54-1
- Update to 4.54

* Wed Sep 16 2009 Bastien Nocera <bnocera@redhat.com> 4.53-2
- Update cable plugin for gudev changes

* Thu Sep 10 2009 Bastien Nocera <bnocera@redhat.com> 4.53-1
- Update to 4.53

* Fri Sep 04 2009 Bastien Nocera <bnocera@redhat.com> 4.52-1
- Update to 4.52

* Thu Sep 03 2009 Bastien Nocera <bnocera@redhat.com> 4.51-1
- Update to 4.51

* Tue Sep 01 2009 Bastien Nocera <bnocera@redhat.com> 4.50-2
- Remove obsoleted patches
- Add another CUPS backend patch
- Update cable pairing patch for new build system

* Tue Sep 01 2009 Bastien Nocera <bnocera@redhat.com> 4.50-1
- Update to 4.50

* Tue Aug 25 2009 Karsten Hopp <karsten@redhat.com> 4.47-6
- don't buildrequire libusb1 on s390*

* Tue Aug 11 2009 Bastien Nocera <bnocera@redhat.com> 4.47-5
- More upstream CUPS fixes

* Tue Aug 11 2009 Bastien Nocera <bnocera@redhat.com> 4.47-4
- Fix cups discovery the first time we discover a device

* Mon Aug 10 2009 Ville Skyttä <ville.skytta@iki.fi> - 4.47-3
- Use bzipped upstream tarball.

* Wed Aug 05 2009 Bastien Nocera <bnocera@redhat.com> 4.47-2
- Remove hid2hci calls, they're in udev now
- Work-around udev bug, bluetoothd wasn't getting enabled
  on coldplug

* Sun Aug 02 2009 Bastien Nocera <bnocera@redhat.com> 4.47-1
- Update to 4.47

* Wed Jul 29 2009 Bastien Nocera <bnocera@redhat.com> 4.46-3
- Add rfkill plugin to restore the state of the adapters
  after coming back from a blocked adapter

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.46-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Sun Jul 19 2009 Bastien Nocera <bnocera@redhat.com> 4.46-1
- Update to 4.46

* Wed Jul 08 2009 Bastien Nocera <bnocera@redhat.com> 4.45-1
- Update to 4.45

* Tue Jul 07 2009 Bastien Nocera <bnocera@redhat.com> 4.44-1
- Update to 4.44

* Fri Jul 03 2009 Bastien Nocera <bnocera@redhat.com> 4.43-2
- Up the required udev requires so bluetoothd gets started
  on boot when an adapter is present

* Fri Jul 03 2009 Bastien Nocera <bnocera@redhat.com> 4.43-1
- Update to 4.43

* Sun Jun 21 2009 Bastien Nocera <bnocera@redhat.com> 4.42-2
- Update to 4.42

* Thu Jun 11 2009 Bastien Nocera <bnocera@redhat.com> 4.41-2
- Switch to on-demand start/stop using udev

* Mon Jun 08 2009 Bastien Nocera <bnocera@redhat.com> 4.41-1
- Update to 4.41

* Fri Jun 05 2009 Bastien Nocera <bnocera@redhat.com> 4.40-2
- Add patch to allow Sixaxis pairing

* Tue May 19 2009 Bastien Nocera <bnocera@redhat.com> 4.40-1
- Update to 4.40

* Sat May 09 2009 Bastien Nocera <bnocera@redhat.com> 4.39-1
- Update to 4.39

* Tue May 05 2009 Petr Lautrbach <plautrba@redhat.com> 4.38-3
- Start/stop the bluetooth service via udev (#484345)

* Tue May 05 2009 Bastien Nocera <bnocera@redhat.com> 4.38-2
- Add patch to activate the Socket Mobile CF kit (#498756)

* Mon May 04 2009 Bastien Nocera <bnocera@redhat.com> 4.38-1
- Update to 4.38

* Wed Apr 29 2009 Bastien Nocera <bnocera@redhat.com> 4.37-2
- Split off dund, pand, hidd, and rfcomm helper into a compat package
  (#477890, #473892)

* Thu Apr 23 2009 - Bastien Nocera <bnocera@redhat.com> - 4.37-1
- Update to 4.37

* Fri Apr 17 2009 - Bastien Nocera <bnocera@redhat.com> - 4.36-1
- Update to 4.36

* Sat Apr 11 2009 - Bastien Nocera <bnocera@redhat.com> - 4.35-1
- Update to 4.35

* Fri Apr 03 2009 - Bastien Nocera <bnocera@redhat.com> - 4.34-3
- Avoid disconnecting audio devices straight after they're connected

* Fri Apr 03 2009 - Bastien Nocera <bnocera@redhat.com> - 4.34-2
- Don't crash when audio devices are registered and the adapter
  is removed

* Sun Mar 29 2009 - Bastien Nocera <bnocera@redhat.com> - 4.34-1
- Update to 4.34

* Tue Mar 24 2009 - Bastien Nocera <bnocera@redhat.com> - 4.33-11
- Fix a possible crasher

* Mon Mar 16 2009 - Bastien Nocera <bnocera@redhat.com> - 4.33-1
- Update to 4.33

* Sat Mar 14 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-10
- Fix a couple of warnings in the CUPS/BlueZ 4.x patch

* Fri Mar 13 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-9
- Switch Wacom Bluetooth tablet to mode 2

* Mon Mar 09 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-8
- Port CUPS backend to BlueZ 4.x

* Mon Mar 09 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-7
- A (slightly) different fix for parsing to XML when it contains a NULL

* Mon Mar 09 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-6
- Fix sdp_copy_record(), so records are properly exported through D-Bus

* Fri Mar 06 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-5
- Fix SDP parsing to XML when it contains NULLs

* Thu Mar 05 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-4
- Work-around broken devices that export their names in ISO-8859-1
  (#450081)

* Thu Mar 05 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-3
- Fix permissions on the udev rules (#479348)

* Wed Mar 04 2009 - Bastien Nocera <bnocera@redhat.com> - 4.32-2
- Own /usr/lib*/bluetooth and children (#474632)

* Mon Mar 2 2009 Lennart Poettering <lpoetter@redhat.com> - 4.32-1
- Update to 4.32

* Thu Feb 26 2009 Lennart Poettering <lpoetter@redhat.com> - 4.31-1
- Update to 4.31

* Mon Feb 23 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 4.30-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Mon Feb 23 2009 - Bastien Nocera <bnocera@redhat.com> - 4.30-2
- Fix the cups backend being a libtool stub

* Thu Feb 12 2009 - Bastien Nocera <bnocera@redhat.com> - 4.30-1
- Update to 4.30

* Thu Feb 12 2009 Karsten Hopp <karsten@redhat.com> 4.29-3
- disable 0001-Add-icon-for-other-audio-device.patch, already upstream

* Thu Feb 12 2009 Karsten Hopp <karsten@redhat.com> 4.29-2
- bluez builds fine on s390(x) and the packages are required to build
  other packages, drop ExcludeArch

* Mon Feb 09 2009 - Bastien Nocera <bnocera@redhat.com> - 4.29-1
- Update to 4.29

* Mon Feb 02 2009 - Bastien Nocera <bnocera@redhat.com> - 4.28-1
- Update to 4.28

* Mon Jan 19 2009 - Bastien Nocera <bnocera@redhat.com> - 4.27-1
- Update to 4.27

* Fri Jan 09 2009 - Bastien Nocera <bnocera@redhat.com> - 4.26-1
- Update to 4.26

* Sat Jan 03 2009 - Bastien Nocera <bnocera@redhat.com> - 4.25-1
- Update to 4.25

* Tue Dec 09 2008 - Bastien Nocera <bnocera@redhat.com> - 4.22-2
- Fix D-Bus configuration for latest D-Bus (#475069)

* Mon Dec 08 2008 - Bastien Nocera <bnocera@redhat.com> - 4.22-1
- Update to 4.22

* Mon Dec 01 2008 - Bastien Nocera <bnocera@redhat.com> - 4.21-1
- Update to 4.21

* Fri Nov 21 2008 - Bastien Nocera <bnocera@redhat.com> - 4.19-1
- Update to 4.19

* Mon Nov 17 2008 - Bastien Nocera <bnocera@redhat.com> - 4.18-1
- Update to 4.18

* Mon Oct 27 2008 - Bastien Nocera <bnocera@redhat.com> - 4.17-2
- Own /var/lib/bluetooth (#468717)

* Sun Oct 26 2008 - Bastien Nocera <bnocera@redhat.com> - 4.17-1
- Update to 4.17

* Tue Oct 21 2008 - Bastien Nocera <bnocera@redhat.com> - 4.16-1
- Update to 4.16

* Mon Oct 20 2008 - Bastien Nocera <bnocera@redhat.com> - 4.15-1
- Update to 4.15

* Fri Oct 17 2008 - Bastien Nocera <bnocera@redhat.com> - 4.14-2
- Add script to autoload uinput on startup, so the PS3 remote
  works out-of-the-box

* Fri Oct 17 2008 - Bastien Nocera <bnocera@redhat.com> - 4.14-1
- Update to 4.14

* Tue Oct 14 2008 - Bastien Nocera <bnocera@redhat.com> - 4.13-3
- Update udev rules (#246840)

* Mon Oct 13 2008 - Bastien Nocera <bnocera@redhat.com> - 4.13-2
- Fix PS3 BD remote input event generation

* Fri Oct 10 2008 - Bastien Nocera <bnocera@redhat.com> - 4.13-1
- Update to 4.13

* Mon Oct 06 2008 - Bastien Nocera <bnocera@redhat.com> - 4.12-1
- Update to 4.12

* Sat Oct 04 2008 - Bastien Nocera <bnocera@redhat.com> - 4.11-1
- Update to 4.11

* Fri Oct 03 2008 - Bastien Nocera <bnocera@redhat.com> - 4.10-1
- Update to 4.10

* Mon Sep 29 2008 - Bastien Nocera <bnocera@redhat.com> - 4.9-1
- Update to 4.9

* Mon Sep 29 2008 - Bastien Nocera <bnocera@redhat.com> - 4.8-1
- Update to 4.8

* Fri Sep 26 2008 - Bastien Nocera <bnocera@redhat.com> - 4.7-1
- Update to 4.7

* Wed Sep 24 2008 - Bastien Nocera <bnocera@redhat.com> - 4.6-4
- Fix patch application

* Wed Sep 24 2008 - Bastien Nocera <bnocera@redhat.com> - 4.6-3
- Add fuzz

* Wed Sep 24 2008 - Bastien Nocera <bnocera@redhat.com> - 4.6-2
- Fix possible crasher on resume from suspend

* Sun Sep 14 2008 - David Woodhouse <David.Woodhouse@intel.com> - 4.6-1
- Update to 4.6

* Fri Sep 12 2008 - David Woodhouse <David.Woodhouse@intel.com> - 4.5-4
- SDP browse fixes

* Fri Sep 12 2008 - David Woodhouse <David.Woodhouse@intel.com> - 4.5-3
- Bluez-alsa needs to provide/obsolete bluez-utils-alsa
- Use versioned Obsoletes:

* Fri Sep 12 2008 - David Woodhouse <David.Woodhouse@intel.com> - 4.5-2
- Change main utils package name to 'bluez'; likewise its subpackages
- Remove references to obsolete initscripts (hidd,pand,dund)

* Fri Sep 12 2008 - Bastien Nocera <bnocera@redhat.com> - 4.5-1
- Update to 4.5
- Fix initscript to actually start bluetoothd by hand
- Add chkconfig information to the initscript

* Tue Sep 09 2008 - David Woodhouse <David.Woodhouse@intel.com> - 4.4-2
- Fix rpmlint problems
- Fix input device handling

* Tue Sep 09 2008 - Bastien Nocera <bnocera@redhat.com> - 4.4-1
- Update to 4.4
- Update source address, and remove unneeded deps (thanks Marcel)

* Mon Aug 11 2008 - Bastien Nocera <bnocera@redhat.com> - 4.1-1
- Initial build
