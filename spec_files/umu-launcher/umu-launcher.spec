%define commit 9b12f90b4e113275b5e8ea33a88674275bf3a1c8
%global shortcommit %(c=%{commit}; echo ${c:0:7})

%global build_timestamp %(date +"%Y%m%d")

%global rel_build 1.%{build_timestamp}.%{shortcommit}%{?dist}

Name:           umu-launcher
Version:        1.0
Release:        %{rel_build}
Summary:        A tool for launching non-steam games with proton

License:        GPLv3
URL:            https://github.com/Open-Wine-Components/umu-launcher

BuildArch:  noarch
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

Requires:	python
Requires:	python3
Requires:	python3-xlib


%description
%{name} A tool for launching non-steam games with proton

%prep
git clone --single-branch --branch main https://github.com/Open-Wine-Components/umu-launcher.git
cd umu-launcher
git checkout %{commit}
git submodule update --init --recursive

%build
cd umu-launcher
./configure.sh --prefix=/usr
make

%install
cd umu-launcher
make DESTDIR=%{buildroot} PYTHONDIR=%{python3_sitelib} install

%files
%{_bindir}/umu-run
%{_datadir}/man/*
%{_datadir}/steam/compatibilitytools.d/umu-launcher/
%{python3_sitelib}/umu*

%changelog

