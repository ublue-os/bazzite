#!/bin/sh

set -u
TMPBASE=$(mktemp -d /tmp/conky_efi.XXXX) || exit 0
cleanup() {
  [ -d "$TMPBASE" ] && rmdir "$TMPBASE"
}
trap cleanup EXIT

seen=""

for name in $(lsblk -prno NAME --filter 'FSTYPE=="vfat" and RM==0'); do
  [ -z "$name" ] && continue

  base=$(basename "$name")
  base=${base%%[0-9]*}

  mp="$TMPBASE/mnt_${base}_${RANDOM}"
  mkdir -p "$mp" || continue
  if mount -o ro "$name" "$mp" >& /dev/null; then
    if [ -d "$mp/EFI" ]; then
      for d in "$mp"/EFI/*; do
        [ -d "$d" ] || continue
        dn=$(basename "$d" | tr '[:lower:]' '[:upper:]')
        [ "$dn" == "BOOT" ] && continue
        case ",$seen," in
          *",$dn,"*) ;;
          *) [ -z "$seen" ] && seen="$dn" || seen="$seen,$dn" ;;
        esac
      done
    fi
    umount "$mp" 2>/dev/null || true
  fi
  rmdir "$mp" 2>/dev/null || true
done

printf "%s\n" "$seen"

exit 0