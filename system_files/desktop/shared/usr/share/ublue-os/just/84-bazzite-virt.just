# vim: set ft=make :

# Setup and configure virtualization and vfio
setup-virtualization ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    # Check if we are running on a Steam Deck
    if /usr/libexec/hwsupport/valve-hardware; then
      echo "${red}${b}WARNING${n}: Virtualization is not properly supported on Steam Deck by Valve"
      echo "Use at your own risk and performance may not be ideal."
    fi
    if [ "$(systemctl is-enabled libvirtd.service)" == "disabled" ]; then
      echo "${b}libvirtd${n} service is ${red}disabled${n}!"
      echo "${green}enabling${n} and starting libvirtd"
      echo "If virt-manager says libvirtd.sock is not available after a big update, re-run this command."
      sudo systemctl enable --now libvirtd 2> /dev/null
      echo "Press ESC if you want to exit and do not need to do anything"
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtualization <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'virt-on' to select Enable Virtualization"
      echo "  Use 'virt-off' to select Disable Virtualization"
      echo "  Use 'group' to select Add $USER to libvirt group"
      echo "  Use 'vfio-on' to select Enable VFIO drivers"
      echo "  Use 'vfio-off' to select Disable VFIO drivers"
      echo "  Use 'kvmfr' to select Autocreate Looking-Glass shm"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtualization Setup${normal}"
      echo "NOTE: Enabling Virtualization will install the virt-manager flatpak and set kernel args"
      OPTION=$(Choose \
        "Enable Virtualization" \
        "Disable Virtualization" \
        "Add $USER to libvirt group" \
        "Enable VFIO drivers" \
        "Disable VFIO drivers" \
        "Enable kvmfr module" \
      )
    fi
    if [[ "${OPTION,,}" =~ (^enable[[:space:]]virtualization|virt-on) ]]; then
        if ! rpm -q virt-manager | grep -P "^virt-manager-" 1>/dev/null; then
          echo "Installing virt-manager..."
          flatpak install flathub org.virt_manager.virt-manager
          rpm-ostree kargs \
          --append-if-missing="kvm.ignore_msrs=1" \
          --append-if-missing="kvm.report_ignored_msrs=0"
          echo "Making sure swtpm will work"
          if [ ! -d "/var/lib/swtpm-localca" ]; then
            sudo mkdir /var/lib/swtpm-localca
          fi
          sudo chown tss /var/lib/swtpm-localca
          if sudo test ! -f "/etc/libvirt/hooks/qemu"; then
            echo "Adding libvirt qemu hooks"
            sudo grep -A1 -B1 "# Add" /etc/libvirt/hooks/qemu | sed 's/^# //g'
            sudo wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' -O /etc/libvirt/hooks/qemu
            sudo chmod +x /etc/libvirt/hooks/qemu
            if sudo test ! -d "/etc/libvirt/hooks/qemu/qemu.d"; then
              sudo mkdir /etc/libvirt/hooks/qemu/qemu.d
            fi
          fi
          sudo systemctl enable bazzite-libvirtd-setup.service \
            && echo "libvirtd will be enabled at next reboot"
          echo 'Please reboot to apply changes'
        fi
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]virtualization|virt-off) ]]; then
      if [ "$(systemctl is-enabled libvirtd.service)" == "enabled" ]; then
        echo "${red}Disabling${n} libvirtd before removal"
        sudo systemctl disable --now libvirtd 2> /dev/null
      fi
      if [ "$(systemctl is-enabled bazzite-libvirtd-setup.service)" == "enabled" ]; then
        echo "${red}Disabling${n} bazzite-libvirtd-setup"
        sudo systemctl disable --now bazzite-libvirtd-setup.service 2> /dev/null
      fi
      echo "Removing virt-manager..."
      flatpak uninstall org.virt_manager.virt-manager
      rpm-ostree kargs \
      --delete-if-present="kvm.ignore_msrs=1" \
      --delete-if-present="kvm.report_ignored_msrs=0"
      echo 'Please reboot to apply changes'
    elif [[ "${OPTION,,}" =~ (^enable[[:space:]]vfio|vfio-on) ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo "Enabling VFIO..."
      VIRT_TEST=$(rpm-ostree kargs)
      CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
      VENDOR_KARG="unset"
      if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
        rpm-ostree initramfs --enable
        if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
          VENDOR_KARG="amd_iommu=on"
        elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
          VENDOR_KARG="intel_iommu=on"  
        fi
        if [[ ${VENDOR_KARG} == "unset" ]]; then
          echo "Failed to get CPU vendor, exiting..."
          exit 1
        else
          rpm-ostree kargs \
            --append-if-missing="${VENDOR_KARG}" \
            --append-if-missing="iommu=pt" \
            --append-if-missing="rd.driver.pre=vfio-pci" \
            --append-if-missing="vfio_pci.disable_vga=1"
          echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
          echo "Please understand that since this is such a niche use case, support will be very limited!"
          echo 'Use the command "ls-iommu -grk" to get iommu information about your GPUs, use the "--help" flag for more options'
          echo ""
          echo "${b}Systems with multiple GPUs${n}"
          echo "Bind your unused/second GPU device ids to the vfio driver by running"
          echo 'rpm-ostree kargs --append-if-missing="vfio_pci.ids=xxxx:yyyy,xxxx:yyzz"'
          echo "You will require a $(Urllink "https://www.amazon.com/s?k=hdmi+displayport+dummy+plug" "Dummy HDMI/DisplayPort plug (Ghost Adapter)") or hook the GPU"
          echo "to a separate monitor input in order to turn the GPU on when starting the VM."
          echo "NOTE: Your second GPU should be as different as possible from your main GPU and will not be usable by the host after you bind it to the vfio driver!"
          echo ""
          echo "${b}Systems with 1 GPU${n}"
          echo "Once rebooted you can continue setting up whatever scripts and hooks you need"
          echo "to get Single GPU passthrough working, however ${u}you will be on your own${n}."
          echo "${b}Do not ask for support for setting up Single GPU Passthrough, we can not help you!${n}"
        fi
      fi
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]vfio|vfio-off) ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo ""
      echo "Make sure you have ${b}disabled autostart of all VMs using VFIO${n} before continuing!"
      CONFIRM=$(Choose Cancel Continue)
      if [ "$CONFIRM" == "Continue" ]; then
        echo "Disabling VFIO..."
        VFIO_IDS="$(rpm-ostree kargs | sed -E 's/.+(vfio_pci.ids=.+\s)/\1/' | awk '{ print $1 }' | grep vfio_pci.ids)"
        VFIO_IDS_KARG=""
        if [ -n "$VFIO_IDS" ]; then
          echo "Found VFIO ids in kargs, adding the below line to removal list"
          echo "$VFIO_IDS"
          VFIO_IDS_KARG="--delete-if-present=\"$VFIO_IDS\""
        fi
        KVMFR_VAL="$(rpm-ostree kargs | sed -E 's/.+(kvmfr.static_size_mb=.+\s)/\1/' | awk '{ print $1 }' | grep kvmfr.static_size_mb)"
        KVMFR_KARG=""
        if [ -n "$KVMFR_VAL" ]; then
          echo "Found KVMFR static_size_mb in kargs, adding the below line to removal list"
          echo "$KVMFR_VAL"
          KVMFR_KARG="--delete-if-present=\"$KVMFR_VAL\""
        fi
        echo "Removing deprecated dracut modules"
        sudo rm /etc/dracut.conf.d/vfio.conf
        sudo rm /etc/modprobe.d/kvmfr.conf
        rpm-ostree kargs \
        --delete-if-present="iommu=pt" \
        --delete-if-present="iommu=on" \
        --delete-if-present="amd_iommu=on" \
        --delete-if-present="intel_iommu=on" \
        --delete-if-present="rd.driver.pre=vfio-pci" \
        --delete-if-present="vfio_pci.disable_vga=1" \
        --delete-if-present="vfio_pci.disable_vga=0" \
        $VFIO_IDS_KARG \
        $KVMFR_KARG
      fi
    elif [[ "${OPTION,,}" =~ kvmfr ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "This module") along with $(Urllink "https://looking-glass.io" "Looking Glass") is very experimental and not recommended for production use!"
      echo "The ublue team packages the kvmfr module only because it has to be supplied with the system image while using an atomic desktop."
      echo "If you do plan to use Looking Glass, please $(Urllink "https://docs.bazzite.gg/Advanced/looking-glass/" "follow the guide here") on how to compile it for your system."
      echo "To use the kvmfr module after enabling it, just add and edit the xml for libvirt from the documentation in the first link."
      echo "Since we package the kvmfr module please open kvmfr related issues you have on Bazzite"
      echo "in the $(Urllink "https://discord.bazzite.gg/" "Bazzite Discord") or the $(Urllink "https://github.com/ublue-os/bazzite/issues" "Bazzite Github issue tracker")."
      echo "~ @HikariKnight"
      CONFIRM=$(Choose Ok Cancel)
      if [ "$CONFIRM" == "Cancel" ]; then
        exit 0
      fi
      echo ""
      echo "Setting up kvmfr module so it loads next boot"
      if [ -f "/etc/modprobe.d/kvmfr.conf" ]; then
        echo "Re-creating dummy kvmfr modprobe file"
        sudo rm /etc/modprobe.d/kvmfr.conf
      fi
      sudo bash -c "cat << KVMFR_MODPROBE > /etc/modprobe.d/kvmfr.conf
    # This is a dummy file and changing it does nothing
    # If you want to change the kvmfr static_size_mb
    # Run "rpm-ostree kargs --replace=kvmfr.static_size_mb=oldvalue=newvalue"
    # Default value set by us is 128 which is enough for 4k SDR
    # Find the current value by running "rpm-ostree kargs"
    KVMFR_MODPROBE"
      rpm-ostree kargs --append-if-missing="kvmfr.static_size_mb=128"
      if [ -f "/etc/udev/rules.d/99-kvmfr.rules" ]; then
        echo "Re-creating kvmfr udev rules"
        sudo rm /etc/udev/rules.d/99-kvmfr.rules
      fi
      echo "Adding udev rule for /dev/kvmfr0"
      sudo bash -c 'cat << KVMFR_UDEV > /etc/udev/rules.d/99-kvmfr.rules
    SUBSYSTEM=="kvmfr", OWNER="'$USER'", GROUP="qemu", MODE="0660"
    KVMFR_UDEV'
      echo "Adding /dev/kvmfr0 to qemu cgroup_device_acl"
      sudo perl -0777 -pi -e 's/
    #cgroup_device_acl = \[
    #    "\/dev\/null", "\/dev\/full", "\/dev\/zero",
    #    "\/dev\/random", "\/dev\/urandom",
    #    "\/dev\/ptmx", "\/dev\/kvm",
    #    "\/dev\/userfaultfd"
    #\]
    /
    cgroup_device_acl = \[
        "\/dev\/null", "\/dev\/full", "\/dev\/zero",
        "\/dev\/random", "\/dev\/urandom",
        "\/dev\/ptmx", "\/dev\/kvm",
        "\/dev\/userfaultfd", "\/dev\/kvmfr0"
    \]
    /' /etc/libvirt/qemu.conf
      echo "Adding SELinux context record for /dev/kvmfr0"
      sudo semanage fcontext -a -t svirt_tmpfs_t /dev/kvmfr0
      echo "Adding SELinux access rules for /dev/kvmfr0"
      if [ ! -d "$HOME/.config/selinux_te/mod" ]; then
        mkdir -p "$HOME/.config/selinux_te/mod"
      fi
      if [ ! -d "$HOME/.config/selinux_te/pp" ]; then
        mkdir -p "$HOME/.config/selinux_te/pp"
      fi
      bash -c "cat << KVMFR_SELINUX > $HOME/.config/selinux_te/kvmfr.te
    module kvmfr 1.0;

    require {
        type device_t;
        type svirt_t;
        class chr_file { open read write map };
    }

    #============= svirt_t ==============
    allow svirt_t device_t:chr_file { open read write map };
    KVMFR_SELINUX"
      echo "This is the type enforcement we wrote for SELinux and you can find it in $HOME/.config/selinux_te/kvmfr.te"
      echo "#======= start of kvmfr.te ======="
      cat "$HOME/.config/selinux_te/kvmfr.te"
      echo "#======== end of kvmfr.te ========"
      checkmodule -M -m -o "$HOME/.config/selinux_te/mod/kvmfr.mod" "$HOME/.config/selinux_te/kvmfr.te"
      semodule_package -o "$HOME/.config/selinux_te/pp/kvmfr.pp" -m "$HOME/.config/selinux_te/mod/kvmfr.mod"
      sudo semodule -i "$HOME/.config/selinux_te/pp/kvmfr.pp"
      echo "Loading kvmfr module so you do not have to reboot to use it the first time"
      sudo modprobe kvmfr static_size_mb=128
      sudo chown $USER:qemu /dev/kvmfr0
      echo ""
      echo "Kvmfr0 $(Urllink "https://looking-glass.io/docs/B7-rc1/install_libvirt/#determining-memory" "static size is set to 128mb by default")"
      echo "this will work with up to 4K SDR resolutiion, as most dummy plugs go up to 4K"
      echo "some games will try use the adapters max resolution on first boot and cause issues if the value is too low."
      echo "Most ghost display adapters max out at 4k, hence the default value of 128mb."
      echo ""
      echo "If you need to change it to a different value"
      echo "you can do that by running \"rpm-ostree kargs --replace=kvmfr.static_size_mb=128=newvalue\""
      echo "You can check the current kernel arguments with \"rpm-ostree kargs\""
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "Please read official documentation for kvmfr for how to use it")"
      echo "${b}NOTE: You can start using kvmfr right now without rebooting if you already rebooted after enabling VFIO.${n}"
      CONFIRM=$(Choose OK)
    elif [[ "${OPTION,,}" =~ group ]]; then
      if ! grep -q "^libvirt" /etc/group; then
        grep '^libvirt' /usr/lib/group | sudo tee -a /etc/group > /dev/null
      fi
      sudo usermod -aG libvirt $USER
    fi
