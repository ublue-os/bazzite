%global uuid restartto@tiagoporsch.github.io

Name:        gnome-shell-extension-restart-to
Version:     8
Release:     1%{?dist}
Summary:     GNOME extension that adds a menu allowing to reboot into any existing UEFI boot entry 

Group:       User Interface/Desktops
License:     GPLv2
URL:         https://github.com/tiagoporsch/restartto
Source0:     %{url}/releases/download/%{version}/%{uuid}.shell-extension.zip
BuildArch:   noarch

BuildRequires: glib2

Requires:    gnome-shell >= 3.12
%description
GNOME extension that adds a menu allowing to reboot into any existing UEFI boot entry 

%prep
%setup -q -T
mkdir -p %{uuid}.shell-extension
cd %{uuid}.shell-extension
unzip %{SOURCE0}

%build
# Nothing to build

%install
rm README.md
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}
