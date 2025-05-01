%global uuid  burn-my-windows@schneegans.github.com

Name:        gnome-shell-extension-burn-my-windows
Version:     46
Release:     1%{?dist}
Summary:     Disintegrate your windows with style.

Group:       User Interface/Desktops
License:     GPLv3
URL:         https://github.com/Schneegans/Burn-My-Windows
Source0:     %{url}/releases/download/v%{version}/%{uuid}.zip
BuildArch:   noarch

BuildRequires: glib2

Requires:    gnome-shell >= 3.12
%description
Disintegrate your windows with style.

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
