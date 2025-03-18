%global majorversion 1
%global minorversion 2
%global microversion 7

%global apiversion   0.3
%global spaversion   0.2
%global soversion    0
%global libversion   %{soversion}.%(bash -c '((intversion = (%{minorversion} * 100) + %{microversion})); echo ${intversion}').0
%global ms_version   0.4.2

# For rpmdev-bumpspec and releng automation
%global baserelease 1

#global snapdate   20210107
#global gitcommit  b17db2cebc1a5ab2c01851d29c05f79cd2f262bb
#global shortcommit %(c=%{gitcommit}; echo ${c:0:7})

# https://bugzilla.redhat.com/983606
%global _hardened_build 1

# where/how to apply multilib hacks
%global multilib_archs x86_64 %{ix86} ppc64 ppc s390x s390 sparc64 sparcv9 ppc64le

# Build conditions for various features
%bcond_without alsa
%bcond_without vulkan

# Features disabled for RHEL 8
%if 0%{?rhel} && 0%{?rhel} < 9
%bcond_with pulse
%bcond_with jack
%else
%bcond_without pulse
%bcond_without jack
%endif

# Features disabled for RHEL
%if 0%{?rhel}
%bcond_with jackserver_plugin
%bcond_with libmysofa
%bcond_with lv2
%bcond_with roc
%else
%bcond_without jackserver_plugin
%bcond_without libmysofa
%bcond_without lv2
%bcond_without roc
%endif

%if 0%{?rhel} || ("%{_arch}" == "s390x")
%bcond_with ffado
%else
%bcond_without ffado
%endif

# Disabled for RHEL < 11 and Fedora < 36
%if (0%{?rhel} && 0%{?rhel} < 11) || (0%{?fedora} && 0%{?fedora} < 36) || ("%{_arch}" == "s390x") || ("%{_arch}" == "ppc64le")
%bcond_with libcamera_plugin
%else
%bcond_without libcamera_plugin
%endif

%bcond_without v4l2

Name:           pipewire
Summary:        Media Sharing Server
Version:        %{majorversion}.%{minorversion}.%{microversion}
Release:        %{baserelease}%{?snapdate:.%{snapdate}git%{shortcommit}}%{?dist}.bazzite.{{{ git_dir_version }}}
License:        MIT
URL:            https://pipewire.org/
%if 0%{?snapdate}
Source0:        https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/%{gitcommit}/pipewire-%{shortcommit}.tar.gz
%else
Source0:        https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/%{version}/pipewire-%{version}.tar.gz
%endif
Source1:        pipewire.sysusers

## upstream patches

## upstreamable patches

## fedora patches

## valve patches
# Holo: TODO: Bug reference
Patch10:        bc435841c141ad38768b6cb1a7ad45e8bb13c7d2.patch

BuildRequires:  gettext
BuildRequires:  meson >= 0.59.0
BuildRequires:  gcc
BuildRequires:  g++
BuildRequires:  pkgconfig
BuildRequires:  pkgconfig(libudev)
BuildRequires:  pkgconfig(dbus-1)
BuildRequires:  pkgconfig(glib-2.0) >= 2.32
BuildRequires:  pkgconfig(gio-unix-2.0) >= 2.32
BuildRequires:  pkgconfig(gstreamer-1.0) >= 1.10.0
BuildRequires:  pkgconfig(gstreamer-base-1.0) >= 1.10.0
BuildRequires:  pkgconfig(gstreamer-plugins-base-1.0) >= 1.10.0
BuildRequires:  pkgconfig(gstreamer-net-1.0) >= 1.10.0
BuildRequires:  pkgconfig(gstreamer-allocators-1.0) >= 1.10.0
# libldac is not built on x390x, see rhbz#1677491
%ifnarch s390x
BuildRequires:  pkgconfig(ldacBT-enc)
BuildRequires:  pkgconfig(ldacBT-abr)
%endif
BuildRequires:  pkgconfig(fdk-aac)
BuildRequires:  pkgconfig(bluez)
BuildRequires:  systemd
BuildRequires:  systemd-devel
BuildRequires:  alsa-lib-devel
BuildRequires:  libv4l-devel
BuildRequires:  doxygen
BuildRequires:  python-docutils
BuildRequires:  graphviz
BuildRequires:  sbc-devel
BuildRequires:  liblc3-devel
BuildRequires:  libsndfile-devel
BuildRequires:  ncurses-devel
BuildRequires:  pulseaudio-libs-devel
BuildRequires:  avahi-devel
%if 0%{?fedora} >= 40 || 0%{?rhel} >= 10
BuildRequires:  pkgconfig(webrtc-audio-processing-1)
%else
BuildRequires:  pkgconfig(webrtc-audio-processing) >= 0.2
%endif
BuildRequires:  libusb1-devel
BuildRequires:  readline-devel
BuildRequires:  openssl-devel
BuildRequires:  libcanberra-devel
BuildRequires:  libuv-devel
BuildRequires:  speexdsp-devel
BuildRequires:  systemd-rpm-macros
%{?sysusers_requires_compat}

Requires(pre):  shadow-utils
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
Requires:       systemd
Requires:       rtkit
# A virtual Provides so we can swap session managers
Requires:       pipewire-session-manager
# Prefer WirePlumber for session manager
Suggests:       wireplumber
# Bring in libcamera plugin for MIPI / complex camera support
Recommends:     pipewire-plugin-libcamera

%description
PipeWire is a multimedia server for Linux and other Unix like operating
systems.

%package libs
Summary:        Libraries for PipeWire clients
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Obsoletes:      %{name}-libpulse < %{version}-%{release}

%description libs
This package contains the runtime libraries for any application that wishes
to interface with a PipeWire media server.

%package gstreamer
Summary:        GStreamer elements for PipeWire
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description gstreamer
This package contains GStreamer elements to interface with a
PipeWire media server.

%package devel
Summary:        Headers and libraries for PipeWire client development
License:        MIT
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
%description devel
Headers and libraries for developing applications that can communicate with
a PipeWire media server.

%package doc
Summary:        PipeWire media server documentation
License:        MIT

%description doc
This package contains documentation for the PipeWire media server.

%package utils
Summary:        PipeWire media server utilities
License:        MIT
Requires:       %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description utils
This package contains command line utilities for the PipeWire media server.

%if %{with alsa}
%package alsa
Summary:        PipeWire media server ALSA support
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
%if ! (0%{?fedora} && 0%{?fedora} < 34)
# Ensure this is provided by default to route all audio
Supplements:    %{name} = %{version}-%{release}
# Replace PulseAudio and JACK ALSA plugins with PipeWire
## N.B.: If alsa-plugins gets updated in F33, this will need to be bumped
Obsoletes:      alsa-plugins-jack < 1.2.2-5
Obsoletes:      alsa-plugins-pulseaudio < 1.2.2-5
%endif

%description alsa
This package contains an ALSA plugin for the PipeWire media server.
%endif

%if %{with jack}
%package jack-audio-connection-kit-libs
Summary:        PipeWire JACK implementation libraries
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
%if 0%{?rhel}
Requires:       %{name}-jack-audio-connection-kit%{?_isa} = %{version}-%{release}
%endif
# Fixed jack subpackages
Conflicts:      %{name}-libjack < 0.3.13-6
Conflicts:      %{name}-jack-audio-connection-kit < 0.3.13-6
# Replaces libjack subpackage
Obsoletes:      %{name}-libjack < 0.3.19-2
Provides:       %{name}-libjack = %{version}-%{release}
Provides:       %{name}-libjack%{?_isa} = %{version}-%{release}

%description jack-audio-connection-kit-libs
This package provides a JACK implementation libraries based on PipeWire

%package jack-audio-connection-kit
Summary:        PipeWire JACK implementation
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-jack-audio-connection-kit-libs%{?_isa} = %{version}-%{release}
Conflicts:      jack-audio-connection-kit
Conflicts:      jack-audio-connection-kit-dbus
# Replaces libjack subpackage
%if ! (0%{?fedora} && 0%{?fedora} < 34)
# Ensure this is provided by default to route all audio
Supplements:    %{name} = %{version}-%{release}
# Replace JACK with PipeWire-JACK
## N.B.: If jack gets updated in F33, this will need to be bumped
Obsoletes:      jack-audio-connection-kit < 1.9.16-2
# Fix upgrade path to f38, see #2203789
Obsoletes:      jack-audio-connection-kit-example-clients < 1.9.22
%endif

%description jack-audio-connection-kit
This package provides a JACK implementation based on PipeWire

%package jack-audio-connection-kit-devel
Summary:        Development files for %{name}-jack-audio-connection-kit
License:        MIT
Requires:       %{name}-jack-audio-connection-kit-libs%{?_isa} = %{version}-%{release}
Conflicts:      jack-audio-connection-kit-devel
Enhances:       %{name}-jack-audio-connection-kit-libs

%description jack-audio-connection-kit-devel
This package provides development files for building JACK applications
using PipeWire's JACK library.
%endif

%if %{with jackserver_plugin}
%package plugin-jack
Summary:        PipeWire media server JACK support
License:        MIT
BuildRequires:  jack-audio-connection-kit-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-jack-audio-connection-kit-libs = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
Requires:       jack-audio-connection-kit

%description plugin-jack
This package contains the PipeWire spa plugin to connect to a JACK server.
%endif

%if %{with libcamera_plugin}
%package plugin-libcamera
Summary:        PipeWire media server libcamera support
License:        MIT
BuildRequires:  libcamera-devel
BuildRequires:  libdrm-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
Requires:       libcamera
Requires:       libdrm

%description plugin-libcamera
This package contains the PipeWire spa plugin to access cameras through libcamera.
%endif

%if %{with vulkan}
%package plugin-vulkan
Summary:        PipeWire media server vulkan support
License:        MIT
BuildRequires:  pkgconfig(vulkan)
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description plugin-vulkan
This package contains the PipeWire spa plugin for vulkan.
%endif

%if %{with pulse}
%package pulseaudio
Summary:        PipeWire PulseAudio implementation
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}
Conflicts:      pulseaudio
# Fixed pulseaudio subpackages
Conflicts:      %{name}-libpulse < 0.3.13-6
Conflicts:      %{name}-pulseaudio < 0.3.13-6
%if ! (0%{?fedora} && 0%{?fedora} < 34)
# Ensure this is provided by default to route all audio
Supplements:    %{name} = %{version}-%{release}
# Replace PulseAudio with PipeWire-PulseAudio
## N.B.: If pulseaudio gets updated in F33, this will need to be bumped
Obsoletes:      pulseaudio < 14.2-3
Obsoletes:      pulseaudio-esound-compat < 14.2-3
Obsoletes:      pulseaudio-module-bluetooth < 14.2-3
Obsoletes:      pulseaudio-module-gconf < 14.2-3
Obsoletes:      pulseaudio-module-gsettings < 14.2-3
Obsoletes:      pulseaudio-module-jack < 14.2-3
Obsoletes:      pulseaudio-module-lirc < 14.2-3
Obsoletes:      pulseaudio-module-x11 < 14.2-3
Obsoletes:      pulseaudio-module-zeroconf < 14.2-3
Obsoletes:      pulseaudio-qpaeq < 14.2-3
%endif

# Virtual Provides to support swapping between PipeWire-PA and PA
Provides:       pulseaudio-daemon
Conflicts:      pulseaudio-daemon
Provides:       pulseaudio-module-bluetooth
Provides:       pulseaudio-module-jack

%description pulseaudio
This package provides a PulseAudio implementation based on PipeWire
%endif

%if %{with v4l2}
%package v4l2
Summary:        PipeWire media server v4l2 LD_PRELOAD support
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description v4l2
This package contains an LD_PRELOAD library that redirects v4l2 applications to
PipeWire.
%endif

%package module-x11
Summary:        PipeWire media server x11 support
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description module-x11
This package contains X11 bell support for PipeWire.

%if %{with ffado}
%package module-ffado
Summary:        PipeWire media server ffado support
License:        MIT
BuildRequires:  libffado-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description module-ffado
This package contains the FFADO support for PipeWire.
%endif

%if %{with roc}
%package module-roc
Summary:        PipeWire media server ROC support
License:        MIT
BuildRequires:  roc-toolkit-devel
BuildRequires:  libunwind-devel
BuildRequires:  openfec-devel
BuildRequires:  sox-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description module-roc
This package contains the ROC support for PipeWire.
%endif

%if %{with libmysofa}
%package module-filter-chain-sofa
Summary:        PipeWire media server sofa filter-chain support
License:        MIT
BuildRequires:  libmysofa-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description module-filter-chain-sofa
This package contains the mysofa support for PipeWire filter-chain.
%endif

%if %{with lv2}
%package module-filter-chain-lv2
Summary:        PipeWire media server lv2 filter-chain support
License:        MIT
BuildRequires:  lilv-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description module-filter-chain-lv2
This package contains the mysofa support for PipeWire filter-chain.
%endif

%package config-rates
Summary:        PipeWire media server multirate configuration
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description config-rates
This package contains the configuration files to support multiple
sample rates.

%package config-upmix
Summary:        PipeWire media server upmixing configuration
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description config-upmix
This package contains the configuration files to support upmixing.


%prep
%autosetup -p1 %{?snapdate:-n %{name}-%{gitcommit}}


%if %{with media-session}
mkdir subprojects/packagefiles
cp %{SOURCE1} subprojects/packagefiles/
%endif

%build
%meson \
    -D docs=enabled -D man=enabled -D gstreamer=enabled -D systemd=enabled	\
    -D sdl2=disabled 								\
    -D audiotestsrc=disabled -D videotestsrc=disabled				\
    -D volume=disabled -D bluez5-codec-aptx=disabled 		  		\
    -D bluez5-codec-lc3plus=disabled -D bluez5-codec-lc3=enabled		\
%ifarch s390x
    -D bluez5-codec-ldac=disabled						\
%endif
    -D session-managers=[] 							\
    -D rtprio-server=60 -D rtprio-client=55 -D rlimits-rtprio=70		\
    -D snap=disabled								\
    %{!?with_jack:-D pipewire-jack=disabled} 					\
    %{!?with_jackserver_plugin:-D jack=disabled} 				\
    %{!?with_libcamera_plugin:-D libcamera=disabled} 				\
    %{?with_jack:-D jack-devel=true} 						\
    %{!?with_alsa:-D pipewire-alsa=disabled}					\
    %{?with_vulkan:-D vulkan=enabled}						\
    %{!?with_libmysofa:-D libmysofa=disabled}					\
    %{!?with_lv2:-D lv2=disabled}						\
    %{!?with_roc:-D roc=disabled}						\
    %{!?with_ffado:-D libffado=disabled}					\
    %{nil}
%meson_build

%install
install -p -D -m 0644 %{SOURCE1} %{buildroot}%{_sysusersdir}/pipewire.conf
%meson_install

# Own this directory so add-ons can use it
install -d -m 0755 %{buildroot}%{_datadir}/pipewire/pipewire.conf.d/
install -d -m 0755 %{buildroot}%{_datadir}/pipewire/client.conf.d/
install -d -m 0755 %{buildroot}%{_datadir}/pipewire/client-rt.conf.d/

%if %{with jack}
mkdir -p %{buildroot}%{_sysconfdir}/ld.so.conf.d/
echo %{_libdir}/pipewire-%{apiversion}/jack/ > %{buildroot}%{_sysconfdir}/ld.so.conf.d/pipewire-jack-%{_arch}.conf
%else
rm %{buildroot}%{_datadir}/pipewire/jack.conf

%endif

%if %{with alsa}
mkdir -p %{buildroot}%{_sysconfdir}/alsa/conf.d/
cp %{buildroot}%{_datadir}/alsa/alsa.conf.d/50-pipewire.conf \
        %{buildroot}%{_sysconfdir}/alsa/conf.d/50-pipewire.conf
cp %{buildroot}%{_datadir}/alsa/alsa.conf.d/99-pipewire-default.conf \
        %{buildroot}%{_sysconfdir}/alsa/conf.d/99-pipewire-default.conf

%endif

%if ! %{with pulse}
# If the PulseAudio replacement isn't being offered, delete the files
rm %{buildroot}%{_bindir}/pipewire-pulse
rm %{buildroot}%{_userunitdir}/pipewire-pulse.*
rm %{buildroot}%{_datadir}/pipewire/pipewire-pulse.conf

%endif

%if %{with pulse}
# Own this directory so add-ons can use it
install -d -m 0755 %{buildroot}%{_datadir}/pipewire/pipewire-pulse.conf.d/

ln -s ../pipewire-pulse.conf.avail/20-upmix.conf \
		%{buildroot}%{_datadir}/pipewire/pipewire-pulse.conf.d/20-upmix.conf
%endif

# rates config
ln -s ../pipewire.conf.avail/10-rates.conf \
		%{buildroot}%{_datadir}/pipewire/pipewire.conf.d/10-rates.conf

# upmix config
ln -s ../pipewire.conf.avail/20-upmix.conf \
		%{buildroot}%{_datadir}/pipewire/pipewire.conf.d/20-upmix.conf
ln -s ../client.conf.avail/20-upmix.conf \
		%{buildroot}%{_datadir}/pipewire/client.conf.d/20-upmix.conf
ln -s ../client-rt.conf.avail/20-upmix.conf \
		%{buildroot}%{_datadir}/pipewire/client-rt.conf.d/20-upmix.conf


%find_lang %{name}

%check
%meson_test || TESTS_ERROR=$?
if [ "${TESTS_ERROR}" != "" ]; then
echo "test failed"
%{!?tests_nonfatal:exit $TESTS_ERROR}
fi

%pre
%sysusers_create_compat %{SOURCE1}

%post
%systemd_user_post pipewire.service
%systemd_user_post pipewire.socket

%triggerun -- %{name} < 0.3.6-2
# This is for upgrades from previous versions which had a static symlink.
# The %%post scriptlet above only does anything on initial package installation.
# Remove before F33.
systemctl --no-reload preset --global pipewire.socket >/dev/null 2>&1 || :

%if %{with pulse}
%post pulseaudio
%systemd_user_post pipewire-pulse.service
%systemd_user_post pipewire-pulse.socket
%endif

%files
%license LICENSE COPYING
%doc README.md NEWS
%{_userunitdir}/pipewire.*
%{_userunitdir}/filter-chain.*
%{_bindir}/pipewire
%{_bindir}/pipewire-avb
%{_bindir}/pipewire-aes67
%{_bindir}/pipewire-vulkan
%{_mandir}/man1/pipewire.1*
%dir %{_datadir}/pipewire/
%dir %{_datadir}/pipewire/pipewire.conf.d/
%{_datadir}/pipewire/pipewire.conf
%{_datadir}/pipewire/pipewire.conf.avail/10-rates.conf
%{_datadir}/pipewire/pipewire.conf.avail/20-upmix.conf
%{_datadir}/pipewire/minimal.conf
%{_datadir}/pipewire/filter-chain.conf
%{_datadir}/pipewire/filter-chain/*.conf
%{_datadir}/pipewire/pipewire-avb.conf
%{_datadir}/pipewire/pipewire-aes67.conf
%{_datadir}/pipewire/pipewire-vulkan.conf
%{_mandir}/man5/pipewire.conf.5*
%{_mandir}/man5/pipewire-filter-chain.conf.5*
%config(noreplace) %{_sysconfdir}/security/limits.d/*.conf
%{_sysusersdir}/pipewire.conf

%files libs -f %{name}.lang
%license LICENSE COPYING
%doc README.md
%{_libdir}/libpipewire-%{apiversion}.so.*
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-access.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-adapter.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-avb.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-client-device.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-client-node.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-combine-stream.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-echo-cancel.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-fallback-sink.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-filter-chain.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-link-factory.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-loopback.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-metadata.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-netjack2-driver.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-netjack2-manager.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-parametric-equalizer.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-pipe-tunnel.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-portal.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-profiler.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-protocol-native.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-protocol-simple.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-pulse-tunnel.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-raop-discover.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-raop-sink.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-rtkit.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-rtp-sap.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-rtp-session.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-rtp-sink.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-rtp-source.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-rt.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-session-manager.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-snapcast-discover.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-spa-device-factory.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-spa-device.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-spa-node-factory.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-spa-node.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-vban-send.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-vban-recv.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-zeroconf-discover.so
%dir %{_datadir}/alsa-card-profile/
%dir %{_datadir}/alsa-card-profile/mixer/
%{_datadir}/alsa-card-profile/mixer/paths/
%{_datadir}/alsa-card-profile/mixer/profile-sets/
%dir %{_datadir}/spa-0.2/
%{_datadir}/spa-0.2/bluez5/bluez-hardware.conf
%{_prefix}/lib/udev/rules.d/90-pipewire-alsa.rules
%dir %{_libdir}/spa-%{spaversion}
%{_libdir}/spa-%{spaversion}/aec/
%{_libdir}/spa-%{spaversion}/alsa/
%{_libdir}/spa-%{spaversion}/audioconvert/
%{_libdir}/spa-%{spaversion}/audiomixer/
%{_libdir}/spa-%{spaversion}/avb/
%{_libdir}/spa-%{spaversion}/bluez5/
%{_libdir}/spa-%{spaversion}/control/
%{_libdir}/spa-%{spaversion}/support/
%{_libdir}/spa-%{spaversion}/v4l2/
%{_libdir}/spa-%{spaversion}/videoconvert/
%{_datadir}/pipewire/client.conf
%dir %{_datadir}/pipewire/client.conf.d/
%{_datadir}/pipewire/client.conf.avail/20-upmix.conf
%{_datadir}/pipewire/client-rt.conf
%dir %{_datadir}/pipewire/client-rt.conf.d/
%{_datadir}/pipewire/client-rt.conf.avail/20-upmix.conf
%{_mandir}/man5/pipewire-client.conf.5.gz
%{_mandir}/man7/pipewire-props.7.gz
%{_mandir}/man7/libpipewire-module-access.7.gz
%{_mandir}/man7/libpipewire-module-adapter.7.gz
%{_mandir}/man7/libpipewire-module-avb.7.gz
%{_mandir}/man7/libpipewire-module-client-device.7.gz
%{_mandir}/man7/libpipewire-module-client-node.7.gz
%{_mandir}/man7/libpipewire-module-combine-stream.7.gz
%{_mandir}/man7/libpipewire-module-echo-cancel.7.gz
%{_mandir}/man7/libpipewire-module-example-filter.7.gz
%{_mandir}/man7/libpipewire-module-example-sink.7.gz
%{_mandir}/man7/libpipewire-module-example-source.7.gz
%{_mandir}/man7/libpipewire-module-fallback-sink.7.gz
%{_mandir}/man7/libpipewire-module-ffado-driver.7.gz
%{_mandir}/man7/libpipewire-module-filter-chain.7.gz
%{_mandir}/man7/libpipewire-module-jack-tunnel.7.gz
%{_mandir}/man7/libpipewire-module-jackdbus-detect.7.gz
%{_mandir}/man7/libpipewire-module-link-factory.7.gz
%{_mandir}/man7/libpipewire-module-loopback.7.gz
%{_mandir}/man7/libpipewire-module-metadata.7.gz
%{_mandir}/man7/libpipewire-module-netjack2-driver.7.gz
%{_mandir}/man7/libpipewire-module-netjack2-manager.7.gz
%{_mandir}/man7/libpipewire-module-parametric-equalizer.7.gz
%{_mandir}/man7/libpipewire-module-pipe-tunnel.7.gz
%{_mandir}/man7/libpipewire-module-portal.7.gz
%{_mandir}/man7/libpipewire-module-profiler.7.gz
%{_mandir}/man7/libpipewire-module-protocol-native.7.gz
%{_mandir}/man7/libpipewire-module-protocol-pulse.7.gz
%{_mandir}/man7/libpipewire-module-protocol-simple.7.gz
%{_mandir}/man7/libpipewire-module-pulse-tunnel.7.gz
%{_mandir}/man7/libpipewire-module-raop-discover.7.gz
%{_mandir}/man7/libpipewire-module-raop-sink.7.gz
%{_mandir}/man7/libpipewire-module-roc-sink.7.gz
%{_mandir}/man7/libpipewire-module-roc-source.7.gz
%{_mandir}/man7/libpipewire-module-rt.7.gz
%{_mandir}/man7/libpipewire-module-rtp-sap.7.gz
%{_mandir}/man7/libpipewire-module-rtp-session.7.gz
%{_mandir}/man7/libpipewire-module-rtp-sink.7.gz
%{_mandir}/man7/libpipewire-module-rtp-source.7.gz
%{_mandir}/man7/libpipewire-module-session-manager.7.gz
%{_mandir}/man7/libpipewire-module-snapcast-discover.7.gz
%{_mandir}/man7/libpipewire-module-vban-recv.7.gz
%{_mandir}/man7/libpipewire-module-vban-send.7.gz
%{_mandir}/man7/libpipewire-module-x11-bell.7.gz
%{_mandir}/man7/libpipewire-module-zeroconf-discover.7.gz
%{_mandir}/man7/libpipewire-modules.7.gz


%files gstreamer
%{_libdir}/gstreamer-1.0/libgstpipewire.*

%files devel
%{_libdir}/libpipewire-%{apiversion}.so
%{_includedir}/pipewire-%{apiversion}/
%{_includedir}/spa-%{spaversion}/
%{_libdir}/pkgconfig/libpipewire-%{apiversion}.pc
%{_libdir}/pkgconfig/libspa-%{spaversion}.pc

%files doc
%doc README.md NEWS
%{_datadir}/doc/pipewire/html

%files utils
%{_bindir}/pw-cat
%{_bindir}/pw-cli
%{_bindir}/pw-config
%{_bindir}/pw-container
%{_bindir}/pw-dot
%{_bindir}/pw-dsdplay
%{_bindir}/pw-dump
%{_bindir}/pw-encplay
%{_bindir}/pw-link
%{_bindir}/pw-loopback
%{_bindir}/pw-metadata
%{_bindir}/pw-mididump
%{_bindir}/pw-midiplay
%{_bindir}/pw-midirecord
%{_bindir}/pw-mon
%{_bindir}/pw-play
%{_bindir}/pw-profiler
%{_bindir}/pw-record
%{_bindir}/pw-reserve
%{_bindir}/pw-top
%{_mandir}/man1/pw-cat.1*
%{_mandir}/man1/pw-cli.1*
%{_mandir}/man1/pw-config.1*
%{_mandir}/man1/pw-container.1*
%{_mandir}/man1/pw-dot.1*
%{_mandir}/man1/pw-dump.1*
%{_mandir}/man1/pw-link.1*
%{_mandir}/man1/pw-loopback.1*
%{_mandir}/man1/pw-metadata.1*
%{_mandir}/man1/pw-mididump.1*
%{_mandir}/man1/pw-mon.1*
%{_mandir}/man1/pw-profiler.1*
%{_mandir}/man1/pw-reserve.1*
%{_mandir}/man1/pw-top.1*
%{_mandir}/man1/spa-acp-tool.1*
%{_mandir}/man1/spa-inspect.1*
%{_mandir}/man1/spa-json-dump.1*
%{_mandir}/man1/spa-monitor.1*
%{_mandir}/man1/spa-resample.1*

%{_bindir}/spa-acp-tool
%{_bindir}/spa-inspect
%{_bindir}/spa-json-dump
%{_bindir}/spa-monitor
%{_bindir}/spa-resample

%if %{with alsa}
%files alsa
%{_libdir}/alsa-lib/libasound_module_pcm_pipewire.so
%{_libdir}/alsa-lib/libasound_module_ctl_pipewire.so
%{_datadir}/alsa/alsa.conf.d/50-pipewire.conf
%{_datadir}/alsa/alsa.conf.d/99-pipewire-default.conf
%config(noreplace) %{_sysconfdir}/alsa/conf.d/50-pipewire.conf
%config(noreplace) %{_sysconfdir}/alsa/conf.d/99-pipewire-default.conf
%endif

%if %{with jack}
%files jack-audio-connection-kit-libs
%{_bindir}/pw-jack
%{_mandir}/man1/pw-jack.1*
%{_libdir}/pipewire-%{apiversion}/jack/libjack.so.*
%{_libdir}/pipewire-%{apiversion}/jack/libjacknet.so.*
%{_libdir}/pipewire-%{apiversion}/jack/libjackserver.so.*
%{_datadir}/pipewire/jack.conf
%{_mandir}/man5/pipewire-jack.conf.5*

%files jack-audio-connection-kit
%{_sysconfdir}/ld.so.conf.d/pipewire-jack-%{_arch}.conf

%files jack-audio-connection-kit-devel
%{_includedir}/jack/
%{_libdir}/pipewire-%{apiversion}/jack/libjack.so
%{_libdir}/pipewire-%{apiversion}/jack/libjacknet.so
%{_libdir}/pipewire-%{apiversion}/jack/libjackserver.so
%{_libdir}/pkgconfig/jack.pc
%endif

%if %{with jackserver_plugin}
%files plugin-jack
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-jack-tunnel.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-jackdbus-detect.so
%{_libdir}/spa-%{spaversion}/jack/
%endif

%if %{with libcamera_plugin}
%files plugin-libcamera
%{_libdir}/spa-%{spaversion}/libcamera/
%endif

%if %{with vulkan}
%files plugin-vulkan
%{_libdir}/spa-%{spaversion}/vulkan/
%endif

%if %{with pulse}
%files pulseaudio
%{_bindir}/pipewire-pulse
%{_userunitdir}/pipewire-pulse.*
%{_datadir}/pipewire/pipewire-pulse.conf
%dir %{_datadir}/pipewire/pipewire-pulse.conf.d/
%{_datadir}/pipewire/pipewire-pulse.conf.avail/20-upmix.conf
%{_datadir}/glib-2.0/schemas/org.freedesktop.pulseaudio.gschema.xml
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-protocol-pulse.so
%{_mandir}/man1/pipewire-pulse.1*
%{_mandir}/man5/pipewire-pulse.conf.5.gz
%{_mandir}/man7/pipewire-pulse-module-alsa-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-alsa-source.7.gz
%{_mandir}/man7/pipewire-pulse-module-always-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-combine-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-device-manager.7.gz
%{_mandir}/man7/pipewire-pulse-module-device-restore.7.gz
%{_mandir}/man7/pipewire-pulse-module-echo-cancel.7.gz
%{_mandir}/man7/pipewire-pulse-module-gsettings.7.gz
%{_mandir}/man7/pipewire-pulse-module-jackdbus-detect.7.gz
%{_mandir}/man7/pipewire-pulse-module-ladspa-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-ladspa-source.7.gz
%{_mandir}/man7/pipewire-pulse-module-loopback.7.gz
%{_mandir}/man7/pipewire-pulse-module-native-protocol-tcp.7.gz
%{_mandir}/man7/pipewire-pulse-module-null-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-pipe-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-pipe-source.7.gz
%{_mandir}/man7/pipewire-pulse-module-raop-discover.7.gz
%{_mandir}/man7/pipewire-pulse-module-remap-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-remap-source.7.gz
%{_mandir}/man7/pipewire-pulse-module-roc-sink-input.7.gz
%{_mandir}/man7/pipewire-pulse-module-roc-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-roc-source.7.gz
%{_mandir}/man7/pipewire-pulse-module-rtp-recv.7.gz
%{_mandir}/man7/pipewire-pulse-module-rtp-send.7.gz
%{_mandir}/man7/pipewire-pulse-module-simple-protocol-tcp.7.gz
%{_mandir}/man7/pipewire-pulse-module-stream-restore.7.gz
%{_mandir}/man7/pipewire-pulse-module-switch-on-connect.7.gz
%{_mandir}/man7/pipewire-pulse-module-tunnel-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-tunnel-source.7.gz
%{_mandir}/man7/pipewire-pulse-module-virtual-sink.7.gz
%{_mandir}/man7/pipewire-pulse-module-virtual-source.7.gz
%{_mandir}/man7/pipewire-pulse-module-x11-bell.7.gz
%{_mandir}/man7/pipewire-pulse-module-zeroconf-discover.7.gz
%{_mandir}/man7/pipewire-pulse-module-zeroconf-publish.7.gz
%{_mandir}/man7/pipewire-pulse-modules.7.gz
%endif

%if %{with v4l2}
%files v4l2
%{_bindir}/pw-v4l2
%{_libdir}/pipewire-%{apiversion}/v4l2/libpw-v4l2.so
%{_mandir}/man1/pw-v4l2.1*
%endif

%files module-x11
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-x11-bell.so

%if %{with ffado}
%files module-ffado
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-ffado-driver.so
%endif

%if %{with roc}
%files module-roc
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-roc-sink.so
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-roc-source.so
%endif

%if %{with libmysofa}
%files module-filter-chain-sofa
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-filter-chain-sofa.so
%endif

%if %{with lv2}
%files module-filter-chain-lv2
%{_libdir}/pipewire-%{apiversion}/libpipewire-module-filter-chain-lv2.so
%endif

%files config-rates
%{_datadir}/pipewire/pipewire.conf.d/10-rates.conf

%files config-upmix
%{_datadir}/pipewire/pipewire.conf.d/20-upmix.conf
%{_datadir}/pipewire/client.conf.d/20-upmix.conf
%{_datadir}/pipewire/client-rt.conf.d/20-upmix.conf
%if %{with pulse}
%{_datadir}/pipewire/pipewire-pulse.conf.d/20-upmix.conf
%endif

%changelog
* Tue Nov 26 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.7-1
- Update version to 1.2.7 

* Wed Oct 23 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.6-1
- Update version to 1.2.6

* Fri Sep 27 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.5-1
- Update version to 1.2.5
- Add config packages

* Thu Sep 19 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.4-1
- Update version to 1.2.4
- Add Recommends: pipewire-plugin-libcamera for MIPI camera support

* Thu Aug 22 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.3-1
- Update version to 1.2.3

* Sun Aug 04 2024 Yaakov Selkowitz <yselkowi@redhat.com> - 1.2.1-3
- pipewire-jack-libs Requires pipewire-jack on RHEL

* Fri Jul 19 2024 Fedora Release Engineering <releng@fedoraproject.org> - 1.2.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_41_Mass_Rebuild

* Fri Jul 12 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.1-1
- Update version to 1.2.1

* Mon Jul 1 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.0-3
- Add patch for Ardour export regresssion.

* Mon Jul 1 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.0-2
- Add patch for KODI regresssion.

* Thu Jun 27 2024 Wim Taymans <wtaymans@redhat.com> - 1.2.0-1
- Update version to 1.2.0

* Tue Jun 18 2024 Wim Taymans <wtaymans@redhat.com> - 1.1.83-1
- Update version to 1.1.83

* Fri May 24 2024 Wim Taymans <wtaymans@redhat.com> - 1.1.82-1
- Update version to 1.1.82

* Thu May 23 2024 Peter Robinson <pbrobinson@fedoraproject.org> - 1.1.81-2
- Rebuild for libcamera 0.3

* Thu May 16 2024 Wim Taymans <wtaymans@redhat.com> - 1.1.81-1
- Update version to 1.1.81

* Thu May 09 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.6-1
- Update version to 1.0.6

* Tue Apr 23 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.5-2
- Enable ROC again

* Mon Apr 15 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.5-1
- Update version to 1.0.5

* Wed Mar 13 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.4-2
- Configure server, client and rlimit priorities to be the same as JACK.

* Wed Mar 13 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.4-1
- Update version to 1.0.4

* Tue Feb 13 2024 Yaakov Selkowitz <yselkowi@redhat.com> - 1.0.3-2
- Use webrtc-audio-processing-1 on F40 and RHEL 10

* Fri Feb 02 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.3-1
- Update version to 1.0.3

* Wed Jan 31 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.2-1
- Update version to 1.0.2

* Thu Jan 25 2024 Fedora Release Engineering <releng@fedoraproject.org> - 1.0.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Sun Jan 21 2024 Fedora Release Engineering <releng@fedoraproject.org> - 1.0.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_40_Mass_Rebuild

* Thu Jan 11 2024 Wim Taymans <wtaymans@redhat.com> - 1.0.1-1
- Update version to 1.0.1
- Add patch to support libcamera 0.2

* Thu Dec 14 2023 Wim Taymans <wtaymans@redhat.com> - 1.0.0-2
- Add patch to avoid crash in deviceprovider.

* Sun Nov 26 2023 Wim Taymans <wtaymans@redhat.com> - 1.0.0-1
- Update version to 1.0.0
- Disable ROC until updated in Fedora.

* Thu Nov 16 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.85-1
- Update version to 0.3.85

* Wed Nov 15 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.84-5
- Disable libcamera in RHEL 10

* Tue Nov 14 2023 Peter Robinson <pbrobinson@fedoraproject.org> - 0.3.84-4
- Enable support for the lc3 bluetooth codec

* Thu Nov 09 2023 Hector Martin <marcan@fedoraproject.org> - 0.3.84-3
- Create and own /usr/share/pipewire/pipewire-pulse.conf.d

* Mon Nov 06 2023 Hector Martin <marcan@fedoraproject.org> - 0.3.84-2
- Create and own /usr/share/pipewire/pipewire.conf.d

* Thu Nov 02 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.84-1
- Update version to 0.3.84

* Mon Oct 23 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.83-2
- Apply patches to fix openal delay and echo-cancel distortion

* Thu Oct 19 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.83-1
- Update version to 0.3.83

* Mon Oct 16 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.82-2
- Add patch for device detection for asahi linux.
- Add patch to avoid crash in ALSA.

* Fri Oct 13 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.82-1
- Update version to 0.3.82

* Fri Oct 6 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.81-1
- Update version to 0.3.81

* Thu Sep 14 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.80-1
- Update version to 0.3.80
- Revert webrtc echo-cancel updates until fedora has newer version.

* Tue Aug 29 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.79-1
- Update version to 0.3.79

* Tue Aug 22 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.78-1
- Update version to 0.3.78

* Tue Aug 08 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.77-3
- Add patch to avoid duplicate sinks and sources.

* Mon Aug 07 2023 Sandro Bonazzola <sbonazzo@redhat.com> - 0.3.77-2
- Explicitly require pipewire-jack-audio-connection-kit-libs for pipewire-plugin-jack

* Fri Aug 04 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.77-1
- Update version to 0.3.77

* Sun Jul 30 2023 Javier Martinez Canillas <javierm@redhat.com>  0.3.76-2
- Rebuild for libcamera 0.1.0 bump

* Fri Jul 28 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.76-1
- Update version to 0.3.76

* Fri Jul 21 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.75-1
- Update version to 0.3.75

* Fri Jul 21 2023 Fedora Release Engineering <releng@fedoraproject.org> - 0.3.74-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Wed Jul 12 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.74-1
- Update version to 0.3.74

* Thu Jul 06 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.73-1
- Update version to 0.3.73
- Fixes rhbz#2156003 Split out lv2 and sofa filter-chain packages.
- Split out vulkan plugin and roc module

* Thu Jun 29 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.72-2
- Move the ffado driver to module-ffado
  Fixes rhbz#2218481

* Mon Jun 26 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.72-1
- Update version to 0.3.72
- The jack libraries and ld.so override were split so that jack can
  be installed together with the pipewire-jack libraries and pw-jack.

* Thu Jun 15 2023 Yaakov Selkowitz <yselkowi@redhat.com> - 0.3.71-4
- Disable libmysofa, lv2, roc in RHEL builds

* Tue May 23 2023 Yaakov Selkowitz <yselkowi@redhat.com> - 0.3.71-3
- Move JACK modules to plugin-jack subpackage

* Thu May 18 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.71-2
- Add patch to fix JACK buffersize updates

* Wed May 17 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.71-1
- Update version to 0.3.71

* Thu Apr 20 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.70-1
- Update version to 0.3.70

* Tue Apr 18 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.69-2
- Add 3 useful patches.

* Thu Apr 13 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.69-1
- Update version to 0.3.69

* Tue Apr 11 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.68-2
- Add 2 patches for some critical bugs.

* Thu Apr 6 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.68-1
- Update version to 0.3.68
- Enable gstreamer-device-provider (rhbz#2183691)

* Thu Mar 9 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.67-1
- Update version to 0.3.67

* Thu Feb 16 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.66-1
- Update version to 0.3.66

* Sat Jan 28 2023 Stefan Bluhm <stefan.bluhm@clacee.eu> - 0.3.65-3
- Added missing build dependency

* Thu Jan 26 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.65-2
- Add NEWS file (rhbz#2032237)

* Thu Jan 26 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.65-1
- Update version to 0.3.65

* Thu Jan 19 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.64-3
- Add patch to avoid DSP mixing issues with AVX in filter-chain.
- Add patch to revert API breakage with deprecated symbols.
- Add patch to fix scaling overflow that could cause stuttering.

* Tue Jan 17 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.64-2
- Re-enabled roc-toolkit support.

* Thu Jan 12 2023 Wim Taymans <wtaymans@redhat.com> - 0.3.64-1
- Update version to 0.3.64
- Disable ROC again until 0.2 support is merged in fedora.

* Sun Jan 01 2023 Mamoru TASAKA <mtasaka@fedoraproject.org> - 0.3.63-2
- Rebuild for new libcamera again

* Thu Dec 15 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.63-1
- Update version to 0.3.63

* Tue Dec 13 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.62-3
- Add patch to fix distorted sound on AVX2 in some cases.

* Mon Dec 12 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.62-2
- Package X11 bell support separately
  Fixes rhbz#2152385

* Fri Dec 09 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.62-1
- Update version to 0.3.62

* Wed Dec 07 2022 Mamoru TASAKA <mtasaka@fedoraproject.org> - 0.3.61-2
- Rebuild for new libcamera

* Thu Nov 24 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.61-1
- Update version to 0.3.61

* Thu Nov 17 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.60-5
- Add patch to fix sound in qemu.

* Tue Nov 15 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.60-4
- Add patch to avoid crashes when switching profiles

* Thu Nov 10 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.60-3
- Add patch to make Telegram playback work again

* Thu Nov 10 2022 Neal Gompa <ngompa@fedoraproject.org> - 0.3.60-2
- Restore libusb support

* Thu Nov 10 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.60-1
- Update version to 0.3.60

* Mon Oct 24 2022 Jaroslav Škarvada <jskarvad@redhat.com> - 0.3.59-3
- Enabled roc-toolkit support
  Resolves: rhbz#2041189

* Fri Oct 21 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.59-2
- Add a patch to fix midi processing in some cases.
- Add a patch to fix crash when exiting some JACK apps such as
  Ardour7.
- Add a patch to fix a crash when switching bluetooth profiles.
- Add a patch to fix bluetooth source switching between drivers.

* Fri Sep 30 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.59-1
- Update version to 0.3.59

* Thu Sep 22 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.58-3
- Add patch to fix ffmpeg capture and other stutterings.

* Mon Sep 19 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.58-2
- Add patch to fix stuttering in Teamspeak.

* Thu Sep 15 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.58-1
- Update version to 0.3.58

* Fri Sep 2 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.57-1
- Update version to 0.3.57
- Add systemd BuildRequires
- Fix lv2 include path

* Fri Jul 22 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.3.56-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Tue Jul 19 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.56-1
- Update version to 0.3.56

* Tue Jul 12 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.55-2
- Add patch to avoid crash in JACK.

* Tue Jul 12 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.55-1
- Update version to 0.3.55

* Thu Jul 07 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.54-1
- Update version to 0.3.54

* Mon Jul 4 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.53-4
- Add channel remap patch.

* Mon Jul 4 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.53-3
- Add patch to fix speaker-test.
- Add patch to fix noise in resampler.

* Fri Jul 1 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.53-2
- Add patch to avoid crash in audioconvert (mpv)

* Thu Jun 30 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.53-1
- Update version to 0.3.53

* Thu Jun 23 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.52-4
- Add patch to remove 44.1KHz from samplerates
- See rhbz#2096193

* Wed Jun 15 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.52-3
- Add patch to fix stuttering in TeamSpeak.
- Inc baserel to 3, previous build was accidentally done with 2
  instead of 1.

* Thu Jun 09 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.52-1
- Update version to 0.3.52
- Disable LC3plus codec.

* Thu May 19 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.51-2
- Add pulseaudio-utils as Requires for pipewire-pulseaudio

* Thu Apr 28 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.51-1
- Update version to 0.3.51

* Wed Apr 13 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.50-1
- Update version to 0.3.50

* Tue Mar 29 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.49-1
- Update version to 0.3.49
- libusb was removed from f37

* Thu Mar 3 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.48-1
- Update version to 0.3.48

* Fri Feb 18 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.47-1
- Update version to 0.3.47

* Thu Feb 17 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.46-1
- Update version to 0.3.46

* Mon Feb 7 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.45-2
- Add patch for kernels with CONFIG_SND_VERBOSE_PROCFS=n
- Add patch to make Musescore work again

* Thu Feb 3 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.45-1
- Update version to 0.3.45

* Thu Jan 27 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.44-1
- Update version to 0.3.44

* Tue Jan 25 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.43-5
- Add more patches to avoid segfaults in bluez5

* Fri Jan 21 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.3.43-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Tue Jan 18 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.43-3
- Add patch to avoid segfault in bluez5 (rhbz#2041481)

* Mon Jan 17 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.43-2
- Add patch to avoid segfault in bluez5 (rhbz#2041481)

* Wed Jan 5 2022 Wim Taymans <wtaymans@redhat.com> - 0.3.43-1
- Update version to 0.3.43

* Thu Dec 16 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.42-1
- Update version to 0.3.42

* Mon Dec 13 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.41-1
- Update version to 0.3.41

* Thu Nov 11 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.40-1
- Update version to 0.3.40 and media-session 0.4.1
- Enable tests for s390x again

* Tue Nov 09 2021 Peter Hutterer <peter.hutterer@redhat.com> - 0.3.39-3
- Don't build media-session on F35, it's a separate package now, see #2016247

* Wed Oct 27 2021 Peter Hutterer <peter.hutterer@redhat.com> - 0.3.39-2
- Don't build media-session on F36, it's a separate package now, see #2016247
- Remove versioned systemd dependency, 184 was released in 2012

* Thu Oct 21 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.39-1
- Update version to 0.3.39

* Wed Oct 13 2021 Neal Gompa <ngompa@fedoraproject.org> - 0.3.38-2
- Fix libcamera bcond to work properly in RHEL10+ and F36+

* Thu Sep 30 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.38-1
- Update version to 0.3.38

* Wed Sep 29 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.37-3
- Rebuild for new libcamera

* Thu Sep 23 2021 Javier Martinez Canillas <javierm@redhat.com> - 0.3.37-2
- Enable libcamera SPA plugin

* Thu Sep 23 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.37-1
- Update version to 0.3.37

* Thu Sep 16 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.36-2
- Update version to 0.3.36

* Thu Sep 16 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.36-1
- Update to 0.3.36
- Do systemd post install of pipewire-media-session.service

* Thu Sep 09 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.35-2
- Add patch to fix passthrough check.

* Thu Sep 09 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.35-1
- Update to 0.3.35

* Mon Aug 30 2021 Neal Gompa <ngompa@fedoraproject.org> - 0.3.34-2
- Add preference for WirePlumber for session manager (#1989959)

* Thu Aug 26 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.34-1
- Update to 0.3.34

* Wed Aug 11 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.33-3
- Add more upstream patches.

* Tue Aug 10 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.33-2
- Add patch to fix default device persistence.

* Thu Aug 5 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.33-1
- Update to 0.3.33

* Thu Aug 5 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.32-4
- Add media-session Conflicts: with older pipewire versions, they can't be
  installed at the same time because they both contain the media-session binary.

* Fri Jul 23 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.3.32-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Wed Jul 21 2021 Neal Gompa <ngompa@fedoraproject.org> - 0.3.32-2
- Add conditional for media-session subpackage

* Tue Jul 20 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.32-1
- Update to 0.3.32

* Thu Jul 15 2021 Peter Hutterer <peter.hutterer@redhat.com> - 0.3.31-4
- Enable media-session.service, requires fedora-release-35-0.10 to enable the
  service by default (#1976006).

* Mon Jul 05 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.31-3
- Add "Conflicts: pipewire-session-manager" to pipewire-media-session
  to enforce one implementation of the session manager at a time

* Mon Jun 28 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.31-2
- Fix session manager path

* Mon Jun 28 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.31-1
- Update to 0.3.31

* Fri Jun 25 2021 Peter Hutterer <peter.hutterer@redhat.com> - 0.3.30-5
- Split media-session into a subpackage and Require it through a virtual
  Provides from the main pipewire package

* Tue Jun 15 2021 Łukasz Patron <priv.luk@gmail.com> - 0.3.30-4
- Add patch for setting node description for module-combine-sink

* Tue Jun 15 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.30-3
- Rebuild for Gstreamer update

* Thu Jun 10 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.30-2
- Add ALSA UCM 1.2.5 compatibility fixes

* Wed Jun 09 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.30-1
- Update to 0.3.30

* Fri Jun 04 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.29-2
- Add some important patches.

* Thu Jun 03 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.29-1
- Update to 0.3.29

* Mon May 17 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.28-1
- Update to 0.3.28

* Mon May 10 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.27-2
- Add patch to fix volume issues.

* Thu May 06 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.27-1
- Update to 0.3.27

* Thu Apr 29 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.26-4
- Add some more important upstream patches.

* Mon Apr 26 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.26-3
- Add some important upstream patches.

* Sat Apr 24 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.26-2
- Disable JACK server integration on RHEL

* Thu Apr 22 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.26-1
- Update to 0.3.26

* Tue Apr 20 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.25-2
- Add jack-devel subpackage, enable JACK support on RHEL 9+ (#1945951)

* Tue Apr 06 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.25-1
- Update to 0.3.25

* Thu Mar 25 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.24-4
- Apply some critical upstream patches

* Thu Mar 25 2021 Kalev Lember <klember@redhat.com> - 0.3.24-3
- Fix RHEL build

* Thu Mar 25 2021 Kalev Lember <klember@redhat.com> - 0.3.24-2
- Move individual config files to the subpackages that make use of them

* Thu Mar 18 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.24-1
- Update to 0.3.24

* Tue Mar 09 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.23-2
- Add patch to enable UCM Microphones

* Thu Mar 04 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.23-1
- Update to 0.3.23

* Wed Feb 24 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.22-7
- Add patch to sample destroy use after free

* Wed Feb 24 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.22-6
- Add patch for jack names

* Mon Feb 22 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.22-5
- Add some critical patches

* Fri Feb 19 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.22-4
- Replace more PulseAudio modules on upgrade in F34+

* Fri Feb 19 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.22-3
- Replace ALSA plugins and PulseAudio modules on upgrade in F34+

* Fri Feb 19 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.22-2
- Replace JACK and PulseAudio on upgrade in F34+
  Reference: https://fedoraproject.org/wiki/Changes/DefaultPipeWire

* Thu Feb 18 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.22-1
- Update to 0.3.22
- disable sdl2 examples

* Thu Feb 04 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.21-2
- Add some upstream patches
- Fixes rhbz#1925138

* Wed Feb 03 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.21-1
- Update to 0.3.21

* Wed Jan 27 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.3.20-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Wed Jan 20 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.20-1
- Update to 0.3.20
- Fix baseversion
- Add gettext dependency

* Tue Jan 12 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.19-4
- Rework conditional build to fix ELN builds

* Sat Jan  9 2021 Evan Anderson <evan@eaanderson.com> - 0.3.19-3
- Add LDAC and AAC dependency to enhance Bluetooth support

* Thu Jan  7 2021 Neal Gompa <ngompa13@gmail.com> - 0.3.19-2
- Obsolete useless libjack subpackage with jack-audio-connection-kit subpackage

* Tue Jan 5 2021 Wim Taymans <wtaymans@redhat.com> - 0.3.19-1
- Update to 0.3.19
- Add ncurses-devel BR

* Tue Dec 15 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.18-1
- Update to 0.3.18

* Fri Nov 27 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.17-2
- Add some more Provides: for pulseaudio

* Thu Nov 26 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.17-1
- Update to 0.3.17

* Tue Nov 24 2020 Neal Gompa <ngompa13@gmail.com> - 0.3.16-4
- Add 'pulseaudio-daemon' Provides + Conflicts to pipewire-pulseaudio
- Remove useless ldconfig macros that expand to nothing

* Fri Nov 20 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.16-3
- Fix Requires for pipewire-pulseaudio
- Fixes rhbz#1899945

* Fri Nov 20 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.16-2
- Add patch to fix crash in kwin, Fixes rhbz#1899826

* Thu Nov 19 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.16-1
- Update to 0.3.16

* Wed Nov 4 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.15-2
- Add patch to fix screen sharing for old clients

* Wed Nov 4 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.15-1
- Update to 0.3.15

* Sun Nov 1 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.14-2
- Add some pulse server patches

* Fri Oct 30 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.14-1
- Update to 0.3.14

* Sun Oct 18 2020 Neal Gompa <ngompa13@gmail.com> - 0.3.13-6
- Fix jack and pulseaudio subpackages to generate dependencies properly

* Tue Oct 13 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.13-5
- Disable device provider for now
- Fixes rhbz#1884260

* Thu Oct 1 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.13-4
- Add patches for some crasher bugs
- Fixes rhbz#1884177

* Tue Sep 29 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.13-3
- Add patch to improve pulse compatibility

* Mon Sep 28 2020 Jeff Law <law@redhat.com> - 0.3.13-2
- Re-enable LTO as upstream GCC target/96939 has been fixed

* Mon Sep 28 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.13-1
- Update to 0.3.13

* Fri Sep 18 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.12-1
- Update to 0.3.12

* Fri Sep 11 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.11-2
- Add some patches to improve pulse compatibility

* Thu Sep 10 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.11-1
- Update to 0.3.11

* Mon Aug 17 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.10-1
- Update to 0.3.10

* Tue Aug 04 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.9-1
- Update to 0.3.9

* Tue Aug 04 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.8-3
- Add patch to avoid segfault when iterating ports.
- Fixes #1865827

* Wed Jul 29 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.8-2
- Add patch for fix chrome audio hicups
- Add patch for infinite loop in device add/remove
- Disable LTO on armv7

* Tue Jul 28 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.8-1
- Update to 0.3.8

* Tue Jul 21 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.7-2
- Add patch to avoid crash when clearing metadata

* Tue Jul 21 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.7-1
- Update to 0.3.7

* Wed Jun 10 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.6-2
- Use systemd presets to enable pipewire.socket
- Remove duplicate hardened_build flags
- Add meson build again
- Fix -gstreamer subpackage Requires:

* Wed Jun 10 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.6-1
- Update to 0.3.6
- Add new man pages
- Only build vulkan/pulse/jack in Fedora.

* Mon May 11 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.5-1
- Update to 0.3.5

* Fri May 01 2020 Adam Williamson <awilliam@redhat.com> - 0.3.4-2
- Suppress library provides from pipewire-lib{pulse,jack}

* Thu Apr 30 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.4-1
- Update to 0.3.4
- Add 2 more packages that replace libjack and libpulse

* Tue Mar 31 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.2-3
- Add patch to unsubscribe unused sequencer ports
- Change config to only disable bluez5 handling by default.

* Mon Mar 30 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.2-2
- Add config to disable alsa and bluez5 handling by default.

* Thu Mar 26 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.2-1
- Update to 0.3.2

* Fri Mar 06 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.1-1
- Update to 0.3.1

* Thu Feb 20 2020 Wim Taymans <wtaymans@redhat.com> - 0.3.0-1
- Update to 0.3.0
- Add libpulse-simple-pw.so

* Wed Feb 19 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.97-1
- Update to 0.2.97
- Change download link

* Tue Feb 18 2020 Kalev Lember <klember@redhat.com> - 0.2.96-2
- Rename subpackages so that libjack-pw is in -libjack
  and libpulse-pw is in -libpulse
- Split libspa-jack.so out to -plugin-jack subpackage
- Avoid hard-requiring the daemon from any of the library subpackages

* Tue Feb 11 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.96-1
- Update to 0.2.96
- Split -gstreamer package
- Enable aarch64 tests again

* Fri Feb 07 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.95-1
- Update to 0.2.95
- Disable test on aarch64 for now

* Wed Feb 05 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.94-1
- Update to 0.2.94
- Move pipewire modules to -libs
- Add pw-profiler
- Add libsndfile-devel as a BR

* Thu Jan 30 2020 Fedora Release Engineering <releng@fedoraproject.org> - 0.2.92-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_32_Mass_Rebuild

* Tue Jan 28 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.93-1
- Update to 0.2.93

* Wed Jan 15 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.92-1
- Update to 0.2.92

* Wed Jan 15 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.91-1
- Update to 0.2.91
- Add some more BR
- Fix some unit tests

* Mon Jan 13 2020 Wim Taymans <wtaymans@redhat.com> - 0.2.90-1
- Update to 0.2.90

* Thu Nov 28 2019 Kalev Lember <klember@redhat.com> - 0.2.7-2
- Move spa plugins to -libs subpackage

* Thu Sep 26 2019 Wim Taymans <wtaymans@redhat.com> - 0.2.7-1
- Update to 0.2.7

* Mon Sep 16 2019 Kalev Lember <klember@redhat.com> - 0.2.6-5
- Don't require the daemon package for -devel subpackage
- Move pipewire.conf man page to the daemon package

* Fri Jul 26 2019 Fedora Release Engineering <releng@fedoraproject.org> - 0.2.6-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_31_Mass_Rebuild

* Wed Jun 19 2019 Wim Taymans <wtaymans@redhat.com> - 0.2.6-3
- Add patch to reuse fd in pipewiresrc
- Add patch for device provider
- Add patch to disable extra security checks until portal is fixed.

* Tue Jun 04 2019 Kalev Lember <klember@redhat.com> - 0.2.6-2
- Split libpipewire and the gstreamer plugin out to -libs subpackage

* Wed May 22 2019 Wim Taymans <wtaymans@redhat.com> - 0.2.6-1
- Update to 0.2.6
- Add patch for alsa-lib 1.1.9 include path

* Sat Feb 02 2019 Fedora Release Engineering <releng@fedoraproject.org> - 0.2.5-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_30_Mass_Rebuild

* Fri Jan 04 2019 Wim Taymans <wtaymans@redhat.com> - 0.2.5-2
- Add patch to avoid invalid conversion error with C++ compilers

* Thu Nov 22 2018 Wim Taymans <wtaymans@redhat.com> - 0.2.5-1
- Update to 0.2.5

* Thu Nov 22 2018 Wim Taymans <wtaymans@redhat.com> - 0.2.4-1
- Update to 0.2.4

* Thu Oct 18 2018 Wim Taymans <wtaymans@redhat.com> - 0.2.3-2
- Add systemd socket activation

* Thu Aug 30 2018 Wim Taymans <wtaymans@redhat.com> - 0.2.3-1
- Update to 0.2.3

* Tue Jul 31 2018 Wim Taymans <wtaymans@redhat.com> - 0.2.2-1
- Update to 0.2.2

* Fri Jul 20 2018 Wim Taymans <wtaymans@redhat.com> - 0.2.1-1
- Update to 0.2.1

* Tue Jul 17 2018 Wim Taymans <wtaymans@redhat.com> - 0.2.0-1
- Update to 0.2.0

* Fri Jul 13 2018 Fedora Release Engineering <releng@fedoraproject.org> - 0.1.9-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Tue Feb 27 2018 Wim Taymans <wtaymans@redhat.com> - 0.1.9-1
- Update to 0.1.9

* Fri Feb 09 2018 Fedora Release Engineering <releng@fedoraproject.org> - 0.1.8-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_28_Mass_Rebuild

* Sat Feb 03 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 0.1.8-2
- Switch to %%ldconfig_scriptlets

* Tue Jan 23 2018 Wim Taymans <wtaymans@redhat.com> - 0.1.8-1
- Update to 0.1.8

* Fri Nov 24 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.7-1
- Update to 0.1.7
- Add to build when memfd_create is already defined

* Fri Nov 03 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.6-1
- Update to 0.1.6

* Tue Sep 19 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.5-2
- Add patch to avoid segfault when probing

* Tue Sep 19 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.5-1
- Update to 0.1.5

* Thu Sep 14 2017 Kalev Lember <klember@redhat.com> - 0.1.4-3
- Rebuilt for GNOME 3.26.0 megaupdate

* Fri Sep 08 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.4-2
- Install SPA hooks

* Wed Aug 23 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.4-1
- Update to 0.1.4

* Wed Aug 09 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.3-1
- Update to 0.1.3

* Tue Jul 04 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.2-1
- Update to 0.1.2
- Added more build requirements
- Make separate doc package

* Mon Jun 26 2017 Wim Taymans <wtaymans@redhat.com> - 0.1.1-1
- Update to 0.1.1
- Add dbus-1 to BuildRequires
- change libs-devel to -devel

* Wed Sep 9 2015 Wim Taymans <wtaymans@redhat.com> - 0.1.0-2
- Fix BuildRequires to use pkgconfig, add all dependencies found in configure.ac
- Add user and groups  if needed
- Add license to %%licence

* Tue Sep 1 2015 Wim Taymans <wtaymans@redhat.com> - 0.1.0-1
- First version
