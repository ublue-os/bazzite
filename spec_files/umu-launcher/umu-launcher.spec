# Tag is auto-inserted by workflow
%global tag 1.2.9

# Manual commit is auto-inserted by workflow
%global commit 7f9d3a19ddfc0f408fd79adbafdd9a737d8c2282

%global shortcommit %(c=%{commit}; echo ${c:0:7})

%global build_timestamp %(date +"%Y%m%d")

%global rel_build 1.%{build_timestamp}.%{shortcommit}%{?dist}

# F41 doesn't ship urllib3 >= 2.0 needed
%global urllib3 2.3.0

Name:           umu-launcher
Version:        %{tag}
Release:        %{rel_build}
Summary:        A tool for launching non-steam games with proton

License:        GPLv3
URL:            https://github.com/Open-Wine-Components/umu-launcher
Source0:        %{url}/archive/refs/tags/%{tag}.tar.gz#/%{name}-%{tag}.tar.gz
Source1:        https://github.com/urllib3/urllib3/releases/download/%{urllib3}/urllib3-%{urllib3}.tar.gz

BuildRequires:  meson >= 0.54.0
BuildRequires:  ninja-build
BuildRequires:  cmake
BuildRequires:  g++
BuildRequires:  gcc-c++
BuildRequires:  scdoc
BuildRequires:  git
BuildRequires:  python3-devel
BuildRequires:  python3-build
BuildRequires:  python3-installer
BuildRequires:  python3-hatchling
BuildRequires:  python
BuildRequires:  python3
BuildRequires:  python3-pip
BuildRequires:  libzstd-devel
BuildRequires:  python3-hatch-vcs = 0.4.0
BuildRequires:  python3-wheel
BuildRequires:  python3-xlib
BuildRequires:  python3-pyzstd
BuildRequires:  cargo

# Can't use these yet, F41 doesn't ship urllib3 >= 2.0 needed
#BuildRequires:  python3-urllib3

Requires:   python
Requires:   python3
Requires:   python3-xlib
Requires:   python3-filelock
Requires:   python3-pyzstd

# Can't use these yet, F41 doesn't ship urllib3 >= 2.0 needed
#Requires:  python3-urllib3

Recommends: python3-cbor2
Recommends: python3-xxhash
Recommends: libzstd

# We need this for now to allow umu's builtin urllib3 version to be used.
# Can be removed when python3-urllib3 version is bumped >= 2.0
AutoReqProv: no


%description
%{name} A tool for launching non-steam games with proton

%prep
%autosetup -p 1
if ! find subprojects/urllib3/ -mindepth 1 -maxdepth 1 | read; then
    # Directory is empty, perform action
    mv %{SOURCE1} .
    tar -xf urllib3-%{urllib3}.tar.gz
    rm *.tar.gz
    mv urllib3-%{urllib3}/* subprojects/urllib3/
fi

%build
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1
# Update this when fedora ships urllib3 >= 2.0
#./configure.sh --prefix=/usr --use-system-pyzstd --use-system-urllib
./configure.sh --prefix=/usr --use-system-pyzstd
make

%install
make DESTDIR=%{buildroot} PYTHONDIR=%{python3_sitelib} install

%files
%{_bindir}/umu-run
%{_datadir}/man/*
%{python3_sitelib}/umu*

%changelog
