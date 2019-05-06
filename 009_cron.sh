#!/bin/sh

. ./errors.sh
. ./config.sh


artools-chroot /mnt pacman -Sy --noconfirm cronie
artools-chroot /mnt rc-update add cronie default