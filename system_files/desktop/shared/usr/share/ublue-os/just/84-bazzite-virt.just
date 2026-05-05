# vim: set ft=make :

# Setup and configure virtualization
[group("virtualization")]
setup-virtualization ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    if [[ $(id -u) -eq 0 ]]; then
      echo "Please do not run this command as root"
      exit 1
    fi
    # Check if we are running on a Steam Deck
    if /usr/libexec/hwsupport/valve-hardware; then
      echo "${red}${b}WARNING${n}: Virtualization is not properly supported on Steam Deck by Valve"
      echo "Use at your own risk and performance may not be ideal."
    fi
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtualization <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'virt-on' to select Enable Virtualization"
      echo "  Use 'virt-off' to select Disable Virtualization"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtualization Setup${normal}"
      echo "NOTE: Enabling Virtualization will install the virt-manager flatpak and set kernel args"
      OPTION=$(Choose \
        "Enable Virtualization" \
        "Disable Virtualization" \
      )
    fi
    if [[ "${OPTION,,}" =~ (^enable[[:space:]]virtualization|virt-on) ]]; then
        if [ "$(systemctl is-enabled libvirtd.service)" == "disabled" ]; then
          echo "${b}libvirtd${n} service is ${red}disabled${n}!"
          echo "${green}enabling${n} and starting libvirtd"
          echo "If virt-manager says libvirtd.sock is not available after a big update, re-run this command."
          sudo systemctl enable --now libvirtd 2> /dev/null
        fi
        FLATPAKS_TO_INSTALL=()
        if ! flatpak info --system org.virt_manager.virt-manager 1>/dev/null 2>&1; then
          FLATPAKS_TO_INSTALL+=(org.virt_manager.virt-manager)
        fi
        if ! flatpak info --system org.virt_manager.virt_manager.Extension.Qemu 1>/dev/null 2>&1; then
          FLATPAKS_TO_INSTALL+=(org.virt_manager.virt_manager.Extension.Qemu)
        fi
        if [ ${#FLATPAKS_TO_INSTALL[@]} -gt 0 ]; then
          echo "Installing virt-manager and QEMU extension..."
          flatpak install --system --assumeyes flathub "${FLATPAKS_TO_INSTALL[@]}"
          rpm-ostree kargs \
          --append-if-missing="kvm.ignore_msrs=1" \
          --append-if-missing="kvm.report_ignored_msrs=0"
          echo "Making sure swtpm will work"
          if [ ! -d "/var/lib/swtpm-localca" ]; then
            sudo mkdir /var/lib/swtpm-localca
          fi
          sudo chown tss /var/lib/swtpm-localca
          sudo restorecon -rv /var/lib/libvirt
          sudo restorecon -rv /var/log/libvirt
          sudo systemctl enable bazzite-libvirtd-setup.service \
            && echo "libvirtd will be enabled at next reboot"
          echo 'Please reboot to apply changes'
        fi
        if ! getent group libvirt 1>/dev/null; then
          sudo groupadd --system libvirt
        fi
        sudo usermod -aG libvirt $USER
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
      if flatpak info --system org.virt_manager.virt-manager 1>/dev/null 2>&1; then
        flatpak uninstall --system --assumeyes org.virt_manager.virt-manager
      fi
      if flatpak info --system org.virt_manager.virt_manager.Extension.Qemu 1>/dev/null 2>&1; then
        flatpak uninstall --system --assumeyes org.virt_manager.virt_manager.Extension.Qemu
      fi
      rpm-ostree kargs \
      --delete-if-present="kvm.ignore_msrs=1" \
      --delete-if-present="kvm.report_ignored_msrs=0"
      echo 'Please reboot to apply changes'
    fi
