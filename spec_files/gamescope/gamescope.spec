%global libliftoff_minver 0.4.1

Name:           gamescope
Version:        3.13.19
Release:    	1%{?dist}.bazzite.{{{ git_dir_version }}}
Summary:        Micro-compositor for video games on Wayland

License:        BSD
URL:            https://github.com/ValveSoftware/gamescope

# Create stb.pc to satisfy dependency('stb')
Source1:        stb.pc
Source2:        chimeraos.patch
Source3:        crashfix.patch
Source4:        add_720p_var.patch
Source5:        touch_gestures_env.patch
Source6:        legion_go.patch

BuildRequires:  meson >= 0.54.0
BuildRequires:  ninja-build
BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  glm-devel
BuildRequires:  google-benchmark-devel
BuildRequires:  libXmu-devel
BuildRequires:  pkgconfig(libdisplay-info)
BuildRequires:  pkgconfig(x11)
BuildRequires:  pkgconfig(xdamage)
BuildRequires:  pkgconfig(xcomposite)
BuildRequires:  pkgconfig(xrender)
BuildRequires:  pkgconfig(xext)
BuildRequires:  pkgconfig(xfixes)
BuildRequires:  pkgconfig(xxf86vm)
BuildRequires:  pkgconfig(xtst)
BuildRequires:  pkgconfig(xres)
BuildRequires:  pkgconfig(libdrm)
BuildRequires:  pkgconfig(vulkan)
BuildRequires:  pkgconfig(wayland-scanner)
BuildRequires:  pkgconfig(wayland-server)
BuildRequires:  pkgconfig(wayland-protocols) >= 1.17
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  pkgconfig(sdl2)
BuildRequires:  pkgconfig(libpipewire-0.3)
BuildRequires:  (pkgconfig(wlroots) >= 0.17.0 with pkgconfig(wlroots) < 0.18.0)
BuildRequires:  (pkgconfig(libliftoff) >= 0.4.1 with pkgconfig(libliftoff) < 0.5)
BuildRequires:  pkgconfig(libcap)
BuildRequires:  pkgconfig(hwdata)
BuildRequires:  pkgconfig(xwayland)
BuildRequires:  pkgconfig(xcursor)
BuildRequires:  vkroots-devel
BuildRequires:  /usr/bin/glslangValidator
BuildRequires:  git
BuildRequires:  stb_image-devel
BuildRequires:  stb_image_write-devel
BuildRequires:  stb_image_resize-devel

# libliftoff hasn't bumped soname, but API/ABI has changed for 0.2.0 release
Requires:       libliftoff%{?_isa} >= %{libliftoff_minver}
Requires:       xorg-x11-server-Xwayland
Requires:       google-benchmark
Requires:	    gamescope-libs = %{version}-%{release}
Recommends:     mesa-dri-drivers
Recommends:     mesa-vulkan-drivers

%description
%{name} is the micro-compositor optimized for running video games on Wayland.

%package libs
Summary:	libs for %{name}
%description libs
%summary

%prep
git clone --single-branch --branch %{version} https://github.com/ValveSoftware/gamescope.git
cd gamescope
git submodule update --init --recursive
mkdir -p pkgconfig
cp %{SOURCE1} pkgconfig/stb.pc
patch -Np1 < %{SOURCE2}
patch -Np1 < %{SOURCE3}
patch -Np1 < %{SOURCE4}
patch -Np1 < %{SOURCE5}
patch -Np1 < %{SOURCE6}

%build
cd gamescope
export PKG_CONFIG_PATH=pkgconfig
%meson -Dpipewire=enabled -Denable_gamescope=true -Denable_gamescope_wsi_layer=true -Denable_openvr_support=true -Dforce_fallback_for=[]
%meson_build

%install
cd gamescope
%meson_install --skip-subprojects

%files
%license gamescope/LICENSE
%doc gamescope/README.md
%attr(0755, root, root) %caps(cap_sys_nice=eip) %{_bindir}/gamescope

%files libs
%{_libdir}/*.so
%{_datadir}/vulkan/implicit_layer.d/

%changelog
{{{ git_dir_changelog }}}
