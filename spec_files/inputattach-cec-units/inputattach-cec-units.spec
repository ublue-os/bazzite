Name:           inputattach-cec-units
Version:        2
Release:        1%{?dist}
Summary:        systemd units and udev rules for HDMI CEC dongles
License:        GPL-2.0-or-later
URL:            https://gitlab.steamos.cloud/holo/inputattach-cec-units
Source0:        %{url}/-/archive/v%{version}/%{name}-v%{version}.tar.gz
BuildArch:      noarch

BuildRequires:  make
BuildRequires:  pkgconf-pkg-config
BuildRequires:  systemd-rpm-macros

Requires:       linuxconsoletools
Requires:       systemd-udev

%description
A collection of systemd units and udev rules to automatically attach various
HDMI CEC dongles to Linux's CEC subsystem via the inputattach program.

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n %{name}-v%{version}

%build

%install
%make_install \
    PREFIX=%{_prefix} \
    UDEV_RULES_DIR=%{_udevrulesdir} \
    SYSTEMD_SYSTEM_UNIT_DIR=%{_unitdir}

# Do post-installation
%post
%systemd_post pulse8-cec-inputattach@.service rainshadow-cec-inputattach@.service

# Do before uninstallation
%preun
%systemd_preun pulse8-cec-inputattach@.service rainshadow-cec-inputattach@.service

# Do after uninstallation
%postun
%systemd_postun pulse8-cec-inputattach@.service rainshadow-cec-inputattach@.service

%files
%license %{_datadir}/licenses/%{name}/LICENSE
%doc %{_datadir}/doc/%{name}/README.md
%{_udevrulesdir}/60-inputattach-cec.rules
%{_unitdir}/pulse8-cec-inputattach@.service
%{_unitdir}/rainshadow-cec-inputattach@.service

%changelog
%autochangelog
