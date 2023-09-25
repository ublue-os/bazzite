# Created by pyp2rpm-3.3.6
%global pypi_name python-pidfile
%global srcname python-pidfile

Name:           python-%{srcname}
Version:        3.0.0
Release:        1%{?dist}
Summary:        PIDFile context processor. Supported py2 and py3

License:        MIT
URL:            https://github.com/mosquito/python-pidfile
Source0:        %{pypi_source}
BuildArch:      noarch

BuildRequires:  python3-devel
BuildRequires:  python3dist(setuptools)

%description
Python context manager for managing pid files.


%package -n     python3-%{srcname}
Summary:        %{summary}
%{?python_provide:%python_provide python3-%{srcname}}

Requires:       python3dist(psutil)


%description -n python3-%{srcname}
Python context manager for managing pid files.


%prep
%autosetup -n %{pypi_name}-%{version}
# Remove bundled egg-info
rm -rf %{pypi_name}.egg-info


%build
%py3_build


%install
%py3_install


%files -n python3-%{srcname}
%doc README.rst
%{python3_sitelib}/pidfile
%{python3_sitelib}/python_pidfile-%{version}-py%{python3_version}.egg-info


%changelog
* Fri Apr 02 2021 Peter Oliver <rpm@mavit.org.uk> - 3.0.0-1
- Initial package.
