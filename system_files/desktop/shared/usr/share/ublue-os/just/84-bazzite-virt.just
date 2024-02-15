# vim: set ft=make :

# Setup and configure virtualization and vfio
setup-virtualization ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    # Check if we are running on a Steam Deck
    if /usr/libexec/hardware/valve-hardware; then
      echo "Virtualization is not supported on Steam Deck"
      exit 0
    else
      if [ "$(systemctl is-enabled libvirtd.service)" == "disabled" ]; then
        echo "${b}libvirtd${n} service is ${red}disabled${n}!"
        echo "${green}enabling${n} and starting libvirtd"
        echo "If virt-manager says libvirtd.sock is not available after a big update, re-run this command."
        sudo systemctl enable --now libvirtd 2> /dev/null
        echo "Press ESC if you want to exit and do not need to do anything"
      fi
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust configure-grub <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'enable' to select Enable Virtualization"
      echo "  Use 'disable' to select Disable Virtualization"
      echo "  Use 'vfio' to select Enable VFIO drivers"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtualization Setup${normal}"
      echo "NOTE: Enabling Virtualization will layer virt-manager and qemu"
      echo "      this will slow down system updates by a lot."
      OPTION=$(Choose "Enable Virtualization" "Disable Virtualization" "Enable VFIO drivers")
    fi
    if [[ "${OPTION,,}" =~ ^enable[[:space:]]virt ]]; then
      virt_test=$(rpm-ostree status | grep -A 4 "●" | grep "virt-manager")
      if [[ -z ${virt_test} ]]; then
        echo "Installing QEMU and virt-manager..."
        rpm-ostree install -y virt-manager edk2-ovmf qemu
        rpm-ostree kargs \
        --append-if-missing="kvm.ignore_msrs=1" \
        --append-if-missing="kvm.report_ignored_msrs=0"
        echo 'Please re-run "ujust setup-virtualization" after the reboot to enable libvirtd service'
      fi
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
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
    elif [[ "${OPTION,,}" =~ vfio ]]; then
      echo "Enabling VFIO..."
      VIRT_TEST=$(rpm-ostree kargs)
      CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
      VENDOR_KARG="unset"
      if [[ ${VIRT_TEST} == *kvm.report_ignored_msrs* ]]; then
        echo 'add_drivers+=" vfio vfio_iommu_type1 vfio-pci "' | sudo tee /etc/dracut.conf.d/vfio.conf
        sudo touch /etc/bazzite/initramfs/rebuild
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
    fi
