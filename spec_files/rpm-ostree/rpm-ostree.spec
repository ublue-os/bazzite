# The canonical copy of this spec file is upstream at:
# https://github.com/coreos/rpm-ostree/blob/main/packaging/rpm-ostree.spec.in

Summary: Hybrid image/package system
Name: rpm-ostree
Version: 2024.9
Release: 100.bazzite
License: LGPL-2.0-or-later
URL: https://github.com/coreos/rpm-ostree
# This tarball is generated via "cd packaging && make -f Makefile.dist-packaging dist-snapshot"
# in the upstream git.  It also contains vendored Rust sources.
Source0: https://github.com/coreos/rpm-ostree/releases/download/v%{version}/rpm-ostree-%{version}.tar.xz

ExclusiveArch: %{rust_arches}

# ostree not on i686 for RHEL 10
# https://github.com/containers/composefs/pull/229#issuecomment-1838735764
%if 0%{?rhel} >= 10
ExcludeArch:    %{ix86}
%endif

BuildRequires: make
%if 0%{?rhel}
BuildRequires: rust-toolset
%else
BuildRequires: rust-packaging
BuildRequires: cargo
BuildRequires: rust
%endif

# Enable ASAN + UBSAN
%bcond_with sanitizers
# Embedded unit tests
%bcond_with bin_unit_tests
# Don't add the ostree-container binaries
%bcond_with ostree_ext

# This is copied from the libdnf spec
%if 0%{?rhel} && ! 0%{?centos}
%bcond_without rhsm
%else
%bcond_with rhsm
%endif

# RHEL (8,9) doesn't ship zchunk today.  Keep this in sync
# with libdnf: https://gitlab.com/redhat/centos-stream/rpms/libdnf/-/blob/762f631e36d1e42c63a794882269d26c156b68c1/libdnf.spec#L45
%if 0%{?rhel}
%bcond_with zchunk
%else
%bcond_without zchunk
%endif

# For the autofiles bits below
BuildRequires: python3-devel
# We always run autogen.sh
BuildRequires: autoconf automake libtool git
# For docs
BuildRequires: chrpath
BuildRequires: gtk-doc
BuildRequires: /usr/bin/g-ir-scanner
# Core requirements
# One way to check this: `objdump -p /path/to/rpm-ostree | grep LIBOSTREE` and pick the highest (though that might miss e.g. new struct members)
BuildRequires: pkgconfig(ostree-1) >= 2021.5
BuildRequires: pkgconfig(polkit-gobject-1)
BuildRequires: pkgconfig(json-glib-1.0)
BuildRequires: pkgconfig(rpm) >= 4.14.0
BuildRequires: pkgconfig(libarchive)
BuildRequires: pkgconfig(libsystemd)
BuildRequires: libcap-devel
BuildRequires: libattr-devel
# Needed by the ostree-ext crate
BuildRequires: libzstd-devel

# We currently interact directly with librepo (libdnf below also pulls it in,
# but duplicating to be clear)
BuildRequires: pkgconfig(librepo)

# Needed by curl-rust
BuildRequires: pkgconfig(libcurl)

BuildRequires: cmake
BuildRequires: pkgconfig(expat)
BuildRequires: pkgconfig(check)

# We use some libsolv types directly too (libdnf below also pulls it in,
# but duplicating to be clear)
BuildRequires: pkgconfig(libsolv)

# These are build deps which aren't strictly required in Koji/Brew builds, but
# are required for git builds. Since they're few and tiny, we just add it here
# to keep it part of `dnf builddep`.
BuildRequires: jq

#########################################################################
#                         libdnf build deps                             #
#                                                                       #
# Copy/pasted from libdnf/libdnf.spec. Removed the irrelevant bits like #
# valgrind, rhsm, swig, python, and sanitizer stuff.                    #
#########################################################################


%global libsolv_version 0.7.21
%global libmodulemd_version 2.13.0
%global librepo_version 1.13.1

BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  libsolv-devel >= %{libsolv_version}
BuildRequires:  pkgconfig(librepo) >= %{librepo_version}
BuildRequires:  pkgconfig(check)
BuildRequires:  pkgconfig(gio-unix-2.0) >= 2.46.0
BuildRequires:  pkgconfig(gtk-doc)
BuildRequires:  rpm-devel >= 4.15.0
%if %{with rhsm}
BuildRequires:  pkgconfig(librhsm) >= 0.0.3
%endif
%if %{with zchunk}
BuildRequires:  pkgconfig(zck) >= 0.9.11
%endif
BuildRequires:  pkgconfig(sqlite3)
BuildRequires:  pkgconfig(json-c)
BuildRequires:  pkgconfig(cppunit)
BuildRequires:  pkgconfig(modulemd-2.0) >= %{libmodulemd_version}
BuildRequires:  pkgconfig(smartcols)
BuildRequires:  gettext
BuildRequires:  gpgme-devel

Requires:       libmodulemd%{?_isa} >= %{libmodulemd_version}
Requires:       libsolv%{?_isa} >= %{libsolv_version}
Requires:       librepo%{?_isa} >= %{librepo_version}

#########################################################################
#                     end of libdnf build deps                          #
#########################################################################

# For now...see https://github.com/projectatomic/rpm-ostree/pull/637
# and https://github.com/fedora-infra/fedmsg-atomic-composer/pull/17
# etc.  We'll drop this dependency at some point in the future when
# rpm-ostree wraps more of ostree (such as `ostree admin unlock` etc.)
Requires: ostree
Requires: bubblewrap
Requires: fuse3

# ref https://github.com/coreos/rpm-ostree/issues/4994
Requires: bootc
%if %{without ostree_ext}
Requires: ostree-cli(ostree-container)
%endif
# For container functionality
# https://github.com/coreos/rpm-ostree/issues/3286
Requires: skopeo

Requires: %{name}-libs%{?_isa} = %{version}-%{release}

%description
rpm-ostree is a hybrid image/package system.  It supports
"composing" packages on a build server into an OSTree repository,
which can then be replicated by client systems with atomic upgrades.
Additionally, unlike many "pure" image systems, with rpm-ostree
each client system can layer on additional packages, providing
a "best of both worlds" approach.

%package libs
Summary: Shared library for rpm-ostree

%description libs
The %{name}-libs package includes the shared library for %{name}.

%package devel
Summary: Development headers for %{name}
Requires: %{name}-libs%{?_isa} = %{version}-%{release}

%description devel
The %{name}-devel package includes the header files for %{name}-libs.

%prep
%autosetup -Sgit -n %{name}-%{version} -p1
%if 0%{?__isa_bits} == 32
sed -ie 's,^lto = true,lto = false,' Cargo.toml
%endif

%build
env NOCONFIGURE=1 ./autogen.sh
# Since we're hybrid C++/Rust we need to propagate this manually;
# the %%configure macro today assumes (reasonably) that one is building
# C/C++ and sets C{,XX}FLAGS
%if 0%{?build_rustflags:1}
export RUSTFLAGS="%{build_rustflags}"
%endif
%configure --disable-silent-rules --enable-gtk-doc %{?rpmdb_default} %{?with_sanitizers:--enable-sanitizers}  %{?with_bin_unit_tests:--enable-bin-unit-tests} \
  %{?with_rhsm:--enable-featuresrs=rhsm}

%make_build
%if 0%{?fedora} || 0%{?rhel} >= 10
%cargo_license_summary
%{cargo_license} > LICENSE.dependencies
%cargo_vendor_manifest
%endif

%install
%make_install INSTALL="install -p -c"
%if %{without ostree_ext}
rm -vrf $RPM_BUILD_ROOT/usr/libexec/libostree/ext
%endif
find $RPM_BUILD_ROOT -name '*.la' -delete

# I try to do continuous delivery via rpmdistro-gitoverlay while
# reusing the existing spec files.  Currently RPM only supports
# mandatory file entries.  What this is doing is making each file
# entry optional - if it exists it will be picked up.  That
# way the same spec file works more easily across multiple versions where e.g. an
# older version might not have a systemd unit file.
cat > autofiles.py <<EOF
import os,sys,glob
os.chdir(os.environ['RPM_BUILD_ROOT'])
for line in sys.argv[1:]:
    if line == '':
        break
    if line[0] != '/':
        sys.stdout.write(line + '\n')
    else:
        files = glob.glob(line[1:])
        if len(files) > 0:
            sys.stderr.write('{0} matched {1} files\n'.format(line, len(files)))
            sys.stdout.write(line + '\n')
        else:
            sys.stderr.write('{0} did not match any files\n'.format(line))
EOF
PYTHON='%{python3}'
if ! test -x '%{python3}'; then
    PYTHON=python2
fi
$PYTHON autofiles.py > files \
  '%{_bindir}/*' \
  '%{_libdir}/%{name}' \
  '%{_mandir}/man*/*' \
  '%{_datadir}/dbus-1/system.d/*' \
  '%{_sysconfdir}/rpm-ostreed.conf' \
  '%{_prefix}/lib/systemd/system/*' \
  '%{_libexecdir}/rpm-ostree*' \
%if %{with ostree_ext}
  '%{_libexecdir}/libostree/ext/*' \
%endif
  '%{_datadir}/polkit-1/actions/*.policy' \
  '%{_datadir}/dbus-1/system-services/*' \
  '%{_datadir}/bash-completion/completions/*'

$PYTHON autofiles.py > files.lib \
  '%{_libdir}/*.so.*' \
  '%{_libdir}/girepository-1.0/*.typelib'

$PYTHON autofiles.py > files.devel \
  '%{_libdir}/lib*.so' \
  '%{_includedir}/*' \
  '%{_datadir}/dbus-1/interfaces/org.projectatomic.rpmostree1.xml' \
  '%{_libdir}/pkgconfig/*' \
  '%{_datadir}/gtk-doc/html/*' \
  '%{_datadir}/gir-1.0/*-1.0.gir'

# Setup rpm-ostree-countme.timer according to presets
%post
%systemd_post rpm-ostree-countme.timer
# Only enable on rpm-ostree based systems and manually force unit enablement to
# explicitly ignore presets for this security fix
if [ -e /run/ostree-booted ]; then
    ln -snf /usr/lib/systemd/system/rpm-ostree-fix-shadow-mode.service  /usr/lib/systemd/system/multi-user.target.wants/
fi

%preun
%systemd_preun rpm-ostree-countme.timer

%postun
%systemd_postun_with_restart rpm-ostree-countme.timer

%files -f files
%doc COPYING.GPL COPYING.LGPL LICENSE README.md

%files libs -f files.lib
%if 0%{?fedora} || 0%{?rhel} >= 10
%license LICENSE.dependencies
%license cargo-vendor.txt
%endif

%files devel -f files.devel

%changelog
%autochangelog
