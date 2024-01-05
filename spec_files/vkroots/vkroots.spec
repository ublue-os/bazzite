%global debug_package %{nil}
%global commit 2ceb105700e23842bec0e56a0a2cbd5885dfcf4b
%global shortcommit %(c=%{commit}; echo ${c:0:7})
%global git_date 20231118

Name:           vkroots
Version:        0^%{git_date}git%{shortcommit}
Release:        1%{?dist}
Summary:        A stupid simple method of making Vulkan layers, at home
License:        LGPL-2.1-or-later AND (Apache-2.0 or MIT)
URL:            https://github.com/Joshua-Ashton/vkroots
Source:         %{url}/archive/%{commit}/%{name}-%{shortcommit}.tar.gz

BuildRequires:  meson
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  vulkan-headers


%description
vkroots is a framework for writing Vulkan layers that
takes all the complexity/hastle away from you. It's so simple.


%package devel
Summary:        A stupid simple method of making Vulkan layers, at home

%description devel
vkroots is a framework for writing Vulkan layers that
takes all the complexity/hastle away from you. It's so simple.

%prep
%autosetup -p1 -n %{name}-%{commit}


%build
%meson
%meson_build


%install
%meson_install


%files devel
%license LICENSE
%doc README.md
%{_includedir}/%{name}.h
%{_libdir}/pkgconfig/%{name}.pc


%changelog
* Tue Jul 25 2023 Frantisek Zatloukal <fzatlouk@redhat.com> - 0^20230313gite554d4c-1
- Rebase to a later snapshot

* Fri Mar 03 2023 Onuralp SEZER <thunderbirdtr@fedoraproject.org> - 0^20230103git2675710-1
- Initial package vkroots
