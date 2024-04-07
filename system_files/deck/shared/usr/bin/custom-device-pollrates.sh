#!/bin/bash
set -m

# Gather device poll rate settings from /etc/custom-device-pollrates/custom-device-pollrates.conf
DEVICES=$(grep -v '^\s*$\|^\s*\#' /etc/custom-device-pollrates/custom-device-pollrates.conf | paste -sd, -)

# Set new polling rate for devices
echo "$DEVICES" | sudo tee /sys/module/usbcore/parameters/interrupt_interval_override > /dev/null


# Reload all USB devices

for xhci in /sys/bus/pci/drivers/?hci_hcd ; do

  if ! cd $xhci ; then
    echo Failed to change directory to $xhci
    exit 1
  fi

  echo Resetting devices from $xhci...

  for i in ????:??:??.? ; do
    echo -n "$i" > unbind
    echo -n "$i" > bind
  done
sleep 1
done


