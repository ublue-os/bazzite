%global uuid tofumenu@tofu

Name:		   gnome-shell-extension-bazzite-menu
Version:   {{{ git_dir_version }}}
Release:   1%{?dist}
Summary:	 Tofu Menu fork that provides helpful shortcuts for the Steam Deck

Group:		 User Interface/Desktops
License:	 GPLv2
URL:		   https://github.com/KyleGospo/tofumenu
Source0:	 https://github.com/KyleGospo/tofumenu/archive/refs/heads/main.tar.gz
BuildArch: noarch

Requires:	gnome-shell >= 3.12
%description
Gnome shell extension that provides a Steam Deck icon in the top bar and helpful shortcuts. A fork of Tofu Menu.

%prep
%autosetup -n tofumenu-main

%build
# Nothing to build

%install
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
rm %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/LICENSE
rm %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/makefile
rm %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/{preview,screenshot1,screenshot2}.png

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}