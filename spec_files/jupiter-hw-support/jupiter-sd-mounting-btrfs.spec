%define packagename jupiter-hw-support
%define packagever jupiter-3.6-20240624.1
%global _default_patch_fuzz 2

Name:           jupiter-sd-mounting-btrfs
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        SteamOS SD card mounting for desktops
License:        GPLv3
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/%{packagename}/-/archive/%{packagever}/%{packagename}-%{packagever}.tar.gz
Source1:        99-sdcard-rescan.rules
Source2:        99-steamos-automount.rules
Source3:        99-framework-steam-automount.rules
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
Patch10:        ntfs.patch
Patch11:        more-time.patch

Requires:       jq

BuildRequires:  systemd-rpm-macros

Conflicts:      %{packagename}-btrfs

%description
SteamOS SD card mounting for desktops

# Disable debug packages and build ID links
%define debug_package %{nil}

%prep
%autosetup -p1 -n %{packagename}-%{packagever}

%build

%install
export QA_RPATHS=0x0003
mkdir -p %{buildroot}%{_libexecdir}/hwsupport/
mkdir -p %{buildroot}%{_prefix}/lib/udev/rules.d/
cp usr/lib/hwsupport/sdcard-rescan.sh %{buildroot}%{_libexecdir}/hwsupport/sdcard-rescan.sh
cp usr/lib/hwsupport/steamos-automount.sh %{buildroot}%{_libexecdir}/hwsupport/steamos-automount.sh
cp usr/lib/hwsupport/common-functions %{buildroot}%{_libexecdir}/hwsupport/common-functions
cp usr/lib/hwsupport/block-device-event.sh %{buildroot}%{_libexecdir}/hwsupport/block-device-event.sh
cp %{SOURCE1} %{buildroot}%{_prefix}/lib/udev/rules.d/99-sdcard-rescan.rules
cp %{SOURCE2} %{buildroot}%{_prefix}/lib/udev/rules.d/99-steamos-automount.rules
cp %{SOURCE3} %{buildroot}%{_prefix}/lib/udev/rules.d/99-framework-steam-automount.rules

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%{_libexecdir}/hwsupport/sdcard-rescan.sh
%{_libexecdir}/hwsupport/steamos-automount.sh
%{_libexecdir}/hwsupport/common-functions
%{_libexecdir}/hwsupport/block-device-event.sh
%{_prefix}/lib/udev/rules.d/*

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
