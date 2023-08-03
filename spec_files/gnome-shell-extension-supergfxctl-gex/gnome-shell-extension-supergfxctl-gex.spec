%global extdir      %{_datadir}/gnome-shell/extensions/supergfxctl-gex@asus-linux.org
%global gschemadir  %{_datadir}/glib-2.0/schemas

%global giturl https://gitlab.com/asus-linux/supergfxctl-gex

Name:           gnome-shell-extension-supergfxctl-gex
Version:        5.1.1
Release:        1%{?dist}
Summary:        Extension for visualizing supergfxctl settings and status.

License:        MIT
URL:            https://gitlab.com/asus-linux/supergfxctl-gex
Source0:        https://gitlab.com/asus-linux/supergfxctl-gex/-/archive/main/supergfxctl-gex-main.tar.gz

BuildArch:      noarch

BuildRequires:  nodejs-npm
BuildRequires:  gettext
BuildRequires:  make
BuildRequires:  sassc
BuildRequires:  %{_bindir}/glib-compile-schemas
BuildRequires:  gnome-shell
BuildRequires:  glib2-devel

Requires:       gnome-shell-extension-common
Requires:       dconf-editor
Requires:       dconf
Requires:	      supergfxctl

%description
Extension for visualizing supergfxctl settings and status.

%prep
%autosetup -n supergfxctl-gex-main -p 1

%build
npm i
npm run build
glib-compile-resources --external-data \
                       --generate=.gresource \
                       --sourcedir=./ \
                       --target=_build/resources/org.gnome.Shell.Extensions.supergfxctl-gex.gresource resources/org.gnome.Shell.Extensions.supergfxctl-gex.gresource.xml

%install
mkdir -p %{buildroot}%{extdir}/
mv /builddir/build/BUILD/supergfxctl-gex-main/_build/* %{buildroot}%{extdir}/

%files
%doc README.md
%license LICENSE
%{extdir}

%changelog
