%define packagename jupiter-hw-support
%define packagever jupiter-3.6-20240624.1
%global _default_patch_fuzz 2

Name:           %{packagename}-btrfs
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steam Deck Hardware Support Package
License:        GPLv3
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/%{packagename}/-/archive/%{packagever}/%{packagename}-%{packagever}.tar.gz
Source2:        bazzite.png
Source3:        https://github.com/apmorton/pyhidapi/raw/396ae60212fe08ff1d12879e9a049fb126e966c3/hid/__init__.py
Patch0:         fedora.patch
Patch1:         selinux.patch
Patch2:         btrfs-automount.patch
Patch3:         btrfs-format.patch
Patch4:         user.patch
Patch5:         bazzite-btrfs.patch
Patch6:         priv-write.patch
Patch7:         biosupdate.patch
Patch8:         gnome.patch
Patch9:         fstrim.patch
Patch10:        cursor-path.patch
Patch11:        ntfs.patch
Patch12:        more-time.patch
Patch13:        supported-hw.patch

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
mkdir -p %{buildroot}%{_libexecdir}/hwsupport/
cp -rv usr/share/* %{buildroot}%{_datadir}
cp -rv usr/lib/systemd/system/* %{buildroot}%{_unitdir}/
cp usr/lib/hwsupport/format-device.sh %{buildroot}%{_libexecdir}/hwsupport/format-device.sh
cp usr/lib/hwsupport/format-sdcard.sh %{buildroot}%{_libexecdir}/hwsupport/format-sdcard.sh
cp usr/lib/hwsupport/sdcard-rescan.sh %{buildroot}%{_libexecdir}/hwsupport/sdcard-rescan.sh
cp usr/lib/hwsupport/steamos-automount.sh %{buildroot}%{_libexecdir}/hwsupport/steamos-automount.sh
cp usr/lib/hwsupport/trim-devices.sh %{buildroot}%{_libexecdir}/hwsupport/trim-devices.sh
cp usr/lib/hwsupport/common-functions %{buildroot}%{_libexecdir}/hwsupport/common-functions
cp usr/lib/hwsupport/block-device-event.sh %{buildroot}%{_libexecdir}/hwsupport/block-device-event.sh
cp -rv usr/lib/udev %{buildroot}%{_prefix}/lib/udev
cp -rv usr/bin/* %{buildroot}%{_bindir}
cp -rv usr/lib/systemd/system/* %{buildroot}%{_unitdir}
xcursorgen usr/share/steamos/steamos-cursor-config %{buildroot}%{_datadir}/icons/steam/cursors/default
# Remove unneeded files
rm %{buildroot}%{_datadir}/jupiter_bios_updater/h2offt-g
rm %{buildroot}%{_datadir}/jupiter_bios_updater/H2OFFTx64-G.sh
rm %{buildroot}%{_datadir}/steamos/steamos.png
rm %{buildroot}%{_prefix}/lib/udev/rules.d/80-gpu-reset.rules
rm -rf %{buildroot}%{_datadir}/jupiter_bios_updater/driver
rm -rf %{buildroot}%{_unitdir}/multi-user.target.wants
rm -rf %{buildroot}%{_datadir}/alsa
# Add Bazzite PNG
cp %{SOURCE2} %{buildroot}%{_datadir}/steamos/steamos.png
# Add fix for controller FW updater
cp %{SOURCE3} %{buildroot}%{_datadir}/jupiter_controller_fw_updater/hid.py

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
%{_libexecdir}/hwsupport/format-device.sh
%{_libexecdir}/hwsupport/format-sdcard.sh
%{_libexecdir}/hwsupport/sdcard-rescan.sh
%{_libexecdir}/hwsupport/steamos-automount.sh
%{_libexecdir}/hwsupport/trim-devices.sh
%{_libexecdir}/hwsupport/common-functions
%{_libexecdir}/hwsupport/block-device-event.sh
%{_prefix}/lib/systemd/system/*
%{_prefix}/lib/udev/rules.d/*
%{_datadir}/icons/steam/*
%{_datadir}/jupiter_bios/*
%{_datadir}/jupiter_bios_updater/*
%{_datadir}/jupiter_controller_fw_updater/*
%{_datadir}/plymouth/themes/steamos/*
%{_datadir}/polkit-1/actions/org.valve.steamos.policy
%{_datadir}/polkit-1/rules.d/org.valve.steamos.rules
%{_datadir}/steamos/*

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
