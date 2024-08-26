%define commit 83cd26eb9ebca69a155d83e907679fdee11ca039
%global shortcommit %(c=%{commit}; echo ${c:0:7})
%global build_timestamp %(date +"%Y%m%d")
%global rel_build git.%{build_timestamp}.%{shortcommit}%{?dist}
%define _disable_source_fetch 0

Name:           scx-scheds
Version:        1.0.3
Release:        %{rel_build}
Summary:        Sched_ext Schedulers and Tools

License:        GPL=2.0
URL:            https://github.com/sched-ext/scx
Source0:        %{URL}/archive/%{commit}.tar.gz

BuildRequires:  gcc
BuildRequires:  git
BuildRequires:  meson >= 1.2
BuildRequires:  python
BuildRequires:  cargo
BuildRequires:  rust
BuildRequires:  clang >= 17
BuildRequires:  llvm >= 17
BuildRequires:  lld >= 17
BuildRequires:  elfutils-libelf
BuildRequires:  elfutils-libelf-devel
BuildRequires:  zlib
BuildRequires:  jq
BuildRequires:  jq-devel
BuildRequires:  systemd
Requires:  elfutils-libelf
Requires:  zlib
Requires:  jq

%description
sched_ext is a Linux kernel feature which enables implementing kernel thread schedulers in BPF and dynamically loading them. This repository contains various scheduler implementations and support utilities.

%prep
%autosetup -n scx-%{commit}

%build
%meson \
 -Dsystemd=enabled \
 -Dopenrc=disabled \
 -Dlibalpm=disabled
%meson_build


%install
%meson_install


%files
%{_bindir}/*
%{_prefix}/lib/systemd/system/scx.service
%attr(0644,root,root) %config(noreplace) %{_sysconfdir}/default/scx
%{_sysconfdir}/systemd/journald@sched-ext.conf
