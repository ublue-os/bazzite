%global uuid compiz-windows-effect@hermes83.github.com

Name:        gnome-shell-extension-compiz-windows-effect
Version:     {{{ git_dir_version }}}
Release:     1%{?dist}
Summary:     Compiz wobbly windows effect for GNOME Shell

Group:       User Interface/Desktops
License:     GPLv2
URL:         https://github.com/hermes83/compiz-windows-effect
Source0:     https://github.com/bazzite-org/compiz-windows-effect/archive/refs/heads/master.tar.gz
BuildArch:   noarch

BuildRequires: glib2

Requires:    gnome-shell >= 3.12
%description
Compiz wobbly windows effect with compiz plugin engine.

%prep
%autosetup -n compiz-windows-effect-master

%build
# Nothing to build

%install
rm -rf assets
rm README.md
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r * %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/
glib-compile-schemas %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}/schemas/

%files
%license LICENSE
%{_datadir}/gnome-shell/extensions/%{uuid}/

%changelog
{{{ git_dir_changelog }}}