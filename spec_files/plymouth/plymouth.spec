Summary: Graphical Boot Animation and Logger
Name: plymouth
Version: 24.004.60
Release: 100.bazzite
License: GPL-2.0-or-later
URL: http://www.freedesktop.org/wiki/Software/Plymouth

Source0: %{name}-%{version}.tar.bz2
# Spinner update from: https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/1a01883fa2659bfb5e7417e1d5bd8d287a2cac36
# Drop this on next rebase to latest upstream
Source1: spinner-update.tar.gz
Source2: charge.plymouth

# Bazzite-specific fixes
Patch: bazzite.patch

# Revert https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/48881ba
# to fix console display on minimal installs
# https://bugzilla.redhat.com/show_bug.cgi?id=2269385
# This bug should also be fixed by:
# https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/d2ab367e12423646d3a6bb35d16570f8e3126234
# https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/1e206268df99d28e9fb3d3cf8379a553abb05af0
# Drop this Fedora patch on next rebase to latest upstream
Patch: 0001-Revert-src-Hide-console-text-when-splash-is-requeste.patch

# https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/10ac8d2dc927b112ce6aeb06bc73d9c46550954c
# Fix encryption passphrase appearing in plain text in text mode
# https://bugzilla.redhat.com/show_bug.cgi?id=2271337
Patch: 0001-ply-boot-splash-Set-unbuffered-input-when-creating-a.patch

# Revert patch to immediately switch to text mode on first renderer plugin error
# Fixes unwanted text mode when drm-plugin init races with simpledrm unregistration
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/319 (merged)
# https://bugzilla.redhat.com/show_bug.cgi?id=2270030
Patch: 0001-ply-device-manager-Revert-Fall-back-to-text-plugin-i.patch

# Probe simpledrm immediately instead of waiting for udev_device_get_is_initialized ()
# to return true. This fixes users getting the text splash on laptops with somewhat
# slower CPUs combined with loading the amdgpu module which may take 7+ seconds
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/323/ (merged)
# https://bugzilla.redhat.com/show_bug.cgi?id=2183743
# https://bugzilla.redhat.com/show_bug.cgi?id=2274770
Patch: plymouth-24.004.60-immediately-probe-simpledrm.patch

# Backport of upstream commit 709f21e80199ee51badff2d9b5dc6bae8af2a1a1
# "renderers: Do not assume all keyboards have LEDs"
# This fixes:
# https://bugzilla.redhat.com/show_bug.cgi?id=2282384
Patch: 0001-renderers-Do-not-assume-all-keyboards-have-LEDs.patch

# Fix Dvorak layout icon not showing when the evdev keyboard driver is used
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/341 (merged)
# https://bugzilla.redhat.com/show_bug.cgi?id=2341810
Patch: 0001-ply-keymap-icon-Make-Dvorak-check-case-insensitive.patch
# And a generic fix for missing pre-rendered keyboard-layout texts
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/358
Patch: 0001-ply-keymap-icon-Fix-falling-back-to-label-plugin-whe.patch

# https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/792fe7474a02a1facacdd52e0dcf9053da4b1f6e
# Fix for the label plugin not finding fonts
Patch: 0001-label-freetype-fix-fallback-not-working-when-fc-matc.patch

# 2 tweaks for hidpi scale factor calculations
# https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/acf97c73670b80a65329aaa35e40438d86fca3c6
# https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/3b8e918479f47a845d4f88d281f7dfe412195628
Patch: plymouth-24.004.60-device-scale-fixes.patch

# A set of 5 patches to make use-simpledrm configurable from the config file
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/342
# https://bugzilla.redhat.com/show_bug.cgi?id=2346150
Patch: plymouth-24.004.60-use_simpledrm-config.patch

# Backport upstream fix for crash when using 2 GPUs with displays attached and
# using evdev input support (XKBLAYOUT set in /etc/vconsole.conf)
# https://gitlab.freedesktop.org/plymouth/plymouth/-/commit/d20b1be527817c21500c3daa4dfdd0e9c7c731b8
# https://bugzilla.redhat.com/show_bug.cgi?id=2368186
Patch: 0001-drm-Check-for-NULL-terminal-in-watch_input_device.patch

# Fix a crash caused by calling ply_event_loop_watch_fd () with a -1 fd
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/354
# https://bugzilla.redhat.com/show_bug.cgi?id=2370979
Patch: 0001-drm-Fix-crash-when-terminal-fd-is-still-1-after-reco.patch

# Don't use simpledrm together with LUKS, see commit message for details
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/355
# https://bugzilla.redhat.com/show_bug.cgi?id=2359283
Patch: 0001-Add-UseSimpledrmNoLuks-config-file-keyword.patch

# Fix Disk unlock screen keymap and capslock icons not shown on monitor on second GPU
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/356
# https://bugzilla.redhat.com/show_bug.cgi?id=2375854
Patch: 0001-Fix-keymap-and-capslock-icon-on-displays-on-second-G.patch

# Make the prompt below the diskunlock password entry box look a bit better
# https://gitlab.freedesktop.org/plymouth/plymouth/-/merge_requests/357
# https://gitlab.freedesktop.org/plymouth/plymouth/-/issues/294
# https://bugzilla.redhat.com/show_bug.cgi?id=2356893
Patch: 0001-two-step-Remove-at-the-end-of-passphrase-prompt-belo.patch
Patch: 0002-two-step-Add-some-padding-between-text-entry-field-a.patch

# Patches from upstream to fix messages being logged twice on serial consoles
Patch: 0001-utils-Don-t-lose-log-level-when-silencing-kmsg.patch
Patch: 0002-details-Suppress-kernel-s-own-kmsg-console-output.patch
Patch: 0003-kmsg-reader-Seek-to-the-end-of-the-ringbuffer.patch

BuildRequires: meson
BuildRequires: system-logos
BuildRequires: gcc libtool git
BuildRequires: pkgconfig(libdrm)
BuildRequires: pkgconfig(libevdev)
BuildRequires: pkgconfig(libudev)
BuildRequires: pkgconfig(xkeyboard-config)
BuildRequires: kernel-headers
BuildRequires: libpng-devel
BuildRequires: libxslt, docbook-style-xsl
BuildRequires: pkgconfig(gtk+-3.0)
BuildRequires: pango-devel >= 1.21.0
BuildRequires: cairo-devel
BuildRequires: gettext-devel
# for /usr/bin/systemd-tty-ask-password-agent
BuildRequires: systemd
# for _unitdir macro
BuildRequires: systemd-rpm-macros

Requires: %{name}-core-libs = %{version}-%{release}
Requires: %{name}-scripts = %{version}-%{release}
# For keyboard layouts
Requires: xkeyboard-config
Suggests: logrotate

%description
Plymouth provides an attractive graphical boot animation in
place of the text messages that normally get shown.  Text
messages are instead redirected to a log file for viewing
after boot.


%package system-theme
Summary: Plymouth default theme
Requires: plymouth(system-theme) = %{version}-%{release}

%description system-theme
This meta-package tracks the current distribution default theme.


%package core-libs
Summary: Plymouth core libraries

%description core-libs
This package contains the core libraries used by Plymouth.


%package graphics-libs
Summary: Plymouth graphics libraries
Requires: %{name}-core-libs = %{version}-%{release}
Requires: system-logos

%description graphics-libs
This package contains the libraries used by graphical Plymouth splashes.


%package devel
Summary: Libraries and headers for writing Plymouth splash plugins
Requires: %{name} = %{version}-%{release}
Requires: pkgconfig

%description devel
This package contains the libraries and headers needed to develop
3rd party splash plugins for Plymouth.


%package scripts
Summary: Plymouth related scripts
Requires: findutils, coreutils, gzip, cpio, dracut
Requires: xkeyboard-config
Requires: %{name} = %{version}-%{release}

%description scripts
This package contains scripts that help integrate Plymouth with
the system.


%package plugin-label
Summary: Plymouth label plugin
Requires: %{name} = %{version}-%{release}
Requires: %{name}-graphics-libs = %{version}-%{release}

%description plugin-label
This package contains the label control plugin for Plymouth.
It provides the ability to render text on graphical boot splashes.


%package plugin-script
Summary: Plymouth "script" plugin
Requires: %{name} = %{version}-%{release}
Requires: %{name}-graphics-libs = %{version}-%{release}

%description plugin-script
This package contains the "script" boot splash plugin for
Plymouth. It features an extensible boot splash language that
allows writing new plugins as scripts, simplifying the process
of designing custom boot splash themes.


%package plugin-fade-throbber
Summary: Plymouth "Fade-Throbber" plugin
Requires: %{name} = %{version}-%{release}
Requires: %{name}-graphics-libs = %{version}-%{release}

%description plugin-fade-throbber
This package contains the "Fade-In" boot splash plugin for
Plymouth. It features a centered image that fades in and out
while other images pulsate around during system boot up.


%package plugin-space-flares
Summary: Plymouth "space-flares" plugin
Requires: %{name} = %{version}-%{release}
Requires: %{name}-graphics-libs = %{version}-%{release}
Requires: plymouth-plugin-label = %{version}-%{release}

%description plugin-space-flares
This package contains the "space-flares" boot splash plugin for
Plymouth. It features a corner image with animated flares.


%package plugin-two-step
Summary: Plymouth "two-step" plugin
Requires: %{name} = %{version}-%{release}
Requires: %{name}-graphics-libs = %{version}-%{release}
Requires: plymouth-plugin-label = %{version}-%{release}
# Spinifinity like themes should now use two-step instead of throbgress
# No provides, the throbgress plugin has been removed upstream
Obsoletes: %{name}-plugin-throbgress < %{version}-%{release}

%description plugin-two-step
This package contains the "two-step" boot splash plugin for
Plymouth. It features a two phased boot process that starts with
a progressing animation synced to boot time and finishes with a
short, fast one-shot animation.

# Don't build charge theme in ELN/RHEL as it's Fedora specific
%if ! 0%{?rhel}
%package theme-charge
Summary: Plymouth "Charge" plugin
Requires: %{name}-plugin-two-step = %{version}-%{release}
Requires: fedora-logos-classic
Requires(post): plymouth-scripts

%description theme-charge
This package contains the "charge" boot splash theme for
Plymouth. It features the shadowy hull of a Fedora logo charge up and
and finally burst into full form.
%endif

%package theme-fade-in
Summary: Plymouth "Fade-In" theme
Requires: %{name}-plugin-fade-throbber = %{version}-%{release}
Requires(post): plymouth-scripts

%description theme-fade-in
This package contains the "Fade-In" boot splash theme for
Plymouth. It features a centered logo that fades in and out
while stars twinkle around the logo during system boot up.


%package theme-script
Summary: Plymouth "Script" plugin
Requires: %{name}-plugin-script = %{version}-%{release}
Requires(post): plymouth-scripts

%description theme-script
This package contains the "script" boot splash theme for
Plymouth. It it is a simple example theme the uses the "script"
plugin.


%package theme-solar
Summary: Plymouth "Solar" theme
Requires: %{name}-plugin-space-flares = %{version}-%{release}
Requires(post): plymouth-scripts

%description theme-solar
This package contains the "Solar" boot splash theme for
Plymouth. It features a blue flamed sun with animated solar flares.


%package theme-spinfinity
Summary: Plymouth "Spinfinity" theme
Requires: %{name}-plugin-two-step = %{version}-%{release}
Requires(post): plymouth-scripts

%description theme-spinfinity
This package contains the "Spinfinity" boot splash theme for
Plymouth. It features a centered logo and animated spinner that
spins in the shape of an infinity sign.


%package theme-spinner
Summary: Plymouth "Spinner" theme
Requires: %{name}-plugin-two-step = %{version}-%{release}
%if 0%{?rhel} > 9
Requires: redhat-mono-vf-fonts
Requires: redhat-text-vf-fonts
%else
Requires: font(cantarell) font(cantarelllight)
%endif
Requires(post): plymouth-scripts
Provides: plymouth(system-theme) = %{version}-%{release}

%description theme-spinner
This package contains the "spinner" boot splash theme for
Plymouth. It features a small spinner on a dark background.


%prep
%autosetup -p1 -a 1
# Change the default theme
sed -i -e 's/spinner/bgrt/g' src/plymouthd.defaults
# Use simpledrm /dev/dri/card# by default, except when LUKS disk encrpytion is used
echo UseSimpledrmNoLuks=1 >> src/plymouthd.defaults

%if 0%{?rhel} > 9
find -type f -exec sed -i -e 's/Cantarell/Red Hat Text/g' {} \;
%endif

%build
%meson -Dtracing=true  \
       -Dlogo=%{_datadir}/pixmaps/system-logo-white.png \
       -Dbackground-start-color-stop=0x0073B3           \
       -Dbackground-end-color-stop=0x00457E             \
       -Dbackground-color=0x3391cd
%meson_build

%install
%meson_install

%find_lang %{name}
find $RPM_BUILD_ROOT -name '*.la' -delete

mkdir -p $RPM_BUILD_ROOT%{_localstatedir}/lib/plymouth

%if ! 0%{?rhel}
# Add charge, our old default
mkdir -p $RPM_BUILD_ROOT%{_datadir}/plymouth/themes/charge
cp %{SOURCE2} $RPM_BUILD_ROOT%{_datadir}/plymouth/themes/charge
cp $RPM_BUILD_ROOT%{_datadir}/plymouth/themes/glow/{box,bullet,entry,lock}.png $RPM_BUILD_ROOT%{_datadir}/plymouth/themes/charge
%endif

# Drop glow, it's not very Fedora-y
rm -rf $RPM_BUILD_ROOT%{_datadir}/plymouth/themes/glow


%ldconfig_scriptlets core-libs

%ldconfig_scriptlets graphics-libs

%if ! 0%{?rhel}
%postun theme-charge
export PLYMOUTH_PLUGIN_PATH=%{_libdir}/plymouth/
if [ $1 -eq 0 ]; then
    if [ "$(%{_sbindir}/plymouth-set-default-theme)" == "charge" ]; then
        %{_sbindir}/plymouth-set-default-theme --reset
    fi
fi
%endif

%postun theme-fade-in
export PLYMOUTH_PLUGIN_PATH=%{_libdir}/plymouth/
if [ $1 -eq 0 ]; then
    if [ "$(%{_sbindir}/plymouth-set-default-theme)" == "fade-in" ]; then
        %{_sbindir}/plymouth-set-default-theme --reset
    fi
fi

%postun theme-solar
export PLYMOUTH_PLUGIN_PATH=%{_libdir}/plymouth/
if [ $1 -eq 0 ]; then
    if [ "$(%{_sbindir}/plymouth-set-default-theme)" == "solar" ]; then
        %{_sbindir}/plymouth-set-default-theme --reset
    fi
fi

%postun theme-spinfinity
export PLYMOUTH_PLUGIN_PATH=%{_libdir}/plymouth/
if [ $1 -eq 0 ]; then
    if [ "$(%{_sbindir}/plymouth-set-default-theme)" == "spinfinity" ]; then
        %{_sbindir}/plymouth-set-default-theme --reset
    fi
fi

%post theme-spinner
export PLYMOUTH_PLUGIN_PATH=%{_libdir}/plymouth/
# On upgrades replace charge with the new bgrt default
if [ $1 -eq 2 ]; then
    if [ "$(%{_sbindir}/plymouth-set-default-theme)" == "charge" ]; then
        %{_sbindir}/plymouth-set-default-theme bgrt
    fi
fi

%postun theme-spinner
export PLYMOUTH_PLUGIN_PATH=%{_libdir}/plymouth/
if [ $1 -eq 0 ]; then
    if [ "$(%{_sbindir}/plymouth-set-default-theme)" == "bgrt" -o \
         "$(%{_sbindir}/plymouth-set-default-theme)" == "spinner" ]; then
        %{_sbindir}/plymouth-set-default-theme --reset
    fi
fi


%files -f %{name}.lang
%license COPYING
%doc AUTHORS README.md
%dir %{_datadir}/plymouth
%dir %{_datadir}/plymouth/themes
%dir %{_datadir}/plymouth/themes/details
%dir %{_datadir}/plymouth/themes/text
%dir %{_datadir}/plymouth/themes/tribar
%dir %{_libexecdir}/plymouth
%dir %{_localstatedir}/lib/plymouth
%dir %{_libdir}/plymouth/renderers
%dir %{_sysconfdir}/plymouth
%config(noreplace) %{_sysconfdir}/plymouth/plymouthd.conf
%config(noreplace) %{_sysconfdir}/logrotate.d/bootlog
%{_sbindir}/plymouthd
%{_libexecdir}/plymouth/plymouthd-fd-escrow
%{_bindir}/plymouth
%{_libdir}/plymouth/details.so
%{_libdir}/plymouth/text.so
%{_libdir}/plymouth/tribar.so
%{_datadir}/plymouth/themes/details/details.plymouth
%{_datadir}/plymouth/themes/text/text.plymouth
%{_datadir}/plymouth/themes/tribar/tribar.plymouth
%{_datadir}/plymouth/plymouthd.defaults
%{_localstatedir}/spool/plymouth
%{_mandir}/man?/*
%ghost %verify(not mode) %{_localstatedir}/lib/plymouth/boot-duration
%{_unitdir}/

%files devel
%{_libdir}/libply.so
%{_libdir}/libply-splash-core.so
%{_libdir}/libply-boot-client.so
%{_libdir}/libply-splash-graphics.so
%{_libdir}/pkgconfig/ply-splash-core.pc
%{_libdir}/pkgconfig/ply-splash-graphics.pc
%{_libdir}/pkgconfig/ply-boot-client.pc
%{_libdir}/plymouth/renderers/x11*
%{_includedir}/plymouth-1

%files core-libs
%{_libdir}/libply.so.*
%{_libdir}/libply-splash-core.so.*
%{_libdir}/libply-boot-client.so.*
%dir %{_libdir}/plymouth

%files graphics-libs
%{_libdir}/libply-splash-graphics.so.*
%{_libdir}/plymouth/renderers/drm*
%{_libdir}/plymouth/renderers/frame-buffer*

%files scripts
%{_sbindir}/plymouth-set-default-theme
%{_libexecdir}/plymouth/plymouth-update-initrd
%{_libexecdir}/plymouth/plymouth-generate-initrd
%{_libexecdir}/plymouth/plymouth-populate-initrd

%files plugin-label
%{_libdir}/plymouth/label-freetype.so
%{_libdir}/plymouth/label-pango.so

%files plugin-script
%{_libdir}/plymouth/script.so

%files plugin-fade-throbber
%{_libdir}/plymouth/fade-throbber.so

%files plugin-space-flares
%{_libdir}/plymouth/space-flares.so

%files plugin-two-step
%{_libdir}/plymouth/two-step.so

%if ! 0%{?rhel}
%files theme-charge
%{_datadir}/plymouth/themes/charge
%endif

%files theme-fade-in
%{_datadir}/plymouth/themes/fade-in

%files theme-script
%{_datadir}/plymouth/themes/script

%files theme-solar
%{_datadir}/plymouth/themes/solar

%files theme-spinfinity
%{_datadir}/plymouth/themes/spinfinity

%files theme-spinner
# bgrt is a variant of spinner with different settings in its .plymouth file
%{_datadir}/plymouth/themes/bgrt
%{_datadir}/plymouth/themes/spinner

%files system-theme

%changelog
%autochangelog
