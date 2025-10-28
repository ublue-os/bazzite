%global glib_version 2.81.1
%global gtk3_version 3.19.8
%global gtk4_version 4.0.0
%global gsettings_desktop_schemas_version 47~beta
%global libinput_version 1.26.0
%global pipewire_version 1.2.0
%global lcms2_version 2.6
%global colord_version 1.4.5
%global libei_version 1.3.901
%global _default_patch_fuzz 2

%global mutter_api_version 17

%global major_version %%(echo %{version} | cut -d '.' -f1 | cut -d '~' -f 1)
%global tarball_version %%(echo %{version} | tr '~' '.')

Name:          mutter
Version:       49.1.1
Release:       %autorelease.bazzite
Summary:       Window and compositing manager based on Clutter

# Automatically converted from old format: GPLv2+ - review is highly recommended.
License:       GPL-2.0-or-later
URL:           https://www.gnome.org
Source0:       https://download.gnome.org/sources/%{name}/%{major_version}/%{name}-%{tarball_version}.tar.xz
Source1:       org.gnome.mutter.fedora.gschema.override

# https://bugzilla.redhat.com/show_bug.cgi?id=1936991
Patch0:        mutter-42.alpha-disable-tegra.patch

# https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/4296
Patch10:       https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/4296.patch

BuildRequires: pkgconfig(gobject-introspection-1.0) >= 1.41.0
BuildRequires: pkgconfig(sm)
BuildRequires: pkgconfig(libadwaita-1)
BuildRequires: pkgconfig(libwacom)
BuildRequires: pkgconfig(xkbcommon)
BuildRequires: mesa-libEGL-devel
BuildRequires: mesa-libGLES-devel
BuildRequires: mesa-libGL-devel
BuildRequires: mesa-libgbm-devel
BuildRequires: pkgconfig(glesv2)
BuildRequires: pkgconfig(graphene-gobject-1.0)
BuildRequires: pam-devel
BuildRequires: pkgconfig(libdisplay-info)
BuildRequires: pkgconfig(libpipewire-0.3) >= %{pipewire_version}
BuildRequires: pkgconfig(sysprof-capture-4)
BuildRequires: sysprof-devel
BuildRequires: pkgconfig(libsystemd)
BuildRequires: pkgconfig(umockdev-1.0)
BuildRequires: desktop-file-utils
BuildRequires: cvt
BuildRequires: python3-argcomplete
BuildRequires: python3-docutils
# Bootstrap requirements
BuildRequires: gettext-devel git-core
BuildRequires: pkgconfig(libcanberra)
BuildRequires: pkgconfig(gsettings-desktop-schemas) >= %{gsettings_desktop_schemas_version}
BuildRequires: pkgconfig(gnome-settings-daemon)
BuildRequires: meson
BuildRequires: pkgconfig(gbm)
BuildRequires: pkgconfig(glycin-2)
BuildRequires: pkgconfig(gnome-desktop-4)
BuildRequires: pkgconfig(gudev-1.0)
BuildRequires: pkgconfig(libdrm)
BuildRequires: pkgconfig(libstartup-notification-1.0)
BuildRequires: pkgconfig(wayland-protocols)
BuildRequires: pkgconfig(wayland-server)
BuildRequires: pkgconfig(lcms2) >= %{lcms2_version}
BuildRequires: pkgconfig(colord) >= %{colord_version}
BuildRequires: pkgconfig(libei-1.0) >= %{libei_version}
BuildRequires: pkgconfig(libeis-1.0) >= %{libei_version}

BuildRequires: pkgconfig(libinput) >= %{libinput_version}
BuildRequires: pkgconfig(xwayland)
BuildRequires: pkgconfig(bash-completion)

BuildRequires: python3-dbusmock

Requires: control-center-filesystem
Requires: gsettings-desktop-schemas%{?_isa} >= %{gsettings_desktop_schemas_version}
Requires: gnome-settings-daemon
Requires: gtk4%{?_isa} >= %{gtk4_version}
Requires: libinput%{?_isa} >= %{libinput_version}
Requires: pipewire%{_isa} >= %{pipewire_version}
Requires: startup-notification
Requires: dbus
Requires: python3-argcomplete

# Need common
Requires: %{name}-common = %{version}-%{release}

Recommends: mesa-dri-drivers%{?_isa}

Provides: firstboot(windowmanager) = mutter

# Cogl and Clutter were forked at these versions, but have diverged
# significantly since then.
Provides: bundled(cogl) = 1.22.0
Provides: bundled(clutter) = 1.26.0

Conflicts: mutter < 45~beta.1-2

# Make sure dnf updates gnome-shell together with this package; otherwise we
# might end up with broken gnome-shell installations due to mutter ABI changes.
Conflicts: gnome-shell < 45~rc

%description
Mutter is a window and compositing manager that displays and manages
your desktop via OpenGL. Mutter combines a sophisticated display engine
using the Clutter toolkit with solid window-management logic inherited
from the Metacity window manager.

While Mutter can be used stand-alone, it is primarily intended to be
used as the display core of a larger system such as GNOME Shell. For
this reason, Mutter is very extensible via plugins, which are used both
to add fancy visual effects and to rework the window management
behaviors to meet the needs of the environment.

%package common
Summary: Common files used by %{name} and forks of %{name}
BuildArch: noarch
Conflicts: mutter < 45~beta.1-2

%description common
Common files used by Mutter and soft forks of Mutter

%package devel
Summary: Development package for %{name}
Requires: %{name}%{?_isa} = %{version}-%{release}
# for EGL/eglmesaext.h that's included from public cogl-egl-defines.h header
Requires: mesa-libEGL-devel

%description devel
Header files and libraries for developing Mutter plugins. Also includes
utilities for testing Metacity/Mutter themes.

%package  tests
Summary:  Tests for the %{name} package
Requires: %{name}-devel%{?_isa} = %{version}-%{release}
Requires: %{name}%{?_isa} = %{version}-%{release}
Requires: gtk3%{?_isa} >= %{gtk3_version}

%description tests
The %{name}-tests package contains tests that can be used to verify
the functionality of the installed %{name} package.

%prep
%autosetup -S git -n %{name}-%{tarball_version}

%build
%meson -Degl_device=true
%meson_build

%install
%meson_install
install -p %{SOURCE1} %{buildroot}%{_datadir}/glib-2.0/schemas

%find_lang %{name}

%files -f %{name}.lang
%license COPYING
%doc NEWS
%{_bindir}/mutter
%{_datadir}/polkit-1/actions/org.gnome.mutter.*.policy
%{_bindir}/gdctl
%{_bindir}/gnome-service-client
%{_datadir}/bash-completion/completions/gdctl
%{_libdir}/lib*.so.*
%{_libdir}/mutter-%{mutter_api_version}/
%{_libexecdir}/mutter-backlight-helper
%{_libexecdir}/mutter-x11-frames
%{_mandir}/man1/mutter.1*
%{_mandir}/man1/gdctl.1*
%{_mandir}/man1/gnome-service-client.1*

%files common
%{_datadir}/GConf/gsettings/mutter-schemas.convert
%{_datadir}/glib-2.0/schemas/org.gnome.mutter.fedora.gschema.override
%{_datadir}/glib-2.0/schemas/org.gnome.mutter.gschema.xml
%{_datadir}/glib-2.0/schemas/org.gnome.mutter.wayland.gschema.xml
%{_datadir}/gnome-control-center/keybindings/50-mutter-*.xml
%{_udevrulesdir}/61-mutter.rules

%files devel
%{_datadir}/applications/org.gnome.Mutter.Mdk.desktop
%{_datadir}/glib-2.0/schemas/org.gnome.mutter.devkit.gschema.xml
%{_datadir}/icons/hicolor/*/apps/org.gnome.Mutter.Mdk*
%{_includedir}/*
%{_libdir}/lib*.so
%{_libdir}/mutter-%{mutter_api_version}/*.gir
%{_libdir}/pkgconfig/*
%{_libexecdir}/mutter-devkit

%files tests
%{_libexecdir}/installed-tests/mutter-%{mutter_api_version}
%{_datadir}/installed-tests/mutter-%{mutter_api_version}
%{_datadir}/mutter-%{mutter_api_version}/tests

%changelog
%autochangelog
