%global tarball_version %%(echo %{version} | tr '~' '.')

Name:           gnome-shell
Version:        45.4
Release:        %autorelease.bazzite.{{{ git_dir_version }}}
Summary:        Window management and application launching for GNOME

License:        GPLv2+
URL:            https://wiki.gnome.org/Projects/GnomeShell
Source0:        https://download.gnome.org/sources/gnome-shell/45/%{name}-%{tarball_version}.tar.xz

# Replace Epiphany with Firefox in the default favourite apps list
Patch: gnome-shell-favourite-apps-firefox.patch

# Some users might have a broken PAM config, so we really need this
# downstream patch to stop trying on configuration errors.
Patch: 0001-gdm-Work-around-failing-fingerprint-auth.patch

Patch: 0001-status-keyboard-Add-a-catch-around-reload-call.patch
Patch: 0002-status-keyboard-Load-keyboard-from-system-settings-i.patch
Patch: 0003-status-keyboard-Use-gnome-desktop-API-for-getting-de.patch

# shell-app: improve discrete GPU detectio
# https://gitlab.gnome.org/GNOME/gnome-shell/-/merge_requests/3193
Patch: 3193.patch

%define eds_version 3.45.1
%define gnome_desktop_version 44.0-7
%define glib2_version 2.56.0
%define gobject_introspection_version 1.49.1
%define gjs_version 1.73.1
%define gtk4_version 4.0.0
%define adwaita_version 1.0.0
%define mutter_version 45.0
%define polkit_version 0.100
%define gsettings_desktop_schemas_version 42~beta
%define ibus_version 1.5.2
%define gnome_bluetooth_version 1:42.3
%define gstreamer_version 1.4.5
%define pipewire_version 0.3.0
%define gnome_settings_daemon_version 3.37.1

BuildRequires:  bash-completion
BuildRequires:  gcc
BuildRequires:  meson
BuildRequires:  git
BuildRequires:  pkgconfig(ibus-1.0) >= %{ibus_version}
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(libedataserver-1.2) >= %{eds_version}
BuildRequires:  pkgconfig(gcr-4)
BuildRequires:  pkgconfig(gjs-1.0) >= %{gjs_version}
BuildRequires:  pkgconfig(gio-2.0) >= %{glib2_version}
BuildRequires:  pkgconfig(gnome-autoar-0)
BuildRequires:  pkgconfig(gnome-desktop-4) >= %{gnome_desktop_version}
BuildRequires:  pkgconfig(gobject-introspection-1.0) >= %{gobject_introspection_version}
BuildRequires:  mesa-libGL-devel
BuildRequires:  mesa-libEGL-devel
BuildRequires:  pkgconfig(libnm)
BuildRequires:  pkgconfig(polkit-agent-1) >= %{polkit_version}
BuildRequires:  pkgconfig(libstartup-notification-1.0)
BuildRequires:  pkgconfig(libsystemd)
# for screencast recorder functionality
BuildRequires:  pkgconfig(gstreamer-base-1.0) >= %{gstreamer_version}
BuildRequires:  pkgconfig(libpipewire-0.3) >= %{pipewire_version}
BuildRequires:  pkgconfig(gtk4) >= %{gtk4_version}
BuildRequires:  gettext >= 0.19.6
BuildRequires:  python3

# for barriers
BuildRequires:  libXfixes-devel >= 5.0
# used in unused BigThemeImage
BuildRequires:  librsvg2-devel
BuildRequires:  mutter-devel >= %{mutter_version}
BuildRequires:  pkgconfig(libpulse)
%ifnarch s390 s390x ppc ppc64 ppc64p7
BuildRequires:  gnome-bluetooth-libs-devel >= %{gnome_bluetooth_version}
%endif
# Bootstrap requirements
BuildRequires: gtk-doc
%ifnarch s390 s390x
Recommends:     gnome-bluetooth%{?_isa} >= %{gnome_bluetooth_version}
%endif
Requires:       gnome-desktop3%{?_isa} >= %{gnome_desktop_version}
%if 0%{?rhel} != 7
# Disabled on RHEL 7 to allow logging into KDE session by default
Recommends:     gnome-session-xsession
%endif
Requires:       gcr%{?_isa}
Requires:       gobject-introspection%{?_isa} >= %{gobject_introspection_version}
Requires:       gjs%{?_isa} >= %{gjs_version}
Requires:       gtk4%{?_isa} >= %{gtk4_version}
Requires:       libadwaita%{_isa} >= %{adwaita_version}
Requires:       libnma-gtk4%{?_isa}
# needed for loading SVG's via gdk-pixbuf
Requires:       librsvg2%{?_isa}
Requires:       mutter%{?_isa} >= %{mutter_version}
Requires:       upower%{?_isa}
Requires:       polkit%{?_isa} >= %{polkit_version}
Requires:       gnome-desktop4%{?_isa} >= %{gnome_desktop_version}
Requires:       glib2%{?_isa} >= %{glib2_version}
Requires:       gsettings-desktop-schemas%{?_isa} >= %{gsettings_desktop_schemas_version}
Requires:       gnome-settings-daemon%{?_isa} >= %{gnome_settings_daemon_version}
Requires:       gstreamer1%{?_isa} >= %{gstreamer_version}
# needed for screen recorder
Requires:       gstreamer1-plugins-good%{?_isa}
Requires:       pipewire-gstreamer%{?_isa}
Requires:       xdg-user-dirs-gtk
# needed for schemas
Requires:       at-spi2-atk%{?_isa}
# needed for on-screen keyboard
Requires:       ibus%{?_isa} >= %{ibus_version}
# needed for "show keyboard layout"
Requires:       tecla
# needed for the user menu
Requires:       accountsservice-libs%{?_isa}
Requires:       gdm-libs%{?_isa}
# needed for settings items in menus
Requires:       gnome-control-center
# needed by some utilities
Requires:       python3%{_isa}
# needed for the dual-GPU launch menu
Requires:       switcheroo-control
# needed for clocks/weather integration
Requires:       geoclue2-libs%{?_isa}
Requires:       libgweather4%{?_isa}
# for gnome-extensions CLI tool
Requires:  gettext
# needed for thunderbolt support
Requires:       bolt%{?_isa}
# Needed for launching flatpak apps etc
# 1.8.0 is needed for source type support in the screencast portal.
Requires:       xdg-desktop-portal-gtk >= 1.8.0
Requires:       xdg-desktop-portal-gnome
# needed by the welcome dialog
Recommends:     gnome-tour

Provides:       desktop-notification-daemon = %{version}-%{release}
Provides:       PolicyKit-authentication-agent = %{version}-%{release}
Provides:       bundled(gvc)
Provides:       bundled(libcroco) = 0.6.13

%if 0%{?rhel}
# In Fedora, fedora-obsolete-packages obsoletes caribou
Obsoletes:      caribou < 0.4.21-10
Obsoletes:      caribou-antler < 0.4.21-10
Obsoletes:      caribou-devel < 0.4.21-10
Obsoletes:      caribou-gtk2-module < 0.4.21-10
Obsoletes:      caribou-gtk3-module < 0.4.21-10
Obsoletes:      python-caribou < 0.4.21-10
Obsoletes:      python2-caribou < 0.4.21-10
Obsoletes:      python3-caribou < 0.4.21-10
%endif

# https://bugzilla.redhat.com/show_bug.cgi?id=1740897
Conflicts:      gnome-shell-extension-background-logo < 3.34.0

%description
GNOME Shell provides core user interface functions for the GNOME 3 desktop,
like switching to windows and launching applications. GNOME Shell takes
advantage of the capabilities of modern graphics hardware and introduces
innovative user interface concepts to provide a visually attractive and
easy to use experience.

%prep
%autosetup -S git -n %{name}-%{tarball_version}

%build
%meson -Dextensions_app=false
%meson_build

%install
%meson_install

# Create empty directories where other packages can drop extensions
mkdir -p %{buildroot}%{_datadir}/gnome-shell/extensions
mkdir -p %{buildroot}%{_datadir}/gnome-shell/search-providers

%find_lang %{name}

%check
desktop-file-validate %{buildroot}%{_datadir}/applications/org.gnome.Shell.desktop
desktop-file-validate %{buildroot}%{_datadir}/applications/org.gnome.Shell.Extensions.desktop
desktop-file-validate %{buildroot}%{_datadir}/applications/org.gnome.Shell.PortalHelper.desktop

%files -f %{name}.lang
%license COPYING
%doc README.md
%{_bindir}/gnome-shell
%{_bindir}/gnome-extensions
%{_bindir}/gnome-shell-extension-prefs
%{_bindir}/gnome-shell-extension-tool
%{_bindir}/gnome-shell-test-tool
%{_datadir}/glib-2.0/schemas/*.xml
%{_datadir}/glib-2.0/schemas/00_org.gnome.shell.gschema.override
%{_datadir}/applications/org.gnome.Shell.Extensions.desktop
%{_datadir}/applications/org.gnome.Shell.desktop
%{_datadir}/applications/org.gnome.Shell.PortalHelper.desktop
%{_datadir}/bash-completion/completions/gnome-extensions
%{_datadir}/gnome-control-center/keybindings/50-gnome-shell-launchers.xml
%{_datadir}/gnome-control-center/keybindings/50-gnome-shell-screenshots.xml
%{_datadir}/gnome-control-center/keybindings/50-gnome-shell-system.xml
%{_datadir}/gnome-shell/
%{_datadir}/dbus-1/services/org.gnome.ScreenSaver.service
%{_datadir}/dbus-1/services/org.gnome.Shell.CalendarServer.service
%{_datadir}/dbus-1/services/org.gnome.Shell.Extensions.service
%{_datadir}/dbus-1/services/org.gnome.Shell.HotplugSniffer.service
%{_datadir}/dbus-1/services/org.gnome.Shell.Notifications.service
%{_datadir}/dbus-1/services/org.gnome.Shell.PortalHelper.service
%{_datadir}/dbus-1/services/org.gnome.Shell.Screencast.service
%{_datadir}/dbus-1/interfaces/org.gnome.Shell.Extensions.xml
%{_datadir}/dbus-1/interfaces/org.gnome.Shell.Introspect.xml
%{_datadir}/dbus-1/interfaces/org.gnome.Shell.PadOsd.xml
%{_datadir}/dbus-1/interfaces/org.gnome.Shell.Screencast.xml
%{_datadir}/dbus-1/interfaces/org.gnome.Shell.Screenshot.xml
%{_datadir}/dbus-1/interfaces/org.gnome.ShellSearchProvider.xml
%{_datadir}/dbus-1/interfaces/org.gnome.ShellSearchProvider2.xml
%{_datadir}/icons/hicolor/scalable/apps/org.gnome.Shell.Extensions.svg
%{_datadir}/icons/hicolor/symbolic/apps/org.gnome.Shell.Extensions-symbolic.svg
%{_userunitdir}/org.gnome.Shell-disable-extensions.service
%{_userunitdir}/org.gnome.Shell.target
%{_userunitdir}/org.gnome.Shell@wayland.service
%{_userunitdir}/org.gnome.Shell@x11.service
# Co own directory instead of pulling in xdg-desktop-portal - we
# are providing a backend to the portal, not depending on it
%dir %{_datadir}/xdg-desktop-portal/portals/
%{_datadir}/xdg-desktop-portal/portals/gnome-shell.portal
%{_libdir}/gnome-shell/
%{_libexecdir}/gnome-shell-calendar-server
%{_libexecdir}/gnome-shell-perf-helper
%{_libexecdir}/gnome-shell-hotplug-sniffer
%{_libexecdir}/gnome-shell-portal-helper
%{_mandir}/man1/gnome-extensions.1*
%{_mandir}/man1/gnome-shell.1*

%changelog
%autochangelog
