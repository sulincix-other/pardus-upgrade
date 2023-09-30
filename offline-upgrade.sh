#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
source /etc/profile
if [[ $$ -eq 1 ]] ; then
    set +e
    plymouth --quit
    mount -o remount,rw /
    /lib/systemd/systemd-udevd --daemon
    # Starting udevadm
    udevadm trigger -c add
    udevadm settle
    # start dbus
    dbus-daemon --system --nofork &
    sleep 1
    # block upgrade b43 package
    apt-mark hold firmware-b43-installer
    apt-mark hold firmware-b43-legacy-installer
    # full upgrade https://serverfault.com/questions/48724/100-non-interactive-debian-dist-upgrade
    echo 'libc6 libraries/restart-without-asking boolean true' | debconf-set-selections
    apt -fuy -q  full-upgrade \
        --no-download \
        -o Dpkg::Options::="--force-confnew" \
        --allow-downgrades \
        --allow-remove-essential \
        --allow-change-held-packages
    apt-mark unhold firmware-b43-installer
    apt-mark unhold firmware-b43-legacy-installer
    rm /sbin/init
    mv /lib/systemd/systemd /sbin/init
    # sync and force reboot
    sync
    reboot -f
else
    apt -yq -d full-upgrade
    rm -f /sbin/init
    ln -s /usr/bin/pardus-upgrade /sbin/init
    # sync and force reboot
    sync
    reboot -f
fi
