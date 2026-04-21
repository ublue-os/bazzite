%global majorversion 1
%global minorversion 6
%global microversion 4

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
%bcond_with ffado
%bcond_with onnx
%else
%bcond_without jackserver_plugin
%bcond_without libmysofa
%bcond_without lv2
%bcond_without roc
%ifarch s390x
%bcond_with ffado
%bcond_with onnx
%elifarch %{ix86}
%bcond_without ffado
%bcond_with onnx
%else
%bcond_without ffado
%bcond_without onnx
%endif
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
# PipeWire is generally MIT but includes plugins using libraries under other licenses.
# See the module specific License for details.
License:        MIT
URL:            https://pipewire.org/
%if 0%{?snapdate}
Source0:        https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/%{gitcommit}/pipewire-%{shortcommit}.tar.gz
%else
Source0:        https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/%{version}/pipewire-%{version}.tar.gz
%endif
Source1:        pipewire.sysusers

## valve patches
Patch10:        bc435841c141ad38768b6cb1a7ad45e8bb13c7d2.patch

## upstream patches

## upstreamable patches

## fedora patches

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
%if (0%{?fedora} && 0%{?fedora} < 44) || (0%{?rhel} && 0%{?rhel} < 11)
BuildRequires:  pkgconfig(webrtc-audio-processing-1)
%else
BuildRequires:  pkgconfig(webrtc-audio-processing-2)
%endif
BuildRequires:  libusb1-devel
BuildRequires:  readline-devel
BuildRequires:  openssl-devel
BuildRequires:  libcanberra-devel
BuildRequires:  libuv-devel
BuildRequires:  speexdsp-devel
BuildRequires:  systemd-rpm-macros
BuildRequires:  libebur128-devel
BuildRequires:  fftw-devel
BuildRequires:  spandsp-devel

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
# fftw is GPL-2.0-or later, ladpsa is LGPL-2.0-or-later and used in filter-graph.
License:        MIT AND GPL-2.0-or-later AND BSD-2-Clause AND LGPL-2.0-or-later
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
Requires:       %{name}-jack-audio-connection-kit%{?_isa} = %{version}-%{release}
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
License:        MIT AND GPL-2.0-only OR GPL-3.0-only
BuildRequires:  libffado-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description module-ffado
This package contains the FFADO support for PipeWire.
%endif

%if %{with roc}
%package module-roc
Summary:        PipeWire media server ROC support
License:        MIT AND MPL-2.0 AND LGPL-2.1-or-later AND CECILL-C
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
License:        MIT AND BSD-3-Clause
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

%if %{with onnx}
%package module-filter-chain-onnx
Summary:        PipeWire media server ONNX filter-chain support
License:        MIT AND Apache-2.0 AND BSL-1.0 AND BSD-3-Clause
BuildRequires:  onnxruntime-devel
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description module-filter-chain-onnx
This package contains the ONNX support for PipeWire filter-chain.
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

%package config-raop
Summary:        PipeWire configuration enabling the raop module
License:        MIT
Recommends:     %{name}%{?_isa} = %{version}-%{release}
Requires:       %{name}-libs%{?_isa} = %{version}-%{release}

%description config-raop
This package contains the configuration file to enable the RAOP module.

%prep
%autosetup -p1 %{?snapdate:-n %{name}-%{gitcommit}}


%if %{with media-session}
mkdir subprojects/packagefiles
cp %{SOURCE1} subprojects/packagefiles/
%endif

%build
%meson \
    -D docs=enabled -D man=enabled -D gstreamer=enabled -D libsystemd=enabled	\
    -D systemd-user-service=enabled 						\
    -D sdl2=disabled 								\
    -D audiotestsrc=disabled -D videotestsrc=disabled				\
    -D volume=disabled -D bluez5-codec-aptx=disabled 		  		\
    -D bluez5-codec-lc3plus=disabled -D bluez5-codec-lc3=enabled		\
    -D bluez5-codec-ldac-dec=disabled 						\
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
    %{!?with_onnx:-D onnxruntime=disabled}					\
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

# raop config
ln -s ../pipewire.conf.avail/50-raop.conf \
		%{buildroot}%{_datadir}/pipewire/pipewire.conf.d/50-raop.conf

%find_lang %{name}

%check
%meson_test || TESTS_ERROR=$?
if [ "${TESTS_ERROR}" != "" ]; then
echo "test failed"
%{!?tests_nonfatal:exit $TESTS_ERROR}
fi


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
%{_datadir}/pipewire/pipewire.conf.avail/50-raop.conf
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
%{_libdir}/spa-%{spaversion}/filter-graph/libspa-filter-graph.so
%{_libdir}/spa-%{spaversion}/filter-graph/libspa-filter-graph-plugin-builtin.so
%{_libdir}/spa-%{spaversion}/filter-graph/libspa-filter-graph-plugin-ebur128.so
%{_libdir}/spa-%{spaversion}/filter-graph/libspa-filter-graph-plugin-ladspa.so
%{_libdir}/spa-%{spaversion}/support/
%{_libdir}/spa-%{spaversion}/v4l2/
%{_libdir}/spa-%{spaversion}/videoconvert/
%{_libdir}/spa-%{spaversion}/libspa.so
%{_datadir}/pipewire/client.conf
%dir %{_datadir}/pipewire/client.conf.d/
%{_datadir}/pipewire/client.conf.avail/20-upmix.conf
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
%{_mandir}/man7/libpipewire-module-spa-device-factory.7.gz
%{_mandir}/man7/libpipewire-module-spa-device.7.gz
%{_mandir}/man7/libpipewire-module-spa-node-factory.7.gz
%{_mandir}/man7/libpipewire-module-spa-node.7.gz
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
%{_bindir}/pw-midi2play
%{_bindir}/pw-midi2record
%{_bindir}/pw-mon
%{_bindir}/pw-play
%{_bindir}/pw-profiler
%{_bindir}/pw-record
%{_bindir}/pw-reserve
%{_bindir}/pw-sysex
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
%{_libdir}/pkgconfig/jackserver.pc
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
%{_libdir}/spa-%{spaversion}/filter-graph/libspa-filter-graph-plugin-sofa.so
%endif

%if %{with lv2}
%files module-filter-chain-lv2
%{_libdir}/spa-%{spaversion}/filter-graph/libspa-filter-graph-plugin-lv2.so
%endif

%if %{with onnx}
%files module-filter-chain-onnx
%{_libdir}/spa-%{spaversion}/filter-graph/libspa-filter-graph-plugin-onnx.so
%endif

%files config-rates
%{_datadir}/pipewire/pipewire.conf.d/10-rates.conf

%files config-upmix
%{_datadir}/pipewire/pipewire.conf.d/20-upmix.conf
%{_datadir}/pipewire/client.conf.d/20-upmix.conf
%if %{with pulse}
%{_datadir}/pipewire/pipewire-pulse.conf.d/20-upmix.conf
%endif

%files config-raop
%{_datadir}/pipewire/pipewire.conf.d/50-raop.conf

%changelog
%autochangelog
