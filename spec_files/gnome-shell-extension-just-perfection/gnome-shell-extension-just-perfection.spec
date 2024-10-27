%global extension       just-perfection
%global uuid            %{extension}-desktop@%{extension}

Name:           gnome-shell-extension-%{extension}
Version:        30.0
Release:        %autorelease
Summary:        GNOME Shell extension to change behavior and disable UI elements
License:        GPL-3.0-only
URL:            https://gitlab.gnome.org/jrahmatzadeh/just-perfection
BuildArch:      noarch

Source:         %{url}/-/archive/%{version}/%{extension}-%{version}.tar.gz

BuildRequires:  glib2-devel
BuildRequires:  gettext

Requires:       gnome-shell >= 45
Recommends:     gnome-extensions-app
Provides:       %{extension} = %{version}-%{release}


%description
%{summary}.


%prep
%autosetup -n %{extension}-%{version}

# fix spurious-executable-perm and script-without-shebang rpmlint warnings/errors
find -type f -print -exec chmod 644 {} \;


%build
glib-compile-resources \
    --sourcedir src/data \
    src/data/resources.gresource.xml


%install
pushd src

# install main extension files
install -d -m 0755 %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}
cp -r --preserve=timestamps \
    *.js stylesheet.css metadata.json \
    lib data/resources.gresource \
    %{buildroot}%{_datadir}/gnome-shell/extensions/%{uuid}

# install the schema file
install -D -p -m 0644 \
    schemas/org.gnome.shell.extensions.%{extension}.gschema.xml \
    %{buildroot}%{_datadir}/glib-2.0/schemas/org.gnome.shell.extensions.%{extension}.gschema.xml

popd

# install locale files
pushd po
for po in *.po; do
    install -d -m 0755 %{buildroot}%{_datadir}/locale/${po%.po}/LC_MESSAGES
    msgfmt -o %{buildroot}%{_datadir}/locale/${po%.po}/LC_MESSAGES/%{extension}.mo $po
done
popd
%find_lang %{extension}


%files -f %{extension}.lang
%license LICENSE
%doc CHANGELOG.md
%{_datadir}/gnome-shell/extensions/%{uuid}
%{_datadir}/glib-2.0/schemas/org.gnome.shell.extensions.%{extension}.gschema.xml


%changelog
%autochangelog
