## START: Set by rpmautospec
## (rpmautospec version 0.3.5)
## RPMAUTOSPEC: autorelease, autochangelog
%define autorelease(e:s:pb:n) %{?-p:0.}%{lua:
    release_number = 2;
    base_release_number = tonumber(rpm.expand("%{?-b*}%{!?-b:1}"));
    print(release_number + base_release_number - 1);
}%{?-e:.%{-e*}}%{?-s:.%{-s*}}%{!?-n:%{?dist}}
## END: Set by rpmautospec

%global appname MangoHud

%global imgui_ver 1.89.9
%global imgui_wrap_ver 2
%global vulkan_headers_ver 1.2.158
%global vulkan_headers_wrap_ver 1
%global implot_ver 0.16
%global implot_wrap_ver 2

%global tarball_version master

# Tests requires bundled stuff. Disable for now.
%ifnarch s390x
%bcond_without tests
%endif

# Disable unpackaged files check for 32-bit builds shipping with conflicting files
%if %{__isa_bits} != 64
  %define _unpackaged_files_terminate_build 0
%endif

Name:           mangohud
Version:        100.0.7.2
Release:        %autorelease
Summary:        Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load

License:        MIT
URL:            https://github.com/flightlessmango/MangoHud
# git clone --recurse-submodules https://github.com/flightlessmango/MangoHud MangoHud-master
# tar -cvzf master.tar.gz MangoHud-master
Source0:        master.tar.gz
Source1:        https://github.com/ocornut/imgui/archive/v%{imgui_ver}/imgui-%{imgui_ver}.tar.gz
Source2:        https://wrapdb.mesonbuild.com/v%{imgui_wrap_ver}/imgui_%{imgui_ver}-1/get_patch#/imgui-%{imgui_ver}-%{imgui_wrap_ver}-wrap.zip
Source3:        https://github.com/epezent/implot/archive/v%{implot_ver}/implot-%{implot_ver}.tar.gz
Source4:        https://wrapdb.mesonbuild.com/v%{implot_wrap_ver}/implot_%{implot_ver}-1/get_patch#/implot-%{implot_ver}-%{implot_wrap_ver}-wrap.zip
Source5:        https://github.com/KhronosGroup/Vulkan-Headers/archive/v%{vulkan_headers_ver}/Vulkan-Headers-%{vulkan_headers_ver}.tar.gz
Source6:        https://wrapdb.mesonbuild.com/v%{vulkan_headers_wrap_ver}/projects/vulkan-headers/%{vulkan_headers_ver}/%{vulkan_headers_wrap_ver}/get_zip#/vulkan-headers-%{vulkan_headers_ver}-%{vulkan_headers_wrap_ver}-wrap.zip

BuildRequires:  appstream
BuildRequires:  dbus-devel
BuildRequires:  gcc-c++
BuildRequires:  git-core
BuildRequires:  glew-devel
BuildRequires:  glfw-devel
BuildRequires:  glslang-devel
BuildRequires:  libappstream-glib
BuildRequires:  libstdc++-static
BuildRequires:  mesa-libGL-devel
BuildRequires:  meson >= 0.60
BuildRequires:  python3-mako
BuildRequires:  spdlog-devel
BuildRequires:  pkgconfig(dbus-1)
BuildRequires:  pkgconfig(dri)
BuildRequires:  pkgconfig(gl)
BuildRequires:  pkgconfig(glew)
BuildRequires:  pkgconfig(glfw3)
BuildRequires:  pkgconfig(libdrm)
BuildRequires:  pkgconfig(xkbcommon)
BuildRequires:  pkgconfig(nlohmann_json)
# Tip and memo if upstream decide to unbundle vulkan-headers
# BuildRequires:  pkgconfig(vulkan) < 1.3.241
BuildRequires:  pkgconfig(wayland-client)
BuildRequires:  pkgconfig(x11)

Requires:       python3-matplotlib
Requires:       python3-numpy

%if %{with tests}
BuildRequires:  libcmocka-devel
%endif

Requires:       hicolor-icon-theme
Requires:       vulkan-loader%{?_isa}

Recommends:     (mangohud(x86-32) if glibc(x86-32))

Suggests:       goverlay

Provides:       bundled(imgui) = %{imgui_ver}
Provides:       bundled(vulkan-headers) = %{vulkan_headers_ver}

%global _description %{expand:
A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and
more.

To install GUI front-end:

  # dnf install goverlay}

%description %{_description}


%prep
%autosetup -n %{appname}-%{tarball_version} -p1
%setup -qn %{appname}-%{tarball_version} -D -T -a1
%setup -qn %{appname}-%{tarball_version} -D -T -a2
%setup -qn %{appname}-%{tarball_version} -D -T -a3
%setup -qn %{appname}-%{tarball_version} -D -T -a4
%setup -qn %{appname}-%{tarball_version} -D -T -a5
%setup -qn %{appname}-%{tarball_version} -D -T -a6

mv imgui-%{imgui_ver} subprojects/
mv implot-%{implot_ver} subprojects/
mv Vulkan-Headers-%{vulkan_headers_ver} subprojects/

%if %{with tests}
# Use system cmocka instead of subproject
# https://gitlab.archlinux.org/archlinux/packaging/packages/mangohud/-/blob/0.6.9.1-10/PKGBUILD?ref_type=tags#L32
sed -i "s/  cmocka = subproject('cmocka')//g" meson.build
sed -i "s/cmocka_dep = cmocka.get_variable('cmocka_dep')/cmocka_dep = dependency('cmocka')/g" meson.build
%endif

%build
%meson \
    -Dmangoapp=true \
    -Dmangoapp_layer=true \
    -Dmangohudctl=true \
    -Dinclude_doc=true \
    -Duse_system_spdlog=enabled \
    -Dwith_wayland=enabled \
    -Dwith_xnvctrl=disabled \
    %if %{with tests}
    -Dtests=enabled \
    %else
    -Dtests=disabled \
    %endif
    %{nil}
%meson_build


%install
%meson_install

# ERROR: ambiguous python shebang
sed -i "s@#!/usr/bin/env python@#!/usr/bin/python3@" \
    %{buildroot}%{_bindir}/mangoplot

%check
# https://github.com/flightlessmango/MangoHud/issues/812
# ? tag-invalid           : stock icon is not valid [io.github.flightlessmango.mangohud]
%dnl appstream-util validate-relax --nonet %{buildroot}%{_metainfodir}/*.xml
%if %{with tests}
%meson_test
%endif


%files
%license LICENSE
%doc README.md
%if %{__isa_bits} == 64
%{_bindir}/%{name}*
%{_bindir}/mangoapp
%{_bindir}/mangoplot
%{_datadir}/icons/hicolor/scalable/*/*.svg
%{_docdir}/%{name}/%{appname}.conf.example
%{_docdir}/%{name}/presets.conf.example
%{_mandir}/man1/%{name}.1*
%{_mandir}/man1/mangoapp.1*
%{_metainfodir}/*.metainfo.xml
%endif
%{_datadir}/vulkan/implicit_layer.d/*Mango*.json
%{_libdir}/%{name}/

%changelog
* Mon Oct 02 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.7.0-6
- build: Fix description about 'mangoplot'

* Mon Oct 02 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.7.0-5
- build: mangohud-mangoplot as Suggests

* Thu Sep 28 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.7.0-4
- build: Add missed deps for mangoplot

* Thu Sep 28 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.7.0-3
- build: Package mangoplot as separate sub-package

* Thu Sep 28 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.7.0-2
- build: Upload sources

* Thu Sep 28 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.7.0-1
- build: Update to 0.7.0

* Sun Sep 10 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-11
- build: Backport upstream patch

* Sun Sep 10 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-10
- test: Skip for s390x arch

* Sun Sep 10 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-9
- build: Drop BR: pkgconfig(vulkan)

* Sun Sep 10 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-8
- test: Fix and enable tests

* Sun Sep 10 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-7
- style: Minor Spec file update

* Sun Sep 10 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-6
- build: Bundle vulkan-headers to fix FTBFS

* Thu Jul 20 2023 Fedora Release Engineering <releng@fedoraproject.org> - 0.6.9.1-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_39_Mass_Rebuild

* Tue Jul 11 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-4
- build: mangohud relies on old Vulkan-headers < 1.3.241

* Sat Jul 08 2023 Vitaly Zaitsev <vitaly@easycoding.org> - 0.6.9.1-3
- Rebuilt due to spdlog 1.12 update.

* Wed Jun 28 2023 Vitaly Zaitsev <vitaly@easycoding.org> - 0.6.9.1-2
- Rebuilt due to fmt 10 update.

* Wed Apr 19 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9.1-1
- build: Update to 0.6.9-1

* Fri Apr 14 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.9-1
- build: Update to 0.6.9

* Tue Mar 14 2023 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.8-4
- build: Fix FTBFS 38

* Thu Jan 19 2023 Fedora Release Engineering <releng@fedoraproject.org> - 0.6.8-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_38_Mass_Rebuild

* Thu Nov 03 2022 Vitaly Zaitsev <vitaly@easycoding.org> - 0.6.8-2
- Rebuilt due to spdlog update.

* Tue Aug 02 2022 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.8-1
- chore(update): 0.6.8

* Thu Jul 21 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.6.7.1-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_37_Mass_Rebuild

* Tue Jul 19 2022 Mamoru TASAKA <mtasaka@fedoraproject.org> - 0.6.7.1-3
- Rebuild for fmt-9

* Fri May 13 2022 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.7.1-2
- fix: Upload sources

* Fri May 13 2022 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.7.1-1
- chore(update): 0.6.7-1

* Wed May 04 2022 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.7-1
- chore(update): 0.6.7

* Thu Jan 20 2022 Fedora Release Engineering <releng@fedoraproject.org> - 0.6.6-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_36_Mass_Rebuild

* Mon Oct 18 2021 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.6-1
- chore(update): 0.6.6

* Thu Oct 07 2021 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.5-3
- build: Fix multilib dep | rh#1830718

* Thu Jul 22 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.6.5-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_35_Mass_Rebuild

* Thu Jul 08 2021 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.5-1
- build(update): 0.6.5

* Thu Jun 24 2021 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.4-1
- build(update): 0.6.4

* Sat Jun 12 2021 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.3-1
- build(update): 0.6.3

* Fri Jun 11 2021 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.2-1
- build(update): 0.6.2

* Wed Jan 27 2021 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.1-3
- build: Install 32-bit version automagically if multilib packages already
  installed on end user machine

* Tue Jan 26 2021 Fedora Release Engineering <releng@fedoraproject.org> - 0.6.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_34_Mass_Rebuild

* Sun Nov 29 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.1-1
- build(update): 0.6.1

* Sun Nov 29 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.0-2
- fix: version in HUD | GH-411

* Sat Nov 28 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.6.0-1
- build(update): 0.6.0

* Sun Aug 16 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.5.1-1
- Update to 0.5.1

* Tue Jul 28 2020 Fedora Release Engineering <releng@fedoraproject.org> - 0.4.1-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_33_Mass_Rebuild

* Sat Jun 13 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.4.1-2
- Add patch which fix F33 build | GH-213

* Thu Jun 11 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.4.1-1
- Update to 0.4.1
- Disable LTO

* Sat May 02 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.3.5-1
- Update to 0.3.5
- Remove ExclusiveArch. Now compiles on all arches, see GitHub#88.

* Thu Mar 26 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.3.1-2
- Add GUI fron-end 'goverlay' as very weak dep

* Wed Mar 18 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.3.1-1
- Update to 0.3.1

* Sun Mar 15 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.3.0-1
- Update to 0.3.0

* Fri Feb 14 2020 Artem Polishchuk <ego.cordatus@gmail.com> - 0.2.0-11
- Initial package
- Thanks for help with packaging to:
  gasinvein <gasinvein@gmail.com>
  Vitaly Zaitsev <vitaly@easycoding.org>


