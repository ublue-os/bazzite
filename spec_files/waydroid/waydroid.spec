%global forgeurl https://github.com/waydroid/waydroid
%global selinuxtype targeted

Version:        1.4.3
%global tag %{version}

%forgemeta
Name:           waydroid
Release:        100%{?dist}.bazzite
Summary:        Container-based approach to boot a full Android system on GNU/Linux
License:        GPL-3.0-only
URL:            %{forgeurl}
Source:         %{forgesource}
Source1:        waydroid.te
Source4:        dev-binderfs.mount
Source6:        waydroid.fc

# Assign firewalld zone to the waydroid network interface
Patch0:         setup-firewalld.patch

# Mount the android rootfs with a default selinux context
Patch1:         mount-secontext.patch

# Fedora LXC is compiled without AppArmor support and fails to parse lxc.apparmor.profile config
Patch2:         no-apparmor.patch 

# https://github.com/waydroid/waydroid/issues/1550
# initializer: Refactor setup to better handle preinstalled images
Patch3:         5000c9703de873e4f477ebcdd3556ad163252115.patch

BuildArch:      noarch

BuildRequires:  make
BuildRequires:  selinux-policy-devel
BuildRequires:  container-selinux
BuildRequires:  systemd
BuildRequires:  python3-devel
BuildRequires:  systemd-rpm-macros
BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib

Requires:       python3dist(gbinder-python) >= 1.1.0
Requires:       python3dist(dbus-python) 
Requires:       python3-gobject
Requires:       lxc
Requires:       gtk3
Requires:       (%{name}-selinux = %{version}-%{release} if selinux-policy-%{selinuxtype})
Requires:       nftables
Requires:       iproute
Requires:       dnsmasq
Recommends:     python3-pyclip
Recommends:     wl-clipboard

%description
Waydroid uses Linux namespaces to run a full Android system in a container
and provide Android applications on any GNU/Linux-based platform.
The Android system inside the container has direct access to needed hardware
through LXC and the binder interface.

%package selinux
Summary:            SELinux policy module for waydroid
Requires:           %{name} = %{version}-%{release}
Requires:           container-selinux
%{?selinux_requires}

%description selinux
This package contains the SELinux policy module necessary to run waydroid.

%prep
%forgeautosetup -p1
mkdir SELinux
cp %{S:1} SELinux/
cp %{S:6} SELinux/

%build
# Remove link for ROM files
sed -i -e '/"system_channel":/ s/: ".*"/: ""/' tools/config/__init__.py
sed -i -e '/"vendor_channel":/ s/: ".*"/: ""/' tools/config/__init__.py
sed -i -e '/options: OTA channel URL/ s/default is Official OTA server/mandatory/' tools/helpers/arguments.py
# Compile sepolicy
cd SELinux
%{__make} NAME=%{selinuxtype} -f /usr/share/selinux/devel/Makefile

%install
%make_install LIBDIR=%{_libdir} DESTDIR=%{buildroot} USE_SYSTEMD=1 USE_DBUS_ACTIVATION=1 USE_NFTABLES=1
%py_byte_compile %{python3} %{buildroot}%{_prefix}/lib/waydroid
%{__install} -d %{buildroot}%{_unitdir}
%{__install} -d %{buildroot}%{_datadir}/selinux/%{selinuxtype}
%{__install} -p -m 644 %{S:4} %{buildroot}%{_unitdir}/
%{__install} -p -m 644 SELinux/%{name}.pp %{buildroot}%{_datadir}/selinux/%{selinuxtype}/%{name}.pp
sed -i '/^\[Unit\]/a Wants=dev-binderfs.mount' %{buildroot}%{_unitdir}/waydroid-container.service
sed -i '/^\[Service\]/a ExecStartPre=/usr/bin/ln -sf /dev/binderfs/binder /dev/binderfs/vndbinder /dev/binderfs/hwbinder /dev/' %{buildroot}%{_unitdir}/waydroid-container.service

%check
desktop-file-validate %{buildroot}/%{_datadir}/applications/Waydroid.desktop
desktop-file-validate %{buildroot}/%{_datadir}/applications/waydroid.market.desktop
desktop-file-validate %{buildroot}/%{_datadir}/applications/waydroid.app.install.desktop
appstream-util validate --nonet %{buildroot}%{_metainfodir}/id.waydro.waydroid.metainfo.xml

%pre selinux
%selinux_relabel_pre -s %{selinuxtype}

%post selinux
%selinux_modules_install -s %{selinuxtype} %{_datadir}/selinux/%{selinuxtype}/%{name}.pp
%selinux_relabel_post -s %{selinuxtype}

if [ "$1" -le "1" ]; then # First install
  # the daemon needs to be restarted for the custom label to be applied
  %systemd_postun_with_restart waydroid-container.service
fi

%postun selinux
if [ $1 -eq 0 ]; then
  %selinux_modules_uninstall -s %{selinuxtype} %{name}
  %selinux_relabel_post -s %{selinuxtype}
fi

%post
waydroid upgrade -o > /dev/null || :
%systemd_post waydroid-container.service
if [ $1 -eq 1 ]; then
  if systemctl -q is-enabled waydroid-container.service > /dev/null 2>&1 ; then
    systemctl start waydroid-container.service > /dev/null 2>&1 || :
  fi
fi

%preun
%systemd_preun waydroid-container.service

%postun
%systemd_postun_with_restart waydroid-container.service

%files
%license LICENSE
%doc README.md
%{_prefix}/lib/waydroid
%{_datadir}/applications/Waydroid.desktop
%{_datadir}/applications/waydroid.market.desktop
%{_datadir}/applications/waydroid.app.install.desktop
%{_datadir}/metainfo/id.waydro.waydroid.metainfo.xml
%{_datadir}/icons/hicolor/512x512/apps/waydroid.png
%{_bindir}/waydroid
%{_unitdir}/waydroid-container.service
%{_unitdir}/dev-binderfs.mount
%{_datadir}/dbus-1/system-services/id.waydro.Container.service
%{_datadir}/dbus-1/system.d/id.waydro.Container.conf
%{_datadir}/polkit-1/actions/id.waydro.Container.policy
%{_datadir}/desktop-directories/waydroid.directory
%{_sysconfdir}/xdg/menus/applications-merged/waydroid.menu

%files selinux
%doc SELinux/%{name}.te
%{_datadir}/selinux/%{selinuxtype}/%{name}.pp

%changelog
* Sat Aug 10 2024 Alessandro Astone <alessandro.astone@canonical.com> - 1.4.3-1
+ - new version (rhbz#2303618)
+ - fix python 3.12 error (rhbz#2258411)
+ - make it clearer that OTA channels must be provided to `waydroid init`

* Thu Mar 14 2024 Alessandro Astone <ales.astone@gmail.com> - 1.4.2-3
- Completely disable apparmor

* Tue Oct 31 2023 Alessandro Astone <ales.astone@gmail.com> - 1.4.2-1
- Update to 1.4.2

* Tue Sep 26 2023 Alessandro Astone <ales.astone@gmail.com> - 1.4.1-3
- Amend SELinux to coexist with snap

* Sat Jul 22 2023 Fedora Release Engineering <releng@fedoraproject.org> - 1.4.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Tue Apr 25 2023 Alessandro Astone <ales.astone@gmail.com> - 1.4.1-1
- Update to 1.4.1

* Wed Feb 08 2023 Alessandro Astone <ales.astone@gmail.com> - 1.4.0-1
- Update to 1.4.0

* Sat Jan 21 2023 Fedora Release Engineering <releng@fedoraproject.org> - 1.3.4-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Fri Jan 06 2023 Alessandro Astone <ales.astone@gmail.com> - 1.3.4-4
- Re-enable s390x build
- Sepolicy fixes

* Tue Dec 27 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.4-3
- Fix description typos etc.
- Validate desktop and metainfo files
- Reorder post install scriptlets

* Sun Dec 25 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.4-2
- Add selinux label to android rootfs
- Make package noarch

* Wed Dec 14 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.4-1
- Update to 1.3.4

* Sat Nov 05 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.3-3
- Override selinux context of the android rootfs
- Fixes https://github.com/casualsnek/waydroid_script

* Sun Oct 30 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.3-2
- Add sepolicy for updating from the android app

* Sun Sep 25 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.3-1
- Update to 1.3.3

* Fri Sep 02 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.1-1
- Update to 1.3.1

* Tue Aug 09 2022 Alessandro Astone <ales.astone@gmail.com> - 1.3.0-1
- Update to 1.3.0

* Sun Apr 17 2022 Alessandro Astone <ales.astone@gmail.com> - 1.2.1-1
- Update to 1.2.1

* Mon Mar 07 2022 Alessandro Astone <ales.astone@gmail.com> - 1.2.0-7.20220307git1.2.0
- Recommend pyclip

* Sat Feb 26 2022 Alessandro Astone <ales.astone@gmail.com> - 1.2.0-5.20220226git1.2.0
- Add sepolicy for crash handler

* Fri Feb 25 2022 Alessandro Astone <ales.astone@gmail.com> - 1.2.0-4.20220225git1.2.0
- Respin package

* Wed Aug 12 2020 Qiyu Yan <yanqiyu@fedoraproject.org> - 0-0.1.20200811gitc87ea48
- initial package
