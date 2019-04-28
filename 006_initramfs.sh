#!/bin/sh

. ./errors.sh
. ./config.sh

cat << 'EOF' > /mnt/etc/mkinitcpio.conf
MODULES=()
BINARIES=()
FILES=()
HOOKS=(base udev autodetect modconf block keyboard encrypt lvm2 filesystems fsck)
EOF

artools-chroot /mnt mkinitcpio -p linux