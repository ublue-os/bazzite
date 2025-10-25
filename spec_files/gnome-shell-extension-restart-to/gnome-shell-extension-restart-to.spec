%global uuid restartto@tiagoporsch.github.io

Name:        gnome-shell-extension-restart-to
Version:     10
Release:     1%{?dist}
Summary:     GNOME extension that adds a menu allowing to reboot into any existing UEFI boot entry 

Group:       User Interface/Desktops
License:     GPLv3
URL:         https://github.com/tiagoporsch/restartto
Source0:     %{url}/releases/download/%{version}/%{uuid}.shell-extension.zip
Source1:     LICENSE
BuildArch:   noarch

BuildRequires: glib2

Requires:    gnome-shell >= 3.12
%description
GNOME extension that adds a menu allowing to reboot into any existing UEFI boot entry 

%prep
%setup -c -n %{uuid}.shell-extension

%build
# Nothing to build

%install
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/
mkdir -p %{buildroot}%{_licensedir}/%{name}
cp -p %{SOURCE1} %{buildroot}%{_licensedir}/%{name}

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}
