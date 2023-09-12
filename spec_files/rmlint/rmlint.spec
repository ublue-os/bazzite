%undefine _package_note_file

Name:           rmlint
Version:        2.10.2
Release:        %autorelease
Summary:        Finds space waste and other broken things on your filesystem
# GPLv3: main code
# MIT: metrohash
# BSD: xxHash Library
# CC0 or ASL 2.0 or OpenSSL: blake2
# Public code: MurmurHash3, sha3
License:        GPLv3 and MIT and BSD and (CC0 or ASL 2.0 or OpenSSL) and Public Domain
URL:            https://rmlint.rtfd.org
Source0:        https://github.com/sahib/rmlint/archive/v%{version}/%{name}-%{version}.tar.gz
Patch0:         0001-Add-RPM_BUILD_ROOT-to-env.patch
Patch1:         rmlint-scons-c99.patch

BuildRequires:  scons
BuildRequires:  gcc
BuildRequires:  python3-sphinx
BuildRequires:  python3-devel
BuildRequires:  gettext
BuildRequires:  libblkid-devel
BuildRequires:  elfutils-libelf-devel
BuildRequires:  glib2-devel
BuildRequires:  sqlite-devel
BuildRequires:  json-glib-devel
BuildRequires:  desktop-file-utils
Requires:       hicolor-icon-theme
Recommends:     gtksourceview3

Provides:       bundled(blake2)
Provides:       bundled(sha3)
Provides:       bundled(xxhash)
Provides:       bundled(metrohash)
Provides:       bundled(murmurhash3)

%description
Rmlint finds space waste and other broken things and offers to remove it. It is
especially an extremely fast tool to remove duplicates from your filesystem.

%prep
%autosetup -p1
for f in `find gui/shredder -name "*.py"`; do
    sed '1{\@^#!/usr/bin/env python@d}' $f > $f.new &&
    touch -r $f $f.new &&
    mv $f.new $f
done

%build
%set_build_flags
scons config %{?_smp_mflags} --prefix="%{buildroot}%{_prefix}" --actual-prefix="%{_prefix}" --libdir="%{_lib}" DEBUG=1 SYMBOLS=1 VERBOSE=1
scons

%install
scons install --prefix="%{buildroot}%{_prefix}" --actual-prefix="%{_prefix}" --libdir="%{_lib}" DEBUG=1 SYMBOLS=1 VERBOSE=1
desktop-file-validate %{buildroot}/%{_datadir}/applications/shredder.desktop
%find_lang %{name}

%files -f %{name}.lang
%doc README.rst
%license COPYING
%{_bindir}/rmlint
%{_datadir}/applications/shredder.desktop
%{_datadir}/glib-2.0/schemas/org.gnome.Shredder.gschema.xml
%exclude %{_datadir}/glib-2.0/schemas/gschemas.compiled
%{_datadir}/icons/hicolor/scalable/apps/shredder.svg
%{_mandir}/man1/rmlint.1*
%{python3_sitelib}/shredder/
%{python3_sitelib}/Shredder-%{version}-py*.egg-info

%changelog
%autochangelog
