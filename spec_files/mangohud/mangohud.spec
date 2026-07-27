%global appname MangoHud
%global forgeurl https://github.com/flightlessmango/MangoHud

%global imgui_ver 1.91.6
%global vulkan_headers_ver 1.4.346
%global vulkan_utility_libraries_ver 1.4.346
%global implot_ver 0.16
%global implot_wrap_ver 2

%global tarball_version %%(echo %{version} | tr '~' '-')

# TODO: try to fix amdgpu tests
%bcond_with tests

Name:           mangohud
Version:        0.8.4
%forgemeta
Release:        %autorelease
Summary:        Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load

License:        MIT
URL:            %{forgeurl}
Source0:        %{url}/archive/v%{tarball_version}/%{name}-%{tarball_version}.tar.gz
# imgui
Source1:        https://github.com/ocornut/imgui/archive/v%{imgui_ver}/imgui-%{imgui_ver}.tar.gz
# Vulkan-Headers
Source2:        https://github.com/KhronosGroup/Vulkan-Headers/archive/v%{vulkan_headers_ver}/Vulkan-Headers-%{vulkan_headers_ver}.tar.gz
# Vulkan-Utility-Libraries
Source3:        https://github.com/KhronosGroup/Vulkan-Utility-Libraries/archive/v%{vulkan_utility_libraries_ver}/Vulkan-Utility-Libraries-%{vulkan_utility_libraries_ver}.tar.gz
# implot
Source4:        https://github.com/epezent/implot/archive/v%{implot_ver}/implot-%{implot_ver}.tar.gz
Source5:        https://wrapdb.mesonbuild.com/v%{implot_wrap_ver}/implot_%{implot_ver}-1/get_patch#/implot-%{implot_ver}-wrap.zip

BuildRequires:  vulkan-headers
BuildRequires:  appstream
BuildRequires:  dbus-devel
BuildRequires:  gcc-c++
BuildRequires:  git-core
BuildRequires:  libappstream-glib
BuildRequires:  libstdc++-static
BuildRequires:  meson >= 0.60
BuildRequires:  python3-mako
BuildRequires:  pkgconfig(dri)
BuildRequires:  pkgconfig(glfw3)
BuildRequires:  pkgconfig(glslang)
BuildRequires:  pkgconfig(nlohmann_json)
BuildRequires:  pkgconfig(spdlog)
BuildRequires:  pkgconfig(wayland-client)
BuildRequires:  pkgconfig(x11)
BuildRequires:  pkgconfig(xkbcommon)
# Tip and memo if upstream decide to unbundle vulkan-headers
# BuildRequires:  pkgconfig(vulkan) < 1.3.241


%if %{with tests}
BuildRequires:  libcmocka-devel
%endif

Requires:       hicolor-icon-theme
Requires:       vulkan-loader%{?_isa}

Recommends:     (mangohud(x86-32) if glibc(x86-32))

Suggests:       %{name}-mangoplot
Suggests:       goverlay

Provides:       bundled(imgui) = %{imgui_ver}
Provides:       bundled(implot) = %{implot_ver}
Provides:       bundled(vulkan-headers) = %{vulkan_headers_ver}
Provides:       bundled(vulkan-utility-libraries) = %{vulkan_utility_libraries_ver}

%global _description %{expand:
A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and
more.}

%description %{_description}


%package        mangoplot
Summary:        Local visualization "mangoplot" for %{name}
BuildArch:      noarch

Requires:       %{name} = %{version}-%{release}
Requires:       python3-matplotlib
Requires:       python3-numpy

%description    mangoplot
Local visualization "mangoplot" for %{name}.


%prep
%autosetup -n %{appname}-%{tarball_version} -p1
%setup -qn %{appname}-%{tarball_version} -D -T -a1
%setup -qn %{appname}-%{tarball_version} -D -T -a2
%setup -qn %{appname}-%{tarball_version} -D -T -a3
%setup -qn %{appname}-%{tarball_version} -D -T -a4
%setup -qn %{appname}-%{tarball_version} -D -T -a5

# Meson only applies a wrap's patch_directory when it downloads the subproject
# itself, so the packagefiles have to be copied in by hand here.
# imgui
mv imgui-%{imgui_ver} subprojects/
cp -a subprojects/packagefiles/imgui-%{imgui_ver}/. subprojects/imgui-%{imgui_ver}/
# Vulkan-Headers
mv Vulkan-Headers-%{vulkan_headers_ver} subprojects/
cp -a subprojects/packagefiles/vulkan-headers/. subprojects/Vulkan-Headers-%{vulkan_headers_ver}/
# Vulkan-Utility-Libraries
mv Vulkan-Utility-Libraries-%{vulkan_utility_libraries_ver} subprojects/
cp -a subprojects/packagefiles/vulkan-utility-libraries/. \
    subprojects/Vulkan-Utility-Libraries-%{vulkan_utility_libraries_ver}/
# implot (build files come from the wrapdb patch archive unpacked above)
mv implot-%{implot_ver} subprojects/

%if %{with tests}
# Use system cmocka instead of subproject
# https://gitlab.archlinux.org/archlinux/packaging/packages/mangohud/-/blob/0.6.9.1-10/PKGBUILD?ref_type=tags#L32
sed -i "s/  cmocka = subproject('cmocka')//g" meson.build
sed -i "s/cmocka_dep = cmocka.get_variable('cmocka_dep')/cmocka_dep = dependency('cmocka')/g" meson.build
%endif


%build
%meson \
    -Dmangoapp=true \
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
%{_bindir}/mangoapp
%{_bindir}/mangohud
%{_bindir}/mangohudctl
%{_datadir}/icons/hicolor/scalable/*/*.svg
%{_datadir}/vulkan/implicit_layer.d/*Mango*.json
%{_docdir}/%{name}/%{appname}.conf.example
%{_docdir}/%{name}/presets.conf.example
%{_libdir}/%{name}/
%{_mandir}/man1/%{name}.1*
%{_mandir}/man1/mangoapp.1*
%{_metainfodir}/*.metainfo.xml

%files mangoplot
%{_bindir}/mangoplot


%changelog
%autochangelog
