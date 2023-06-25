Name:           mesa-va-drivers-freeworld-steamfix
Version:        1.0.0
Release:        1%{?dist}
Summary:        Corrects a dependency issue between steam and mesa-va-drivers-freeworld on rpm-ostree distributions
License:    	GPLv2
URL:            https://github.com/ublue-os/bazzite
BuildArch:      noarch

Source0:        https://github.com/ublue-os/bazzite/blob/yafti/spec_files/mesa-va-drivers-freeworld-steamfix/LICENSE

Requires:       mesa-va-drivers-freeworld
Provides:       mesa-va-drivers

%description
Corrects a dependency issue between steam and mesa-va-drivers-freeworld on rpm-ostree distributions

# Disable debug packages
%define debug_package %{nil}

%files
%license LICENSE
