%undefine _hardened_build

Name: sunshine
Version: 2026.516.143833
Release: 1%{?dist}.bazzite
Summary: Self-hosted game stream host for Moonlight.
License: GPLv3-only
URL: https://github.com/LizardByte/Sunshine

Source0: sunshine-service-override.conf

Patch0: disable-std-static-linking.patch
Patch1: cuda-use-external-deps.patch
Patch2: disable-codecov.patch

BuildRequires: cmake
BuildRequires: curl
BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: git
BuildRequires: libcap-devel
BuildRequires: libcurl-devel
BuildRequires: libdrm-devel
BuildRequires: libevdev-devel
BuildRequires: libva-devel
BuildRequires: mesa-libgbm-devel
BuildRequires: micromamba
BuildRequires: miniupnpc-devel
BuildRequires: nodejs
BuildRequires: npm
BuildRequires: numactl-devel
BuildRequires: opus-devel
BuildRequires: pipewire-devel
BuildRequires: pulseaudio-libs-devel
BuildRequires: systemd-rpm-macros
BuildRequires: systemd-udev
BuildRequires: vulkan-devel
BuildRequires: glslc
BuildRequires: libXfixes-devel
BuildRequires: libXrandr-devel
BuildRequires: python3-jinja2
BuildRequires: python3-setuptools
BuildRequires: uv
BuildRequires: libappindicator-gtk3-devel
BuildRequires: libnotify-devel
%if 0%{?fedora} >= 45
# fix(crypto): OpenSSL 4.x compatibility (#5330)
BuildRequires: openssl3-devel
%else
BuildRequires: openssl-devel
%endif

%description
Self-hosted game stream host for Moonlight.

%define sourcedir %{_builddir}/%{name}
%define cudadir %{_builddir}/cuda-env

%prep
# Install cuda compiler (nvcc) with mamba (Anaconda packages)
micromamba create -y -p %{cudadir} conda-forge::cuda-nvcc

# Release tarballs are incomplete and cmake is using git commands
git clone --branch=v%{version} --depth=1 %{url}.git %{sourcedir}
cd %{sourcedir}
git submodule update --init --depth 1 --recursive
%autopatch -p1

%build
cd %{sourcedir}

export BRANCH=master
export BUILD_VERSION=v%{version}
export COMMIT=$(git rev-parse HEAD)

cmake_args=(
  "-B=build"
  "-G=Unix Makefiles"
  "-S=."
  "-DBUILD_DOCS=OFF"
  "-DBUILD_TESTS=OFF"
  "-DBUILD_WERROR=OFF"
  "-DCMAKE_BUILD_TYPE=Release"
  "-DCMAKE_INSTALL_PREFIX=%{_prefix}"
  "-DSUNSHINE_ASSETS_DIR=%{_datadir}/sunshine"
  "-DSUNSHINE_EXECUTABLE_PATH=%{_bindir}/sunshine"
  "-DSUNSHINE_ENABLE_X11=ON"
  "-DSUNSHINE_ENABLE_WAYLAND=ON"
  "-DSUNSHINE_ENABLE_DRM=ON"
  "-DSUNSHINE_ENABLE_PORTAL=ON"
  "-DSUNSHINE_ENABLE_VULKAN=ON"
  "-DSUNSHINE_ENABLE_KWIN=ON"
  "-DSUNSHINE_PUBLISHER_NAME=copr:ublue-os:bazzite"
  "-DSUNSHINE_PUBLISHER_WEBSITE=https://copr.fedorainfracloud.org/coprs/ublue-os/bazzite/sunshine"
  "-DSUNSHINE_PUBLISHER_ISSUE_URL=https://github.com/ublue-os/bazzite/issues"
  "-DSUNSHINE_ENABLE_CUDA=ON"
  "-DCMAKE_CUDA_COMPILER=%{cudadir}/bin/nvcc"
  "-DCMAKE_CUDA_HOST_COMPILER=%{cudadir}/bin/%{_arch}-conda-linux-gnu-g++"
  "-DSUNSHINE_CUDA_LIBRARY_PATH=%{cudadir}/lib"
)
cmake "${cmake_args[@]}"
make -j$(nproc) -C "build"

%install
cd %{sourcedir}/build
%make_install

# Keep old service with symlink
if [ ! -f %{buildroot}%{_userunitdir}/sunshine.service ] \
  && [ -f %{buildroot}%{_userunitdir}/app-dev.lizardbyte.app.Sunshine.service ]; \
then
  ln -s app-dev.lizardbyte.app.Sunshine.service %{buildroot}%{_userunitdir}/sunshine.service
fi

# Install service override to start properly on Gnome
install -Dm0644 %{SOURCE0} %{buildroot}%{_userunitdir}/sunshine.service.d/override.conf

%check
if [ ! -f %{buildroot}%{_userunitdir}/sunshine.service ]; then
  echo "Error: missing sunshine.service" >&2
  exit 1
fi
if [ ! -f %{buildroot}%{_userunitdir}/sunshine.service.d/override.conf ]; then
  echo "Error: missing sunshine.service.d/override.conf" >&2
  exit 1
fi

%post
if ! command -v rpm-ostree >/dev/null 2>&1; then
  modprobe uhid || :
  udevadm control --reload-rules || :
  udevadm trigger || :
fi
%systemd_user_post sunshine.service

%preun
%systemd_user_preun sunshine.service

%postun
if ! command -v rpm-ostree >/dev/null 2>&1; then
  udevadm control --reload-rules || :
fi
%systemd_user_postun_with_restart sunshine.service

%files
%caps(cap_sys_admin,cap_sys_nice+p) %{_bindir}/sunshine
%{_userunitdir}/*.service
%{_userunitdir}/sunshine.service.d/override.conf
%{_udevrulesdir}/*-sunshine.rules
%{_modulesloaddir}/*-sunshine.conf
%{_datadir}/applications/*.desktop
%{_datadir}/icons/hicolor/scalable/**/*.svg
%{_datadir}/metainfo/*.metainfo.xml
%{_datadir}/sunshine/**
