Name:           jupiter-hw-support
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steam Deck Hardware Support Package
License:    	MIT
URL:            https://github.com/ublue-os/bazzite

Source:        	https://gitlab.com/evlaV/%{name}/-/archive/master/%{name}-master.tar.gz
Patch0:         fedora.patch

Requires:       python3
Requires:       python3-libevdev
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

BuildRequires:  systemd-rpm-macros

%description
SteamOS 3.0 Steam Deck Hardware Support Package

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n %{name}-master

%build

%install
export QA_RPATHS=0x0003
mkdir -p %{buildroot}%{_datadir}/
mkdir -p %{buildroot}%{_unitdir}/
mkdir -p %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_sysconfdir}/
cp -rv usr/share/* %{buildroot}%{_datadir}
cp -rv usr/lib/systemd/system/* %{buildroot}%{_unitdir}/
cp -rv usr/lib/hwsupport %{buildroot}%{_prefix}/lib/hwsupport
cp -rv usr/lib/udev %{buildroot}%{_prefix}/lib/udev
cp -rv usr/bin/* %{buildroot}%{_bindir}
cp -rv usr/lib/systemd/system/* %{buildroot}%{_unitdir}
cp -rv etc/* %{buildroot}%{_sysconfdir}
# Remove unneeded files
rm %{buildroot}%{_sysconfdir}/default/grub-steamos
rm %{buildroot}%{_datadir}/jupiter_bios_updater/h2offt-g
rm %{buildroot}%{_datadir}/jupiter_bios_updater/H2OFFTx64-G.sh
rm -rf %{buildroot}%{_datadir}/jupiter_bios_updater/driver
rm -rf %{buildroot}%{_unitdir}/multi-user.target.wants

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
%license LICENSE
# %%{_sysconfdir}/default/grub-steamos
%{_sysconfdir}/systemd/system/sdcard-mount@.service
%{_sysconfdir}/systemd/system/alsa-restore.service
%{_sysconfdir}/xdg/kded5rc
%{_bindir}/amd_system_info
%{_bindir}/foxnet-biosupdate
%{_bindir}/jupiter-biosupdate
%{_bindir}/jupiter-check-support
%{_bindir}/jupiter-controller-update
%{_bindir}/steamos-polkit-helpers/jupiter-biosupdate
%{_bindir}/steamos-polkit-helpers/jupiter-check-support
%{_bindir}/steamos-polkit-helpers/jupiter-dock-updater
%{_bindir}/steamos-polkit-helpers/jupiter-fan-control
%{_bindir}/steamos-polkit-helpers/jupiter-get-als-gain
%{_bindir}/steamos-polkit-helpers/steamos-devkit-mode
%{_bindir}/steamos-polkit-helpers/steamos-disable-wireless-power-management
%{_bindir}/steamos-polkit-helpers/steamos-enable-sshd
%{_bindir}/steamos-polkit-helpers/steamos-factory-reset-config
%{_bindir}/steamos-polkit-helpers/steamos-format-sdcard
%{_bindir}/steamos-polkit-helpers/steamos-poweroff-now
%{_bindir}/steamos-polkit-helpers/steamos-priv-write
%{_bindir}/steamos-polkit-helpers/steamos-reboot-now
%{_bindir}/steamos-polkit-helpers/steamos-reboot-other
%{_bindir}/steamos-polkit-helpers/steamos-restart-sddm
%{_bindir}/steamos-polkit-helpers/steamos-select-branch
%{_bindir}/steamos-polkit-helpers/steamos-set-hostname
%{_bindir}/steamos-polkit-helpers/steamos-set-timezone
%{_bindir}/steamos-polkit-helpers/steamos-update
%{_bindir}/thumbstick_cal
%{_bindir}/trigger_cal
%{_prefix}/lib/hwsupport/cirrus-fixup.sh
%{_prefix}/lib/hwsupport/ev2_cirrus_alsa_fixups.sh
%{_prefix}/lib/hwsupport/format-sdcard.sh
%{_prefix}/lib/hwsupport/power-button-handler.py
%{_prefix}/lib/hwsupport/sdcard-mount.sh
%{_prefix}/lib/systemd/system/jupiter-biosupdate.service
%{_prefix}/lib/systemd/system/jupiter-controller-update.service
%{_prefix}/lib/udev/rules.d/99-power-button.rules
%{_prefix}/lib/udev/rules.d/99-sdcard-mount.rules
%{_datadir}/alsa/ucm2/conf.d/acp5x/HiFi.conf
%{_datadir}/alsa/ucm2/conf.d/acp5x/acp5x.conf
%{_datadir}/icons/steam/index.theme
%{_datadir}/icons/steam/cursors/arrow
%{_datadir}/icons/steam/cursors/left_ptr
%{_datadir}/icons/steam/cursors/left_ptr_help
%{_datadir}/icons/steam/cursors/left_ptr_watch
%{_datadir}/steamos/steamos.png
%{_datadir}/jupiter_bios/F7A0110_sign.fd
%{_datadir}/jupiter_bios_updater/BatCtrl
# %%{_datadir}/jupiter_bios_updater/H2OFFTx64-G.sh
%{_datadir}/jupiter_bios_updater/H2OFFTx64.sh
%{_datadir}/jupiter_bios_updater/Logo.png
# %%{_datadir}/jupiter_bios_updater/driver/Makefile
# %%{_datadir}/jupiter_bios_updater/driver/phy_alloc.c
# %%{_datadir}/jupiter_bios_updater/driver/phy_alloc.h
%{_datadir}/jupiter_bios_updater/h2offt
# %%{_datadir}/jupiter_bios_updater/h2offt-g
%{_datadir}/jupiter_bios_updater/h2osde-lx64
%{_datadir}/jupiter_bios_updater/msg_cht.ini
%{_datadir}/jupiter_bios_updater/msg_eng.ini
%{_datadir}/jupiter_bios_updater/platform.ini
%{_datadir}/jupiter_controller_fw_updater/D20_APP_REL_631F5DF4.bin
%{_datadir}/jupiter_controller_fw_updater/D21_APP_REL_631F5DF4.bin
%{_datadir}/jupiter_controller_fw_updater/RA_APP_REL_631F5DF4.bin
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/boot_ra_Release.srec
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/linux_host_tools/BatCtrl
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/linux_host_tools/rfp-linux-x64/Devices.xml
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/linux_host_tools/rfp-linux-x64/License_Agreement.txt
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/linux_host_tools/rfp-linux-x64/Messages.xml
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/linux_host_tools/rfp-linux-x64/libRFP.so
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/linux_host_tools/rfp-linux-x64/rfp-cli
%{_datadir}/jupiter_controller_fw_updater/RA_bootloader_updater/rfp_cli_linux.sh
%{_datadir}/jupiter_controller_fw_updater/d20bootloader.py
%{_datadir}/jupiter_controller_fw_updater/d21bootloader16.py
%{_datadir}/plymouth/themes/steamos/steamos.plymouth
%{_datadir}/plymouth/themes/steamos/steamos.png
%{_datadir}/plymouth/themes/steamos/steamos.script
%{_datadir}/polkit-1/actions/org.valve.steamos.policy
%{_datadir}/polkit-1/rules.d/org.valve.steamos.rules
%{_datadir}/steamos/steamos-cursor-config
%{_datadir}/steamos/steamos-cursor.png

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
