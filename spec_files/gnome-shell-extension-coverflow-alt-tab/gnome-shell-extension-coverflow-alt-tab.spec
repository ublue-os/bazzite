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

Requires:    gnome-shell >= 3.12
%description
Coverflow like Alt-Tab replacement for Gnome-Shell

%prep
%autosetup -n CoverflowAltTab-%{version}

%build
# Nothing to build

%install
rm -rf assets
rm README.md
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license COPYING
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}