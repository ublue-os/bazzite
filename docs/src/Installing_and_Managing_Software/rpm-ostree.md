<!-- ANCHOR: METADATA -->
<!--{"url_discourse": "https://universal-blue.discourse.group/docs?topic=2642", "fetched_at": "2024-09-03 16:43:05.295995+00:00"}-->
<!-- ANCHOR_END: METADATA -->

![rpm-ostree|500x500, 30%](../img/rpm-ostree.png)

# `rpm-ostree` Overview

>**Notice**: Using `rpm-ostree` irresponsibly can be **destructive**.

>**Attention**: Layering packages may prevent updates and **may cause several issues until the layered packages are uninstalled**.

Install Fedora Linux packages by installing them with `rpm-ostree`.

- This is known as "layering packages" to the image.
- Layering packages will **require** a system reboot when it finishes creating the new deployment with the package(s) added to your image.
- Use this method as a **last resort** and for anything at a "system-level" only.

### Common `rpm-ostree` Terminal Commands:

```
rpm-ostree install <package>
```
Installs Fedora package(s) to the system that stay between updates.

```
rpm-ostree uninstall <package>
``` 
Uninstalls any layered packages added to the system.
 
```
rpm-ostree search <package>
```
Search for Fedora packages that can be installed.

# RPM packages installed on the host

Fedora containers should be used for most RPM files, but sometimes they need to be installed to your host.

You can install RPM files **to your host** with `rpm-ostree` by entering:
```
rpm-ostree install <package>.rpm
```
You may need to copy the full path (`/path/to/rpmfile.rpm`) for it to install properly.

>**Note**: The downside of installing local RPM files outside of the Fedora repositories is updates for the specific RPM package will not apply automatically.

# How do I install [COPR](https://copr.fedorainfracloud.org) repositories?

>**Note**: It is highly advised to **not** use third-party COPR repos if possible, so be aware there are risks associated with it including broken updates until removed.

1. Download the .repo file and save it to `/etc/yum.repos.d/`

2. Then install the package with `rpm-ostree`

3. Reboot

If you experience issues updating your system due to GPG signature issues, then this can be fixed by either removing the COPR repository, or editing the file by changing `gpgcheck=1` to `gpgcheck=0` (or similar) and saving it **at your own risk**.

There is also an experimental `copr` utility script that ships with Bazzite. Run `copr --help` in the terminal for to see usage documentation, and the source code for the helper script can be found [here](https://github.com/ublue-os/COPR-command).

# **MAJOR** caveats using `rpm-ostree`

Layering packages are mostly intended for system-level applications, libraries, and other dependencies.  It is recommend by upstream to use all of the methods above **before** installing software with `rpm-ostree`.  Typical users should **not** be using `rpm-ostree` to install end-user graphical applications.

Layering packages can cause **severe consequences** including:
- Break upgrades or prevent rebasing.
- Conflict with existing packages as part of the image leading to dependency issues.
- Updates will take longer to download as you layer more packages to your system.
- Eventually package layering will be removed later in the future for Fedora Atomic Desktop and is only used currently as a crutch for the current software ecosystem on desktop Linux.

It is **highly recommended** to only use this command when absolutely necessary especially if the application can be obtained through other methods. 

# How to remove **ALL** Layered Packages

If you run into issues upgrading due to a layered package conflict, then either optionally uninstall the conflicted package(s) or remove all layered packages with this **command**:
```bash
rpm-ostree reset
```

# Image Information

See information about image build date, update channel, layered packages, etc. by **entering this command in a host terminal**:

```command
rpm-ostree status
```

# Project Website

https://coreos.github.io/rpm-ostree/

<hr>

**See also**: https://universal-blue.discourse.group/docs?topic=513


[**<-- Back to Installing and Managing Software on Bazzite**](https://universal-blue.discourse.group/docs?topic=35)