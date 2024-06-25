#
# spec file for package python-fuse
#
# Copyright (c) 2024 SUSE LLC
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#

Name:           python-fuse
Version:        1.0.7
Release:        0
Summary:        Python bindings for FUSE
License:        LGPL-2.1-only
URL:            https://github.com/libfuse/python-fuse
Source:         https://github.com/libfuse/%{name}/archive/v%{version}.tar.gz#/%{name}-%{version}.tar.gz
# PATCH-FIX-UPSTREAM gh#libfuse/python-fuse#58
Patch0:         no-more-distutils.patch
BuildRequires:  python3-devel
BuildRequires:  python3-pip
BuildRequires:  python3-setuptools
BuildRequires:  python3-wheel
BuildRequires:  fdupes
BuildRequires:  fuse-devel
BuildRequires:  pkgconfig
BuildRequires:  python-rpm-macros
BuildRequires:  gcc

%description
Python bindings for FUSE (User space File System)

%prep
%autosetup -p1

%build	
%pyproject_wheel

%install
%pyproject_install

%files
%license COPYING
%doc README.* FAQ AUTHORS
%{python3_sitearch}/fuse.py
%{python3_sitearch}/__pycache__/fuse*.py*
%{python3_sitearch}/fuseparts
%{python3_sitearch}/fuse_python-%{version}.dist-info

%changelog
