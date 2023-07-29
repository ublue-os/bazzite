Name:           sddm-sugar-steamOS
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Modified version of MarianArlt's Sugar theme for Simple Desktop Display Manager (SDDM), based on the aesthetic of Valve's SteamOS.
License:        GPLv3
URL:            https://github.com/KyleGospo/sddm-sugar-steamOS

Source0:        %{url}/archive/refs/heads/master.zip
BuildArch:      noarch

Requires:       sddm
Requires:       qt5-qtquickcontrols2
Requires:       qt5-qtsvg

%global debug_package %{nil}

%description
A modified version of MarianArlt's Sugar Dark theme for Simple Desktop Display Manager (SDDM). Based on the aesthetic of Valve's SteamOS. Created for HoloISO.

%prep
%autosetup -n %{name}-master
rm -rf .github
rm %{name}.spec

%install
mkdir -p %{buildroot}%{_datadir}/sddm/themes/sugar-steamOS
cp -rv * %{buildroot}%{_datadir}/sddm/themes/sugar-steamOS/
rm -rf %{buildroot}%{_datadir}/sddm/themes/sugar-steamOS/Previews
rm -rf %{buildroot}%{_datadir}/sddm/themes/sugar-steamOS/ImageWIP

%files
%license COPYING
%{_datadir}/sddm/themes/sugar-steamOS/*

%changelog
{{{ git_dir_changelog }}}
