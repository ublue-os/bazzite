Name:           steamdeck-dsp
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steamdeck Audio Processing
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite
Source:         https://gitlab.com/evlaV/valve-hardware-audio-processing/-/archive/main/valve-hardware-audio-processing-main.tar.gz

BuildRequires:  make
BuildRequires:  faust
BuildRequires:  boost-devel
BuildRequires:  lv2-devel

%description
Steamdeck Audio Processing

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n valve-hardware-audio-processing-main

%build
%make_build FAUSTINC="/usr/include/faust"  FAUSTLIB="/usr/share/faust"

%install
%make_install

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%license valve-hardware-audio-processing-main/LICENSE

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}