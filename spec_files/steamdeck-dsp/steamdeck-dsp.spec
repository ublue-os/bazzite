Name:           steamdeck-dsp
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steamdeck Audio Processing
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite
Source:         https://gitlab.com/evlaV/valve-hardware-audio-processing/-/archive/main/valve-hardware-audio-processing-main.tar.gz

BuildRequires:  make
BuildRequires:  faust
BuildRequires:  faust-tools
BuildRequires:  boost-devel
BuildRequires:  lv2-devel
BuildRequires:  g++

%description
Steamdeck Audio Processing

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n valve-hardware-audio-processing-main

%build
%make_build FAUSTINC="/usr/include/faust"  FAUSTLIB="/usr/share/faust"

%install
%make_install DEST_DIR="%{buildroot}"
mkdir -p %{buildroot}%{_datadir}/licenses/%{name}/
cp LICENSE %{buildroot}%{_datadir}/licenses/%{name}/LICENSE

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%license LICENSE
%{_prefix}/lib/firmware/amd/*
%{_prefix}/lib/lv2/svg/valve_deck_*
%{_prefix}/lib/lv2/valve_*
%{_datadir}/alsa/ucm2/conf.d/acp5x/*.conf
%{_datadir}/alsa/ucm2/conf.d/sof-nau8821-max/*.conf
%{_datadir}/pipewire/pipewire.conf.d/*.conf
%{_datadir}/wireplumber/bluetooth.lua.d/*.lua
%{_datadir}/wireplumber/main.lua.d/*.lua
%{_datadir}/wireplumber/scripts/*.lua

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}