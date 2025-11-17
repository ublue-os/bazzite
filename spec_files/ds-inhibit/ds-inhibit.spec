Name:           ds-inhibit
Version:        {{{ git_dir_version }}}
Release:        2%{?dist}
Summary:        DualShock 4/DualSense mouse inhibitor
License:        BSD-2-Clause
URL:            https://github.com/evlav/

Source0:        %{url}ds-inhibit/archive/refs/heads/main.tar.gz
BuildArch:      noarch

Patch0:         fedora.patch

Requires:       python3
Requires:       python3-inotify

BuildRequires:  systemd-rpm-macros

%description
DualShock 4/DualSense mouse inhibitor

# Disable debug packages
%define debug_package %{nil}

%prep
%setup -n %{name}-main
%patch 0
chmod +x ds_inhibit.py

%build

%install
mkdir -p %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_unitdir}/
mkdir -p %{buildroot}%{_sysconfdir}/modules-load.d
cp -v ds_inhibit.py %{buildroot}%{_bindir}/ds-inhibit
cp -v systemd.service %{buildroot}%{_unitdir}/ds-inhibit.service

# Do post-installation
%post
%systemd_post ds-inhibit.service

# Do before uninstallation
%preun
%systemd_preun ds-inhibit.service

# Do after uninstallation
%postun
%systemd_postun_with_restart ds-inhibit.service

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%license LICENSE
%{_bindir}/ds-inhibit
%{_unitdir}/ds-inhibit.service

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
