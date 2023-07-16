# Dummy package to make kernel-fsync installable on Bazzite

Name: kernel
Version: 20380119
Release: 1
Summary: The kernel-fsync kernel for Bazzite

License: GPLv2

Provides: kernel = %{version}-%{release}
Provides: kernel-core = %{version}-%{release}
Provides: kernel-devel = %{version}-%{release}
Provides: kernel-devel-matched = %{version}-%{release}
Provides: kernel-headers = %{version}-%{release}
Provides: kernel-modules = %{version}-%{release}
Provides: kernel-modules-extra = %{version}-%{release}

Provides: kernel-%{_arch} = %{version}-%{release}
Provides: kernel-core-%{_arch} = %{version}-%{release}
Provides: kernel-devel-%{_arch} = %{version}-%{release}
Provides: kernel-devel-matched-%{_arch} = %{version}-%{release}
Provides: kernel-headers-%{_arch} = %{version}-%{release}
Provides: kernel-modules-%{_arch} = %{version}-%{release}
Provides: kernel-modules-extra-%{_arch} = %{version}-%{release}

Provides: kernel%{_isa} = %{version}-%{release}
Provides: kernel-core%{_isa} = %{version}-%{release}
Provides: kernel-devel%{_isa} = %{version}-%{release}
Provides: kernel-devel-matched%{_isa} = %{version}-%{release}
Provides: kernel-headers%{_isa} = %{version}-%{release}
Provides: kernel-modules%{_isa} = %{version}-%{release}
Provides: kernel-modules-extra%{_isa} = %{version}-%{release}

Requires: kernel

%description
The linux-fsync kernel for Bazzite

%prep

%build

%install

%files
