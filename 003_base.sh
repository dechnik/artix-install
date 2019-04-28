#!/bin/sh

. ./errors.sh
. ./config.sh

pacman -Syy 

basestrap /mnt base base-devel openrc efitools grub efibootmgr lvm2 cryptsetup parted 

fstabgen -U -p /mnt >> /mnt/etc/fstab
cp /etc/resolv.conf /mnt/etc/resolv.conf
