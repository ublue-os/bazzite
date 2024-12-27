Name:           sunshine-fix
Version:        2024.911.215655
Release:        100%{?dist}
Summary:        Corrects a name change issue between original unofficial sunshine builds and the new official ones
License:    	GPLv2
URL:            https://github.com/ublue-os/bazzite
BuildArch:      noarch

Source0:        LICENSE

Requires:       Sunshine
Provides:       sunshine = %{version}
Obsoletes:      sunshine <= %{version}

%description
Corrects a name change issue between original unofficial sunshine builds and the new official ones

# Disable debug packages
%define debug_package %{nil}

%install
mkdir -p %{buildroot}%{_defaultlicensedir}/%{name}
install -D -m 0644 %{SOURCE0} %{buildroot}%{_defaultlicensedir}/%{name}/LICENSE

%files
%license LICENSE