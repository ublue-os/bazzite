# vim: set ft=make :

# Install Docker, VS Code and add user to relevant groups for docker
install-visual-studio-code:
    #!/usr/bin/bash
    # check for updates
    ublue-update --wait
    # add yum repo
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    # install layer
    rpm-ostree install -y code
    echo 'Complete, please reboot to apply changes.'

install-docker-ce:
    #!/usr/bin/bash
    # check for updates
    ublue-update --wait
    # add yum repo
    echo -e "[docker-ce-stable]\nname=Docker CE Stable - $basearch\nbaseurl=https://download.docker.com/linux/fedora/$releasever/$basearch/stable\nenabled=1\ngpgcheck=1\ngpgkey=https://download.docker.com/linux/fedora/gpg" | sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null
    # install the layer
    rpm-ostree install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
    # Enable the service
    systemctl enable docker
    echo 'Complete, please reboot to apply changes.'

add-user-to-docker-group:
    #!/usr/bin/bash
    if ! grep -q "^docker:" /etc/group; then
      grep '^docker:' /usr/lib/group | sudo tee -a /etc/group > /dev/null
    fi
    sudo usermod -aG docker $USER
    echo 'Complete, please reboot/logout to apply changes.'
