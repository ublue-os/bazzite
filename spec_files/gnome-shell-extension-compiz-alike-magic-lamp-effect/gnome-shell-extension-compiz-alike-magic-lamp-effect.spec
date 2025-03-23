%global uuid compiz-alike-magic-lamp-effect@hermes83.github.com

Name:        gnome-shell-extension-compiz-alike-magic-lamp-effect
Version:     {{{ git_dir_version }}}
Release:     1%{?dist}
Summary:     Compiz alike magic lamp effect for GNOME Shell 

Group:       User Interface/Desktops
License:     GPLv2
URL:         https://github.com/hermes83/compiz-alike-magic-lamp-effect
Source0:     https://github.com/bazzite-org/compiz-alike-magic-lamp-effect/archive/refs/heads/master.tar.gz
BuildArch:   noarch

BuildRequires: glib2

Requires:    gnome-shell >= 3.12
%description
Compiz alike magic lamp effect for GNOME Shell 

%prep
%autosetup -n compiz-alike-magic-lamp-effect-master

%build
# Nothing to build

%install
rm -rf assets
rm README.md
rm zip.sh
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}
