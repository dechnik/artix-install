#!/bin/sh

. ./errors.sh
. ./config.sh

echo "aomen" > /mnt/etc/hostname

cat << EOF > /mnt/etc/hosts
# <header>
127.0.0.1       localhost aomen
255.255.255.255 broadcasthost
::1             localhost aomen ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
ff02::3         ip6-allhosts
# </header>
EOF

artools-chroot /mnt pacman -Sy --noconfirm networkmanager networkmanager-openrc
artools-chroot /mnt rc-update add NetworkManager default