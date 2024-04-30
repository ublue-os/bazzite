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
      echo "NOTE: Enabling Virtualization will layer virt-manager and qemu"
      echo "      this will slow down system updates by a lot."
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
      virt_test=$(rpm-ostree status | grep -A 4 "●" | grep "virt-manager")
      if [[ -z ${virt_test} ]]; then
        echo "Installing QEMU and virt-manager..."
        rpm-ostree install -y virt-manager edk2-ovmf qemu
        rpm-ostree kargs \
        --append-if-missing="kvm.ignore_msrs=1" \
        --append-if-missing="kvm.report_ignored_msrs=0"
        echo 'Please re-run "ujust setup-virtualization" after the reboot to enable libvirtd service'
      fi
    elif [[ "${OPTION,,}" =~ (^disable[[:space:]]virtualization|virt-off) ]]; then
      virt_test=$(rpm-ostree status | grep -A 4 "●" | grep "virt-manager")
      if [[ ${virt_test} ]]; then
        if [ "$(systemctl is-enabled libvirtd.service)" == "enabled" ]; then
          echo "${red}Disabling${n} libvirtd before removal"
          sudo systemctl disable --now libvirtd 2> /dev/null
        fi
        echo "Removing QEMU and virt-manager..."
        rpm-ostree remove -y virt-manager edk2-ovmf qemu
        rpm-ostree kargs \
        --delete-if-present="kvm.ignore_msrs=1" \
        --delete-if-present="kvm.report_ignored_msrs=0"
        echo 'Please re-run "ujust enable-virtualization" after the reboot to finish setup'
      fi
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
        echo 'add_drivers+=" vfio vfio_iommu_type1 vfio-pci "' | sudo tee /etc/dracut.conf.d/vfio.conf
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
            --append-if-missing="rd.driver.pre=vfio_pci" \
            --append-if-missing="vfio_pci.disable_vga=1"
          echo "VFIO will be enabled on next boot, make sure you enable IOMMU, VT-d or AMD-v in your BIOS!"
          echo "Please understand that since this is such a niche use case, support will be very limited!"
          echo "To add your unused/second GPU device ids to the vfio driver by running"
          echo 'rpm-ostree kargs --append-if-missing="vfio-pci.ids=xxxx:yyyy,xxxx:yyzz"'
          echo "NOTE: Your second GPU will not be usable by the host after you do this!"
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
        echo "Removing dracut modules"
        sudo rm /etc/dracut.conf.d/vfio.conf
        rpm-ostree initramfs --enable
        rpm-ostree kargs \
        --delete-if-present="iommu=pt" \
        --delete-if-present="iommu=on" \
        --delete-if-present="amd_iommu=on" \
        --delete-if-present="intel_iommu=on" \
        --delete-if-present="rd.driver.pre=vfio_pci" \
        --delete-if-present="vfio_pci.disable_vga=1" \
        --delete-if-present="vfio_pci.disable_vga=0" \
        $VFIO_IDS_KARG
      fi
    elif [[ "${OPTION,,}" =~ kvmfr ]]; then
      # Check if we are running on a Steam Deck
      if /usr/libexec/hwsupport/valve-hardware; then
        echo "IOMMU is not supported on Steam Deck"
        exit 0
      fi
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "This module") along with $(Urllink "https://looking-glass.io" "Looking Glass") is very experimental and not recommended for production use!"
      echo "The ublue team packages the kvmfr module only because it has to be supplied with the system image while using an atomic desktop."
      echo "If you do plan to use Looking Glass, please $(Urllink "https://universal-blue.discourse.group/docs?topic=956" "follow the guide here") on how to compile it for your system."
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
      sudo bash -c 'cat << KVMFR_DRACUT > /etc/dracut.conf.d/kvmfr.conf
    install_items+=" /etc/modprobe.d/kvmfr.conf "
    KVMFR_DRACUT'
      sudo bash -c "cat << KVMFR_MODPROBE > /etc/modprobe.d/kvmfr.conf
    options kvmfr static_size_mb=128
    KVMFR_MODPROBE"
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
      echo "you can do that in /etc/modprobe.d/kvmfr.conf"
      echo "$(Urllink "https://looking-glass.io/docs/rc/ivshmem_kvmfr/#libvirt" "Please read official documentation for kvmfr for how to use it")"
      echo ""
      echo "Press OK to start the process of regenerating your initramfs, this will take a long time"
      echo "and there is no good way to track progress for it, if anything is wrong it will error out."
      echo "${b}NOTE: You can start using kvmfr right now without rebooting, but you will need to regenerate initramfs for it to auto load next boot.${n}"
      CONFIRM=$(Choose OK)
      rpm-ostree initramfs --enable
    elif [[ "${OPTION,,}" =~ group ]]; then
      if ! grep -q "^libvirt" /etc/group; then
        grep '^libvirt' /usr/lib/group | sudo tee -a /etc/group > /dev/null
      fi
      sudo usermod -aG libvirt $USER
    fi
