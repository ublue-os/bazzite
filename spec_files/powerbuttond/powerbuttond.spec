Name:           powerbuttond
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steam Deck power button daemon

License:        BSD
URL:            https://gitlab.com/evlaV/%{name}/
Source:         %{url}-/archive/main/%{name}-main.tar.gz

BuildRequires:  systemd-rpm-macros
BuildRequires:  libevdev-devel
BuildRequires:  cmake
BuildRequires:  gcc

Requires:       libevdev

%description
Steam Deck power button daemon

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n %{name}-main -p1

%build
%make_build

%install
install -D -m 755 %{name} %{buildroot}%{_bindir}/%{name}

%files
%license LICENSE
%{_bindir}/%{name}

%changelog
%autochangelog
