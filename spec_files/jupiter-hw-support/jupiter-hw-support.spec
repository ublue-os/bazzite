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
%setup -n %{name}-master
%patch 0 -p1

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
%{_sysconfdir}/systemd/system/*
%{_bindir}/amd_system_info
%{_bindir}/foxnet-biosupdate
%{_bindir}/jupiter-biosupdate
%{_bindir}/jupiter-check-support
%{_bindir}/jupiter-controller-update
%{_bindir}/steamos-polkit-helpers/*
%{_bindir}/thumbstick_cal
%{_bindir}/thumbstick_fine_cal
%{_bindir}/trigger_cal
%{_prefix}/lib/hwsupport/*
%{_prefix}/lib/systemd/system/*
%{_prefix}/lib/udev/rules.d/*
%{_datadir}/alsa/ucm2/conf.d/acp5x/*
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
