HikariKnight | 2024-07-25 11:14:34 UTC | #1

# READ FIRST

[Looking-Glass](https://looking-glass.io/) is a very experimental project and is not ready for production use!
This means there are no official packages for `looking-glass-client` yet. <br>
For this reason we do not package or ship `looking-glass-client`, we only provide a working configuration and SELinux rules so that it can be used in Bazzite, Bluefin and Aurora.
We do however package the `kvmfr` kernel module and include it with the system image, as such file any issue with the `kvmfr` module in bazzite or bluefin/aurora to our discord or github issue tracker and add @HikariKnight in the issue.

We will only tell you to file an issue with LookingGlass directly if the issue is not related to the packaging and configuration of the `kvmfr` module.

## Enabling the kvmfr module

You can enable the kvmfr module by running the command based on if you are using bazzite or bluefin/aurora

Bazzite:

```bash
ujust setup-virtualization kvmfr
```

Bluefin-dx/Aurora-dx:

```bash
ujust configure-vfio kvmfr
```

Change the `static_size_mb` of kvmfr by editing `/etc/modprobe.d/kvmfr.conf`
by default it is set to 128mb, this is enough for 4K SDR.

## Compiling Looking-Glass client

1. Create a `fedora:latest` distrobox that we will use to compile the binary, use the following command to make the container, when asked about what image to use, select the default one as i have verified this guide works with that image for building.
   This distrobox has to be made manually without the `--nvidia` flag which our ujust automatically applies in order to maker `cmake-data` successfully install.
   **NOTE**: If you are not using the latest fedora version, please change `latest` to match your version number, this is to avoid dependency versioning issues.<br>

```bash
distrobox create -i "fedora:latest" -n "tmp-lookingglass"
```

If you want to use a separate home folder for this then make a folder to contain this containers home folder and run this command instead

```bash
distrobox create -i "fedora:latest" -n "tmp-lookingglass" -H "/path/to/new/home"
```

2. Enter the container with `distrobox enter tmp-lookingglass`
3. Follow [upstream documentation](https://looking-glass.io/docs/rc/build/#installing-build-dependencies), you can find the fedora build dependencies [here](https://looking-glass.io/wiki/Installation_on_other_distributions) and you will also want to install the dependencies mentioned for **PipeWire Users**.
   Since we will be building for **Wayland** and not X11 you will also need the package `libdecor-devel`
4. When you get to the part for running `cmake` you can(and should on bazzite at least) use the command

```
cmake -DENABLE_WAYLAND=1 -DENABLE_X11=0 -DENABLE_PULSEAUDIO=0 -DENABLE_PIPEWIRE=1 ..
```

5. The above command will disable X11 support and Pulseaudio support, but enable pipewire and wayland support, this will avoid any issues as we do not ship the X11 dependencies for looking-glass.
6. Copy the built `looking-glass-client` binary to `/run/host/home/$USER/.local/bin/`
   You can do that using the following commands if you followed the looking-glass documentation.

```bash
mkdir /run/host/home/$USER/.local/bin
cp ./looking-glass-client /run/host/home/$USER/.local/bin/
```

7. Test and see if `looking-glass-client` binary works for you on the host with your VM running.
8. Exit the container and run the below command to remove the container we used to build the looking-glass client.

```bash
distrobox stop tmp_lookingglass ; distrobox rm tmp_lookingglass
```

---

akarypid | 2024-05-09 06:38:38 UTC | #2

Thank you for this guide!

Is it possible to use Looking-Glass in Bluefin-DX? From what I see, the only thing extra is some SELinux rules?

> ...we only provide a working configuration and SELinux rules so that it can be used in Bazzite.

Hopefully there is there an RPM I can layer in Bluefin-DX to get these SELinux configs? And after that I can simply try following these instructions?

---

HikariKnight | 2024-05-09 09:08:55 UTC | #3

this is already in bluefin-dx as they did not want users to layer virt-manager on the non-dx image, the ujust will add the SELinux rules and even give you a human readable copy of them in `.config/selinux_te` :slight_smile:

`ujust configure-vfio` on bluefin-dx

https://github.com/ublue-os/bluefin/pull/1226

guide for compiling looking-glass is still the same as in bazzite though (just make sure you compile it using a `fedora:39` container if you are using `bluefin-dx:gts` or `bluefin-dx:39` as of writing)

<hr>

**Documentation Author**: [HikariKnight](https://github.com/HikariKnight)
