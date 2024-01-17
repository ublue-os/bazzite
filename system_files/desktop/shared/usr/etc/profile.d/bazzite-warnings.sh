IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_FLAVOR=$(jq -r '."image-flavor"' < $IMAGE_INFO)

if [[ $IMAGE_FLAVOR = "nvidia"  ]]; then
	if ! grep -q "nvidia" <<< $(lsmod); then
		echo -e 'You are using a Nvidia image, but the Nvidia driver is not loaded:\n - If you are using secure boot, run "ujust enroll-secure-boot-key", then reboot and enter the password "ublue-os" when prompted.\n - If you are not using secure boot or have already enrolled the above key, ensure you have the needed kargs by running "ujust configure-nvidia kargs" and then rebooting.\n - This message will not appear if the issue is resolved.\n'
	fi
else
	if ! grep -q "v4l2loopback" <<< $(lsmod); then
		echo -e 'Requires drivers could not be loaded:\n - If you are using secure boot, run "ujust enroll-secure-boot-key", then reboot and enter the password "ublue-os" when prompted.\n - This message will not appear if the issue is resolved.\n'
	fi
fi
