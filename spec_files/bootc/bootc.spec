%bcond_without check
%bcond_with tests
%if 0%{?rhel} >= 9 || 0%{?fedora} > 41
    %bcond_without ostree_ext
%else
    %bcond_with ostree_ext
%endif

%if 0%{?rhel}
    %bcond_without rhsm
%else
    %bcond_with rhsm
%endif

%global rust_minor %(rustc --version | cut -f2 -d" " | cut -f2 -d".")

# https://github.com/bootc-dev/bootc/issues/1640
%if 0%{?fedora} || 0%{?rhel} >= 10 || 0%{?rust_minor} >= 89
    %global new_cargo_macros 1
%else
    %global new_cargo_macros 0
%endif

Name:           bootc
# Ensure this local build overrides anything else.
Version:        1.11.0
Release:        100.bazzite
Summary:        Bootable container system

# Apache-2.0
# Apache-2.0 OR BSL-1.0
# Apache-2.0 OR MIT
# Apache-2.0 WITH LLVM-exception OR Apache-2.0 OR MIT
# BSD-3-Clause
# MIT
# MIT OR Apache-2.0
# Unlicense OR MIT
License:        Apache-2.0 AND BSD-3-Clause AND MIT AND (Apache-2.0 OR BSL-1.0) AND (Apache-2.0 OR MIT) AND (Apache-2.0 WITH LLVM-exception OR Apache-2.0 OR MIT) AND (Unlicense OR MIT)
URL:            https://github.com/bootc-dev/bootc
Source0:        %{url}/releases/download/v%{version}/bootc-%{version}.tar.zstd
Source1:        %{url}/releases/download/v%{version}/bootc-%{version}-vendor.tar.zstd

Patch0:         unhide.patch

# https://fedoraproject.org/wiki/Changes/EncourageI686LeafRemoval
ExcludeArch:    %{ix86}

BuildRequires: libzstd-devel
BuildRequires: make
BuildRequires: ostree-devel
BuildRequires: openssl-devel
BuildRequires: go-md2man
%if 0%{?rhel}
BuildRequires: rust-toolset
%else
BuildRequires: cargo-rpm-macros >= 25
%endif
BuildRequires: systemd
# For tests
BuildRequires: skopeo ostree

# Backing storage tooling https://github.com/containers/composefs/issues/125
Requires: composefs
# Keep this list in sync with workspace.metadata.binary-dependencies until we sync
# it automatically
Requires: ostree
Requires: skopeo
Requires: podman
Requires: util-linux-core
Requires: /usr/bin/chcon
# For bootloader updates
Recommends: bootupd

# A made up provides so that rpm-ostree can depend on it
%if %{with ostree_ext}
Provides: ostree-cli(ostree-container)
%endif

%description
%{summary}

# (-n because we don't want the subpackage name to start with bootc-)
%package -n system-reinstall-bootc
Summary: Utility to reinstall the current system using bootc
Recommends: podman
# The reinstall subpackage intentionally does not require bootc, as it pulls in many unnecessary dependencies

%description -n system-reinstall-bootc
This package provides a utility to simplify reinstalling the current system to a given bootc image.

%if %{with tests}
%package tests
Summary: Integration tests for bootc
Requires: %{name} = %{version}-%{release}

%description tests
This package contains the integration test suite for bootc.
%endif

%global system_reinstall_bootc_install_podman_path %{_prefix}/lib/system-reinstall-bootc/install-podman

%if 0%{?container_build}
# Source is already at /src, no subdirectory
%global _buildsubdir .
%endif

%prep
%if ! 0%{?container_build}
%autosetup -p1 -a1
# Default -v vendor config doesn't support non-crates.io deps (i.e. git)
cp .cargo/vendor-config.toml .
%cargo_prep -N
cat vendor-config.toml >> .cargo/config.toml
rm vendor-config.toml
%else
# Container build: source already at _builddir (/src), nothing to extract
# RPM's %mkbuilddir creates a subdirectory; symlink it back to the source
cd ..
rm -rf %{name}-%{version}-build
ln -s . %{name}-%{version}-build
cd %{name}-%{version}-build
%endif

%build
export SYSTEM_REINSTALL_BOOTC_INSTALL_PODMAN_PATH=%{system_reinstall_bootc_install_podman_path}
# Build this first to avoid feature skew
make manpages

# Build all binaries
%if 0%{?container_build}
# Container build: use cargo directly with cached dependencies to avoid RPM macro overhead
cargo build -j%{_smp_build_ncpus} --release %{?with_rhsm:--features rhsm} --bins
%else
# Non-container build: use RPM macros for proper dependency tracking
%if %new_cargo_macros
    %cargo_build %{?with_rhsm:-f rhsm} -- --bins
%else
    %cargo_build %{?with_rhsm:--features rhsm} -- --bins
%endif
%endif

%if ! 0%{?container_build}
%cargo_vendor_manifest
# https://pagure.io/fedora-rust/rust-packaging/issue/33
sed -i -e '/https:\/\//d' cargo-vendor.txt
%cargo_license_summary
%{cargo_license} > LICENSE.dependencies
%endif

%install
%make_install INSTALL="install -p -c"
%if %{with ostree_ext}
make install-ostree-hooks DESTDIR=%{?buildroot}
%endif
%if %{with tests}
install -D -m 0755 target/release/tests-integration %{buildroot}%{_bindir}/bootc-integration-tests
%endif
mkdir -p %{buildroot}/%{dirname:%{system_reinstall_bootc_install_podman_path}}
cat >%{?buildroot}/%{system_reinstall_bootc_install_podman_path} <<EOF
#!/bin/bash
exec dnf -y install podman
EOF
chmod +x %{?buildroot}/%{system_reinstall_bootc_install_podman_path}
# generate doc file list excluding directories; workaround for
# https://github.com/coreos/rpm-ostree/issues/5420
touch %{?buildroot}/%{_docdir}/bootc/baseimage/base/sysroot/.keepdir
find %{?buildroot}/%{_docdir} ! -type d -printf '%{_docdir}/%%P\n' > bootcdoclist.txt

%if %{with check}
%check
if grep -qEe 'Seccomp:.*0$' /proc/self/status; then
    %cargo_test
else
    echo "skipping unit tests due to https://github.com/rpm-software-management/mock/pull/1613#issuecomment-3421908652"
fi
%endif

%files -f bootcdoclist.txt
%license LICENSE-MIT
%license LICENSE-APACHE
%if ! 0%{?container_build}
%license LICENSE.dependencies
%license cargo-vendor.txt
%endif
%doc README.md
%{_bindir}/bootc
%{_prefix}/lib/bootc/
%{_prefix}/lib/systemd/system-generators/*
%{_prefix}/lib/dracut/modules.d/51bootc/
%if %{with ostree_ext}
%{_prefix}/libexec/libostree/ext/*
%endif
%{_unitdir}/*
%{_mandir}/man*/*bootc*

%files -n system-reinstall-bootc
%{_bindir}/system-reinstall-bootc
%{system_reinstall_bootc_install_podman_path}

%if %{with tests}
%files tests
%{_bindir}/bootc-integration-tests
%endif

%changelog
%autochangelog

