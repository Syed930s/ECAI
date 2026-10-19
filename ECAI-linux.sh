#!/usr/bin/env bash
set -e
[ "$EUID" -eq 0 ] || exec sudo "$0" "$@"

ESP=$(lsblk -prno PATH,PARTTYPE | awk 'tolower($2)=="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"{print $1; exit}')
DISK=/dev/$(lsblk -no PKNAME "$ESP" | head -1)
PART=$(cat /sys/class/block/$(basename "$ESP")/partition)

MNT=$(findmnt -no TARGET "$ESP" | head -1 || true)
if [ -z "$MNT" ]; then
    MNT=$(mktemp -d)
    mount "$ESP" "$MNT"
    TMPMOUNT=1
fi

mkdir -p "$MNT/EFI/EFICOMMAND"
curl -L "https://github.com/Syed930s/EFICOMMAND/releases/download/0.5/BOOTX64.EFI" -o "$MNT/EFI/EFICOMMAND/BOOTX64.EFI"

NEW=$(efibootmgr -C -d "$DISK" -p "$PART" -L "EFICOMMAND" -l '\EFI\EFICOMMAND\BOOTX64.EFI' \
      | grep -i ' EFICOMMAND' | head -1 | sed -E 's/^Boot([0-9A-Fa-f]{4}).*/\1/')
ORDER=$(efibootmgr | awk -F': ' '/^BootOrder/{print $2}')
efibootmgr -o "${ORDER:+$ORDER,}$NEW"

if [ -n "$TMPMOUNT" ]; then
    umount "$MNT"
    rmdir "$MNT"
fi
