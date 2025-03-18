Name:           gnome-randr-rust
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        xrandr for Gnome/wayland, on distros that don't support wlr-randr

License:        MIT
URL:            https://github.com/maxwellainatchi/gnome-randr-rust
Source:         %{url}/archive/refs/heads/main.zip

BuildRequires:  rust-packaging >= 21
BuildRequires:  lm_sensors-devel
BuildRequires:  systemd-rpm-macros

%description
xrandr for Gnome/wayland, on distros that don't support wlr-randr

%prep
%setup -n %{name}-main
%cargo_prep

%generate_buildrequires
%cargo_generate_buildrequires

%build
%cargo_build

%install
%cargo_install
rm -rf %{buildroot}%{_datadir}/cargo/registry

%if %{with check}
%check
%cargo_test
%endif

%files
%{_bindir}/gnome-randr

%changelog
%autochangelog
