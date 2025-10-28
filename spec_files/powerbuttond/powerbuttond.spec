Name:           powerbuttond
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steam Deck power button daemon

License:        BSD
URL:            https://github.com/evlav/%{name}/
Source:         %{url}/archive/refs/heads/main.tar.gz

BuildRequires:  systemd-rpm-macros
BuildRequires:  libevdev-devel
BuildRequires:  libudev-devel
BuildRequires:  cmake
BuildRequires:  gcc

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
