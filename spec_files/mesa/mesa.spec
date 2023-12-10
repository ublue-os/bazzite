## START: Set by rpmautospec
## (rpmautospec version 0.3.8)
## RPMAUTOSPEC: autorelease
%define autorelease(e:s:pb:n) %{?-p:0.}%{lua:
    release_number = 1;
    base_release_number = tonumber(rpm.expand("%{?-b*}%{!?-b:1}"));
    print(release_number + base_release_number - 1);
}%{?-e:.%{-e*}}%{?-s:.%{-s*}}%{!?-n:%{?dist}}
## END: Set by rpmautospec

## START: Set by rpmautospec
## (rpmautospec version 0.3.5)
## RPMAUTOSPEC: autorelease, autochangelog
%define autorelease(e:s:pb:n) %{?-p:0.}%{lua:
    release_number = 2;
    base_release_number = tonumber(rpm.expand("%{?-b*}%{!?-b:1}"));
    print(release_number + base_release_number - 1);
}%{?-e:.%{-e*}}%{?-s:.%{-s*}}%{!?-n:%{?dist}}
## END: Set by rpmautospec

%global _default_patch_fuzz 2

%ifnarch s390x
%global with_hardware 1
%global with_vulkan_hw 1
%global with_vdpau 1
%global with_va 1
%if !0%{?rhel}
%global with_nine 1
%global with_omx 1
%global with_opencl 1
%endif
%global base_vulkan ,amd
%endif

%ifarch %{ix86} x86_64
%global with_crocus 1
%global with_i915   1
%if !0%{?rhel}
%global with_intel_clc 1
%endif
%global with_iris   1
%global with_xa     1
%global intel_platform_vulkan ,intel,intel_hasvk
%endif

%ifarch aarch64 x86_64 %{ix86}
%if !0%{?rhel}
%global with_lima      1
%global with_vc4       1
%endif
%global with_etnaviv   1
%global with_freedreno 1
%global with_kmsro     1
%global with_panfrost  1
%global with_tegra     1
%global with_v3d       1
%global with_xa        1
%global extra_platform_vulkan ,broadcom,freedreno,panfrost
%endif

%ifnarch s390x
%if !0%{?rhel}
%global with_r300 1
%global with_r600 1
%endif
%global with_radeonsi 1
%global with_vmware 1
%endif

%if !0%{?rhel}
%global with_libunwind 1
%global with_lmsensors 1
%endif

%ifarch %{valgrind_arches}
%bcond_without valgrind
%else
%bcond_with valgrind
%endif

%global vulkan_drivers swrast%{?base_vulkan}%{?intel_platform_vulkan}%{?extra_platform_vulkan}

Name:           mesa
Summary:        Mesa graphics libraries
%global ver 23.3.0
Version:        %{lua:ver = string.gsub(rpm.expand("%{ver}"), "-", "~"); print(ver)}
Release:        %autorelease.bazzite.{{{ git_dir_version }}}
License:        MIT AND BSD-3-Clause AND SGI-B-2.0
URL:            http://www.mesa3d.org

Source0:        https://gitlab.freedesktop.org/mesa/mesa/-/archive/mesa-%{ver}/mesa-mesa-%{ver}.tar.gz
# src/gallium/auxiliary/postprocess/pp_mlaa* have an ... interestingly worded license.
# Source1 contains email correspondence clarifying the license terms.
# Fedora opts to ignore the optional part of clause 2 and treat that code as 2 clause BSD.
Source1:        Mesa-MLAA-License-Clarification-Email.txt

Patch10: gnome-shell-glthread-disable.patch
Patch11: 0001-zink-initialize-drm_fd-to-1.patch

# https://gitlab.com/evlaV/mesa/
Patch3: valve.patch

# Performance bump
# Original:
# https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/25352
# Proposed alternative:
# https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/25576
Patch2: 25352.patch
# Disabled, currently has problem: https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/25352#note_2145943
#Patch2: 25576.patch

BuildRequires:  meson >= 1.0.0
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  gettext
%if 0%{?with_hardware}
BuildRequires:  kernel-headers
%endif
# We only check for the minimum version of pkgconfig(libdrm) needed so that the
# SRPMs for each arch still have the same build dependencies. See:
# https://bugzilla.redhat.com/show_bug.cgi?id=1859515
BuildRequires:  pkgconfig(libdrm) >= 2.4.97
%if 0%{?with_libunwind}
BuildRequires:  pkgconfig(libunwind)
%endif
BuildRequires:  pkgconfig(expat)
BuildRequires:  pkgconfig(zlib) >= 1.2.3
BuildRequires:  pkgconfig(libzstd)
BuildRequires:  pkgconfig(libselinux)
BuildRequires:  pkgconfig(wayland-scanner)
BuildRequires:  pkgconfig(wayland-protocols) >= 1.8
BuildRequires:  pkgconfig(wayland-client) >= 1.11
BuildRequires:  pkgconfig(wayland-server) >= 1.11
BuildRequires:  pkgconfig(wayland-egl-backend) >= 3
BuildRequires:  pkgconfig(x11)
BuildRequires:  pkgconfig(xext)
BuildRequires:  pkgconfig(xdamage) >= 1.1
BuildRequires:  pkgconfig(xfixes)
BuildRequires:  pkgconfig(xcb-glx) >= 1.8.1
BuildRequires:  pkgconfig(xxf86vm)
BuildRequires:  pkgconfig(xcb)
BuildRequires:  pkgconfig(x11-xcb)
BuildRequires:  pkgconfig(xcb-dri2) >= 1.8
BuildRequires:  pkgconfig(xcb-dri3)
BuildRequires:  pkgconfig(xcb-present)
BuildRequires:  pkgconfig(xcb-sync)
BuildRequires:  pkgconfig(xshmfence) >= 1.1
BuildRequires:  pkgconfig(dri2proto) >= 2.8
BuildRequires:  pkgconfig(glproto) >= 1.4.14
BuildRequires:  pkgconfig(xcb-xfixes)
BuildRequires:  pkgconfig(xcb-randr)
BuildRequires:  pkgconfig(xrandr) >= 1.3
BuildRequires:  bison
BuildRequires:  flex
%if 0%{?with_lmsensors}
BuildRequires:  lm_sensors-devel
%endif
%if 0%{?with_vdpau}
BuildRequires:  pkgconfig(vdpau) >= 1.1
%endif
%if 0%{?with_va}
BuildRequires:  pkgconfig(libva) >= 0.38.0
%endif
%if 0%{?with_omx}
BuildRequires:  pkgconfig(libomxil-bellagio)
%endif
BuildRequires:  pkgconfig(libelf)
BuildRequires:  pkgconfig(libglvnd) >= 1.3.2
BuildRequires:  llvm-devel >= 7.0.0
%if 0%{?with_opencl}
BuildRequires:  clang-devel
BuildRequires:  bindgen
BuildRequires:  rust-packaging
BuildRequires:  pkgconfig(libclc)
BuildRequires:  pkgconfig(SPIRV-Tools)
BuildRequires:  pkgconfig(LLVMSPIRVLib)
%endif
%if %{with valgrind}
BuildRequires:  pkgconfig(valgrind)
%endif
BuildRequires:  python3-devel
BuildRequires:  python3-mako
%if 0%{?with_intel_clc}
BuildRequires:  python3-ply
%endif
BuildRequires:  vulkan-headers
BuildRequires:  glslang
%if 0%{?with_vulkan_hw}
BuildRequires:  pkgconfig(vulkan)
%endif

%description
%{summary}.

%package filesystem
Summary:        Mesa driver filesystem
Provides:       mesa-dri-filesystem = %{?epoch:%{epoch}:}%{version}-%{release}

%description filesystem
%{summary}.

%package libGL
Summary:        Mesa libGL runtime libraries
Requires:       %{name}-libglapi%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Requires:       libglvnd-glx%{?_isa} >= 1:1.3.2
Recommends:     %{name}-dri-drivers%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description libGL
%{summary}.

%package libGL-devel
Summary:        Mesa libGL development package
Requires:       %{name}-libGL%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Requires:       libglvnd-devel%{?_isa} >= 1:1.3.2
Provides:       libGL-devel
Provides:       libGL-devel%{?_isa}
Recommends:     gl-manpages

%description libGL-devel
%{summary}.

%package libEGL
Summary:        Mesa libEGL runtime libraries
Requires:       libglvnd-egl%{?_isa} >= 1:1.3.2
Requires:       %{name}-libgbm%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Requires:       %{name}-libglapi%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Recommends:     %{name}-dri-drivers%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description libEGL
%{summary}.

%package libEGL-devel
Summary:        Mesa libEGL development package
Requires:       %{name}-libEGL%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Requires:       libglvnd-devel%{?_isa} >= 1:1.3.2
Requires:       %{name}-khr-devel%{?_isa}
Provides:       libEGL-devel
Provides:       libEGL-devel%{?_isa}

%description libEGL-devel
%{summary}.

%package dri-drivers
Summary:        Mesa-based DRI drivers
Requires:       %{name}-filesystem%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Requires:       %{name}-libglapi%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
%if 0%{?with_va}
Recommends:     %{name}-va-drivers%{?_isa}
%endif

%description dri-drivers
%{summary}.

%if 0%{?with_omx}
%package omx-drivers
Summary:        Mesa-based OMX drivers
Requires:       %{name}-filesystem%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description omx-drivers
%{summary}.
%endif

%if 0%{?with_va}
%package        va-drivers
Summary:        Mesa-based VA-API video acceleration drivers
Requires:       %{name}-filesystem%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Obsoletes:      %{name}-vaapi-drivers < 22.2.0-5

%description va-drivers
%{summary}.
%endif

%if 0%{?with_vdpau}
%package        vdpau-drivers
Summary:        Mesa-based VDPAU drivers
Requires:       %{name}-filesystem%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description vdpau-drivers
%{summary}.
%endif

%package libOSMesa
Summary:        Mesa offscreen rendering libraries
Requires:       %{name}-libglapi%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Provides:       libOSMesa
Provides:       libOSMesa%{?_isa}

%description libOSMesa
%{summary}.

%package libOSMesa-devel
Summary:        Mesa offscreen rendering development package
Requires:       %{name}-libOSMesa%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description libOSMesa-devel
%{summary}.

%package libgbm
Summary:        Mesa gbm runtime library
Provides:       libgbm
Provides:       libgbm%{?_isa}
Recommends:     %{name}-dri-drivers%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
# If mesa-dri-drivers are installed, they must match in version. This is here to prevent using
# older mesa-dri-drivers together with a newer mesa-libgbm and its dependants.
# See https://bugzilla.redhat.com/show_bug.cgi?id=2193135 .
Requires:       (%{name}-dri-drivers%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release} if %{name}-dri-drivers%{?_isa})

%description libgbm
%{summary}.

%package libgbm-devel
Summary:        Mesa libgbm development package
Requires:       %{name}-libgbm%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Provides:       libgbm-devel
Provides:       libgbm-devel%{?_isa}

%description libgbm-devel
%{summary}.

%if 0%{?with_xa}
%package libxatracker
Summary:        Mesa XA state tracker
Provides:       libxatracker
Provides:       libxatracker%{?_isa}

%description libxatracker
%{summary}.

%package libxatracker-devel
Summary:        Mesa XA state tracker development package
Requires:       %{name}-libxatracker%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Provides:       libxatracker-devel
Provides:       libxatracker-devel%{?_isa}

%description libxatracker-devel
%{summary}.
%endif

%package libglapi
Summary:        Mesa shared glapi
Provides:       libglapi
Provides:       libglapi%{?_isa}
# If mesa-dri-drivers are installed, they must match in version. This is here to prevent using
# older mesa-dri-drivers together with a newer mesa-libglapi or its dependants.
# See https://bugzilla.redhat.com/show_bug.cgi?id=2193135 .
Requires:       (%{name}-dri-drivers%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release} if %{name}-dri-drivers%{?_isa})

%description libglapi
%{summary}.

%if 0%{?with_opencl}
%package libOpenCL
Summary:        Mesa OpenCL runtime library
Requires:       ocl-icd%{?_isa}
Requires:       libclc%{?_isa}
Requires:       %{name}-libgbm%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}
Requires:       opencl-filesystem

%description libOpenCL
%{summary}.

%package libOpenCL-devel
Summary:        Mesa OpenCL development package
Requires:       %{name}-libOpenCL%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description libOpenCL-devel
%{summary}.
%endif

%if 0%{?with_nine}
%package libd3d
Summary:        Mesa Direct3D9 state tracker

%description libd3d
%{summary}.

%package libd3d-devel
Summary:        Mesa Direct3D9 state tracker development package
Requires:       %{name}-libd3d%{?_isa} = %{?epoch:%{epoch}:}%{version}-%{release}

%description libd3d-devel
%{summary}.
%endif

%prep
%autosetup -n %{name}-%{name}-%{ver} -p1
cp %{SOURCE1} docs/

%build
# ensure standard Rust compiler flags are set
export RUSTFLAGS="%build_rustflags"

%meson \
  -Dplatforms=x11,wayland \
  -Ddri3=enabled \
  -Dosmesa=true \
%if 0%{?with_hardware}
  -Dgallium-drivers=swrast,virgl,nouveau%{?with_r300:,r300}%{?with_crocus:,crocus}%{?with_i915:,i915}%{?with_iris:,iris}%{?with_vmware:,svga}%{?with_radeonsi:,radeonsi}%{?with_r600:,r600}%{?with_freedreno:,freedreno}%{?with_etnaviv:,etnaviv}%{?with_tegra:,tegra}%{?with_vc4:,vc4}%{?with_v3d:,v3d}%{?with_kmsro:,kmsro}%{?with_lima:,lima}%{?with_panfrost:,panfrost}%{?with_vulkan_hw:,zink} \
%else
  -Dgallium-drivers=swrast,virgl \
%endif
  -Dgallium-vdpau=%{?with_vdpau:enabled}%{!?with_vdpau:disabled} \
  -Dgallium-omx=%{?with_omx:bellagio}%{!?with_omx:disabled} \
  -Dgallium-va=%{?with_va:enabled}%{!?with_va:disabled} \
  -Dgallium-xa=%{?with_xa:enabled}%{!?with_xa:disabled} \
  -Dgallium-nine=%{?with_nine:true}%{!?with_nine:false} \
  -Dgallium-opencl=%{?with_opencl:icd}%{!?with_opencl:disabled} \
%if 0%{?with_opencl}
  -Dgallium-rusticl=true \
%endif
  -Dvulkan-layers=device-select \
  -Dshared-glapi=enabled \
  -Dgles1=enabled \
  -Dgles2=enabled \
  -Dopengl=true \
  -Dgbm=enabled \
  -Dglx=dri \
  -Degl=enabled \
  -Dglvnd=true \
%if 0%{?with_intel_clc}
  -Dintel-clc=enabled \
%endif
  -Dmicrosoft-clc=disabled \
  -Dllvm=enabled \
  -Dshared-llvm=enabled \
  -Dvalgrind=%{?with_valgrind:enabled}%{!?with_valgrind:disabled} \
  -Dxlib-lease=enabled \
  -Dbuild-tests=false \
  -Dselinux=true \
%if !0%{?with_libunwind}
  -Dlibunwind=disabled \
%endif
%if !0%{?with_lmsensors}
  -Dlmsensors=disabled \
%endif
  -Dandroid-libbacktrace=disabled \
%ifarch %{ix86}
  -Dglx-read-only-text=true
%endif
  %{nil}
%meson_build

%install
%meson_install

# libvdpau opens the versioned name, don't bother including the unversioned
rm -vf %{buildroot}%{_libdir}/vdpau/*.so
# likewise glvnd
rm -vf %{buildroot}%{_libdir}/libGLX_mesa.so
rm -vf %{buildroot}%{_libdir}/libEGL_mesa.so
# XXX can we just not build this
rm -vf %{buildroot}%{_libdir}/libGLES*

# glvnd needs a default provider for indirect rendering where it cannot
# determine the vendor
ln -s %{_libdir}/libGLX_mesa.so.0 %{buildroot}%{_libdir}/libGLX_system.so.0

# this keeps breaking, check it early.  note that the exit from eu-ftr is odd.
pushd %{buildroot}%{_libdir}
for i in libOSMesa*.so libGL.so ; do
    eu-findtextrel $i && exit 1
done
popd

# We build vulkan separately
rm -Rf %{buildroot}/usr/lib/debug/usr/lib64/libvulkan*
rm -Rf %{buildroot}/usr/lib/debug/usr/lib64/libVkLayer*
rm -Rf %{buildroot}%{_libdir}/libvulkan_intel.so
rm -Rf %{buildroot}%{_libdir}/libvulkan_radeon.so
rm -Rf %{buildroot}%{_libdir}/libvulkan_lvp.so
rm -Rf %{buildroot}%{_libdir}/libvulkan_intel_hasvk.so
rm -Rf %{buildroot}%{_libdir}/libVkLayer_MESA_overlay.so
rm -Rf %{buildroot}%{_libdir}/libVkLayer_MESA_device_select.so
rm -Rf %{buildroot}%{_datadir}/vulkan/icd.d/lvp_icd.*.json
rm -Rf %{buildroot}%{_datadir}/vulkan/icd.d/intel_icd.*.json
rm -Rf %{buildroot}%{_datadir}/vulkan/icd.d/radeon_icd.*.json
rm -Rf %{buildroot}%{_datadir}/vulkan/icd.d/intel_hasvk_icd.x86_64.json
rm -Rf %{buildroot}%{_datadir}/vulkan/icd.d/intel_hasvk_icd.i686.json
rm -Rf %{buildroot}%{_datadir}/vulkan/explicit_layer.d/VkLayer_MESA_overlay.json
rm -Rf %{buildroot}%{_datadir}/vulkan/implicit_layer.d/VkLayer_MESA_device_select.json
rm -Rf %{buildroot}%{_bindir}/mesa-overlay-control.py
rm -Rf %{buildroot}%{_datadir}/drirc.d/00-radv-defaults.conf

%files filesystem
%doc docs/Mesa-MLAA-License-Clarification-Email.txt
%dir %{_libdir}/dri
%if 0%{?with_hardware}
%if 0%{?with_vdpau}
%dir %{_libdir}/vdpau
%endif
%endif

%files libGL
%{_libdir}/libGLX_mesa.so.0*
%{_libdir}/libGLX_system.so.0*
%files libGL-devel
%dir %{_includedir}/GL/internal
%{_includedir}/GL/internal/dri_interface.h
%{_libdir}/pkgconfig/dri.pc
%{_libdir}/libglapi.so

%files libEGL
%{_datadir}/glvnd/egl_vendor.d/50_mesa.json
%{_libdir}/libEGL_mesa.so.0*
%files libEGL-devel
%dir %{_includedir}/EGL
%{_includedir}/EGL/eglext_angle.h
%{_includedir}/EGL/eglmesaext.h

%files libglapi
%{_libdir}/libglapi.so.0
%{_libdir}/libglapi.so.0.*

%files libOSMesa
%{_libdir}/libOSMesa.so.8*
%files libOSMesa-devel
%dir %{_includedir}/GL
%{_includedir}/GL/osmesa.h
%{_libdir}/libOSMesa.so
%{_libdir}/pkgconfig/osmesa.pc

%files libgbm
%{_libdir}/libgbm.so.1
%{_libdir}/libgbm.so.1.*
%files libgbm-devel
%{_libdir}/libgbm.so
%{_includedir}/gbm.h
%{_libdir}/pkgconfig/gbm.pc

%if 0%{?with_xa}
%files libxatracker
%if 0%{?with_hardware}
%{_libdir}/libxatracker.so.2
%{_libdir}/libxatracker.so.2.*
%endif

%files libxatracker-devel
%if 0%{?with_hardware}
%{_libdir}/libxatracker.so
%{_includedir}/xa_tracker.h
%{_includedir}/xa_composite.h
%{_includedir}/xa_context.h
%{_libdir}/pkgconfig/xatracker.pc
%endif
%endif

%if 0%{?with_opencl}
%files libOpenCL
%{_libdir}/libMesaOpenCL.so.*
%{_libdir}/libRusticlOpenCL.so.*
%{_sysconfdir}/OpenCL/vendors/mesa.icd
%{_sysconfdir}/OpenCL/vendors/rusticl.icd
%files libOpenCL-devel
%{_libdir}/libMesaOpenCL.so
%{_libdir}/libRusticlOpenCL.so
%endif

%if 0%{?with_nine}
%files libd3d
%dir %{_libdir}/d3d/
%{_libdir}/d3d/*.so.*

%files libd3d-devel
%{_libdir}/pkgconfig/d3d.pc
%{_includedir}/d3dadapter/
%{_libdir}/d3d/*.so
%endif

%files dri-drivers
%dir %{_datadir}/drirc.d
%{_datadir}/drirc.d/00-mesa-defaults.conf
%{_libdir}/dri/kms_swrast_dri.so
%{_libdir}/dri/swrast_dri.so
%{_libdir}/dri/virtio_gpu_dri.so

%if 0%{?with_hardware}
%if 0%{?with_r300}
%{_libdir}/dri/r300_dri.so
%endif
%if 0%{?with_radeonsi}
%if 0%{?with_r600}
%{_libdir}/dri/r600_dri.so
%endif
%{_libdir}/dri/radeonsi_dri.so
%endif
%ifarch %{ix86} x86_64
%{_libdir}/dri/crocus_dri.so
%{_libdir}/dri/i915_dri.so
%{_libdir}/dri/iris_dri.so
%endif
%ifarch aarch64 x86_64 %{ix86}
%{_libdir}/dri/ingenic-drm_dri.so
%{_libdir}/dri/imx-drm_dri.so
%{_libdir}/dri/imx-lcdif_dri.so
%{_libdir}/dri/kirin_dri.so
%{_libdir}/dri/komeda_dri.so
%{_libdir}/dri/mali-dp_dri.so
%{_libdir}/dri/mcde_dri.so
%{_libdir}/dri/mxsfb-drm_dri.so
%{_libdir}/dri/rcar-du_dri.so
%{_libdir}/dri/stm_dri.so
%endif
%if 0%{?with_vc4}
%{_libdir}/dri/vc4_dri.so
%endif
%if 0%{?with_v3d}
%{_libdir}/dri/v3d_dri.so
%endif
%if 0%{?with_freedreno}
%{_libdir}/dri/kgsl_dri.so
%{_libdir}/dri/msm_dri.so
%endif
%if 0%{?with_etnaviv}
%{_libdir}/dri/etnaviv_dri.so
%endif
%if 0%{?with_tegra}
%{_libdir}/dri/tegra_dri.so
%endif
%if 0%{?with_lima}
%{_libdir}/dri/lima_dri.so
%endif
%if 0%{?with_panfrost}
%{_libdir}/dri/panfrost_dri.so
%endif
%{_libdir}/dri/nouveau_dri.so
%if 0%{?with_vmware}
%{_libdir}/dri/vmwgfx_dri.so
%endif
%endif
%if 0%{?with_opencl}
%dir %{_libdir}/gallium-pipe
%{_libdir}/gallium-pipe/*.so
%endif
%if 0%{?with_kmsro}
%{_libdir}/dri/armada-drm_dri.so
%{_libdir}/dri/exynos_dri.so
%{_libdir}/dri/hdlcd_dri.so
%{_libdir}/dri/hx8357d_dri.so
%{_libdir}/dri/ili9225_dri.so
%{_libdir}/dri/ili9341_dri.so
%{_libdir}/dri/imx-dcss_dri.so
%{_libdir}/dri/mediatek_dri.so
%{_libdir}/dri/meson_dri.so
%{_libdir}/dri/mi0283qt_dri.so
%{_libdir}/dri/pl111_dri.so
%{_libdir}/dri/repaper_dri.so
%{_libdir}/dri/rockchip_dri.so
%{_libdir}/dri/st7586_dri.so
%{_libdir}/dri/st7735r_dri.so
%{_libdir}/dri/sun4i-drm_dri.so
%endif
%if 0%{?with_vulkan_hw}
%{_libdir}/dri/zink_dri.so
%endif

%if 0%{?with_omx}
%files omx-drivers
%{_libdir}/bellagio/libomx_mesa.so
%endif

%if 0%{?with_va}
%files va-drivers
%{_libdir}/dri/nouveau_drv_video.so
%if 0%{?with_r600}
%{_libdir}/dri/r600_drv_video.so
%endif
%if 0%{?with_radeonsi}
%{_libdir}/dri/radeonsi_drv_video.so
%endif
%{_libdir}/dri/virtio_gpu_drv_video.so
%endif

%if 0%{?with_vdpau}
%files vdpau-drivers
%{_libdir}/vdpau/libvdpau_nouveau.so.1*
%if 0%{?with_r600}
%{_libdir}/vdpau/libvdpau_r600.so.1*
%endif
%if 0%{?with_radeonsi}
%{_libdir}/vdpau/libvdpau_radeonsi.so.1*
%endif
%{_libdir}/vdpau/libvdpau_virtio_gpu.so.1*
%endif


%changelog
* Thu Nov 30 2023 José Expósito <jexposit@redhat.com> - 23.3.0-1
- Update to 23.3.0

* Wed Nov 29 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc5-1
- Update to 23.3.0-rc5

* Thu Nov 23 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc2-6
- Set glx-read-only-text on i386

* Thu Nov 23 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc2-5
- Disable rwx segment linker error

* Wed Nov 22 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc2-4
- Backport MR #26332 to fix X11 session on VMs

* Fri Nov 17 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc2-3
- Backport MR #26220 to fix GNOME apps crash

* Fri Nov 03 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc2-2
- Backport MR #26029 to fix installer crash

* Thu Nov 02 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc2-1
- Update to 23.3.0-rc2

* Thu Oct 26 2023 José Expósito <jexposit@redhat.com> - 23.3.0~rc1-1
- Update to 23.3.0-rc1

* Thu Oct 05 2023 Adam Williamson <awilliam@redhat.com> - 23.2.1-2
- Backport MR #24045 to fix Iris crashes (#2238711)

* Fri Sep 29 2023 Pete Walter <pwalter@fedoraproject.org> - 23.2.1-1
- Update to 23.2.1

* Fri Sep 15 2023 Dave Airlie <airlied@redhat.com> - 23.2.0~rc3-3
- update SPDX license

* Thu Sep 07 2023 Adam Jackson <ajax@redhat.com> - 23.2.0~rc3-2
- Build a few more drivers for RHEL

* Wed Sep 06 2023 Pete Walter <pwalter@fedoraproject.org> - 23.2.0~rc3-1
- Update to 23.2.0-rc3

* Tue Aug 22 2023 Neal Gompa <ngompa@fedoraproject.org> - 23.2.0~rc2-4
- Enable GLESv1 support

* Mon Aug 14 2023 Neal Gompa <ngompa@fedoraproject.org> - 23.2.0~rc2-3
- Enable all aarch64 drivers for x86 for x86 emulation on aarch64

* Sat Aug 12 2023 Neal Gompa <ngompa@fedoraproject.org> - 23.2.0~rc2-2
- Bump Meson minimum build dependency to 1.2.0

* Thu Aug 10 2023 Pete Walter <pwalter@fedoraproject.org> - 23.2.0~rc2-1
- Update to 23.2.0-rc2

* Thu Aug 03 2023 Pete Walter <pwalter@fedoraproject.org> - 23.1.5-1
- Update to 23.1.5

* Sat Jul 22 2023 Pete Walter <pwalter@fedoraproject.org> - 23.1.4-1
- Update to 23.1.4

* Thu Jul 20 2023 Fedora Release Engineering <releng@fedoraproject.org> - 23.1.3-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Sun Jul 16 2023 Yaakov Selkowitz <yselkowi@redhat.com> - 23.1.3-3
- Disable libunwind, lm_sensors in RHEL builds

* Thu Jul 13 2023 Kamil Páral <kparal@redhat.com> - 23.1.3-2
- Prevent partial updates (rhbz#2193135)

* Fri Jun 30 2023 Nicolas Chauvet <kwizart@gmail.com> - 23.1.3-1
- Update to 23.1.3

* Sun Jun 11 2023 Pete Walter <pwalter@fedoraproject.org> - 23.1.2-1
- Update to 23.1.2

* Wed Jun 07 2023 Neal Gompa <ngompa@fedoraproject.org> - 23.1.1-2
- Enable stack trace and HUD sensor support

* Thu May 25 2023 Dave Airlie <airlied@redhat.com> - 23.1.1-1
- update to 23.1.1

* Tue May 23 2023 Dave Airlie <airlied@redhat.com> - 23.1.0-3
- removed unused BR

* Tue May 23 2023 Dave Airlie <airlied@redhat.com> - 23.1.0-2
- Update to mesa 23.1.0

* Tue May 23 2023 Dave Airlie <airlied@redhat.com> - 23.1.0-1
- Update to mesa 23.1.0

* Wed May 03 2023 Michel Dänzer <mdaenzer@redhat.com> - 23.0.3-4
- Do not enable intel-clc for ELN/RHEL

* Mon May 01 2023 Michel Dänzer <mdaenzer@redhat.com> - 23.0.3-3
- Enable intel-clc for ANV ray tracing support

* Fri Apr 28 2023 Michel Dänzer <mdaenzer@redhat.com> - 23.0.3-2
- Remove superfluous meson parameters for rusticl
- Dllvm=enabled is already there unconditionally further down.

* Tue Apr 25 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.3-1
- Update to 23.0.3

* Tue Apr 25 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.2-3
- Add missing inter-subpackage requires (rhbz#2187726)

* Tue Apr 18 2023 Nicolas Chauvet <kwizart@gmail.com> - 23.0.2-2
- Revert "Tighten mesa-va-drivers recommends again (rhbz#2161338)"

* Thu Apr 13 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.2-1
- Update to 23.0.2

* Thu Apr 13 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.1-3
- Tighten mesa-va-drivers recommends again (rhbz#2161338)

* Mon Apr 03 2023 František Zatloukal <fzatlouk@redhat.com> - 23.0.1-2
- Rebuild for LLVM 16

* Sat Mar 25 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.1-1
- Update to 23.0.1

* Thu Feb 23 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.0-1
- Update to 23.0.0

* Wed Feb 15 2023 Adam Williamson <awilliam@redhat.com> - 23.0.0~rc4-3
- Backport MR #21333 to fix KDE on llvmpipe (#2164667)

* Sun Feb 05 2023 Fabio Valentini <decathorpe@gmail.com> - 23.0.0~rc4-2
- Ensure standard Rust compiler flags are set

* Wed Feb 01 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.0~rc4-1
- Update to 23.0.0-rc4

* Thu Jan 26 2023 Adam Williamson <awilliam@redhat.com> - 23.0.0~rc3-3
- Backport MR #20933 to fix double-free crash (rhbz#2164667)

* Wed Jan 25 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.0~rc3-2
- Fix the build (rhbz#2161370)

* Wed Jan 25 2023 Pete Walter <pwalter@fedoraproject.org> - 23.0.0~rc3-1
- Update to 23.0.0-rc3

* Wed Jan 25 2023 Pete Walter <pwalter@fedoraproject.org> - 22.3.3-3
- Use unversioned recommends for mesa-va-drivers (rhbz#2161338)

* Thu Jan 19 2023 Fedora Release Engineering <releng@fedoraproject.org> - 22.3.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Wed Jan 11 2023 Pete Walter <pwalter@fedoraproject.org> - 22.3.3-1
- Update to 22.3.3

* Sat Dec 31 2022 Pete Walter <pwalter@fedoraproject.org> - 22.3.2-1
- Update to 22.3.2

* Sun Dec 18 2022 Pete Walter <pwalter@fedoraproject.org> - 22.3.1-1
- Update to 22.3.1

* Tue Dec 06 2022 Dave Airlie <airlied@redhat.com> - 22.3.0-2
- fix regression around mit-shm detection

* Wed Nov 30 2022 Pete Walter <pwalter@fedoraproject.org> - 22.3.0-1
- Update to 22.3.0

* Fri Nov 25 2022 Dave Airlie <airlied@redhat.com> - 22.3.0~rc4-2
- disable glthread for gnome-shell

* Thu Nov 24 2022 Pete Walter <pwalter@fedoraproject.org> - 22.3.0~rc4-1
- Update to 22.3.0-rc4

* Tue Nov 22 2022 Dave Airlie <airlied@redhat.com> - 22.3.0~rc3-4
- add hasvk files

* Tue Nov 22 2022 Dave Airlie <airlied@redhat.com> - 22.3.0~rc3-3
- enable hasvk + regression fix

* Mon Nov 21 2022 Pete Walter <pwalter@fedoraproject.org> - 22.3.0~rc3-2
- Sort new files

* Mon Nov 21 2022 Dave Airlie <airlied@redhat.com> - 22.3.0~rc3-1
- rebase to 22.3.0-rc3

* Thu Nov 17 2022 Peter Robinson <pbrobinson@gmail.com> - 22.3.0~rc2-3
- Enable rusticl as an optional OpenCL engine

* Thu Nov 10 2022 Dave Airlie <airlied@redhat.com> - 22.3.0~rc2-2
- Add patch files

* Thu Nov 10 2022 Dave Airlie <airlied@redhat.com> - 22.3.0~rc2-1
- Update to 22.3.0-rc2

* Mon Nov 07 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.3-1
- Update to 22.2.3

* Wed Oct 19 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.2-1
- Update to 22.2.2

* Wed Oct 12 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.1-1
- Update to 22.2.1

* Mon Oct 10 2022 Ray Strode <rstrode@redhat.com> - 22.2.0-7
- Recommend mesa-va-drivers from mesa-dri-drivers

* Sun Oct 02 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0-6
- Remove old obsoletes

* Sun Oct 02 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0-5
- Rename mesa-vaapi-drivers to mesa-va-drivers

* Wed Sep 28 2022 Dave Airlie <airlied@redhat.com> - 22.2.0-4
- mesa: split out vaapi drivers into separate package

* Sun Sep 25 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0-3
- Recommend mesa-dri-drivers from libGL, libEGL, and libgbm subpackages
  (rhbz#1900633)

* Thu Sep 22 2022 Karol Herbst <kherbst@redhat.com> - 22.2.0-2
- Add Nouveau multithreading fix backport (rhbz#2123274)

* Wed Sep 21 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0-1
- Update to 22.2.0

* Tue Sep 20 2022 Dave Airlie <airlied@redhat.com> - 22.2.0~rc3-4
- Drop codecs.

* Sat Sep 17 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0~rc3-3
- Rebuild for llvm 15

* Mon Sep 12 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0~rc3-2
- Re-enable video codecs (rhbz#2123998)

* Thu Aug 18 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0~rc3-1
- Update to 22.2.0-rc3

* Fri Aug 12 2022 Pete Walter <pwalter@fedoraproject.org> - 22.2.0~rc2-1
- Update to 22.2.0-rc2

* Fri Aug 12 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.6-2
- Drop obsolete arm ifarch conditionals

* Thu Aug 11 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.6-1
- Update to 22.1.6

* Thu Aug 04 2022 Dave Airlie <airlied@redhat.com> - 22.1.5-2
- add two llvmpipe fixes for multi-context

* Thu Aug 04 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.5-1
- Update to 22.1.5

* Thu Jul 21 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.4-2
- Enable vmware svga driver on aarch64 (#2108405)

* Wed Jul 20 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.4-1
- Update to 22.1.4

* Thu Jul 14 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.3-3
- Build i915 gallium driver (#2100212)

* Thu Jul 14 2022 Dave Airlie <airlied@redhat.com> - 22.1.3-2
- attempt to fix race in kms_swrast_dri.so affecting kwin.

* Sat Jul 02 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.3-1
- Update to 22.1.3

* Thu Jun 16 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.2-1
- Update to 22.1.2

* Thu Jun 02 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.1-1
- Update to 22.1.1

* Thu Jun 02 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.0-5
- Update Source0

* Thu May 26 2022 Dave Airlie <airlied@redhat.com> - 22.1.0-4
- fix spec file chunk

* Thu May 26 2022 Dave Airlie <airlied@redhat.com> - 22.1.0-3
- backport correct llvmpipe artifact fix

* Wed May 25 2022 Dave Airlie <airlied@redhat.com> - 22.1.0-2
- revert llvmpipe overlap patch to see if it fixes rawhide

* Thu May 19 2022 Pete Walter <pwalter@fedoraproject.org> - 22.1.0-1
- Update to 22.1.0

* Thu May 05 2022 Pete Walter <pwalter@fedoraproject.org> - 22.0.3-1
- Update to 22.0.3

* Mon Apr 25 2022 Pete Walter <pwalter@fedoraproject.org> - 22.0.2-2
- Add new 00-radv-defaults.conf to files list

* Sun Apr 24 2022 Pete Walter <pwalter@fedoraproject.org> - 22.0.2-1
- Update to 22.0.2

* Wed Mar 30 2022 Pete Walter <pwalter@fedoraproject.org> - 22.0.1-1
- Update to 22.0.1

* Mon Mar 21 2022 Pete Walter <pwalter@fedoraproject.org> - 22.0.0-4
- Obsolete empty mesa-vulkan-devel subpackage

* Mon Mar 21 2022 Pete Walter <pwalter@fedoraproject.org> - 22.0.0-3
- Fix the build

* Thu Mar 10 2022 Dave Airlie <airlied@redhat.com> - 22.0.0-2
- fixup unknown args

* Thu Mar 10 2022 Dave Airlie <airlied@redhat.com> - 22.0.0-1
- update to 22.0.0

* Wed Feb 23 2022 Pete Walter <pwalter@fedoraproject.org> - 21.3.7-1
- Update to 21.3.7

* Thu Feb 10 2022 Pete Walter <pwalter@fedoraproject.org> - 21.3.6-1
- Update to 21.3.6

* Mon Jan 31 2022 Lyude Paul <lyude@redhat.com> - 21.3.5-2
- Add missing attributions for 21.3.4-3

* Sat Jan 29 2022 Pete Walter <pwalter@fedoraproject.org> - 21.3.5-1
- Update to 21.3.5

* Fri Jan 21 2022 Lyude Paul <lyude@redhat.com> - 21.3.4-3
- Add patch from upstream to fix blinking with Intel Iris (#2040771)
  (#2036600)

* Thu Jan 20 2022 Fedora Release Engineering <releng@fedoraproject.org> - 21.3.4-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Fri Jan 14 2022 Pete Walter <pwalter@fedoraproject.org> - 21.3.4-1
- Update to 21.3.4

* Thu Dec 30 2021 Pete Walter <pwalter@fedoraproject.org> - 21.3.3-1
- Update to 21.3.3

* Sat Dec 18 2021 Pete Walter <pwalter@fedoraproject.org> - 21.3.2-1
- Update to 21.3.2

* Mon Dec 06 2021 Pete Walter <pwalter@fedoraproject.org> - 21.3.1-2
- Patch from upstream to make GBM work again with NVIDIA 495 (#2028524)

* Wed Dec 01 2021 Pete Walter <pwalter@fedoraproject.org> - 21.3.1-1
- Update to 21.3.1

* Thu Nov 18 2021 Pete Walter <pwalter@fedoraproject.org> - 21.3.0-2
- Fix files list

* Wed Nov 17 2021 Pete Walter <pwalter@fedoraproject.org> - 21.3.0-1
- Update to 21.3.0

* Tue Nov 09 2021 Tom Stellard <tstellar@redhat.com> - 21.2.5-2
- Rebuild for llvm-13.0.0

* Thu Oct 28 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.5-1
- Update to 21.2.5

* Thu Oct 28 2021 Stephen Gallagher <sgallagh@redhat.com> - 21.2.4-3
- Rebuild for llvm 13 soname change

* Thu Oct 14 2021 Tom Stellard <tstellar@redhat.com> - 21.2.4-2
- Rebuild for llvm-13.0.0

* Thu Oct 14 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.4-1
- Update to 21.2.4

* Wed Oct 13 2021 Tom Stellard <tstellar@redhat.com> - 21.2.3-7
- Rebuild for llvm-13.0.0

* Tue Oct 12 2021 Adam Williamson <awilliam@redhat.com> - 21.2.3-6
- Add patches from previous commit to git

* Tue Oct 12 2021 Adam Williamson <awilliam@redhat.com> - 21.2.3-5
- Backport MR#13231 and revert MR#3724 to fix Tegra (kherbst)

* Tue Oct 12 2021 Tom Stellard <tstellar@redhat.com> - 21.2.3-4
- Rebuild for llvm-13.0.0

* Mon Oct 11 2021 Dave Airlie <airlied@redhat.com> - 21.2.3-3
- mesa: backport another crocus fix

* Mon Oct 11 2021 Dave Airlie <airlied@redhat.com> - 21.2.3-2
- mesa: backport some crocus fixes

* Wed Sep 29 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.3-1
- Update to 21.2.3

* Tue Sep 21 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.2-1
- Update to 21.2.2

* Mon Sep 13 2021 Dave Airlie <airlied@redhat.com> - 21.2.1-4
- mesa: add fixes from 21.2 staging branch and enable crocus by default

* Sat Aug 21 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.1-3
- Fix the build

* Fri Aug 20 2021 Peter Robinson <pbrobinson@gmail.com> - 21.2.1-2
- Enable panfrost vulcan driver on arm

* Thu Aug 19 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.1-1
- Update to 21.2.1

* Thu Aug 19 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.0-4
- Opt in to rpmautospec

* Thu Aug 19 2021 Stephen Gallagher <sgallagh@redhat.com> - 21.2.0-3
- Fixes for building against LLVM 13

* Thu Aug 05 2021 ValdikSS <iam@valdikss.org.ru> - 21.2.0-2
- Enable Crocus driver

* Thu Aug 05 2021 Pete Walter <pwalter@fedoraproject.org> - 21.2.0-1
- Update to 21.2.0

* Sat Jul 31 2021 Pete Walter <pwalter@fedoraproject.org> - 21.1.6-1
- Update to 21.1.6

* Thu Jul 22 2021 Fedora Release Engineering <releng@fedoraproject.org> - 21.1.5-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Sat Jul 17 2021 Pete Walter <pwalter@fedoraproject.org> - 21.1.5-1
- Update to 21.1.5

* Sat Jul 03 2021 Pete Walter <pwalter@fedoraproject.org> - 21.1.4-1
- Update to 21.1.4

* Fri Jun 18 2021 Pete Walter <pwalter@fedoraproject.org> - 21.1.3-1
- Update to 21.1.3

* Sat Jun 12 2021 Pete Walter <pwalter@fedoraproject.org> - 21.1.2-1
- Update to 21.1.2

* Thu May 27 2021 Pete Walter <pwalter@fedoraproject.org> - 21.1.1-3
- Clean up %%ldconfig_scriptlets macros

* Wed May 26 2021 Tom Stellard <tstellar@redhat.com> - 21.1.1-2
- Rebuild for LLVM 12.0.0-final

* Wed May 19 2021 Pete Walter <pwalter@fedoraproject.org> - 21.1.1-1
- Update to 21.1.1

* Wed May 05 2021 Adam Jackson <ajax@redhat.com> - 21.1.0-1
- Update to 21.1.0

* Thu Apr 29 2021 Kalev Lember <klember@redhat.com> - 21.0.3-2
- Backport a fix for amdgpu graphics corruption regression

* Thu Apr 22 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.3-1
- Update to 21.0.3

* Mon Apr 19 2021 Dave Airlie <airlied@redhat.com> - 21.0.2-2
- mesa: move imx-drm to correct place in file.

* Wed Apr 07 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.2-1
- Update to 21.0.2

* Thu Apr 01 2021 Dave Airlie <airlied@redhat.com> - 21.0.1-6
- Backport CPU caps fixes

* Fri Mar 26 2021 Adam Jackson <ajax@redhat.com> - 21.0.1-4
- Split out with_r300 and with_r600 Disable r300, r600, etnaviv, lima, vc4
  and v3d in RHEL

* Thu Mar 25 2021 Dave Airlie <airlied@redhat.com> - 21.0.1-3
- add missing patch

* Thu Mar 25 2021 Dave Airlie <airlied@redhat.com> - 21.0.1-2
- fix zink loading in places it shouldn't.

* Wed Mar 24 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.1-1
- Update to 21.0.1

* Tue Mar 23 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.0-2
- Rebuild for llvm 12

* Fri Mar 12 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.0-1
- Update to 21.0.0

* Mon Mar 08 2021 Adam Williamson <awilliam@redhat.com> - 21.0.0~rc5-3
- Backport MR #9425 to fix GNOME Shell crash on Jetson Nano (#1930977)

* Mon Feb 22 2021 Dave Airlie <airlied@redhat.com> - 21.0.0~rc5-2
- fix sddm/vmware regression

* Fri Feb 19 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.0~rc5-1
- Update to 21.0.0-rc5

* Fri Feb 19 2021 Adam Jackson <ajax@redhat.com> - 21.0.0~rc4-2
- Disable OpenMAX, OpenCL, and nine in RHEL

* Wed Feb 17 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.0~rc4-1
- Update to 21.0.0-rc4

* Wed Feb 03 2021 Dave Airlie <airlied@redhat.com> - 21.0.0~rc3-2
- Fix zink/swrast/lavapipe/gnome-shell interaction (#1924360)

* Fri Jan 29 2021 Pete Walter <pwalter@fedoraproject.org> - 21.0.0~rc3-1
- Update to 21.0.0-rc3

* Fri Jan 29 2021 Dave Airlie <airlied@redhat.com> - 20.3.3-7
- Backport upstream fix for EGL issues with qemu

* Tue Jan 26 2021 Fedora Release Engineering <releng@fedoraproject.org> - 20.3.3-6
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Fri Jan 22 2021 Tom Stellard <tstellar@redhat.com> - 20.3.3-5
- Rebuild for clang-11.1.0

* Wed Jan 20 2021 Adam Jackson <ajax@redhat.com> - 20.3.3-4
- Disable classic drivers in RHEL

* Fri Jan 15 2021 Dave Airlie <airlied@redhat.com> - 20.3.3-3
- Fix lavapipe missing ext that breaks gstreamer/pidgin

* Thu Jan 14 2021 Dave Airlie <airlied@redhat.com> - 20.3.3-2
- Fix device selection layer for vulkan 1.2

* Wed Jan 13 2021 Pete Walter <pwalter@fedoraproject.org> - 20.3.3-1
- Update to 20.3.3

* Thu Dec 31 2020 Pete Walter <pwalter@fedoraproject.org> - 20.3.2-1
- Update to 20.3.2

* Wed Dec 16 2020 Pete Walter <pwalter@fedoraproject.org> - 20.3.1-2
- Fix pre-release versions in old %%changelog entries

* Wed Dec 16 2020 Pete Walter <pwalter@fedoraproject.org> - 20.3.1-1
- Update to 20.3.1

* Mon Dec 07 2020 Dave Airlie <airlied@redhat.com> - 20.3.0-2
- Fix regression with radeon si/cik cards

* Fri Dec 04 2020 Dave Airlie <airlied@redhat.com> - 20.3.0-1
- Update to 20.3.0 release

* Tue Dec 01 2020 Peter Robinson <pbrobinson@gmail.com> - 20.3.0~rc3-2
- Enable Zink opengl over vulkan driver, Broadcom v3dv and freedreno vulkan
  drivers on arm

* Mon Nov 30 2020 Dave Airlie <airlied@redhat.com> - 20.3.0~rc3-1
- Update to 20.3.0-rc3

* Mon Nov 30 2020 Dave Airlie <airlied@redhat.com> - 20.3.0~rc2-1
- Update to 20.3.0-rc2

* Sat Nov 28 2020 Peter Robinson <pbrobinson@gmail.com> - 20.2.3-3
- Update meson options and nomenclature

* Sat Nov 28 2020 Peter Robinson <pbrobinson@gmail.com> - 20.2.3-2
- Cleanup vulkan conditionals, make it more inline with dri_drivers so it's
  more straightforward as arches diverge supported drivers

* Tue Nov 24 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.3-1
- Update to 20.2.3

* Sat Nov 07 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.2-1
- Update to 20.2.2

* Wed Oct 14 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.1-1
- Update to 20.2.1

* Tue Sep 29 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0-3
- Update glvnd required version

* Tue Sep 29 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0-2
- Drop no longer needed big endian fix

* Tue Sep 29 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0-1
- Update to 20.2.0

* Fri Sep 25 2020 Adam Jackson <ajax@redhat.com> - 20.2.0~rc4-3
- mesa-libGL-devel Recommends: gl-manpages

* Fri Sep 04 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0~rc4-2
- Remove more no longer needed build hacks

* Fri Sep 04 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0~rc4-1
- Update to 20.2.0~rc4

* Thu Sep 03 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0~rc3-2
- Remove -fcommon build workaround

* Sat Aug 29 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0~rc3-1
- Update to 20.2.0~rc3

* Sun Aug 23 2020 Pete Walter <pwalter@fedoraproject.org> - 20.2.0~rc2-1
- Update to 20.2.0~rc2

* Sat Aug 22 2020 Kalev Lember <klember@redhat.com> - 20.1.6-2
- Disable LTO as it appears to break some games (#1862771)

* Thu Aug 20 2020 Pete Walter <pwalter@fedoraproject.org> - 20.1.6-1
- Update to 20.1.6

* Thu Aug 06 2020 Pete Walter <pwalter@fedoraproject.org> - 20.1.5-1
- Update to 20.1.5

* Tue Jul 28 2020 Fedora Release Engineering <releng@fedoraproject.org> - 20.1.4-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Thu Jul 23 2020 Pete Walter <pwalter@fedoraproject.org> - 20.1.4-1
- Update to 20.1.4

* Wed Jul 22 2020 Lyude Paul <lyude@redhat.com> - 20.1.3-2
- Fix build dependencies on certain arches

* Sat Jul 11 2020 Pete Walter <pwalter@fedoraproject.org> - 20.1.3-1
- Update to 20.1.3

* Thu Jun 25 2020 Pete Walter <pwalter@fedoraproject.org> - 20.1.2-1
- Update to 20.1.2

* Wed Jun 10 2020 Pete Walter <pwalter@fedoraproject.org> - 20.1.1-2
- Fix the build with Python 3.9

* Wed Jun 10 2020 Pete Walter <pwalter@fedoraproject.org> - 20.1.1-1
- Update to 20.1.1

* Thu May 28 2020 Dave Airlie <airlied@redhat.com> - 20.1.0-1
- Update to 20.1.0

* Thu May 21 2020 Dave Airlie <airlied@redhat.com> - 20.1.0~rc4-1
- Update to 20.1.0-rc4

* Thu May 14 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.7-1
- Update to 20.0.7

* Thu Apr 30 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.6-1
- Update to 20.0.6

* Thu Apr 23 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.5-2
- Drop upstreamed patch

* Thu Apr 23 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.5-1
- Update to 20.0.5

* Fri Apr 03 2020 Dave Airlie <airlied@redhat.com> - 20.0.4-1
- Update to 20.0.4 (fix spirv regression)

* Wed Apr 01 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.3-1
- Update to 20.0.3

* Thu Mar 19 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.2-1
- Update to 20.0.2

* Fri Mar 06 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.1-1
- Update to 20.0.1

* Wed Feb 26 2020 Kalev Lember <klember@redhat.com> - 20.0.0-2
- Fix the build with llvm 10

* Thu Feb 20 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.0-1
- Update to 20.0.0

* Fri Feb 14 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.0~rc3-1
- Update to 20.0.0~rc3

* Sat Feb 08 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.0~rc2-1
- Update to 20.0.0~rc2

* Sun Feb 02 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.0~rc1-2
- Update files list for arm drivers

* Sat Feb 01 2020 Pete Walter <pwalter@fedoraproject.org> - 20.0.0~rc1-1
- Update to 20.0.0~rc1

* Wed Jan 29 2020 Pete Walter <pwalter@fedoraproject.org> - 19.3.3-1
- Update to 19.3.3

* Thu Jan 23 2020 Tom Stellard <tstellar@redhat.com> - 19.3.2-3
- Link against libclang-cpp.so https://fedoraproject.org/wiki/Changes/Stop-
  Shipping-Individual-Component-Libraries-In-clang-lib-Package

* Thu Jan 23 2020 Tom Stellard <tstellar@redhat.com> - 19.3.2-2
- Build with -fcommon until upstream fixes omx build with gcc10

* Fri Jan 10 2020 Pete Walter <pwalter@fedoraproject.org> - 19.3.2-1
- Update to 19.3.2

* Wed Dec 18 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.1-1
- Update to 19.3.1

* Mon Dec 16 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.0-1
- Update to 19.3.0

* Thu Dec 05 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.0~rc6-1
- Update to 19.3.0~rc6

* Thu Nov 28 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.0~rc5-1
- Update to 19.3.0~rc5

* Sun Nov 24 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.0~rc4-1
- Update to 19.3.0~rc4

* Thu Nov 14 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.0~rc3-1
- Update to 19.3.0~rc3

* Tue Nov 12 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.0~rc2-2
- Fix the build on arm

* Fri Nov 08 2019 Pete Walter <pwalter@fedoraproject.org> - 19.3.0~rc2-1
- Update to 19.3.0~rc2

* Thu Nov 07 2019 Pete Walter <pwalter@fedoraproject.org> - 19.2.3-1
- Update to 19.2.3

* Fri Oct 25 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.2-5
- adjust mesa-khr-devel requires now provided by libglvnd

* Fri Oct 25 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.2-4
- Fix up and remove bits now in libglvnd

* Fri Oct 25 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.2-3
- rebuild against libglvnd 1.2

* Fri Oct 25 2019 Pete Walter <pwalter@fedoraproject.org> - 19.2.2-2
- Update files lists

* Fri Oct 25 2019 Pete Walter <pwalter@fedoraproject.org> - 19.2.2-1
- Update to 19.2.2

* Thu Oct 10 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.1-1
- 19.2.1

* Fri Oct 04 2019 Gwyn Ciesla <gwync@protonmail.com> - 19.2.0-2
- Rebuild for new freeglut.

* Wed Sep 25 2019 Pete Walter <pwalter@fedoraproject.org> - 19.2.0-1
- Update to 19.2.0

* Wed Sep 18 2019 Pete Walter <pwalter@fedoraproject.org> - 19.2.0~rc4-1
- Update to 19.2.0~rc4

* Tue Sep 17 2019 Adam Jackson <ajax@redhat.com> - 19.2.0~rc3-2
- Build iris too

* Thu Sep 12 2019 Pete Walter <pwalter@fedoraproject.org> - 19.2.0~rc3-1
- Update to 19.2.0~rc3

* Thu Sep 05 2019 Pete Walter <pwalter@fedoraproject.org> - 19.2.0~rc2-1
- Update to 19.2.0~rc2

* Tue Aug 27 2019 Adam Jackson <ajax@redhat.com> - 19.2.0~rc1-5
- BuildRequire vulkan-headers not vulkan-devel to ease llvm updates

* Thu Aug 22 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.0~rc1-4
- Bring back egl.pc for now

* Wed Aug 21 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.0~rc1-3
- add mxsfb-drm_dri and stm_dri drivers for arm platforms

* Wed Aug 21 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.0~rc1-2
- pkgconfig/egl.pc no longer shipped

* Wed Aug 21 2019 Peter Robinson <pbrobinson@gmail.com> - 19.2.0~rc1-1
- 19.2.0~rc1

* Thu Aug 08 2019 Pete Walter <pwalter@fedoraproject.org> - 19.1.4-1
- Update to 19.1.4

* Wed Jul 24 2019 Pete Walter <pwalter@fedoraproject.org> - 19.1.3-1
- Update to 19.1.3

* Tue Jul 09 2019 Pete Walter <pwalter@fedoraproject.org> - 19.1.2-1
- Update to 19.1.2

* Wed Jun 26 2019 Pete Walter <pwalter@fedoraproject.org> - 19.1.1-1
- Update to 19.1.1

* Mon Jun 24 2019 Peter Robinson <pbrobinson@gmail.com> - 19.1.0-2
- Enable v3d driver

* Wed Jun 12 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.1.0-1
- Update to 19.1.0

* Fri Jun 07 2019 Pete Walter <pwalter@fedoraproject.org> - 19.1.0~rc5-1
- Update to 19.1.0~rc5

* Thu May 30 2019 Pete Walter <pwalter@fedoraproject.org> - 19.1.0~rc4-1
- Update to 19.1.0~rc4

* Wed May 22 2019 Dave Airlie <airlied@redhat.com> - 19.1.0~rc3-1
- Update to 19.1.0-rc3

* Tue May 21 2019 Adam Jackson <ajax@redhat.com> - 19.1.0~rc2-2
- Delete unused patch

* Tue May 14 2019 Dave Airlie <airlied@redhat.com> - 19.1.0~rc2-1
- Update to 19.1.0-rc2

* Tue May 14 2019 Dave Airlie <airlied@redhat.com> - 19.1.0~rc1-8
- Bring back glesv2.pc for now

* Sat May 11 2019 Peter Robinson <pbrobinson@gmail.com> - 19.1.0~rc1-7
- Enable panfrost

* Thu May 09 2019 Adam Jackson <ajax@redhat.com> - 19.1.0~rc1-6
- Enable lima

* Thu May 09 2019 Adam Jackson <ajax@redhat.com> - 19.1.0~rc1-5
- Add some more stuff to .gitignore

* Wed May 08 2019 Dave Airlie <airlied@redhat.com> - 19.1.0~rc1-4
- add missing exynos driver

* Wed May 08 2019 Dave Airlie <airlied@redhat.com> - 19.1.0~rc1-3
- fix missing kmsro

* Wed May 08 2019 Dave Airlie <airlied@redhat.com> - 19.1.0~rc1-2
- add missing kmsro drivers

* Wed May 08 2019 Dave Airlie <airlied@redhat.com> - 19.1.0~rc1-1
- Update to 19.1.0-rc1

* Thu Apr 25 2019 Pete Walter <pwalter@fedoraproject.org> - 19.0.3-1
- Update to 19.0.3

* Tue Apr 16 2019 Adam Williamson <awilliam@redhat.com> - 19.0.2-5
- Rebuild with Meson fix for #1699099

* Mon Apr 15 2019 Pete Walter <pwalter@fedoraproject.org> - 19.0.2-4
- Remove unneeded chrpath build dep

* Sun Apr 14 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.2-3
- Remove unneeded sources

* Thu Apr 11 2019 Adam Jackson <ajax@redhat.com> - 19.0.2-2
- Drop the mpeg1/2 sanitize hack Switch to upstream tarball since we no
  longer need to do the above

* Thu Apr 11 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.2-1
- Update to 19.0.2

* Thu Apr 04 2019 Adam Jackson <ajax@redhat.com> - 19.0.1-2
- Nuke rpath from installed DRI drivers

* Wed Mar 27 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.1-1
- Update to 19.0.1

* Mon Mar 25 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.0-2
- Rebuild with -Db_ndebug=true

* Wed Mar 13 2019 Peter Robinson <pbrobinson@gmail.com> - 19.0.0-1
- 19.0.0

* Thu Mar 07 2019 Pete Walter <pwalter@fedoraproject.org> - 19.0.0~rc7-1
- Update to 19.0.0~rc7

* Wed Feb 27 2019 Pete Walter <pwalter@fedoraproject.org> - 19.0.0~rc6-1
- Update to 19.0.0~rc6

* Wed Feb 20 2019 Peter Robinson <pbrobinson@gmail.com> - 19.0.0~rc5-1
- 19.0.0~rc5

* Thu Feb 14 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.0~rc4-3
- Update EGL patch

* Thu Feb 14 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.0~rc4-2
- relax dependency of xcb-randr

* Thu Feb 14 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.0~rc4-1
- Update to 19.0.0~rc4

* Tue Feb 12 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.0~rc2-4
- Fix radv vulkan

* Fri Feb 08 2019 Pete Walter <pwalter@fedoraproject.org> - 19.0.0~rc2-3
- Add back accidentally lost patch to disable rgb10 configs by default
  (#1650929)

* Wed Feb 06 2019 Peter Robinson <pbrobinson@gmail.com> - 19.0.0~rc2-2
- update 19.0.0~rc2

* Wed Feb 06 2019 Peter Robinson <pbrobinson@gmail.com> - 19.0.0~rc2-1
- 19.0.0~rc2

* Thu Jan 31 2019 Peter Robinson <pbrobinson@gmail.com> - 19.0.0~rc1-3
- add kmsro build option, add work around for missing files in 'make dist'
  (fixed upstream)

* Thu Jan 31 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.0~rc1-2
- Switch imx to kmsro

* Thu Jan 31 2019 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 19.0.0~rc1-1
- Update to 19.0.0~rc1

* Thu Jan 17 2019 Adam Jackson <ajax@redhat.com> - 18.3.2-1
- Update to 18.3.2

* Wed Dec 19 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.1-3
- Enable annotated build

* Wed Dec 19 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.1-2
- Switch to meson buildsystem

* Tue Dec 18 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.1-1
- commit spec changes

* Tue Dec 18 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.0-2
- Update to 18.3.1

* Fri Dec 07 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.0-1
- Update to 18.3.0

* Fri Dec 07 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.0~rc5-3
- Remove unused patches

* Tue Dec 04 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.0~rc5-2
- Backport patch to fix totem

* Tue Dec 04 2018 Peter Robinson <pbrobinson@gmail.com> - 18.3.0~rc5-1
- 18.3.0 rc5

* Tue Nov 27 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.3.0~rc4-1
- Update to 18.3.0~rc4

* Thu Nov 15 2018 Adam Jackson <ajax@redhat.com> - 18.3.0~rc2-2
- Add mesa-khr-devel subpackage to hold <KHR/khrplatform.h>, and make mesa-
  lib{GL,GLES,EGL}-devel Require it.

* Wed Nov 14 2018 Adam Jackson <ajax@redhat.com> - 18.3.0~rc2-1
- Update to 18.3.0 RC2 Re-enable 10bpc fbconfigs, clutter apps seem to work
  now Drop now-unnecessary big-endian compilation fix

* Tue Nov 06 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.2.4-3
- Rebuild without workaround

* Mon Nov 05 2018 Dave Airlie <airlied@redhat.com> - 18.2.4-2
- workaround bug with gcc 8.2.1-4

* Thu Nov 01 2018 Adam Jackson <ajax@redhat.com> - 18.2.4-1
- Update to 18.2.4

* Wed Oct 31 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.2.3-1
- Update to 18.2.3

* Fri Oct 05 2018 Peter Robinson <pbrobinson@gmail.com> - 18.2.2-1
- 18.2.2

* Fri Sep 21 2018 Peter Robinson <pbrobinson@gmail.com> - 18.2.1-1
- 18.2.1

* Wed Sep 19 2018 Adam Williamson <awilliam@redhat.com> - 18.2.0-2
- Fix "HW cursor for format" error message flood with swrast

* Sat Sep 08 2018 Peter Robinson <pbrobinson@gmail.com> - 18.2.0-1
- 18.2.0

* Sun Sep 02 2018 Hans de Goede <hdegoede@redhat.com> - 18.2.0~rc5-1
- Update to 18.2.0~rc5

* Wed Aug 22 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.2.0~rc3-2
- Re-enable RadeonSI on ARM

* Tue Aug 21 2018 Peter Robinson <pbrobinson@gmail.com> - 18.2.0~rc3-1
- 18.2.0~rc3

* Sun Aug 19 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.2.0~rc2-4
- correct files

* Sun Aug 19 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.2.0~rc2-3
- no radeon vulkan driver on arm

* Sat Aug 11 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.2.0~rc2-2
- BR: xrandr

* Sat Aug 11 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.2.0~rc2-1
- Update to 18.2.0~rc2

* Mon Jul 30 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.5-1
- 18.1.5

* Mon Jul 23 2018 Dave Airlie <airlied@redhat.com> - 18.1.4-3
- bump glvnd requires

* Mon Jul 23 2018 Dave Airlie <airlied@redhat.com> - 18.1.4-2
- fix fallback path for glvnd

* Tue Jul 17 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.4-1
- 18.1.4

* Fri Jul 13 2018 Fedora Release Engineering <releng@fedoraproject.org> - 18.1.3-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_29_Mass_Rebuild

* Fri Jul 06 2018 Adam Jackson <ajax@redhat.com> - 18.1.3-3
- Drop texture float patch

* Sun Jul 01 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.1.3-2
- Use simpler %%ldconfig macro

* Sun Jul 01 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.3-1
- 18.1.3

* Fri Jun 29 2018 Adam Jackson <ajax@redhat.com> - 18.1.2-5
- Use ldconfig scriptlet macros

* Mon Jun 18 2018 Adam Jackson <ajax@redhat.com> - 18.1.2-4
- Create %%{_includedir}/vulkan unconditionally

* Mon Jun 18 2018 Adam Jackson <ajax@redhat.com> - 18.1.2-3
- Careful, only configure vulkan drivers if hardware

* Mon Jun 18 2018 Adam Jackson <ajax@redhat.com> - 18.1.2-2
- Build mesa-vulkan-drivers everywhere Build actual vulkan drivers on all
  but s390x

* Sat Jun 16 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.2-1
- 18.1.2

* Fri Jun 15 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-9
- Build tegra too

* Thu Jun 14 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-8
- libglvnd is epoched

* Thu Jun 14 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-7
- Change the name of the fallback GLX library

* Wed Jun 06 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-6
- this would all be easier if we just built amdgpu on arm32

* Wed Jun 06 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-5
- ,,,

* Tue Jun 05 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-4
- hrgnarhgnhrn

* Tue Jun 05 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-3
- Stop mentioning ppc and s390, we don't build for them anymore Remove
  with_llvm, now always true Switch with_radeonsi to be an exclude pattern,
  apparently not available for armv7hl.

* Tue Jun 05 2018 Adam Jackson <ajax@redhat.com> - 18.1.1-2
- Stop mentioning ppc and s390, we don't build for them anymore remove
  with_llvm and with_radeonsi as they're now always true

* Sun Jun 03 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.1-1
- 18.1.1

* Thu May 24 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.0-4
- 18.1.0

* Sat May 12 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.0-3
- 18.1.0~rc4

* Sat May 05 2018 Peter Robinson <pbrobinson@gmail.com> - 18.1.0-2
- 18.1 rc3

* Fri May 04 2018 Igor Gnatenko <ignatenkobrain@fedoraproject.org> - 18.1.0-1
- Update ot 18.1.0~rc2

* Tue May 01 2018 Peter Robinson <pbrobinson@gmail.com> - 18.0.2-2
- RPMAUTOSPEC: unresolvable merge
