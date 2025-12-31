Name:           bees
Version:        0.11
Release:        %autorelease
Summary:        Best-Effort Extent-Same, a btrfs dedupe agent

License:        GPL-3.0-only AND MIT AND Zlib
URL:            https://github.com/Zygo/bees

Source:         %{url}/archive/v%{version}/%{name}-v%{version}.tar.gz

# https://github.com/Zygo/bees/pull/286
Patch0:         286.patch

# https://github.com/Zygo/bees/pull/309
Patch1:         309.patch

BuildRequires:  make
BuildRequires:  gcc-c++
BuildRequires:  btrfs-progs-devel
BuildRequires:  systemd-rpm-macros

%description
bees is a block-oriented userspace deduplication agent designed for
large btrfs filesystems. It is an offline dedupe combined with an
incremental data scan capability to minimize time data spends on disk
from write to dedupe.

%prep
%autosetup -p1

%conf
cat <<EOF > localconf
BEES_VERSION=v%{version}
DEFAULT_MAKE_TARGET=all
LIBEXEC_PREFIX=%{_libexecdir}/%{name}
LIB_PREFIX=%{_libdir}
PREFIX=%{_prefix}
BINDIR=bin
SYSTEMD_SYSTEM_UNIT_DIR=%{_unitdir}
EOF

%build
%make_build

%install
%make_install

%post
%systemd_post 'bees@*.service'
 
%preun
%systemd_preun 'bees@*.service'

%postun
%systemd_postun_with_restart 'bees@*.service'

%check
make test

%files
%license COPYING
%doc README.md
%{_bindir}/beesd
%{_libexecdir}/%{name}
%{_unitdir}/beesd@.service
%{_sysconfdir}/%{name}/
%config %{_sysconfdir}/%{name}/beesd.conf.sample

%changelog
%autochangelog
