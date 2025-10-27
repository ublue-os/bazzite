%global debug_package %{nil}

%global tarball_version %%(echo %{version} | tr '~' '.')

Name:           gsettings-desktop-schemas
Version:        49.1
Release:        %autorelease.bazzite
Summary:        A collection of GSettings schemas

License:        LGPL-2.1-or-later
# no homepage exists for this component
URL:            https://gitlab.gnome.org/GNOME/gsettings-desktop-schemas
Source0:        https://download.gnome.org/sources/%{name}/49/%{name}-%{tarball_version}.tar.xz
Source1:        org.gnome.desktop.interface.rhel.gschema.override

Patch:          https://gitlab.gnome.org/GNOME/gsettings-desktop-schemas/-/merge_requests/99.patch

BuildRequires:  gettext
BuildRequires:  glib2-devel >= 2.31.0
BuildRequires:  gobject-introspection-devel
BuildRequires:  meson

Requires: glib2 >= 2.31.0

# Recommend the default fonts set in the schemas
%if 0%{?rhel} && 0%{?rhel} >= 10
Recommends: font(redhattextvf)
Recommends: font(redhatmonovf)
%else
Recommends: font(adwaitasans)
Recommends: font(adwaitamono)
%endif

%description
gsettings-desktop-schemas contains a collection of GSettings schemas for
settings shared by various components of a desktop.


%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description    devel
The %{name}-devel package contains libraries
and header files for developing applications that use %{name}.


%prep
%autosetup -p1 -n %{name}-%{tarball_version}


%build
%meson
%meson_build


%install
%meson_install

%if 0%{?rhel} && 0%{?rhel} >= 10
cp %{SOURCE1} $RPM_BUILD_ROOT%{_datadir}/glib-2.0/schemas
%endif

%find_lang %{name} --with-gnome


%check
# Test that the schemas compile
glib-compile-schemas --dry-run --strict %{buildroot}%{_datadir}/glib-2.0/schemas


%files -f %{name}.lang
%doc AUTHORS MAINTAINERS NEWS README
%license COPYING
%{_datadir}/glib-2.0/schemas/*
%{_datadir}/GConf/gsettings/gsettings-desktop-schemas.convert
%{_datadir}/GConf/gsettings/wm-schemas.convert
%{_libdir}/girepository-1.0/GDesktopEnums-3.0.typelib

%files devel
%doc HACKING
%{_includedir}/*
%{_datadir}/pkgconfig/*
%{_datadir}/gir-1.0/GDesktopEnums-3.0.gir


%changelog
%autochangelog
