#!/bin/sh
set -e

# Fetch offline upgrade
wget https://raw.githubusercontent.com/sulincix-other/pardus-upgrade/main/offline-upgrade.sh -O /usr/bin/pardus-upgrade
chmod +x /usr/bin/pardus-upgrade
# comment out external sources
sed -i "s/^/#/g" /etc/apt/sources.list.d/* || true
apt clean
find /var/lib/apt/lists -type f | xargs rm -fv

# write yirmiuc sources
SOURCE_LIST=/etc/apt/sources.list
cp -fv $SOURCE_LIST $SOURCE_LIST.debsave23
cat > $SOURCE_LIST.23 <<EOF
### The Official Pardus Package Repositories ###

## Pardus
deb http://depo.pardus.org.tr/pardus yirmiuc main contrib non-free non-free-firmware
# deb-src http://depo.pardus.org.tr/pardus yirmiuc main contrib non-free non-free-firmware

## Pardus Deb
deb http://depo.pardus.org.tr/pardus yirmiuc-deb main contrib non-free non-free-firmware
# deb-src http://depo.pardus.org.tr/pardus yirmiuc-deb main contrib non-free non-free-firmware

## Pardus Security Deb
deb http://depo.pardus.org.tr/guvenlik yirmiuc-deb main contrib non-free non-free-firmware
# deb-src http://depo.pardus.org.tr/guvenlik yirmiuc-deb main contrib non-free non-free-firmware
EOF
mv -fv $SOURCE_LIST.23 $SOURCE_LIST

DEBIAN_FRONTEND=noninteractive apt update
bash /usr/bin/pardus-upgrade
