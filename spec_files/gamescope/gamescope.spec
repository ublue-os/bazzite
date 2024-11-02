%global libliftoff_minver 0.4.1

%global _default_patch_fuzz 2
%global build_timestamp %(date +"%Y%m%d")
%global gamescope_tag 3.15.11

Name:           gamescope
Version:        100.%{gamescope_tag}
Release:        12.bazzite
Summary:        Micro-compositor for video games on Wayland

License:        BSD
URL:            https://github.com/ValveSoftware/gamescope

# Create stb.pc to satisfy dependency('stb')
Source0:        stb.pc

Patch0:         0001-cstdint.patch

# https://hhd.dev/
# https://github.com/ChimeraOS/gamescope
Patch1:         handheld.patch

# https://github.com/ValveSoftware/gamescope/pull/740
Patch2:         740.patch

BuildRequires:  meson >= 0.54.0
BuildRequires:  ninja-build
BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  glm-devel
BuildRequires:  google-benchmark-devel
BuildRequires:  libXmu-devel
BuildRequires:  libXcursor-devel
BuildRequires:  libeis-devel
BuildRequires:  pixman-devel
BuildRequires:  pkgconfig(libdisplay-info)
BuildRequires:  pkgconfig(pixman-1)
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
BuildRequires:  pkgconfig(wayland-server) >= 1.23.0
BuildRequires:  pkgconfig(wayland-protocols) >= 1.17
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  pkgconfig(sdl2)
BuildRequires:  pkgconfig(libpipewire-0.3)
BuildRequires:  pkgconfig(libavif)
BuildRequires:  pkgconfig(wlroots)
BuildRequires:  pkgconfig(libliftoff)
BuildRequires:  pkgconfig(libcap)
BuildRequires:  pkgconfig(hwdata)
BuildRequires:  pkgconfig(lcms2)
BuildRequires:  pkgconfig(luajit)
BuildRequires:  spirv-headers-devel
# Enforce the the minimum EVR to contain fixes for all of:
# CVE-2021-28021 CVE-2021-42715 CVE-2021-42716 CVE-2022-28041 CVE-2023-43898
# CVE-2023-45661 CVE-2023-45662 CVE-2023-45663 CVE-2023-45664 CVE-2023-45666
# CVE-2023-45667
BuildRequires:  stb_image-devel >= 2.28^20231011gitbeebb24-12
# Header-only library: -static is for tracking per guidelines
BuildRequires:  stb_image-static
BuildRequires:  stb_image_resize-devel
BuildRequires:  stb_image_resize-static
BuildRequires:  stb_image_write-devel
BuildRequires:  stb_image_write-static
BuildRequires:  /usr/bin/glslangValidator
BuildRequires:  libdecor-devel
BuildRequires:  libXdamage-devel
BuildRequires:  xorg-x11-server-Xwayland-devel
BuildRequires:  git

# libliftoff hasn't bumped soname, but API/ABI has changed for 0.2.0 release
Requires:       libliftoff%{?_isa} >= %{libliftoff_minver}
Requires:       xorg-x11-server-Xwayland
Requires:       gamescope-libs = %{version}-%{release}
Requires:       gamescope-libs(x86-32) = %{version}-%{release}
Recommends:     mesa-dri-drivers
Recommends:     mesa-vulkan-drivers

%description
%{name} is the micro-compositor optimized for running video games on Wayland.

%package libs
Summary:	libs for %{name}
%description libs
%summary

%prep
# git clone --depth 1 --branch %%{gamescope_tag} %%{url}.git
git clone --depth 1 --branch master %{url}.git
cd gamescope
git submodule update --init --recursive
mkdir -p pkgconfig
cp %{SOURCE0} pkgconfig/stb.pc

# Replace spirv-headers include with the system directory
sed -i 's^../thirdparty/SPIRV-Headers/include/spirv/^/usr/include/spirv/^' src/meson.build

%autopatch -p1

%build
cd gamescope
export PKG_CONFIG_PATH=pkgconfig
%meson \
    --auto-features=enabled \
    -Dforce_fallback_for=vkroots,wlroots,libliftoff
%meson_build

%install
cd gamescope
%meson_install --skip-subprojects

%files
%license gamescope/LICENSE
%doc gamescope/README.md
%caps(cap_sys_nice=eip) %{_bindir}/gamescope
%{_bindir}/gamescopectl
%{_bindir}/gamescopestream
%{_bindir}/gamescopereaper
%{_datadir}/gamescope/*

%files libs
%{_libdir}/libVkLayer_FROG_gamescope_wsi_*.so
%{_datadir}/vulkan/implicit_layer.d/VkLayer_FROG_gamescope_wsi.*.json

%changelog
{{{ git_dir_changelog }}}
