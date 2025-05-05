### This is for rpm-ostree based system

```
# Clone repo
git clone https://github.com/catsout/wallpaper-engine-kde-plugin.git
cd wallpaper-engine-kde-plugin


# Install plugin package 
# plasmapkg2 -u, for update
plasmapkg2 -i ./plugin

# Rpmbuild in toolbox
rpmbuild --define="commit $(git rev-parse HEAD)" \
    --define="glslang_ver 11.8.0" \
    --undefine=_disable_source_fetch \
    -ba ./rpm/wek.spec

# Install package
cd ~/rpmbuild/RPMS/x86_64
rpm-ostree install --uninstall=wallpaper-engine-kde-plugin ./<select-rpm-to-install>.rpm
```
