Name:           vpower
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Service that calculates battery metrics and handles critical battery scenarios

License:        MIT
URL:            https://gitlab.com/evlaV/vpower/
Source:         %{url}-/archive/main/vpower-main.tar.gz
Patch0:         fedora.patch

BuildRequires:  rust-packaging >= 21
BuildRequires:  lm_sensors-devel
BuildRequires:  systemd-rpm-macros

Requires:       lm_sensors
Requires:       lm_sensors-libs

%description
Service that calculates battery metrics and handles critical battery scenarios

%prep
%autosetup -n %{name}-main -p1
%cargo_prep

%generate_buildrequires
%cargo_generate_buildrequires

%build
%cargo_build

%install
%cargo_install
mkdir -p %{buildroot}%{_libexecdir}
mv %{buildroot}%{_bindir}/%{name} %{buildroot}%{_libexecdir}/%{name}
mkdir -p %{buildroot}%{_unitdir}/
cp -v vpower.service %{buildroot}%{_unitdir}/%{name}.service
mkdir -p %{buildroot}%{_sysconfdir}/
cp -v vpower.toml %{buildroot}%{_sysconfdir}/%{name}.toml

%if %{with check}
%check
%cargo_test
%endif

# Do post-installation
%post
%systemd_post %{name}.service

# Do before uninstallation
%preun
%systemd_preun %{name}.service

# Do after uninstallation
%postun
%systemd_postun_with_restart %{name}.service

%files
%license LICENSE
%{_libexecdir}/%{name}
%{_unitdir}/%{name}.service
%{_sysconfdir}/%{name}.toml

%changelog
%autochangelog
