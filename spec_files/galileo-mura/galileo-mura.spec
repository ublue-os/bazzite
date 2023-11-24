Name:           galileo-mura
Version:        {{{ git_dir_version }}}
Release:        1%{?dist}
Summary:        Utilities for setting and reading mura correction on Galileo
License:        MIT
URL:            https://github.com/ublue-os/bazzite

Source:         https://gitlab.com/evlaV/galileo-mura-extractor/-/archive/main/galileo-mura-extractor-main.tar.gz

BuildRequires:  systemd-rpm-macros
BuildRequires:  gcc
BuildRequires:  meson >= 0.54.0
BuildRequires:  ninja-build

%description
Utilities for setting and reading mura correction on Galileo

# Disable debug packages
%define debug_package %{nil}

%prep
%autosetup -n galileo-mura-extractor-main

%build
%meson
%meson_build

%install
%meson_install

# This lists all the files that are included in the rpm package and that
# are going to be installed into target system where the rpm is installed.
%files
%license LICENSE
%attr(4755, root, root) %{_bindir}/galileo-mura-extractor
%{_bindir}/galileo-mura-setup

# Finally, changes from the latest release of your application are generated from
# your project's Git history. It will be empty until you make first annotated Git tag.
%changelog
{{{ git_dir_changelog }}}
