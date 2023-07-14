Name:           mesa-va-drivers
Version:        1000.0.0
Release:        1%{?dist}
Summary:        Corrects a dependency issue between steam and mesa-va-drivers-freeworld on rpm-ostree distributions
License:        GPLv2
URL:            https://github.com/ublue-os/bazzite
BuildArch:      noarch

Source0:        https://raw.githubusercontent.com/ublue-os/bazzite/main/spec_files/%{name}/LICENSE

Requires:       mesa-va-drivers-freeworld
Provides:       mesa-va-drivers = %{version}

# Disable debug packages
%define debug_package %{nil}

%description
Corrects a dependency issue between steam and mesa-va-drivers-freeworld on rpm-ostree distributions

%install
mkdir -p %{buildroot}%{_datadir}/licenses/%{name}
cp %{SOURCE0} %{buildroot}%{_datadir}/licenses/%{name}/LICENSE

%files
%license LICENSE
