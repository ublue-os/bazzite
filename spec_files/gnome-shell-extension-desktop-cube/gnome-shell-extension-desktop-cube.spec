%global uuid desktop-cube@schneegans.github.com

Name:        gnome-shell-extension-desktop-cube
Version:     28
Release:     1%{?dist}
Summary:     Indulge in nostalgia with useless 3D effects.

Group:       User Interface/Desktops
License:     GPLv3
URL:         https://github.com/Schneegans/Desktop-Cube
Source0:     %{url}/releases/download/v%{version}/%{uuid}.zip
BuildArch:   noarch

BuildRequires: glib2

Requires:    gnome-shell >= 3.12
%description
Indulge in nostalgia with useless 3D effects.

%prep
%setup -c -n %{uuid}.shell-extension

%build
# Nothing to build

%install
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}
