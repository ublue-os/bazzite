Name:           HandyGCCS
%global _servicename handycon
Version:        2.0.0
Release:        1%{?dist}
Summary:        Handheld Game Console Controller Support (Handy Geeks) for Linux

License:        GPL-v3
URL:            https://github.com/ShadowBlip/%{name}
Source:         %{url}/archive/refs/heads/main.zip
Patch0:         fedora.patch

BuildArch:      noarch
BuildRequires:  python3-devel
BuildRequires:  python3-pip
BuildRequires:  python3-setuptools

Requires: python3-evdev

%description
Handheld Game Console Controller Support (Handy Geeks) for Linux

# Disable debug packages
%define debug_package %{nil}

%prep
%setup -n %{name}-main
%patch 0 -p0

%build
# %make_build
# bash ./build.sh
%{__python3} -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip setuptools
python -m pip install  wheel build
python -m build --wheel --no-isolation

%install
cd "%{_builddir}/%{name}-main/dist"
%{__python3} -m pip install --target %{buildroot}%{python3_sitelib} %{_servicename}-*.whl 
cp -r %{_builddir}/%{name}-main/usr %{buildroot}/
mkdir -p %{buildroot}/usr/bin
mv %{buildroot}%{python3_sitelib}/bin/%{_servicename} %{buildroot}/usr/bin
rm -r %{buildroot}%{python3_sitelib}/bin

%files
/usr/bin/handycon
%{python3_sitelib}/%{_servicename}
%{python3_sitelib}/%{_servicename}-%{version}.dist-info
/usr/lib/systemd/system/handycon.service
/usr/lib/udev/hwdb.d/59-handygccs-ayaneo.hwdb
/usr/lib/udev/rules.d/60-handycon.rules
/usr/share/handygccs/scripts/capture-system.py

%post
/usr/bin/systemctl enable %{_servicename}
/usr/bin/systemd-hwdb update
/usr/sbin/udevadm control -R