#!/bin/sh

. ./errors.sh
. ./config.sh

curl -O http://mirror.f4st.host/archlinux/extra/os/x86_64/parted-3.2-8-x86_64.pkg.tar.xz
curl -O http://mirror.f4st.host/archlinux/core/os/x86_64/readline-8.0.0-1-x86_64.pkg.tar.xz

pacman -U --noconfirm readline-8.0.0-1-x86_64.pkg.tar.xz
pacman -U --noconfirm parted-3.2-8-x86_64.pkg.tar.xz

CMD="parted ${DISK} --align optimal --script --machine --"

# clearing partition header
dd bs=1M count=4 status=none if=/dev/zero of=${DISK} oflag=sync
# partitioning
${CMD} mklabel gpt
${CMD} unit MiB mkpart bios 1 2 name 1 "BIOS" set 1 bios_grub on
${CMD} unit MiB mkpart boot 2 514 name 2 "Boot" set 2 boot on set 2 esp on
${CMD} unit MiB mkpart system 514 -1

curl -O https://archive.archlinux.org/packages/r/readline/readline-7.0.005-1-x86_64.pkg.tar.xz
pacman -U --noconfirm readline-7.0.005-1-x86_64.pkg.tar.xz
# clearing partition header
dd if=/dev/zero bs=1M count=1 of=${DISK}1 oflag=sync status=none
dd if=/dev/zero bs=1M count=1 of=${DISK}2 oflag=sync status=none
dd if=/dev/zero bs=1M count=16 of=${DISK}3 oflag=sync status=none
# making filesystems
mkfs.vfat -F 32 -n EFI ${DISK}2
/etc/init.d/lvmetad start
if [ "${CRYPT}" = "yes" ]; then
    cryptsetup --verbose --cipher aes-xts-plain64 \
        --key-size 512 --hash sha512 --iter-time 2500 --use-urandom \
        --force-password luksFormat ${DISK}3
    cryptsetup luksOpen --allow-discards ${DISK}3 crypt
    
    pvcreate -ff -y --zero y /dev/mapper/crypt
    vgcreate system /dev/mapper/crypt
else
    pvcreate -ff -y --zero y ${DISK}3
    vgcreate system ${DISK}3
fi
lvcreate -L 4G --wipesignatures y -n swap system
lvcreate -l 100%FREE --wipesignatures y -n root system
lvscan
mkfs.ext4 -L root /dev/mapper/system-root
mkswap -f /dev/mapper/system-swap
sync
