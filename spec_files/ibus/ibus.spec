%global source_version %%(echo "%version" | tr '~' '-')

# https://fedoraproject.org/wiki/Changes/No_more_automagic_Python_bytecompilation_phase_3
%if (0%{?fedora} > 29 || 0%{?rhel} > 7)
%global with_python2 0
%else
%global with_python2 1
%endif

%global with_pkg_config %(pkg-config --version >/dev/null 2>&1 && echo -n "1" || echo -n "0")

%global ibus_api_version 1.0
%global pkgcache /var/cache/%name

# for bytecompile in %%{_datadir}/ibus/setup
%global __python %{__python3}

# No gtk2 in RHEL 10
%if 0%{?rhel} > 9
%bcond_with    gtk2
%bcond_with    xinit
%else
%bcond_without gtk2
%bcond_with    xinit
%endif

%if (0%{?fedora} > 33 || 0%{?rhel} > 8)
%bcond_without gtk4
%else
%bcond_with    gtk4
%endif

# FIXME: How to write a condition with multiple lines
%global ibus_panel_condition (%pcd1 or %pcd2 or %pcd3)
%global pcd1 budgie-desktop or cinnamon or deepin-desktop or i3
%global pcd2 lxqt-session or lxsession or mate-panel or phosh
%global pcd3 plasma-workspace or sugar or xfce4-session

%if %with_pkg_config
%if %{with gtk2}
%{!?gtk2_binary_version: %global gtk2_binary_version %(pkg-config  --variable=gtk_binary_version gtk+-2.0)}
%else
%{!?gtk2_binary_version: %global gtk2_binary_version ?.?.?}
%endif
%{!?gtk3_binary_version: %global gtk3_binary_version %(pkg-config  --variable=gtk_binary_version gtk+-3.0)}
%if %{with gtk4}
%{!?gtk4_binary_version: %global gtk4_binary_version %(pkg-config  --variable=gtk_binary_version gtk4)}
%else
%{!?gtk4_binary_version: %global gtk4_binary_version ?.?.?}
%endif
%global glib_ver %([ -a %{_libdir}/pkgconfig/glib-2.0.pc ] && pkg-config --modversion glib-2.0 | cut -d. -f 1,2 || echo -n "999")
%else
%{!?gtk2_binary_version: %global gtk2_binary_version ?.?.?}
%{!?gtk3_binary_version: %global gtk3_binary_version ?.?.?}
%{!?gtk4_binary_version: %global gtk4_binary_version ?.?.?}
%global glib_ver 0
%endif

%global dbus_python_version 0.83.0

Name:           ibus
Version:        1.5.30
# https://github.com/fedora-infra/rpmautospec/issues/101
Release:        100.bazzite
Summary:        Intelligent Input Bus for Linux OS
License:        LGPL-2.1-or-later
URL:            https://github.com/ibus/%name/wiki
Source0:        https://github.com/ibus/%name/releases/download/%{source_version}/%{name}-%{source_version}.tar.gz
Source1:        https://github.com/ibus/%name/releases/download/%{source_version}/%{name}-%{source_version}.tar.gz.sum
Source2:        %{name}-xinput
Source3:        %{name}.conf.5
# Patch0:         %%{name}-HEAD.patch
Patch0:         %{name}-HEAD.patch
# Under testing #1349148 #1385349 #1350291 #1406699 #1432252 #1601577
Patch1:         %{name}-1385349-segv-bus-proxy.patch
%if %{without xinit}
# Use mutter window manager in RHEL CI
Patch100:       %{name}-xx-desktop-testing-mutter.patch
%endif

# autoreconf requires autopoint but not po.m4
BuildRequires:  gettext-devel
BuildRequires:  libtool
# for gtkdoc-fixxref
BuildRequires:  glib2-doc
%if %{with gtk2}
BuildRequires:  gtk2-devel
%endif
BuildRequires:  gtk3-devel
%if %{with gtk4}
BuildRequires:  gtk4-devel
%endif
BuildRequires:  dbus-python-devel >= %{dbus_python_version}
BuildRequires:  desktop-file-utils
BuildRequires:  gtk-doc
BuildRequires:  dconf-devel
BuildRequires:  dbus-x11
BuildRequires:  python3-devel
BuildRequires:  python3-gobject
%if %with_python2
# https://bugzilla.gnome.org/show_bug.cgi?id=759334
# Need python2 for gsettings-schema-convert
BuildRequires:  python2-devel
# for AM_GCONF_SOURCE_2 in configure.ac
BuildRequires:  GConf2-devel
BuildRequires:  intltool
%endif
BuildRequires:  git
BuildRequires:  vala
BuildRequires:  iso-codes-devel
BuildRequires:  libnotify-devel
BuildRequires:  wayland-devel
BuildRequires:  cldr-emoji-annotation
BuildRequires:  unicode-emoji
BuildRequires:  unicode-ucd
BuildRequires:  systemd
# for ibus-keypress
BuildRequires:  libXtst-devel

Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}
%if %{with gtk2}
Requires:      (%{name}-gtk2%{?_isa}   = %{version}-%{release} if gtk2)
%endif
Requires:       %{name}-gtk3%{?_isa}   = %{version}-%{release}
Requires:       %{name}-setup          = %{version}-%{release}
Requires:      (%{name}-panel%{?_isa}   = %{version}-%{release} if %ibus_panel_condition)

Requires:       iso-codes
Requires:       dconf
# rpmlint asks to delete librsvg2
#Requires:       librsvg2
# Owner of %%python3_sitearch/gi/overrides
Requires:       python3-gobject
# https://bugzilla.redhat.com/show_bug.cgi?id=1161871
%{?__python3:Requires: %{__python3}}
%if %{with xinit}
# Owner of %%{_sysconfdir}/X11/xinit
Requires:       xorg-x11-xinit
Requires:       setxkbmap
%endif
%if (0%{?fedora} > 29 || 0%{?rhel} > 8)
%else
Requires:       dbus-x11
%endif

Requires:               desktop-file-utils
Requires(post):         desktop-file-utils
Requires(postun):       desktop-file-utils
Requires:               dconf
Requires(postun):       dconf
Requires(posttrans):    dconf

Requires:               %{_sbindir}/alternatives
Requires(post):         %{_sbindir}/alternatives
Requires(postun):       %{_sbindir}/alternatives

%global _xinputconf %{_sysconfdir}/X11/xinit/xinput.d/ibus.conf

%description
IBus means Intelligent Input Bus. It is an input framework for Linux OS.

%package libs
Summary:        IBus libraries

Requires:       dbus >= 1.2.4
Requires:       glib2 >= %{glib_ver}
# Owner of %%{_libdir}/girepository-1.0
Requires:       gobject-introspection
%if (0%{?fedora} > 28 || 0%{?rhel} > 7)
%else
Conflicts:      %{name}%{?_isa} < %{version}
%endif

%description libs
This package contains the libraries for IBus

%if %{with gtk2}
%package gtk2
Summary:        IBus IM module for GTK2
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}
Requires:       glib2 >= %{glib_ver}
Requires(post): glib2 >= %{glib_ver}
# Added for upgrade el6 to el7
Provides:       ibus-gtk = %{version}-%{release}
Obsoletes:      ibus-gtk < %{version}-%{release}

%description gtk2
This package contains IBus IM module for GTK2
%endif

%package gtk3
Summary:        IBus IM module for GTK3
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}
Requires:       glib2 >= %{glib_ver}
Requires(post): glib2 >= %{glib_ver}

%description gtk3
This package contains IBus IM module for GTK3

%if %{with gtk4}
%package gtk4
Summary:        IBus IM module for GTK4
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}
Requires:       glib2 >= %{glib_ver}
Requires(post): glib2 >= %{glib_ver}

%description gtk4
This package contains IBus IM module for GTK4
%endif

%package setup
Summary:        IBus setup utility
Requires:       %{name} = %{version}-%{release}
%{?__python3:Requires: %{__python3}}
Requires:       python3-gobject
BuildRequires:  gobject-introspection-devel
BuildRequires:  python3-gobject-devel
BuildRequires:  make
BuildArch:      noarch

%description setup
This is a setup utility for IBus.

%if %with_python2
%package pygtk2
Summary:        IBus PyGTK2 library
%if (0%{?fedora} && 0%{?fedora} <= 27) || (0%{?rhel} && 0%{?rhel} <= 7)
Requires:       dbus-python >= %{dbus_python_version}
%else
Requires:       python2-dbus >= %{dbus_python_version}
%endif
Requires:       python2
Requires:       pygtk2
BuildArch:      noarch

%description pygtk2
This is a PyGTK2 library for IBus. Now major IBus engines use PyGObject3
and this package will be deprecated.
%endif

%package py2override
Summary:        IBus Python2 override library
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}
# Owner of %%python2_sitearch/gi/overrides
%if (0%{?fedora} && 0%{?fedora} <= 27) || (0%{?rhel} && 0%{?rhel} <= 7)
Requires:       pygobject3-base
%else
Requires:       python2-gobject-base
%endif
Requires:       python2

%description py2override
This is a Python2 override library for IBus. The Python files override
some functions in GObject-Introspection.

%package wayland
Summary:        IBus IM module for Wayland
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}

%description wayland
This package contains IBus IM module for Wayland

%package panel
Summary:        IBus Panel icon
Requires:       %{name}%{?_isa}        = %{version}-%{release}
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}
%if %{without xinit}
# ibus-xinit is not available in RHEL
%endif
BuildRequires:  libdbusmenu-gtk3-devel

%description panel
This package contains IBus Panel icon using GtkStatusIcon or AppIndicator
in non-GNOME desktop sessions likes XFCE or Plasma because gnome-shell
shows the IBus Icon. This package depends on libdbusmenu-gtk3 for Wayland
desktop sessions.

%if %{without xinit}
%package xinit
Summary:        IBus Xinit
Requires:       %{name} = %{version}-%{release}
BuildArch:      noarch

%description xinit
This package includes xinit scripts to set environment variables of IBus
for Xorg desktop sessions and this is not needed by Wayland desktop sessions.
%endif

%package devel
Summary:        Development tools for ibus
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}
Requires:       dbus-devel
Requires:       glib2-devel
# for %%{_datadir}/gettext/its
Requires:       gettext-runtime

%description devel
The ibus-devel package contains the header files and developer
docs for ibus.

%package devel-docs
Summary:        Developer documents for IBus
BuildArch:      noarch

%description devel-docs
The ibus-devel-docs package contains developer documentation for IBus

%package desktop-testing
Summary:        Wrapper of InstalledTests Runner for IBus
Requires:       %{name} = %{version}-%{release}
%if 0%{?fedora:1}%{?rhel:0}
# Use no-overview mode in CI to get input focus
BuildRequires:  gnome-shell-extension-no-overview
Requires:       gnome-shell-extension-no-overview
%endif
BuildArch:      noarch

%description desktop-testing
GNOME desktop testing runner implements the InstalledTests specification
and IBus also needs focus events to enable input contexts on text widgets.
The wrapper script runs gnome-session for the focus events and GNOME
desktop testing runner internally.

%package  tests
Summary:        Tests for the %{name} package
Requires:       %{name}%{?_isa}        = %{version}-%{release}
Requires:       %{name}-libs%{?_isa}   = %{version}-%{release}

%description tests
The %{name}-tests package contains tests that can be used to verify
the functionality of the installed %{name} package.


%prep
SAVED_SUM=$(grep sha512sum %SOURCE1 | awk '{print $2}')
MY_SUM=$(sha512sum %SOURCE0 | awk '{print $1}')
if test x"$SAVED_SUM" != x"$MY_SUM" ; then
    abort
fi
%autosetup -S git -n %{name}-%{source_version}
# cp client/gtk2/ibusimcontext.c client/gtk3/ibusimcontext.c || :
# cp client/gtk2/ibusim.c client/gtk3/ibusim.c || :
# cp client/gtk2/ibusimcontext.c client/gtk4/ibusimcontext.c || :
cp client/gtk2/ibusimcontext.c client/gtk3/ibusimcontext.c || :
cp client/gtk2/ibusimcontext.c client/gtk4/ibusimcontext.c || :


# prep test
for f in ibusimcontext.c ibusim.c
do
    diff client/gtk2/$f client/gtk3/$f
    if test $? -ne 0 ; then
        echo "Have to copy $f into client/gtk3"
        abort
    fi
done
diff client/gtk2/ibusimcontext.c client/gtk4/ibusimcontext.c
if test $? -ne 0 ; then
    echo "Have to copy ibusimcontext.c into client/gtk4"
    abort
fi

%build
#autoreconf -f -i -v
#make -C ui/gtk3 maintainer-clean-generic
#make -C tools maintainer-clean-generic
#make -C src/compose maintainer-clean-generic
autoreconf -f -i -v
%configure \
    --disable-static \
%if %{with gtk2}
    --enable-gtk2 \
%else
    --disable-gtk2 \
%endif
    --enable-gtk3 \
%if %{with gtk4}
    --enable-gtk4 \
%endif
    --enable-xim \
    --enable-gtk-doc \
    --enable-surrounding-text \
    --with-python=python3 \
%if ! %with_python2
    --disable-python2 \
%else
    --enable-python-library \
%endif
    --enable-wayland \
    --enable-introspection \
    --enable-install-tests \
    %{nil}
make -C ui/gtk3 maintainer-clean-generic

%make_build

%install
make install DESTDIR=$RPM_BUILD_ROOT INSTALL='install -p'
rm -f $RPM_BUILD_ROOT%{_libdir}/libibus-*%{ibus_api_version}.la
%if %{with gtk2}
rm -f $RPM_BUILD_ROOT%{_libdir}/gtk-2.0/%{gtk2_binary_version}/immodules/im-ibus.la
%endif
rm -f $RPM_BUILD_ROOT%{_libdir}/gtk-3.0/%{gtk3_binary_version}/immodules/im-ibus.la
%if %{with gtk4}
rm -f $RPM_BUILD_ROOT%{_libdir}/gtk-4.0/%{gtk4_binary_version}/immodules/libim-ibus.la
%endif
%if %{without xinit}
# setxkbmap is not available in RHEL10
rm -f $RPM_BUILD_ROOT%{_datadir}/installed-tests/ibus/xkb-latin-layouts.test
%endif

# install man page
for S in %{SOURCE3}
do
  cp $S .
  MP=`basename $S` 
  gzip $MP
  install -pm 644 -D ${MP}.gz $RPM_BUILD_ROOT%{_datadir}/man/man5/${MP}.gz
done

# install xinput config file
install -pm 644 -D %{SOURCE2} $RPM_BUILD_ROOT%{_xinputconf}

install -m 755 -d $RPM_BUILD_ROOT%pkgcache/bus
# `rpm -Vaq ibus` compare st_mode of struct stat with lstat(2) and
# st_mode of the RPM cache and if the file does not exist, st_mode of
# RPM cache is o0100000 while the actual st_mode is o0100644.
touch $RPM_BUILD_ROOT%pkgcache/bus/registry

# install .desktop files
%if %with_python2
echo "NoDisplay=true" >> $RPM_BUILD_ROOT%{_datadir}/applications/ibus-setup.desktop
%else
echo "NoDisplay=true" >> $RPM_BUILD_ROOT%{_datadir}/applications/org.freedesktop.IBus.Setup.desktop
%endif
#echo "X-GNOME-Autostart-enabled=false" >> $RPM_BUILD_ROOT%%{_sysconfdir}/xdg/autostart/ibus.desktop

mkdir -p $RPM_BUILD_ROOT%{_libdir}/ibus
cp src/compose/sequences-* $RPM_BUILD_ROOT%{_libdir}/ibus

HAS_PREFIX=$(grep prefix $RPM_BUILD_ROOT%{_bindir}/ibus-setup | wc -l)
[ x"$HAS_PREFIX" == x1 ] && \
  sed -i -e '/prefix/d' $RPM_BUILD_ROOT%{_bindir}/ibus-setup

desktop-file-install --delete-original          \
  --dir $RPM_BUILD_ROOT%{_datadir}/applications \
  $RPM_BUILD_ROOT%{_datadir}/applications/*

# FIXME: no version number
%find_lang %{name}10

%check
make check \
    DISABLE_GUI_TESTS="ibus-compose ibus-keypress test-stress xkb-latin-layouts" \
    VERBOSE=1 \
    %{nil}

%if %{with xinit}
%post
%else
%post xinit
%endif
%{_sbindir}/alternatives --install %{_sysconfdir}/X11/xinit/xinputrc xinputrc %{_xinputconf} 83 || :

%postun
if [ "$1" -eq 0 ]; then
%if %{with xinit}
  %{_sbindir}/alternatives --remove xinputrc %{_xinputconf} || :
  # if alternative was set to manual, reset to auto
  [ -L %{_sysconfdir}/alternatives/xinputrc -a "`readlink %{_sysconfdir}/alternatives/xinputrc`" = "%{_xinputconf}" ] && %{_sbindir}/alternatives --auto xinputrc || :
%endif

  # 'dconf update' sometimes does not update the db...
  dconf update || :
  [ -f %{_sysconfdir}/dconf/db/ibus ] && \
      rm %{_sysconfdir}/dconf/db/ibus || :
fi

%if %{without xinit}
%postun xinit
if [ "$1" -eq 0 ]; then
  %{_sbindir}/alternatives --remove xinputrc %{_xinputconf} || :
  # if alternative was set to manual, reset to auto
  [ -L %{_sysconfdir}/alternatives/xinputrc -a "`readlink %{_sysconfdir}/alternatives/xinputrc`" = "%{_xinputconf}" ] && %{_sbindir}/alternatives --auto xinputrc || :
fi
%endif

%posttrans
dconf update || :

%transfiletriggerin -- %{_datadir}/ibus/component
[ -x %{_bindir}/ibus ] && \
  %{_bindir}/ibus write-cache --system &>/dev/null || :

%transfiletriggerpostun -- %{_datadir}/ibus/component
[ -x %{_bindir}/ibus ] && \
  %{_bindir}/ibus write-cache --system &>/dev/null || :


%ldconfig_scriptlets libs

%files -f %{name}10.lang
# FIXME: no version number
%doc AUTHORS COPYING README
%dir %{_datadir}/ibus/
%{_bindir}/ibus
%{_bindir}/ibus-daemon
%{_datadir}/applications/org.freedesktop.IBus.Panel.Emojier.desktop
%{_datadir}/applications/org.freedesktop.IBus.Panel.Extension.Gtk3.desktop
%{_datadir}/bash-completion/completions/ibus.bash
%{_datadir}/dbus-1/services/*.service
%{_datadir}/GConf/gsettings/*
%{_datadir}/glib-2.0/schemas/*.xml
%{_datadir}/ibus/component
%{_datadir}/ibus/dicts
%dir %{_datadir}/ibus/engine
%{_datadir}/ibus/keymaps
%{_datadir}/icons/hicolor/*/apps/*
%{_datadir}/man/man1/ibus.1.gz
%{_datadir}/man/man1/ibus-daemon.1.gz
%{_datadir}/man/man7/ibus-emoji.7.gz
%{_datadir}/man/man5/00-upstream-settings.5.gz
%{_datadir}/man/man5/ibus.5.gz
%if %{with xinit}
%{_datadir}/man/man5/ibus.conf.5.gz
%endif
%{_libexecdir}/ibus-engine-simple
%{_libexecdir}/ibus-dconf
%{_libexecdir}/ibus-portal
%{_libexecdir}/ibus-extension-gtk3
%{_libexecdir}/ibus-ui-emojier
%{_libexecdir}/ibus-x11
%{_sysconfdir}/dconf/db/ibus.d
%{_sysconfdir}/dconf/profile/ibus
%dir %{_sysconfdir}/xdg/Xwayland-session.d
%{_sysconfdir}/xdg/Xwayland-session.d/10-ibus-x11
%dir %{_prefix}/lib/systemd/user/gnome-session.target.wants
%{_prefix}/lib/systemd/user/gnome-session.target.wants/*.service
%{_prefix}/lib/systemd/user/org.freedesktop.IBus.session.*.service
%python3_sitearch/gi/overrides/__pycache__/*.py*
%python3_sitearch/gi/overrides/IBus.py
%if %{with xinit}
# ibus owns xinput.d because gnome does not like to depend on imsettings.
%dir %{_sysconfdir}/X11/xinit/xinput.d
# Do not use %%config(noreplace) to always get the new keywords in _xinputconf
# For user customization, $HOME/.xinputrc can be used instead.
%config %{_xinputconf}
%endif
%verify(not mtime) %dir %pkgcache
%verify(not mtime) %dir %pkgcache/bus
# 'ibus write-cache --system' updates the system cache.
%ghost %pkgcache/bus/registry

%files libs
%{_libdir}/libibus-*%{ibus_api_version}.so.*
%dir %{_libdir}/girepository-1.0
%{_libdir}/girepository-1.0/IBus*-1.0.typelib

%if %{with gtk2}
%files gtk2
%{_libdir}/gtk-2.0/%{gtk2_binary_version}/immodules/im-ibus.so
%endif

%files gtk3
%{_libdir}/gtk-3.0/%{gtk3_binary_version}/immodules/im-ibus.so

%if %{with gtk4}
%files gtk4
%dir %{_libdir}/gtk-4.0/%{gtk4_binary_version}/immodules
%{_libdir}/gtk-4.0/%{gtk4_binary_version}/immodules/libim-ibus.so
%endif

# The setup package won't include icon files so that
# gtk-update-icon-cache is executed in the main package only one time.
%files setup
%{_bindir}/ibus-setup
%if %with_python2
%{_datadir}/applications/ibus-setup.desktop
%else
%{_datadir}/applications/org.freedesktop.IBus.Setup.desktop
%endif
%{_datadir}/ibus/setup
%{_datadir}/man/man1/ibus-setup.1.gz

%if %with_python2
%files pygtk2
%dir %{python2_sitelib}/ibus
%{python2_sitelib}/ibus/*
%endif

%if %with_python2
%files py2override
%python2_sitearch/gi/overrides/IBus.py*
%endif

%files wayland
%{_libexecdir}/ibus-wayland

%files panel
%{_datadir}/applications/org.freedesktop.IBus.Panel.Wayland.Gtk3.desktop
%{_libexecdir}/ibus-ui-gtk3

%if %{without xinit}
%files xinit
%{_datadir}/man/man5/ibus.conf.5.gz
# ibus owns xinit directory without xorg-x11-xinit package
%dir %{_sysconfdir}/X11/xinit
%dir %{_sysconfdir}/X11/xinit/xinput.d
%config %{_xinputconf}
%endif

%files devel
%{_libdir}/ibus
%{_libdir}/lib*.so
%{_libdir}/pkgconfig/*
%{_includedir}/*
%{_datadir}/gettext/its/ibus.*
%dir %{_datadir}/gir-1.0
%{_datadir}/gir-1.0/IBus*-1.0.gir
%dir %{_datadir}/vala
%dir %{_datadir}/vala/vapi
%{_datadir}/vala/vapi/ibus-*1.0.vapi
%{_datadir}/vala/vapi/ibus-*1.0.deps

%files devel-docs
# Own html dir since gtk-doc is heavy.
%dir %{_datadir}/gtk-doc
%dir %{_datadir}/gtk-doc/html
%{_datadir}/gtk-doc/html/*

%files desktop-testing
%{_bindir}/ibus-desktop-testing-runner
%{_datadir}/ibus/tests
%{_libexecdir}/ibus-desktop-testing-autostart

%files tests
%dir %{_libexecdir}/installed-tests
%{_libexecdir}/installed-tests/ibus
%dir %{_datadir}/installed-tests
%{_datadir}/installed-tests/ibus

%changelog
* Thu Oct 31 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30-7
- Resolves #2321990 Move xinit post scripts

* Wed Aug 14 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30-6
- Revert to fix typing freeze with barcode reader

* Sat Jun 08 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30-5
- Resolves #2290842 Fix Super-space in Wayland
- Fix compose sequences beyond U10000

* Fri Jun 07 2024 Python Maint <python-maint@redhat.com> - 1.5.30-4
- Rebuilt for Python 3.13

* Sat Jun 01 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30-3
- Resolve #2284094 Fix preedit in Flatpak with new DBus unique name
- Add directory %%{_prefix}/lib/systemd/user/gnome-session.target.wants
- Add directory %%{_libdir}/gtk-4.0/%{gtk4_binary_version}/immodules

* Fri May 24 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30-2
- Resolve #2252227 Fix display buffer overflow
- Change IBus unique name to :1.0 from IBUS_SERVICE_IBUS

* Thu May 02 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30-1
- Bump to 1.5.30

* Fri Apr 12 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30~rc3-2
- New sub package ibus-xinit for RHEL not to depend on xorg-x11-xinit

* Tue Apr 02 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30~rc3-1
- Delete upstreamed patches

* Mon Mar 25 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30~rc2-2
- Fix Super modifier in IBusEngine
- Replace deprecated pygobject3-devel with python3-gobject-devel

* Fri Mar 22 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30~rc2-1
- Add some bug fixes & translation updates

* Wed Feb 28 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30~rc1-1
- Add some bug fixes & translation updates

* Tue Feb 13 2024 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.30~beta1-1
- Implement ibus start/restart for Plasma Wayland
- Show preferences menu item in activate menu in Plasma Wayland
- Fix typing freeze with barcode reader

* Wed Jan 24 2024 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.29~rc2-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Sat Jan 20 2024 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.29~rc2-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Thu Dec 21 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc2-6
- Fix game control keys with language layout

* Fri Dec 15 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc2-5
- Refactor object initialization
- Fix some warnings

* Tue Dec 05 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc2-4
- Complete preedit signals for PostProcessKeyEvent

* Sat Nov 25 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc2-3
- Resolve #2188800 Error handling with display == null
- Enhance #2237486 Implement preedit color in Plasma Wayland

* Wed Nov 15 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc2-2
- Call strdup() after g_return_if_fail() in im-ibus.so

* Thu Nov 09 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc2-1
- Bump to 1.5.29-rc2

* Wed Oct 25 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc1-6
- Add preedit D-Bus signals to PostProcessKeyEvent

* Mon Oct 23 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc1-5
- Add DeleteSurroundingText to PostProcessKeyEvent

* Sat Sep 30 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc1-4
- Enhance #2237486 Implement preedit color in Plasma Wayland
- Part-of #2240490 Eacute with CapsLock in Plasma Wayland only
- Revert dnf5 to dnf in autogen
- Test fix #2239633 g_list_remove() in ibus-portal SIGSEGV

* Thu Sep 07 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc1-3
- Resolves #2237486 Implement preedit color in Plasma Wayland

* Tue Aug 22 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc1-2
- Resolves #2233527 Add IMSETTINGS_IGNORE_SESSION=KDE-wayland in ibus.conf

* Tue Aug 22 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~rc1-1
- Bump to 1.5.29-rc1

* Mon Aug 21 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~beta2-3
- Add ibus_panel_condition

* Fri Aug 18 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~beta2-2
- Separate ibus-ui-gtk3 as ibus-panel sub package depended on libdbusmenu
- Update autogen.sh for Fedora 39
- Fix cursor position with GTK4 in Xorg

* Tue Aug 08 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~beta2-1
- Distinguish Arabic XKB and Keypad XKB options

* Thu Aug 03 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~beta1-2
- Fix some source tests
- Fix configure --disable-appindicator
- Fix typo in src/ibusservice.h

* Fri Jul 28 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.29~beta1-1
- Implement Plasma Wayland

* Thu Jul 20 2023 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.28-14
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Wed Jul 12 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-13
- Fix sync ibus_input_context_process_key_event() #3

* Sun Jul 09 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-12
- Fix sync ibus_input_context_process_key_event() #2

* Fri Jul 07 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-11
- Fix sync ibus_input_context_process_key_event()

* Wed Jul 05 2023 Python Maint <python-maint@redhat.com> - 1.5.28-10
- Rebuilt for Python 3.12

* Wed Jul 05 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-9
- Delete upstreamed ibus-xx-cross-compile.patch
- Fix alive ibus-x11 with `Xephyr -query`
- Fix missing ibusenumtypes.h with parallel build
- Fix to build libibus-1.0.la twice

* Thu Jun 15 2023 Python Maint <python-maint@redhat.com> - 1.5.28-8
- Rebuilt for Python 3.12

* Sun Jun 11 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-7
- Delete GZipped man files
- Resolves #2213145 Unselect Add button in Select Input Method dialog in setup
- Fix unaligned accesses in ibuscomposetable

* Fri May 26 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-6
- Resolves: #2195895 ibus_input_context_set_cursor_location(): ibus-x11 SIGSEGV

* Fri May 12 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-5
- Fix cross compiling with gen-internal-compose-table

* Wed May 10 2023 Tomas Popela <tpopela@redhat.com> - 1.5.28-5
- Drop BR on dbus-glib as the project is using already GDBus

* Tue May 02 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-4
- Migrate some upstream patches

* Fri Mar 17 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-3
- Resolves: #2178178 Fix emoji lookup table only but emojier GUI left

* Wed Mar 15 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-2
- Fix Key typing order in ibus-x11
- Disable while loop before call ForwardEventMessageProc() in ibus-x11

* Tue Feb 21 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.28-1
- Bump to 1.5.28

* Fri Feb 17 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-15
- Resolves: #2169205 Return error if D-Bus set/get property method is failed

* Wed Jan 25 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-14
- Add active-surrounding-text property to IBusEngine
- Refactor surrounding text warning & free focus-id tables

* Thu Jan 19 2023 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.27-13
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Tue Jan 17 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-12
- Resolves: #2160957 Fix st_mode in struct stat of registry file with rpm -Va

* Thu Jan 12 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-11
- Refactor surrounding text warning

* Fri Jan 06 2023 Tomas Popela <tpopela@redhat.com> - 1.5.27-10
- Don't build GTK 2 content for RHEL 10 as GTK 2 won't be there

* Thu Jan 05 2023 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-9
- Convert gtk_compose_seqs_compact to GResource

* Wed Dec 07 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-8
- Resolved: #2151344 SEGV with portal_context->owner in name_owner_changed()

* Fri Dec 02 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-7
- Add GitHub action patches

* Thu Nov 24 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-6
-  Implement new process_key_event for ibus-x11

* Wed Nov 16 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-5
- Migrate license tag to SPDX

* Thu Nov 03 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-4
- Resolves: #2081055 Avoid to unref m_engines with double run

* Mon Sep 19 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-3
- Update ibus_input_context_set_surrounding_text for a global IC
- Fix CI

* Fri Sep 16 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-2
- Resolves: #2093313 Stop many warnings of surrounding text
- Fix other surrounding text issues

* Tue Aug 23 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.27-1
- Bump to 1.5.27

* Thu Aug 18 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-17
- Resolves: #2119020 Require gettext-runtime instead of gettext for ibus-devel

* Fri Aug 12 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-16
- Revert Emoji shortcut key to Super-period

* Fri Jul 29 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-15
- Enhance Xutf8TextListToTextProperty in ibus-x11

* Thu Jul 21 2022 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.26-14
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Thu Jul 07 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-13
- Add IBUS_CAP_OSK to IBusCapabilite
- Update ibus restart for --service-file option
- Update manpage for ibus im-module command
- Implement new process_key_event for GTK4
- Add focus_in_id()/focus_out_id() class methods in IBusEngine

* Wed Jun 29 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-12
- Add ibus im-module command

* Sat Jun 25 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-11
- Enable custome theme
- Fix ibus restart for GNOME desktop

* Mon Jun 13 2022 Python Maint <python-maint@redhat.com> - 1.5.26-10
- Rebuilt for Python 3.11

* Sat Jun 11 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-9
- Resolves: #2088656 Revise XKB engine panel menu in Plasma Wayland

* Thu Jun 02 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-8
- Resolves: #2088656 Hide XKB engine but enable it in Plasma Wayland

* Wed May 25 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-7
- Update xkb-latin-layouts gsettings

* Mon May 23 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-6
- Resolves: #1936777 abrt ibus_bus_connect_async(): ibus-x11

* Wed Apr 20 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-4
- Resolves: #2076596 Disable XKB engines in Plasma Wayland

* Thu Mar 31 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-3
- Fix refcounting issues in IBusText & IBusProperty

* Mon Mar 28 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-2
- Update ibus-desktop-testing-runner to always run ibus-daemon directly

* Mon Mar 14 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.26-1
- Bump to 1.5.26
- Revert CCedilla change for pt-BR

* Fri Mar 04 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-13
- Check XDG_SESSION_DESKTOP for Plasma desktop

* Tue Mar 01 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-12
- Fix algorithm dead keys

* Mon Feb 21 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-11
- Fix forwarding keycode in GTK4

* Fri Feb 11 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-10
- Do not mkdir abstract unix socket
- Fix IBus.key_event_from_string
- Add systemd unit file

* Thu Feb 03 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-9
- Change XKB layout string color in panel
- Add Ctrl-semicolon to Emoji shortcut key
- Fix unref problems with floating references
- Update man page for Emoji shortcut key
- Add IBUS_INPUT_HINT_PRIVATE for browser private mode
- mkdir socket dirs instead of socket paths

* Thu Jan 20 2022 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.25-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Tue Jan 18 2022 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-7
- Update and fix typo in autostart scripts

* Fri Dec 03 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-6
- Check mtime of entity compose file instead of one of symlink file
- Disable emoji shortcut key with no-emoji hint
- Resolves: #2026540 Own %%pkgcache directory

* Fri Oct 29 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-5
- Resolves: #1942970 Clear Emoijer preedit/lookup popup between applications

* Mon Sep 06 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-4
- Clear preedit with mouse click and GTK4 applications

* Wed Sep 01 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-3
- Fix wrong cursor location in gtk3

* Fri Aug 27 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-2
- Add --screendump option in ibus-desktop-testing-runner

* Fri Aug 20 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.25-1
- Bump to 1.5.25

* Mon Aug 09 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-13
- Enable sync process in GTK4

* Mon Jul 26 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-12
- Search language name in engine list in ibus-setup
- Set Multi_key to 0xB7 in compose preedit
- Make Compose preedit less intrusive

* Thu Jul 22 2021 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.24-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Thu Jul 15 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-10
- Support include directive in user compose file
- Set Ctrl-period to default Emoji shortcut key

* Tue Jun 29 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-9
- Delete G_MESSAGES_DEBUG for gsettings output

* Mon Jun 28 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-8
- Depend on gnome-shell-extension-no-overview for CI

* Thu Jun 17 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-7
- Use transfiletriggerin and transfiletriggerpostun
- Change mutter to no-overview gnome-shell in CI

* Fri Jun 04 2021 Python Maint <python-maint@redhat.com> - 1.5.24-6
- Rebuilt for Python 3.10

* Wed May 26 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-5
- Fix minor covscan reviews

* Fri May 21 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-4
- Fix covscan reviews
- Implement ibus_im_context_set_surrounding_with_selection()

* Sat Mar 20 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-3
- Don't output FAIL if the actual failure is 0 for Fedora CI

* Sat Mar 20 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-2
- Change default session to mutter from gnome in desktop-testing

* Mon Feb 22 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.24-1
- Bump to 1.5.24

* Tue Jan 26 2021 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.23-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Wed Jan 20 2021 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.23-3
- Enable IM gtk4 module
- Fix to rename xkb:de::ger to sync xkeyboard-config
- Enhance ibus-setup search engine

* Fri Nov 20 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.23-2
- Bug 1898065 - Fix build failure of emoji-*.dict with CLDR 38
- Fix build failure with Vala 0.50
- Add IBUS_INPUT_PURPOSE_TERMINAL

* Tue Sep 29 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.23-1
- Bump to 1.5.23

* Tue Sep 15 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-17
- Update po files

* Wed Sep 09 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-16
- Bug 1876877 - Fix to pull the correct language with no iso639 variants
- Accept xdigits only for Unicode typing

* Thu Aug 27 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-15
- Rename simple.xml to simple.xml.in

* Thu Aug 27 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-14
- Update ibusunicodegen.h with latest unicode-ucd
- Update simple.xml with latest xkeyboard-config
- Fix gvfsd-fuse to unbind directory
- Update translations

* Fri Aug 21 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-13
- Update simple.xml with layout_variant

* Fri Aug 21 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-12
- Generate simple.xml with denylist
- Tell Pango about the engine language in the candidate panel
- Add file list in registry file for Silverblue

* Tue Jul 28 2020 Adam Jackson <ajax@redhat.com> - 1.5.22-11
- Require setxkbmap not xorg-x11-xkb-utils

* Tue Jul 28 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-10
- Delete _python_bytecompile_extra
- Update CI from ibus-typing-booster

* Tue Jul 28 2020 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.22-9
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Tue May 26 2020 Miro Hrončok <mhroncok@redhat.com> - 1.5.22-8
- Rebuilt for Python 3.9

* Fri May 15 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-7
- Resolves #1797726 bus_engine_proxy_new_internal() SIGTRAP

* Fri May 15 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-6
- Update HEAD.patch to make parallel dict build
- Update 1385349-segv-bus-proxy.patch
- Resolves #1767976 #1601577 #1771238 #1797120

* Wed Apr 22 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-5
- Update ibus-desktop-testing-runner for su command

* Wed Mar 11 2020 Adam Williamson <awilliam@redhat.com> - 1.5.22-4
- Update #2195 patch backport (it was revised upstream)

* Wed Mar 11 2020 Adam Williamson <awilliam@redhat.com> - 1.5.22-3
- Backport PR #2195 to fix ibus with GNOME 3.36.0

* Tue Feb 25 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-2
- Bug 1805634 - Add a conditional requires ibus-gtk2 with gtk2

* Thu Feb 13 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.22-1
- Bump to 1.5.22
- Delete package depending ibus-gtk2

* Thu Feb 13 2020 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-9
- Bug 1785276 - Fix abrt without XDG_CACHE_HOME/ibus
- Bug 1788754 - Fix abrt with NULL output of compose keys
- Bug 1787732 - Fix abrt in exit handlers in ibus-x11
- Bug 1795499 - Fix abrt in bus monitor handlers when ibus-daemon restarts
- Fix greek cases
- Increase sleep 3 to wait for running ibus-config in CI.

* Wed Jan 29 2020 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.21-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Thu Dec 26 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-7
- Revise the previous Hangul patch

* Tue Dec 24 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-6
- Fix to connect button-press-event for Hangul
- Delete a previous workaround targeted to firefox only for Hangul

* Wed Dec 11 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-5
- Add RHEL code reviews
- Fix Hangul preedit with mouse click

* Mon Nov 18 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-4
- Replace push with cd for Posix SH
- Use XDG_CONFIG_HOME for Unix socket directory
- Fix deprecated APIs
- Fix restart crash with inotify read()
- Fix Bug 1658187 exit `ibus emoji` with Escape key
- Add fr(bepo_afnor) keymap
- Add file list in registry file for Silverblue

* Fri Oct 04 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-3
- Fix to allocate compose output buffer with more than two chars

* Fri Sep 13 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-2
- Fix #1751940 - CVE-2019-14822 GDBusServer peer authorization

* Fri Aug 23 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.21-1
- Bump to 1.5.21

* Mon Aug 19 2019 Miro Hrončok <mhroncok@redhat.com> - 1.5.20-11
- Rebuilt for Python 3.8

* Tue Aug 13 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-10
- Update ibus-desktop-testing-runner not to fail CI.

* Tue Aug 06 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-9
- ibus-daemon always will exits with parent's death.

* Wed Jul 31 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-8
- Fix a wrong result in direct testing instead of GNOME desktop testing

* Mon Jul 29 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-7
- Add CI

* Fri Jul 26 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-6
- Update ibus-HEAD.patch from upstream
  Integrate a new compose feature
  Generate ibus-tests and ibus-desktop-testing sub packages

* Thu Jul 25 2019 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.20-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Mon May 13 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-4
- Keep preedit cursor_pos and visible in clearing preedit text for Hangul

* Tue Apr 23 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-3
- Fix i18n ibus-setup
- Provide ibus.its

* Tue Apr 16 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-2
- Rebuilt for unicode-ucd- 12.0.0

* Thu Feb 28 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.20-1
- Bumped to 1.5.20

* Thu Feb 28 2019 Pete Walter <pwalter@fedoraproject.org> - 1.5.19-18
- Update wayland deps

* Fri Feb 22 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-17
- Delete dconf dependencies and gettext migration for gschema.xml file
- Delete Super-space notification in initial login in non-GNOME desktops

* Tue Feb 05 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-16
- Resolves: #1671286 wrong mutex

* Mon Feb 04 2019 Kalev Lember <klember@redhat.com> - 1.5.19-15
- Update BRs for vala packaging changes
- Co-own vala and gir directories

* Fri Feb 01 2019 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.19-14
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Tue Jan 29 2019 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-13
- Resolves: #1470673 Replace assert with warning for .XCompose
- Update APIs for Hangul preedit in Flatpak
- Fix Atom and Slack for Flatpak
- Resolves: #1663528 Check if the mutex is not unlocked before the clear

* Thu Dec 20 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-12
- Use ISO 639-3 names instead of 639
- Connect to button-press-event only with IBUS_ENGINE_PREEDIT_COMMIT

* Wed Dec 12 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-11
- Fix SEGV on mouse clicks when ibus-daemon not running

* Mon Dec 10 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-10
- Always reset and clear preedit on mouse click
- Show compose preedit with custom compose file
- Clear preedit in IBusEngineSimple with focus changes
- Obsolete ibus-xkbc since Fedora 30

* Thu Nov 15 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-9
- Detect mouse click to commit Hangul preedit
- Do not delete IBUS_CAP_SURROUNDING_TEXT

* Tue Nov 06 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-8
- Reverted noarch for devel-docs by mistake

* Wed Oct 31 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-7
- RHEL code reviews

* Fri Oct 26 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-6
- dbus-x11 is not required in Fedora 30
- Add Conflicts for Fedora 28

* Tue Oct 23 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-5
- Use __python3 instead of python3
- Delete Requires ibus in ibus-gtk* for Flatpak

* Fri Sep 14 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-4
- Fix Bug SEGV Choose an emoji by mouse from the emoji category list

* Thu Aug 30 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-3
- Fix Bug 1618682 - SEGV with ASCII on emojier in Wayland
- Support Shift-Space on emojier preedit
- Do not move Emojier popup with the active candidate in Xorg

* Wed Aug 22 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-2
- Do not clear Unicode data when emoji annotation lang is changed

* Wed Aug 08 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.19-1
- Bumped to 1.5.19

* Mon Aug 06 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-14
- Fixed Man page scan results for ibus
- Added IBUS_DISCARD_PASSWORD env variable for password dialog in firefox
- Added history annotation for previous emojis

* Tue Jul 24 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-13
- Deleted deprecated g_mem_* APIs

* Mon Jul 23 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-12
- Rebuilt with RHEL code reviews

* Fri Jul 13 2018 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.18-11
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Mon Jul 02 2018 Miro Hrončok <mhroncok@redhat.com> - 1.5.18-10
- Rebuilt for Python 3.7

* Fri Jun 29 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-9
- Do not use combined characters on preedit for compose keys
- Fixed an infinite loop of extension preedit with xterm

* Wed Jun 27 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-8
- Enable preedit for compose keys
- Fix SEGV in panel_binding_parse_accelerator

* Wed Jun 20 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-7
- Moved input focus on Emojier to engines' preedit
- Removed ibus-xx-emoji-harfbuzz.patch not to change session emoji font

* Tue Jun 19 2018 Miro Hrončok <mhroncok@redhat.com> - 1.5.18-6
- Rebuilt for Python 3.7

* Mon May 07 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-5
- Disabled python2 since RHEL8
- Run make check in %%check except for GUI testings
- Fixed Bug 1574855 - [abrt] ibus: ibus_engine_filter_key_event()

* Fri Mar 30 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-4
- Fixed Bug 1554714 - improve order of unicode matches

* Thu Mar 15 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-3
- Fixed Bug 1554813 - Enter key on numpad in Emojier

* Fri Mar 09 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-2
- Rebuilt for cldr-emoji-annotation-32.90.0_1 and unicode-emoji-10.90.20180207

* Fri Mar 02 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.18-1
- Bumped to 1.5.18

* Wed Feb 28 2018 Iryna Shcherbina <ishcherb@redhat.com> - 1.5.17-11
- Update Python 2 dependency declarations to new packaging standards
  (See https://fedoraproject.org/wiki/FinalizingFedoraSwitchtoPython3)

* Tue Feb 27 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.17-10
- Disabled panel extension for gdm user
- Enabled panel extension in Wayland

* Wed Feb 21 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.17-9
- Added panel extension for emoji keybinding not to depen on desktops
- Showed Unicode code points on Unicode name list

* Tue Feb 13 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 1.5.17-8
- Remove useless requires

* Tue Feb 06 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.17-7
- Added Unicode typing on Emojier

* Sat Feb 03 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 1.5.17-6
- Switch to %%ldconfig_scriptlets

* Fri Jan 19 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.17-5
- Rebuilt for scriptlets

* Wed Jan 17 2018 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.17-4
- Added DBus filtering

* Sat Jan 06 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 1.5.17-3
- Remove obsolete scriptlets

* Fri Jan 05 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 1.5.17-2
- Remove obsolete scriptlets

* Sun Oct 22 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.17-1
- Bumped to 1.5.17

* Thu Sep 21 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-11
- Copy ibusimcontext.c
- Fix Super-space in Plasma after ibus exit

* Wed Sep 20 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-10
- Fix Bug 1490733 Emojier takes wrong fonts

* Thu Sep 14 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-9
- Fix scaling factor, mouse events on switcher, c-s-u on im-ibus, 
  propertypanel position and menu 
- Add ibus-portal
- Move ibus-emoji-dialog.vapi in the build
- Fixed some SEGVs #1406699 #1432252

* Wed Aug 02 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.16-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Binutils_Mass_Rebuild

* Mon Jul 31 2017 Florian Weimer <fweimer@redhat.com> - 1.5.16-7
- Rebuild with binutils fix for ppc64le (#1475636)

* Thu Jul 27 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-6
- Fixed some SEGVs #1349148 #1385349 #1350291 #1368593
  Added 1385349-segv-bus-proxy.patch

* Wed Jul 26 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.16-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_27_Mass_Rebuild

* Fri Jul 21 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-4
- Fixed Bug 1471079 - SEGV of Emojier on de locale

* Thu Jul 13 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-3
- Enabled HarfBuzz rendering without Pango glyph calc for emoji

* Mon May 29 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-2
- Added ctrl-c,v,x for annotations and ctrl-shift-c for emoji
- Added Malay and Mongolian keymaps
- Made all emoji dicts to fully qualified

* Mon May 15 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.16-1
- Bumped to 1.5.16

* Tue May 09 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-8
- Dropped nodejs-emojione-json and import unicode-emoji instead
- Created emoji tab in ibus-setup
- Set default emoji font size from gsettings in ibus emoji command
- Added an option of emoji partial match in ibus-setup
- Hid emoji variants by default
- Added ibus-emoji man page
- emoji favorites category is updated by selecting emoji

* Thu Apr 13 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-7
- Supported ibus emoji command on Wayland
- Changed modal dialog to modeless dialog

* Wed Apr 05 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-6
- Enabled unicode_alt in EmojiOne json file
- Enabled to type multiple code points on Emojier
- Fixed IBusEmojiDialog_1_0_gir_LIBS for --as-needed LDFLAGS

* Mon Mar 27 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-5
- Moved language setting on IBusEmojier to ibus-setup.
- Enabled strcasecmp to match emoji annotations.
- Added a build error message if emoji xml files are not found.

* Wed Mar 15 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-4
- Implemented Ctrl-[f|b|n|p|h|e|a|u] for cursor operations on emoji dialog
- Added XSetIOErrorHandler() for GNOME3 desktop

* Mon Mar 13 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-3
- Emoji dialog enhancements and bug fixes
  Fixed ibus_emoji_dict_load() API.
  Focus on emoji text entry by default
  Removed internal text buffer and use Gtk.Entry buffer instead.
  Implemented cursor left, right, home, end on emoji annotation preedit.
  Show localized emoji description from tts in emoji xml.

* Thu Mar 09 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-2
- Added ibus-HEAD.patch to get upstream patches
  Fixed ibus_emojier_run() SIGABRT with `ibus emoji`
  Enhanced theme color on emoji candidates

* Mon Mar 06 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.15-1
- Bumped to 1.5.15

* Fri Feb 10 2017 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.14-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_26_Mass_Rebuild

* Wed Jan 11 2017 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.14-5
- support scroll event in candidates panel
- Fixed Bug 1403985 - Emoji typing is enabled during Unicode typing
- Fixed Bug 1402494 - Font settings of ibus are ignored on non-Gnome

* Mon Dec 19 2016 Miro Hrončok <mhroncok@redhat.com> - 1.5.14-4
- Rebuild for Python 3.6

* Thu Oct 06 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.14-3
- Fixed Bug 1380675 - Emoji leaves the candidates of @laugh when @laughing
- Fixed Bug 1380690 - User is not able to select emojis from digit keys
- Fixed Bug 1380691 - PageUp PageDown buttons on emoji lookup not working

* Fri Sep 09 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.14-2
- Fixed radio button on PropertyPanel.
- Updated translations.

* Fri Aug 05 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.14-1
- Bump to 1.5.14

* Wed Jul 27 2016 Dan Horák <dan[at]danny.cz> - 1.5.13-6
- enable Emoji only on arches providing nodejs functionality

* Tue Jul 26 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.13-5
- Bug 1359753 - Implement Emoji typing

* Tue Jul 19 2016 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.13-4
- https://fedoraproject.org/wiki/Changes/Automatic_Provides_for_Python_RPM_Packages

* Mon Jun 27 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.13-3
- Bug 1349732 - ibus not working at all in Gnome Wayland
- Add ibus service file
- Fix CSS color format and font size

* Mon Mar 28 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.13-2
- Bug 1319215 - Add Requires besides Requires(post)

* Mon Feb 22 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.13-1
- Bumped to 1.5.13

* Thu Feb 04 2016 Fedora Release Engineering <releng@fedoraproject.org> - 1.5.12-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_24_Mass_Rebuild

* Wed Jan 20 2016 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.12-1
- Bumped to 1.5.12

* Tue Nov 10 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.11-2
- Rebuilt for https://fedoraproject.org/wiki/Changes/python3.5

* Thu Jul 16 2015 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.11-1
- Bumped to 1.5.11
- Deleted with_python2_override_pkg macro
- Added glib2-doc BR

* Wed Jun 17 2015 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.10-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_23_Mass_Rebuild

* Fri May 22 2015 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.10-5
- Updated ibus-HEAD.patch
  Fixed Bug 1224025 - IBus radio menu items does not work

* Fri Apr 24 2015 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.10-4
- Bug 1217410 Updated ibus-xinput for KDE5.

* Fri Apr 24 2015 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.10-3
- Updated ibus-HEAD.patch from upstream
  Fixed to show shortcuts on ibus-setup.
  Bug 1214271 Fixed to enable IME with GTK3 applications in wayland.

* Thu Apr 02 2015 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.10-2
- Updated ibus-HEAD.patch from upstream
  Added Swedish svdvorak
  I18N engine longnames and descriptions on ibus-setup
  Moved PropertyPanel at bottom right in KDE5
  Drew gray color on Handle PropertyPanel
  Enabled ibus engine full path icon in KDE5
  Updated translations

* Wed Feb 25 2015 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.10-1
- Bumped to 1.5.10

* Sat Feb 21 2015 Till Maas <opensource@till.name> - 1.5.9-11
- Rebuilt for Fedora 23 Change
  https://fedoraproject.org/wiki/Changes/Harden_all_packages_with_position-independent_code

* Mon Feb 02 2015 Petr Viktorin <pviktori@redhat.com> - 1.5.9-10
- Remove dependency on Python 2 from main package

* Mon Feb 02 2015 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-9
- Updated ibus-HEAD.patch to fix #1187956 IBusRegistry segv.

* Thu Dec 18 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-8
- Updated ibus-HEAD.patch to fix #1175595 ibus-x11 freeze

* Mon Dec 08 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-7
- Added ibus-1136623-lost-by-another-focus.patch to fix #1136623

* Mon Dec 08 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-6
- Updated ibus-xx-increase-timeout.patch to fix #1163722
- Updated ibus-HEAD.patch for upstream #1747, #1748, #1753
  and gnome #703020, gnome #730628

* Wed Nov 12 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-5
- rhbz#1161871 Added BR of python and python3

* Tue Oct 28 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-4
- Updated ibus-HEAD.patch for upstream #1744.

* Fri Oct 24 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-3
- Added ibus-xx-increase-timeout.patch

* Wed Oct 01 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-2
- Updated ibus-HEAD.patch for rhbz#1136623.
- Added ibus-po-1.5.9-20141001.tar.gz

* Tue Sep 16 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.9-1
- Bumped to 1.5.9

* Sat Aug 16 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.8-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_22_Mass_Rebuild

* Thu Jul 24 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.8-1
- Bumped to 1.5.8
- Deleted ibus-810211-no-switch-by-no-trigger.patch
- Deleted ibus-541492-xkb.patch
- Deleted ibus-530711-preload-sys.patch
- Deleted ibus-xx-setup-frequent-lang.patch
- Deleted ibus-xx-f19-password.patch

* Tue Jul 22 2014 Kalev Lember <kalevlember@gmail.com> - 1.5.7-7
- Rebuilt for gobject-introspection 1.41.4

* Mon Jul 14 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.7-6
- Updated ibus-HEAD.patch from upstream.
  Fixed ibus-setup SEGV when an engine is selected.
  Fixed ibus-setup deprecated warnings with the latest python3-gobject.
  Integrated the 'IBUS_SETUP_XID' environment variable for each engine setup.
  Set prgname 'ibus-setup' for ibus-setup.

* Mon Jul 07 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.7-5
- Updated ibus-HEAD.patch from upstream.
  Added pl(qwertz).
  Fixed escape key with Ctrl-Shift-U.
  Updated pt-br compose table from the latest xorg.
  Do not sort ibus engines when they are saved by ibus-setup.
  Updated jp IBusKeymap.
  Added ibus reset-config and read-config sub-commands.
  Update ibus(1) for read-config and reset-config.

* Sat Jun 07 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.5.7-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Tue May 27 2014 Kalev Lember <kalevlember@gmail.com> - 1.5.7-3
- Rebuilt for https://fedoraproject.org/wiki/Changes/Python_3.4

* Tue May 20 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.7-2
- Updated ibus-HEAD.patch for width of ibus-setup.

* Wed Apr 30 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.7-1
- Bumped to 1.5.7

* Mon Apr 21 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.6-3
- Do not require gtk-doc in ibus-devel-docs

* Fri Mar 28 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.6-2
- Updated ibus-HEAD.patch for Czech (qwerty) keymap.

* Thu Mar 06 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.6-1
- Bumped to 1.5.6
- Deleted ibus-xx-ctrl-space.patch

* Fri Jan 31 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.5-2
- Enabled python3 ibus-setup

* Tue Jan 14 2014 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.5-1
- Bumped to 1.5.5
- Deleted notify-python in Requires

* Fri Oct 04 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.4-2
- Added ibus-HEAD.patch to sync upstream.

* Fri Sep 20 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.4-1
- Bumped to 1.5.4
- Added ibus.conf.5
- Added ibus-xkb-1.5.0.tar.gz for po files.
- Added ibus-xx-f19-password.patch for back compatibility.
- Added ibus-wayland in f20 or later.

* Fri Jul 26 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.3-1
- Bumped to 1.5.3
- Deleted ibus-xx-g-s-disable-preedit.patch as EOL.
- Deleted ibus-gjs as EOL.
- Removed imsettings-gnome, im-chooser, libgnomekbd dependencies.

* Thu Jul 11 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-8
- Updated ibus-HEAD.patch to delete pyxdg dependencies.

* Mon Jun 17 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-7
- Bug 972328 - Deleted ibus-panel

* Mon Jun 17 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-6
- Bug 972328 - Bring back the dependency of ibus-setup.

* Tue Jun 11 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-5
- Removed dependencies of ibus-setup and ibus-pygtk2

* Wed Jun 05 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-4
- Updated ibus-HEAD.patch for upstream.
- Added ibus-xx-1.5.2.patch until 1.5.3 will be released.
- Added ibus-xx-ctrl-space.patch for back compatible triggers.

* Wed May 01 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-3
- Updated ibus-HEAD.patch for upstream.
- Deleted ibus-947318-reconnect-gtk-client.patch

* Sun Apr 21 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-2
- Separate python files in f19 or later.

* Thu Apr 18 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.2-1
- Bumped to 1.5.2
- Created noarch packages for python files due to .pyc and .pyo.
- Added man pages.

* Mon Feb 18 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.1-3
- Copied gtk2 module to gtk3 one.

* Thu Jan 31 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.1-2
- Updated ibus-530711-preload-sys.patch. Fixes #904799

* Tue Jan 08 2013 Takao Fujiwara <tfujiwar@redhat.com> - 1.5.1-1
- Bumped to 1.5.1
- Bumped to ibus-gjs 3.4.1.20130115 for f17
- Removed ibus-xx-no-use.diff

* Fri Dec 14 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-9
- Updated ibus-xx-no-use.diff not to use variant.dup_strv()

* Fri Dec 07 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-8
- Resolves #869584 - Removed libgnomekbd dependency in f18.

* Fri Nov 30 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-7
- Set time stamp of ibus/_config.py

* Fri Nov 30 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-6
- Set time stamp of ibus/_config.py

* Fri Nov 30 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-5
- Updated spec file to work witout pkgconfig.

* Tue Nov 27 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-4
- Added comment lines for patches.

* Tue Nov 27 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-3
- Fixed misc issues.

* Thu Oct 11 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-2
- Obsoleted ibus-gnome3

* Thu Oct 11 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121109-1
- Bumped to 1.4.99.20121109
- Removed im-chooser, imsettings-gnome, gnome-icon-theme-symbolic
  dependencies in f18 because ibus gnome integration is done.
  Use ibus-keyboard instead of input-keyboard-symbolic.
- Disabled ibus-gjs build because of ibus gnome integration.

* Thu Oct 11 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121006-2
- Updated ibus-HEAD.patch to fix typo in data/dconf/profile/ibus

* Thu Oct 11 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121006-2
- Updated ibus-HEAD.patch to fix typo in data/dconf/profile/ibus

* Sat Oct 06 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20121006-1
- Bumped to 1.4.99.20121006
- Removed ibus-xx-segv-reg-prop.patch

* Fri Sep 14 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120914-2
- Added ibus-xx-segv-reg-prop.patch to avoid segv

* Fri Sep 14 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120914-1
- Bumped to 1.4.99.20120914

* Thu Sep 06 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120822-2
- Updated ibus-530711-preload-sys.patch
- Updated ibus-541492-xkb.patch
- Updated ibus-xx-no-use.diff
  Fixed Bug 854161 - not able to add keymap with ibus-setup

* Wed Aug 22 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120822-1
- Bumped to 1.4.99.20120822
- Bumped to ibus-gjs 3.4.1.20120815
  Fixed Bug 845956 - ibus backward trigger key is not customized
  Fixed Bug 844580 - ibus-dconf does not load the system gvdb
- Separated ibus-810211-no-switch-by-no-trigger.patch from ibus-HEAD.patch

* Fri Jul 27 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.99.20120712-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Thu Jul 19 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120712-2
- Updated ibus-HEAD.patch
  Support dconf 0.13.4

* Tue Jul 17 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120712-1
- Bumped to 1.4.99.20120712
- Removed ibus-xx-branding-switcher-ui.patch as upstreamed.

* Fri Jun  8 2012 Matthias Clasen <mclasen@redhat.com> - 1.4.99.20120428-3
- Rebuild against new libgnomekbd

* Fri Apr 27 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120428-2
- Updated ibus-HEAD.patch
- Updated ibus-541492-xkb.patch
- Updated ibus-xx-branding-switcher-ui.patch
  Fixed Bug 810211 - Cancel Control + space pressing Control key.
- Updated ibus-xx-no-use.diff
  Enabled to customize trigger keys with non-modifier trigger keys.

* Fri Apr 27 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120428-1
- Bumped to 1.4.99.20120428
  Fixed Bug 799571 - no IME list at the session login.
  Fixed Bug 810415 - ibus does not handle Ctrl+space with BUTTON_PRESS.
- Bumped to ibus-gjs 3.4.1.20120428
  Fixed Bug 802052 - no modifiers trigger keys.
  Fixed Bug 803244 - IME switch Ctrl+space not working on shell text entry.

* Tue Apr 24 2012 Kalev Lember <kalevlember@gmail.com> - 1.4.99.20120317-4
- Update the dconf and icon cache rpm scriptlets

* Wed Apr 18 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120317-3
- Added a RHEL flag.

* Tue Mar 27 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120317-2
- Bumped to ibus-gjs 3.3.92.20120327
  
* Sat Mar 17 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120317-1
- Bumped to 1.4.99.20120317
  Fixed Bug 718668 - focus move is slow with ibus-gnome3
  Fixed Bug 749497 - Enhance IME descriptions in status icon active menu
- Bumped to ibus-gjs 3.3.90.20120317
- Added ibus-xx-no-use.diff
  Fixed Bug 803260 - Disable non-global input method mode
- Updated ibus-HEAD.patch
  Fixed Bug 803250 - ibus lookup window font customization
  Fixed Bug 803177 - language id on ibus-ui-gtk3 switcher
- Update ibus-530711-preload-sys.patch
  Fixed Bug 797023 - port preload engines

* Thu Mar 08 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120303-3
- Bumped to ibus-gjs 3.3.90.20120308 to work with gnome-shell 3.3.90
- Fixed Bug 786906 - Added ifnarch ppc ppc64 s390 s390x
- Updated ibus-HEAD.patch
  Fixed Bug 800897 - After doing "ctrl+space", ibus tray icon freezes

* Mon Mar 05 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120303-2
- Added ibus-HEAD.patch to fix python library to load libibus.so.

* Sun Mar 04 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120303-1
- Bumped to 1.4.99.20120303
  Fixed Bug 796070 - ibus-setup without no ibus-daemon

* Wed Feb 08 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120203-3
- Fixed ibus-setup on C locale
- Fixed to show no registered engines from g-c-c.
- Enabled Alt_R keybinding on ko locales for ibus gtk only.

* Fri Feb 03 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.99.20120203-1
- Updated to 1.4.99.20120203
- Removed ibus-xx-bridge-hotkey.patch
- Updated ibus-541492-xkb.patch to use libgnomekbd.
- Updated ibus-xx-setup-frequent-lang.patch for 1.4.99.20120203

* Wed Jan 04 2012 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-17
- Added ibus-771115-property-compatible.patch for f16
  Fixed Bug 771115 - IBusProperty back compatibility.

* Fri Dec 30 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-16
- Enhanced ibus-gnome3 shell lookup window.
- Updated ibus-HEAD.patch from upstream
  Fixed Bug 769135 - ibus-x11 SEGV in _process_key_event_done.
- Updated ibus-541492-xkb.patch
  Fixed Bug 757889 - ibus-setup SEGV without active engine.
  Fixed Bug 760213 - ibus-setup saves XKB variants correctly.
  Fixed Bug 769133 - ibus-engine-xkb returns FALSE for ASCII typings.
- Updated ibus-xx-bridge-hotkey.patch for an enhancement.

* Wed Nov 30 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-14
- Enabled dconf.
- Updated ibus-HEAD.patch
  Fixed Bug 618229 - engine setup buton on ibus-setup.
- Removed ibus-711632-fedora-fallback-icon.patch as upstreamed.
- Updated ibus-xx-bridge-hotkey.patch
  Removed Enable/Disable buttons on ibus-setup

* Fri Nov 18 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-11
- Updated ibus-541492-xkb.patch
  Fixed Bug 750484 - support reloading Xmodmap
- Updated ibus-HEAD.patch
  Fixed Bug 753781 - ibus-x11 needs async for hangul ibus_commit_text.

* Fri Nov 04 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-10
- Updated ibus-xx-bridge-hotkey.patch for f16
  Fixed no XKB languages from layout only. e.g. in(eng).
- Updated ibus-541492-xkb.patch
  Fixed not to show 'eng' on GUI for in(eng).

* Wed Nov 02 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-9
- Updated ibus-HEAD.patch
  Fixed prev/next keys without global engine.
- Updated ibus-xx-bridge-hotkey.patch for f16
  Fixed Bug 747902 - mouse and ctrl+space not working
  Fixed Bug 749770 - IME hotkey after Control + Space
- Updated ibus-711632-fedora-fallback-icon.patch
  Fixed Bug 717831 - use old icon for desktops other than gnome

* Fri Oct 28 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-8
- Updated ibus-xx-bridge-hotkey.patch for f16
- Fixed Bug 747902 - mouse and ctrl+space not working

* Wed Oct 26 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.4.0-6
- Rebuilt for glibc bug#747377

* Fri Oct 21 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-5
- Fixed Bug 747845 - ibus icon cannot open menu item on gnome-shell

* Thu Oct 20 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-4
- Fixed Bug 746869 - no keymaps if the XKB has no group and no variant

* Fri Sep 30 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-3
- Rebuilt for f16 gnome-shell 3.2 and gjs 1.30

* Wed Sep 28 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.4.0-2
- Updated to 1.4.0
- Updated ibus-gjs 3.0.2.20110928 for f15.
- Updated ibus-gjs 3.2.0.20110928 for f16. (#740588)
- Updated ibus-530711-preload-sys.patch
  Fixed not to show duplicated engine names in setup treeview (#740447)
- Updated bus-gjs-xx-gnome-shell-3.1.4-build-failure.patch for f16.
- Updated ibus-xx-bridge-hotkey.patch
  Fixed a XKB configuration without the input focus for f16 (#739165)
  Fixed not to show null strings in case of no variants (#738130)

* Tue Sep 13 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110817-5
- Updated ibus-gjs 3.1.91.20110913 for f16.

* Thu Sep 08 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110817-4
- Updated ibus-gjs 3.1.91.20110908 and 3.0.2.20110908 for gnome-shell.
  Fixed preedit active segments on gnome-shell and X11 apps.
- Added ibus-xx-g-s-disable-preedit.patch
  Disabled preedit on gnome-shell for a workaround.
- Updated ibus.spec
  Fixed Bug 735879 pre/postun scripts

* Thu Sep 01 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110817-3
- Fixed Bug 700472 Use a symbol icon instead of an image icon.
- Updated ibus-HEAD.patch for upstream.
- Removed ibus-435880-surrounding-text.patch as upstream.
- Added ibus-711632-fedora-fallback-icon.patch
  Fixed SEGV with no icon in oxygen-gtk icon theme.
- Added ibus-xx-bridge-hotkey.patch
  Triaged Bug 707370 SetEngine timeout
  Fixed Bug 731610 Keep IM state when text input focus changes
- Added transitional ibus-gnome3 package.
  Fixed Bug 718110 Use a shell icon instead of pygtk2 icon.

* Thu May 26 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110419-1
- Updated to 1.3.99.20110419
- Added ibus-HEAD.patch
  Fixed Bug 697471 - ibus-gconf zombie when restart ibus from ibus panel.
- Updated ibus-541492-xkb.patch
  Fixed Bug 701202 - us(dvorak) does not show up in list
  Updated ibus-1.0.pc for ibus-xkb
  Showed XKB variant descriptions only without layout descriptions.
- Updated ibus-xx-setup-frequent-lang.patch
  Updated UI strings

* Tue Apr 19 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110408-1
- Updated to 1.3.99.20110408
  Fixed Bug 683484 - Timed out SetEngine when select an engine from panel.
  Fixed Bug 657165 - IBus for gnome-shell for Fedora 15.
- Upstreamed ibus-657165-panel-libs.patch
- Removed ibus-675503-gnome-shell-workaround.patch
- Added ibus-xx-setup-frequent-lang.patch
- Updated ibus-541492-xkb.patch
  Fixed Bug 696481 - no the variant maps without language codes
- Added dependency of imsettings-gnome.
  Fixed Bug 696510 - need a dependency in ibus-gtk3 for imsettings-gnome

* Thu Mar 10 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110228-1
- Updated to 1.3.99.20110228
- Integrated the part of gjs in Bug 657165 ibus for gnome-shell.
  Added ibus-657165-panel-libs.patch
  Added gnome-shell-ibus-plugins-20110304.tar.bz2
- Fixed Bug 675503 - a regression in sync mode
  Added ibus-675503-gnome-shell-workaround.patch until gnome-shell is updated.
- Fixed Bug 677856 - left ibus snooper when im client is switched.
- Fixed Bug 673047 - abrt ibus_xkb_get_current_layout for non-XKB system
  Updated ibus-541492-xkb.patch

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.3.99.20110127-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Fri Feb 04 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110127-1
- Updated to 1.3.99.20110127
- Updated ibus-HEAD.patch from upstream.

* Wed Jan 26 2011 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20110117-1
- Updated to 1.3.99.20110117
- Fixed Bug 666427 - ibus requires dbus-x11
- Fixed Bug 670137 - QT_IM_MODULE=xim in ibus.conf without ibus-qt

* Thu Dec 09 2010 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20101202-1
- Updated to 1.3.99.20101202
- Added ibus-530711-preload-sys.patch
  Fixed Bug 530711 - Reload preloaded engines by login

* Fri Oct 29 2010 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.99.20101028-1
- Updated to 1.3.99.20101028
- Integrated gdbus
- Merged notify.patch into ibus-HEAD.patch

* Fri Oct 22 2010 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.8-1
- Updated to 1.3.8
- Added ibus-541492-xkb.patch
  Fixes Bug 541492 - ibus needs to support some xkb layout switching
- Added ibus-435880-surrounding-text.patch
  Fixes Bug 435880 - ibus-gtk requires surrounding-text support
- Added ibus-xx-workaround-gtk3.patch
  Workaround for f14 http://koji.fedoraproject.org/koji/taskinfo?taskID=2516604

* Mon Aug 23 2010 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.7-1
- Updated to 1.3.7

* Wed Jul 28 2010 Mamoru Tasaka <mtasaka@ioa.s.u-tokyo.ac.jp> - 1.3.6-5
- Rebuild against python 2.7

* Thu Jul 22 2010 Jens Petersen <petersen@redhat.com> - 1.3.6-4
- keep bumping ibus-gtk obsoletes to avoid upgrade problems

* Wed Jul 21 2010 David Malcolm <dmalcolm@redhat.com> - 1.3.6-3
- Rebuilt for https://fedoraproject.org/wiki/Features/Python_2.7/MassRebuild

* Thu Jul 15 2010 Colin Walters <walters@verbum.org> - 1.3.6-2
- Rebuild with new gobject-introspection

* Tue Jul 06 2010 Takao Fujiwara <tfujiwar@redhat.com> - 1.3.6-1
- Update to 1.3.6

* Wed Jun 30 2010 Jens Petersen <petersen@redhat.com>
- version the ibus-gtk obsolete and provides
- drop the old redundant ibus-qt obsoletes

* Mon Jun 28 2010 Matthias Clasen <mclasen@redhat.com> - 1.3.5-3
- Rebuild against newer gtk

* Tue Jun 22 2010 Colin Walters <walters@verbum.org> - 1.3.5-2
- Bump Release to keep ahead of F-13

* Sat Jun 12 2010 Peng Huang <phuang@redhat.com> - 1.3.5-1
- Update to 1.3.5
- Support gtk3, gobject-introspection and vala.

* Sat May 29 2010 Peng Huang <phuang@redhat.com> - 1.3.4-2
- Update to 1.3.4

* Sat May 29 2010 Peng Huang <phuang@redhat.com> - 1.3.4-1
- Update to 1.3.4

* Tue May 04 2010 Peng Huang <phuang@redhat.com> - 1.3.3-1
- Update to 1.3.3

* Sun May 02 2010 Peng Huang <phuang@redhat.com> - 1.3.2-3
- Embedded language bar in menu by default.
- Fix bug 587353 - [abrt] crash in ibus-1.3.2-2.fc12

* Sat Apr 24 2010 Peng Huang <phuang@redhat.com> - 1.3.2-2
- Add requires librsvg2
- Update ibus-HEAD.patch: Update po files and and setting 

* Wed Apr 21 2010 Peng Huang <phuang@redhat.com> - 1.3.2-1
- Update to 1.3.2
- Fix bug 583446 - [abrt] crash in ibus-1.3.1-1.fc12

* Mon Apr 05 2010 Peng Huang <phuang@redhat.com> - 1.3.1-1
- Update to 1.3.1

* Fri Mar 26 2010 Peng Huang <phuang@redhat.com> - 1.3.0-3
- Update ibus-HEAD.patch
- Fix bug - some time panel does not show candidates.
- Update some po files

* Mon Mar 22 2010 Peng Huang <phuang@redhat.com> - 1.3.0-2
- Does not check glib micro version in ibus im module.

* Mon Mar 22 2010 Peng Huang <phuang@redhat.com> - 1.3.0-1
- Update to 1.3.0

* Tue Feb 02 2010 Peng Huang <phuang@redhat.com> - 1.2.99.20100202-1
- Update to 1.2.99.20100202

* Mon Jan 11 2010 Peng Huang <phuang@redhat.com> - 1.2.0.20100111-1
- Update to 1.2.0.20100111

* Fri Dec 25 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20091225-1
- Update to 1.2.0.20091225
- Fix bug 513895 - new IME does not show up in ibus-setup
- Fix bug 531857 - applet order should correspond with preferences order
- Fix bug 532856 - should not list already added input-methods in Add selector

* Tue Dec 15 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20091215-1
- Update to 1.2.0.20091215

* Thu Dec 10 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20091204-2
- Fix rpmlint warnings and errors.

* Fri Dec 04 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20091204-1
- Update to 1.2.0.20091204
- Fix Bug 529920 - language panel pops up on the wrong monitor
- Fix Bug 541197 - Ibus crash

* Tue Nov 24 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20091124-1
- Update to 1.2.0.20091124
- Update some translations.
- Fix bug 538147 - [abrt] crash detected in firefox-3.5.5-1.fc12 

* Sat Oct 24 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20091024-1
- Update to 1.2.0.20091024

* Wed Oct 14 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20091014-2
- Update to 1.2.0.20091014
- Change ICON in ibus.conf 

* Sun Sep 27 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090927-1
- Update to 1.2.0.20090927

* Tue Sep 15 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090915-1
- Update to 1.2.0.20090915
- Fix bug 521591 - check if the icon filename is a real file before trying to open it
- Fix bug 522310 - Memory leak on show/hide
- Fix bug 509518 - ibus-anthy should only override to jp layout for kana input

* Fri Sep 04 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090904-2
- Refresh the tarball.

* Fri Sep 04 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090904-1
- Update to 1.2.0.20090904

* Mon Aug 31 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090828-2
- Change icon path in ibus.conf

* Fri Aug 28 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090828-1
- Update to 1.2.0.20090828
- Change the icon on systray.
- Fix segment fault in ibus_hotkey_profile_destroy
- Fix some memory leaks.

* Wed Aug 12 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090812-1
- Update to 1.2.0.20090812

* Mon Aug 10 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090807-4
- Update ibus-HEAD.patch
- Fix Numlock problem.
- Fix some memory leaks.

* Fri Aug 07 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090807-2
- Update ibus-HEAD.patch
- Fix bug 516154.

* Fri Aug 07 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090807-1
- Update to 1.2.0.20090807

* Thu Aug 06 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090806-1
- Update to 1.2.0.20090806
- Fix bug 515106 - don't install duplicate files

* Tue Jul 28 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090723-3
- Update xinput-ibus: setup QT_IM_MODULE if the ibus qt input method plugin exists. 

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.2.0.20090723-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Thu Jul 23 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090723-1
- Update to 1.2.0.20090723
- Fix dead loop in ibus-gconf

* Wed Jul 22 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090722-1
- Update to 1.2.0.20090722

* Sun Jul 19 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090719-1
- Update to 1.2.0.20090719

* Mon Jun 22 2009 Peng Huang <phuang@redhat.com> - 1.2.0.20090617-1
- Update to 1.2.0.20090617

* Fri Jun 12 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090612-1
- Update to 1.1.0.20090612
- Fix bug 504942 - PageUp and PageDown do not work in candidate list
- Fix bug 491040 - Implememnt mouse selection in candidate list

* Wed Jun 10 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090609-1
- Update to Update to 1.1.0.20090609
- Fix bug 502414 - Implemented on-screen help facility
- Fix bug 502561 - iBus should show keymap name on iBus panel
- Fix bug 498043 - ibus Alt-grave trigger conflicts with openoffice.org
- Implemented API for setting labels for candidates in LookupTable

* Sun May 31 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090531-1
- Update to Update to 1.1.0.20090531

* Tue May 26 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090508-5
- Update ibus-HEAD.patch.
- Show the default input method with bold text
- Add information text below input methods list

* Mon May 25 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090508-4
- Update ibus-HEAD.patch.
- Fix bug 501211 - ibus-setup window should be raised if running or just stay on top/grab focus
- Fix bug 501640 - ibus should adds new IMEs at end of engine list not beginning
- Fix bug 501644 - [IBus] focus-out and disabled IME should hide language panel

* Thu May 14 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090508-2
- Remove requires notification-daemon
- Fix bug 500588 - Hardcoded requirement for notification-daemon

* Fri May 08 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090508-1
- Update to 1.1.0.20090508
- Fix bug 499533 - [Indic] ibus should allow input in KDE using all supported Indic locales
- Fix bug 498352 - hotkey config table should list keys in same order as on main setup page
- Fix bug 497707 - ibus French translation update

* Fri May 08 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090423-3
- Fix bug 498541 - ibus-libs should not contain devel file libibus.so

* Tue May 05 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090423-2
- Fix bug 498141 - new ibus install needs gtk immodules
- Separate ibus document from ibus-devel to ibus-devel-docs

* Thu Apr 23 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090423-1
- Update to ibus-1.1.0.20090423.
- Fix bug 497265 - [mai_IN] Maithili language name is not correct.
- Fix bug 497279 - IBus does not works with evolution correctly.
- Enhance authentication both in daemon & clients

* Fri Apr 17 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090417-1
- Update to ibus-1.1.0.20090417.
- Fix bug 496199 -  cannot remove Ctrl+Space hotkey with ibus-setup

* Fri Apr 17 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090413-4
- Update ibus-HEAD.patch.
- Next Engine hotkey will do nothing if the IM is not active.

* Wed Apr 15 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090413-3
- Update ibus-HEAD.patch.
- Fix bug 495431 -  ibus Release modifier doesn't work with Alt
- Fix bug 494445 -  ibus-hangul missing Hangul Han/En mode
  (and Alt_R+release hotkey)
- Update te.po

* Tue Apr 14 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090413-2
- Update ibus-HEAD.patch.
- Change the mode of /tmp/ibus-$USER to 0700 to improve security
- Change the mode of /tmp/ibus-$USER/socket-address to 0600 to improve security
- Update as.po

* Mon Apr 13 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090413-1
- Update to ibus-1.1.0.20090413.
- Fix crash when restart the ibus-daemon
- Add some translations.

* Tue Apr 07 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090407-3
- Update the tarball.
- Fix bug 494511 - ibus-gtk makes gnome-terminal abort 
  when a key is pressed

* Tue Apr 07 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090407-2
- Update default hotkey settings.

* Tue Apr 07 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090407-1
- Update to ibus-1.1.0.20090407.
- Fix bug 491042 - ibus default trigger hotkeys
- Fix bug 492929 - ibus-hangul can cause gtk app to lockup
- Fix bug 493701 -  (ibus) imsettings disconnect/reconnect kills gtk app
- Fix bug 493687 -  ibus-hangul should default to vertical candidate selection
- Fix bug 493449 -  ibus broke Alt-F2 command auto-completion

* Tue Mar 31 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090331-1
- Update to ibus-1.1.0.20090331.
- Fix bug 492956 - screws up keyboard input in firefox
- Fix bug 490143 - ibus issue with gnome-keyring

* Sun Mar 29 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090311-3
- Recreate the ibus-HEAD.patch from upstream git source tree
- Fix bug 491999 - up/down arrow keys broken in xchat

* Sat Mar 28 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090311-2
- Recreate the ibus-HEAD.patch from upstream git source tree.
- Fix bug 490009 - Deleting Next Engine shortcuts doesn't work
- Fix bug 490381 - Change "Next/Previous engine" labels

* Wed Mar 11 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090311-1
- Update to ibus-1.1.0.20090311.
- Update setup ui follow GNOME Human Interface Guidelines 2.2 (#489497).

* Fri Mar  6 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090306-1
- Update to ibus-1.1.0.20090306.

* Tue Mar  3 2009 Jens Petersen <petersen@redhat.com>
- use post for ibus-gtk requires glib2

* Mon Mar  2 2009 Jens Petersen <petersen@redhat.com> - 1.1.0.20090225-2
- drop the superfluous ibus-0.1 engine obsoletes
- move glib2 requires to gtk package

* Wed Feb 25 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090225-1
- Update to ibus-1.1.0.20090225.
- Fix problems in %%post and %%postun scripts.
- Hide ibus & ibus preferences menu items.

* Tue Feb 17 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-10
- Recreate the ibus-HEAD.patch from upstream git source tree.
- Put 'Select an input method' in engine select combobox (#485861).

* Tue Feb 17 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-9
- Add requires im-chooser >= 1.2.5.

* Tue Feb 17 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-8
- Recreate the ibus-HEAD.patch from upstream git source tree.
- Fix ibus-hangul segfault (#485438).

* Mon Feb 16 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-6
- Recreate the ibus-HEAD.patch from upstream git source tree.
- The new patch fixes ibus-x11 segfault (#485661).

* Sun Feb 15 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-5
- Recreate the ibus-HEAD.patch from upstream git source tree.

* Sun Feb 15 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-4
- Remove gnome-python2-gconf from requires.

* Fri Feb 13 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-3
- Update ibus-HEAD.patch, to fix bug 484652.

* Fri Feb 13 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-2
- Add patch ibus-HEAD.patch, to update ibus to HEAD version.

* Wed Feb 11 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090211-1
- Add --xim argument in xinput-ibus
- Add Obsoletes:  ibus-qt <= 1.1.0
- Move libibus.so.* to ibus-libs to make ibus multilib.
- Update to 1.1.0.20090211.

* Thu Feb 05 2009 Peng Huang <phuang@redhat.com> - 1.1.0.20090205-1
- Update to 1.1.0.20090205.

* Tue Feb 03 2009 Peng Huang <phuang@redhat.com> - 0.1.1.20090203-1
- Update to 0.1.1.20090203.

* Sat Nov 29 2008 Ignacio Vazquez-Abrams <ivazqueznet+rpm@gmail.com> - 0.1.1.20081023-3
- Rebuild for Python 2.6

* Wed Nov 19 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20081023-2
- Move libibus-gtk.so from ibus.rpm to ibus-gtk.rpm to fix bug 472146.

* Thu Oct 23 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20081023-1
- Update to 0.1.1.20081023.

* Thu Oct 16 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20081016-1
- Update to 0.1.1.20081016.

* Tue Oct  7 2008 Jens Petersen <petersen@redhat.com> - 0.1.1.20081006-3
- remove the empty %%doc file entries

* Tue Oct  7 2008 Jens Petersen <petersen@redhat.com> - 0.1.1.20081006-2
- add xinputrc alternative when installing or uninstalling

* Mon Oct 06 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20081006-1
- Update to 0.1.1.20081006.

* Sun Oct 05 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20081005-1
- Update to 0.1.1.20081005.

* Sat Oct 04 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20081004-1
- Update to 0.1.1.20081004.

* Wed Oct 01 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20081001-1
- Update to 0.1.1.20081001.

* Tue Sep 30 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080930-1
- Update to 0.1.1.20080930.

* Tue Sep 23 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080923-1
- Update to 0.1.1.20080923.

* Wed Sep 17 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080917-1
- Update to 0.1.1.20080917.

* Tue Sep 16 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080916-1
- Update to 0.1.1.20080916.

* Mon Sep 15 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080914-1
- Update to 0.1.1.20080914.

* Mon Sep 08 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080908-1
- Update to 0.1.1.20080908.

* Mon Sep 01 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080901-1
- Update to 0.1.1.20080901.

* Sat Aug 30 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080830-1
- Update to 0.1.1.20080830.

* Mon Aug 25 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080825-1
- Update to 0.1.1.20080825.

* Sat Aug 23 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080823-1
- Update to 0.1.1.20080823.

* Fri Aug 15 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080815-1
- Update to 0.1.1.20080815.

* Tue Aug 12 2008 Peng Huang <phuang@redhat.com> - 0.1.1.20080812-1
- Update to 0.1.1.20080812.

* Mon Aug 11 2008 Peng Huang <phuang@redhat.com> - 0.1.0.20080810-2
- Add gnome-python2-gconf in Requires.

* Thu Aug 07 2008 Peng Huang <phuang@redhat.com> - 0.1.0.20080810-1
- The first version.
