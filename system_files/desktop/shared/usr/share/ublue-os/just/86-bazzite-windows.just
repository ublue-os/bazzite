# vim: set ft=make :

# Adds a script in Steam to boot Windows which is useful for dual-boot setups
setup-boot-windows-steam:
    echo "Making efibootmgr -n usable without sudo password"
    echo "%wheel ALL=(root) NOPASSWD: /usr/sbin/efibootmgr" | sudo tee /etc/sudoers.d/efibootmgr-config
    echo "Adding /usr/bin/boot-windows as a Non-steam game"
    touch /tmp/addnonsteamgamefile
    steam "steam://addnonsteamgame/%2Fusr%2Fbin%2Fboot-windows"
