%global forgeurl https://github.com/trigg/Discover
Version:        0.7.0
%forgemeta

Name:           discover-overlay
Release:        %autorelease
Summary:        Voice chat overlay

License:        GPLv3+
URL:            %{forgeurl}
Source0:        %{forgesource}
BuildArch:      noarch

BuildRequires:  desktop-file-utils
BuildRequires:  libappstream-glib
BuildRequires:  python3-devel
BuildRequires:  python3dist(setuptools)

Requires:       python3dist(pillow)
Requires:       python3dist(pygobject) >= 3.22
Requires:       python3dist(python-pidfile) >= 3
Requires:       python3dist(pyxdg)
Requires:       python3dist(requests)
Requires:       python3dist(setuptools)
Requires:       python3dist(websocket-client)
Requires:       python3dist(python-xlib)
Requires:       gtk-layer-shell


%description
Yet another Discord overlay for Linux written in Python using GTK3.


%prep
%forgesetup


%build
%py3_build


%install
%py3_install


%check
desktop-file-validate %{buildroot}/%{_datadir}/applications/*.desktop


%files
%doc README.md
%{_bindir}/discover-overlay
%{_datadir}/applications/discover_overlay.desktop
%{_datadir}/applications/discover_overlay_configure.desktop
%{_datadir}/icons/hicolor/256x256/apps/discover-overlay-default.png
%{_datadir}/icons/hicolor/256x256/apps/discover-overlay-tray.png
%{_datadir}/icons/hicolor/256x256/apps/discover-overlay.png
%{_datadir}/icons/hicolor/scalable/apps/discover-overlay-default.svg
%{_datadir}/icons/hicolor/scalable/apps/discover-overlay-tray.svg
%{_datadir}/icons/hicolor/scalable/apps/discover-overlay.svg
%{python3_sitelib}/discover_overlay
%{python3_sitelib}/discover_overlay-%{version}-py%{python3_version}.egg-info


%changelog
%autochangelog
