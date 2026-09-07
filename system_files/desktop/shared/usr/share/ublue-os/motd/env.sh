#!/usr/bin/env sh
# KEEP THIS SMALL
# This will run on every shell that a user starts up.

export MOTD_IMAGE_NAME="$(jq -rc '."image-ref"' "${MOTD_IMAGE_INFO_FILE:-/usr/share/ublue-os/image-info.json}" | sed 's@ostree-image-signed:docker://@@')"
export MOTD_IMAGE_BRANCH="$(jq -rc '."image-branch"' "${MOTD_IMAGE_INFO_FILE:-/usr/share/ublue-os/image-info.json}")"
export MOTD_IMAGE_TAG="$(jq -rc '."image-tag"' "${MOTD_IMAGE_INFO_FILE:-/usr/share/ublue-os/image-info.json}")"
case "${LC_MESSAGES:-${LANG:-C}}" in
  sv*)
    export MOTD_TEMPLATE_FILE="${MOTD_TEMPLATE_FILE:-/usr/share/ublue-os/motd/template.sv.md}"
    export MOTD_TIP_DIRECTORY="${MOTD_TIP_DIRECTORY:-/usr/share/ublue-os/motd/tips/sv}"
    ;;
esac
export MOTD_TIP="${MOTD_TIP:-"$(/usr/bin/cat "${MOTD_TIP_DIRECTORY:-/usr/share/ublue-os/motd/tips}"/*.md 2>/dev/null | shuf -n 1)"}"
GREENBOOT=""
if [ -f /etc/motd.d/boot-status ]; then
	if grep -q "status is GREEN" /etc/motd.d/boot-status; then
		GREENBOOT='Boot Status: Healthy 󰄳'
	else
		GREENBOOT=$(cat /etc/motd.d/boot-status)
	fi
fi
export MOTD_GREENBOOT="$GREENBOOT"
