%define packagename jupiter-hw-support
%define packagever jupiter-3.5-20231115.1
%global _default_patch_fuzz 2

Name:           %{packagename}-btrfs
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steam Deck Hardware Support Package
License:        GPLv3
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/%{packagename}/-/archive/%{packagever}/%{packagename}-%{packagever}.tar.gz
Patch0:         fedora.patch
Patch1:         selinux.patch
Patch2:	        https://gitlab.com/popsulfr/steamos-btrfs/-/raw/v1.2.6.20231104/files/usr/lib/hwsupport/steamos-automount.sh.patch.old.20231104103824.20231031.1000
Patch3:         https://gitlab.com/popsulfr/steamos-btrfs/-/raw/v1.2.6.20231104/files/usr/lib/hwsupport/format-device.sh.patch.old.20230922091429.20230915.100
Patch4:         user.patch
Patch5:         bazzite-btrfs.patch
Patch6:         systemd-run.patch
Patch7:         priv-write.patch
Patch8:         biosupdate.patch

Requires:       python3
Requires:       python3-evdev
Requires:       python3-crcmod
Requires:       python3-click
Requires:       python3-progressbar2
Requires:       python3-hid
Requires:       hidapi
Requires:       dmidecode
Requires:       jq
Requires:       alsa-utils
Requires:       parted
Requires:       e2fsprogs
Requires:       f3

BuildRequires:  systemd-rpm-macros
BuildRequires:  xcursorgen
BuildRequires:  sed

%description
SteamOS 3.0 Steam Deck Hardware Support Package

# Disable debug packages and build ID links
%define debug_package %{nil}

%prep
%autosetup -p1 -n %{packagename}-%{packagever}

%build

%install
export QA_RPATHS=0x0003
mkdir -p %{buildroot}%{_datadir}/
mkdir -p %{buildroot}%{_unitdir}/
mkdir -p %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_libexecdir}/
mkdir -p %{buildroot}%{_sysconfdir}/
mkdir -p %{buildroot}%{_prefix}/lib/hwsupport/
cp -rv usr/share/* %{buildroot}%{_datadir}
cp -rv usr/lib/systemd/system/* %{buildroot}%{_unitdir}/
cp usr/lib/hwsupport/power-button-handler.py %{buildroot}%{_prefix}/lib/hwsupport/power-button-handler.py
cp usr/lib/hwsupport/format-device.sh %{buildroot}%{_libexecdir}/format-device
cp usr/lib/hwsupport/format-sdcard.sh %{buildroot}%{_libexecdir}/format-sdcard
cp usr/lib/hwsupport/steamos-automount.sh %{buildroot}%{_libexecdir}/steamos-automount
cp usr/lib/hwsupport/trim-devices.sh %{buildroot}%{_libexecdir}/trim-devices
cp -rv usr/lib/udev %{buildroot}%{_prefix}/lib/udev
cp -rv usr/bin/* %{buildroot}%{_bindir}
cp -rv usr/lib/systemd/system/* %{buildroot}%{_unitdir}
cp -rv etc/* %{buildroot}%{_sysconfdir}
sed -i 's@steamos-cursor.png@usr/share/steamos/steamos-cursor.png@g' usr/share/steamos/steamos-cursor-config
xcursorgen usr/share/steamos/steamos-cursor-config %{buildroot}%{_datadir}/icons/steam/cursors/default
# Remove unneeded files
rm %{buildroot}%{_sysconfdir}/default/grub-steamos
rm %{buildroot}%{_datadir}/jupiter_bios_updater/h2offt-g
rm %{buildroot}%{_datadir}/jupiter_bios_updater/H2OFFTx64-G.sh
rm -rf %{buildroot}%{_datadir}/jupiter_bios_updater/driver
rm -rf %{buildroot}%{_unitdir}/multi-user.target.wants
rm -rf %{buildroot}%{_datadir}/alsa

# Do post-installation
%post
%systemd_post jupiter-biosupdate.service
%systemd_post jupiter-controller-update.service

# Do before uninstallation
%preun
%systemd_preun jupiter-biosupdate.service
%systemd_preun jupiter-controller-update.service

# Do after uninstallation
%postun
%systemd_postun_with_restart jupiter-biosupdate.service
%systemd_postun_with_restart jupiter-controller-update.service

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%{_sysconfdir}/systemd/system/*
%{_bindir}/amd_system_info
%{_bindir}/foxnet-biosupdate
%{_bindir}/jupiter-biosupdate
%{_bindir}/jupiter-initial-firmware-update
%{_bindir}/jupiter-check-support
%{_bindir}/jupiter-controller-update
%{_bindir}/steamos-polkit-helpers/*
%{_bindir}/thumbstick_cal
%{_bindir}/thumbstick_fine_cal
%{_bindir}/trigger_cal
%{_libexecdir}/format-device
%{_libexecdir}/format-sdcard
%{_libexecdir}/steamos-automount
%{_libexecdir}/trim-devices
%{_prefix}/lib/hwsupport/*
%{_prefix}/lib/systemd/system/*
%{_prefix}/lib/udev/rules.d/*
%{_datadir}/icons/steam/*
%{_datadir}/steamos/steamos.png
%{_datadir}/jupiter_bios/*
%{_datadir}/jupiter_bios_updater/*
%{_datadir}/jupiter_controller_fw_updater/*
%{_datadir}/plymouth/themes/steamos/*
%{_datadir}/polkit-1/actions/org.valve.steamos.policy
%{_datadir}/polkit-1/rules.d/org.valve.steamos.rules
%{_datadir}/steamos/steamos-cursor-config
%{_datadir}/steamos/steamos-cursor.png

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
