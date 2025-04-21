%bcond_without check
%if 0%{?rhel} >= 10 || 0%{?fedora} > 41
    %bcond_without ostree_ext
%else
    %bcond_with ostree_ext
%endif

%if 0%{?rhel}
    %bcond_without rhsm
%else
    %bcond_with rhsm
%endif

Name:           bootc
Version:        1.1.6
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
URL:            https://github.com/containers/bootc
Source0:        %{url}/releases/download/v%{version}/bootc-%{version}.tar.zstd
Source1:        %{url}/releases/download/v%{version}/bootc-%{version}-vendor.tar.zstd

Patch0: 0001-store-Really-remove-empty-etc-resolv.conf-and-etc-ho.patch

# https://github.com/antheas/bootc/commit/05519a979db0ee64a30663eba4e9ad0e68e6897b
Patch1: 05519a979db0ee64a30663eba4e9ad0e68e6897b.patch

# https://fedoraproject.org/wiki/Changes/EncourageI686LeafRemoval
ExcludeArch:    %{ix86}

BuildRequires: libzstd-devel
BuildRequires: make
BuildRequires: ostree-devel
BuildRequires: openssl-devel
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
# For OS updates
Requires: ostree
Requires: skopeo
Requires: podman
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

%global system_reinstall_bootc_install_podman_path %{_prefix}/lib/system-reinstall-bootc/install-podman

%prep
%autosetup -p1 -a1
# Default -v vendor config doesn't support non-crates.io deps (i.e. git)
cp .cargo/vendor-config.toml .
%cargo_prep -N
cat vendor-config.toml >> .cargo/config.toml
rm vendor-config.toml

%build
# Build the main bootc binary
%if 0%{?fedora} || 0%{?rhel} >= 10
    %cargo_build %{?with_rhsm:-f rhsm}
%else
    %cargo_build %{?with_rhsm:--features rhsm}
%endif

# Build the system reinstallation CLI binary
%global cargo_args -p system-reinstall-bootc
export SYSTEM_REINSTALL_BOOTC_INSTALL_PODMAN_PATH=%{system_reinstall_bootc_install_podman_path}
%if 0%{?fedora} || 0%{?rhel} >= 10
    # In cargo-rpm-macros, the cargo_build macro does flag processing,
    # so we need to pass '--' to signify that cargo_args is not part
    # of the macro args
    %cargo_build -- %cargo_args
%else
    # Older macros from rust-toolset do *not* do flag processing, so
    # '--' would be passed through to cargo directly, which is not
    # what we want.
    %cargo_build %cargo_args
%endif

%cargo_vendor_manifest
# https://pagure.io/fedora-rust/rust-packaging/issue/33
sed -i -e '/https:\/\//d' cargo-vendor.txt
%cargo_license_summary
%{cargo_license} > LICENSE.dependencies

%install
%make_install INSTALL="install -p -c"
%if %{with ostree_ext}
make install-ostree-hooks DESTDIR=%{?buildroot}
%endif
mkdir -p %{buildroot}/%{dirname:%{system_reinstall_bootc_install_podman_path}}
cat >%{?buildroot}/%{system_reinstall_bootc_install_podman_path} <<EOF
#!/bin/bash
exec dnf -y install podman
EOF
chmod +x %{?buildroot}/%{system_reinstall_bootc_install_podman_path}

%if %{with check}
%check
%cargo_test
%endif

%files
%license LICENSE-MIT
%license LICENSE-APACHE
%license LICENSE.dependencies
%license cargo-vendor.txt
%doc README.md
%{_bindir}/bootc
%{_prefix}/lib/bootc/
%{_prefix}/lib/systemd/system-generators/*
%if %{with ostree_ext}
%{_prefix}/libexec/libostree/ext/*
%endif
%{_unitdir}/*
%{_docdir}/bootc/*
%{_mandir}/man*/bootc*

%files -n system-reinstall-bootc
%{_bindir}/system-reinstall-bootc
%{system_reinstall_bootc_install_podman_path}

%changelog
%autochangelog

