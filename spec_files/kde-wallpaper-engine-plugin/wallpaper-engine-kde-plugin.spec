%global _enable_debug_package 0
%global debug_package %{nil}

# upstream:
# https://github.com/ProjectSynchro/copr-wallpaper-engine-kde-plugin/blob/main/wallpaper-engine-kde-plugin.spec
# it separates into a -lib and normal package. We combine them here

%global commit ed58dd8b920dbb2bf0859ab64e0b5939b8a32a0e
%define short_commit %(echo %{commit} | cut -c1-8)

Name:           wallpaper-engine-kde-plugin

Version:        100.%{short_commit}
Release:        1.bazzite
Summary:        KDE wallpaper plugin integrating wallpaper engine

License: GPLv2
URL: https://github.com/catsout/wallpaper-engine-kde-plugin

Patch1: 001-system-deps.patch
Patch2: 002-fix-gcc-15.patch

BuildRequires: vulkan-loader-devel
# TODO wait until the backend doesn't rely on internal headers.
#BuildRequires: glslang-devel >= 14.1.0-1

BuildRequires: plasma-workspace-devel
BuildRequires: libplasma-devel
BuildRequires: gstreamer1-plugin-libav
BuildRequires: lz4-devel
BuildRequires: mpv-libs-devel
BuildRequires: python3-websockets

BuildRequires: qt6-qtbase-private-devel
BuildRequires: qt6-qtwebsockets-devel
BuildRequires: qt6-qtwebchannel-devel

BuildRequires: git
BuildRequires: cmake
BuildRequires: extra-cmake-modules

BuildRequires: kf6-rpm-macros

Requires:      python3-websockets
Requires:      qt6-qtwebchannel
Requires:      qt6-qtwebsockets-devel 

%description
%{name} is a wallpaper plugin integrating wallpaper engine into the KDE wallpaper settings.

%prep
git clone --single-branch --branch main https://github.com/bazzite-org/wallpaper-engine-kde-plugin %{_builddir}/%{name}-%{version}

cd %{_builddir}/%{name}-%{version}
git checkout %{commit}
git submodule update --init --recursive

%autopatch -p1

%build
cd %{_builddir}/%{name}-%{version}
%cmake_kf6 -DQT_MAJOR_VERSION=6 -DBUILD_QML=ON -DUSE_PLASMAPKG=OFF
%cmake_build

%install
cd %{_builddir}/%{name}-%{version}
%cmake_install

%files
%{_kf6_metainfodir}/com.github.catsout.wallpaperEngineKde.appdata.xml
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/images/*
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/*.py
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/*.qml
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/backend/*.qml
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/components/*.qml
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/components/qmldir
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/js/*.mjs
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/page/qmldir
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/qmldir
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/style/*.qml
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/style/qmldir
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/metadata.desktop
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/metadata.json
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/config/*.xml
%{_kf6_datadir}/plasma/wallpapers/com.github.catsout.wallpaperEngineKde/contents/ui/page/*.qml

# Lib part
%{_kf6_qmldir}/com/github/catsout/wallpaperEngineKde/*

%changelog 
%autochangelog
