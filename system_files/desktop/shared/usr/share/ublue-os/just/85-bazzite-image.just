# vim: set ft=make :

# Enable Virtualization and add workaround for a specific windows VM crash
enable-virtualization:
    #!/usr/bin/bash
    virt_test=$(rpm-ostree status | grep -A 4 "●" | grep "virt-manager")
    if [[ -z ${virt_test} ]]; then
      echo "Installing QEMU and virt-manager..."
      rpm-ostree install -y virt-manager edk2-ovmf qemu
      rpm-ostree kargs \
      --append-if-missing="kvm.ignore_msrs=1" \
      --append-if-missing="kvm.report_ignored_msrs=0"
      echo 'Please re-run "ujust enable-virtualization" after the reboot to finish setup'
    else
      echo "Enabling libvirtd service"
      sudo systemctl enable --now libvirtd
      echo "libvirtd enabled! If virt-manager says libvirtd.sock is not available after a big update, re-run this command."
    fi

# Enable VFIO on the system if virtualization is enabled
enable-vfio:
    #!/usr/bin/bash
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
    else
      echo "Enable virtualization with ujust enable-virtualization before running ujust enable-vfio."
    fi

# Add SELinux file context for default looking-glass shm file so that libvirt can create it when needed
selinux-looking-glass:
    sudo tee << 'LOOKING_GLASS_TMP' > /etc/tmpfiles.d/10-looking-glass.conf
    # Type Path               Mode UID  GID Age Argument
    f /dev/shm/looking-glass 0660 1000 qemu -
    LOOKING_GLASS_TMP
    sudo semanage fcontext -a -t svirt_tmpfs_t /dev/shm/looking-glass
