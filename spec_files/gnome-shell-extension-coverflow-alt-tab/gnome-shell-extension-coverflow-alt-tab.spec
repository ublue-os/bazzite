%global uuid CoverflowAltTab@palatis.blogspot.com

Name:        gnome-shell-extension-coverflow-alt-tab
Version:     76
Release:     1%{?dist}
Summary:     Coverflow like Alt-Tab replacement for Gnome-Shell

Group:       User Interface/Desktops
License:     GPLv3
URL:         https://github.com/dsheeler/CoverflowAltTab
Source0:     https://github.com/dsheeler/CoverflowAltTab/archive/refs/tags/v%{version}.tar.gz
BuildArch:   noarch

BuildRequires: glib2
BuildRequires: make
BuildRequires: gnome-shell

Requires:    gnome-shell >= 3.12
%description
Coverflow like Alt-Tab replacement for Gnome-Shell

%prep
%autosetup -n CoverflowAltTab-%{version}

%build
%set_build_flags
%make_build

%install
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
unzip build/%{uuid}.shell-extension.zip -d %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}

%files
%license COPYING
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}