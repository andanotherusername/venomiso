#!/bin/bash -e
#
# this is my helper script to build all edition of venom linux iso
# change suit to your need before run this script
#
# Usage: ./buildall.sh [edition]
#
# edition arg is space separated, without any arg will build all edition
#
# currently support edition is base, xorg, mate, lxde, and xfce4
#

MUST_PKG="linux-firmware linux wpa_supplicant os-prober grub"    # must have pkg in the iso
XORG_PKG="xorg xorg-video-drivers xf86-input-libinput"           # xorg stuff in the iso
EXTRA_PKG="$(cat pkglist | grep -v ^#)"                          # extra stuff in the iso, read from 'pkglist' file in current dir

PKG_DIR="/mnt/data/venom/packages-dev/"                          # prebuilt pkg path in host
SRC_DIR="/mnt/data/venom/sources/"                               # source path in host

BUILD_CMD="sudo ./mkiso -r -p $PKG_DIR -s $SRC_DIR"              # cmd used by 'mkiso' script

if [ "$*" ]; then
	while [ "$1" ]; do
		if [ -z "$EDITION" ]; then
			EDITION="$1"
		else
			EDITION="$EDITION $1"
		fi
		shift
	done
else
	EDITION="rootfs base xorg lxde mate xfce4"
fi

for i in $EDITION; do
	if [ -f venom-$i-$(date +"%Y%m%d").iso ]; then
		echo ":: Skipping venom-$i-$(date +"%Y%m%d").iso"
	else
		case $i in
			rootfs) BUILD_CMD_FINAL="sudo ./mkrootfs -p $PKG_DIR -s $SRC_DIR -o venom-rootfs.txz" ;;
			base)   BUILD_CMD_FINAL="$BUILD_CMD -P $MUST_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			xorg)   BUILD_CMD_FINAL="$BUILD_CMD -P $MUST_PKG $XORG_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			mate)   BUILD_CMD_FINAL="$BUILD_CMD -P $MUST_PKG $XORG_PKG mate mate-extra lxdm $EXTRA_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			lxde)   BUILD_CMD_FINAL="$BUILD_CMD -P $MUST_PKG $XORG_PKG lxde lxdm $EXTRA_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			xfce4)  BUILD_CMD_FINAL="$BUILD_CMD -P $MUST_PKG $XORG_PKG xfce4 lxdm $EXTRA_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			*)      echo "ERROR: Currently suport flavors is rootfs, base, xorg, mate, lxde, and xfce4"; exit 1 ;;
		esac
		echo ":: Building '$i' flavor..."
		$BUILD_CMD_FINAL || error=1
		unset BUILD_CMD_FINAL
	fi
	if [ "$error" = 1 ]; then
		exit 1
	fi
done

exit 0
