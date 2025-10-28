Name:           jupiter-fan-control
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Steam Deck Fan Controller
License:        MIT
URL:            https://github.com/evlav/jupiter-fan-control/

Source:         %{url}archive/refs/heads/main.tar.gz
BuildArch:      noarch

Patch0:         fedora.patch

Requires:       python3

BuildRequires:  systemd-rpm-macros

%description
SteamOS 3.0 Steam Deck Fan Controller

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n %{name}-main -p1

%build

%install
mkdir -p %{buildroot}%{_unitdir}/
mkdir -p %{buildroot}%{_datadir}/jupiter-fan-control
mkdir -p %{buildroot}%{_libexecdir}/jupiter-fan-control
cp -v usr/share/jupiter-fan-control/*.yaml %{buildroot}%{_datadir}/jupiter-fan-control/
cp -v usr/share/jupiter-fan-control/*.py %{buildroot}%{_libexecdir}/jupiter-fan-control/
cp -v usr/lib/systemd/system/jupiter-fan-control.service %{buildroot}%{_unitdir}/jupiter-fan-control.service

# Do post-installation
%post
%systemd_post jupiter-fan-control.service

# Do before uninstallation
%preun
%systemd_preun jupiter-fan-control.service

# Do after uninstallation
%postun
%systemd_postun_with_restart jupiter-fan-control.service

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%doc README.md
%{_libexecdir}/jupiter-fan-control/fancontrol.py
%{_libexecdir}/jupiter-fan-control/PID.py
%{_datadir}/jupiter-fan-control/*.yaml
%{_unitdir}/jupiter-fan-control.service

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}