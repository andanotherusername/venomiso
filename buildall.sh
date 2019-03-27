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

MUST_PKG="wpa_supplicant os-prober linux-firmware btrfs-progs reiserfsprogs xfsprogs" # must have pkg in the iso
XORG_PKG="xorg xorg-video-drivers xf86-input-libinput harfbuzz"                       # xorg stuff in the iso
EXTRA_PKG="$(cat pkglist | grep -v ^#)"                                               # extra stuff in the iso, read from 'pkglist' file in current dir

PKG_DIR="/mnt/data/venom/packages-dev/"   # prebuilt pkg path in host
SRC_DIR="/mnt/data/venom/sources/"        # source path in host

BUILD_CMD="sudo ./mkiso -p $PKG_DIR -s $SRC_DIR" # cmd used by 'mkiso' script

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
	EDITION="base xorg mate lxde xfce4"
fi

for i in $EDITION; do
	if [ -f venom-$i-$(date +"%Y%m%d").iso ]; then
		echo ":: Skipping venom-$i-$(date +"%Y%m%d").iso"
	else
		case $i in
			base) BUILD_CMD_FINAL="$BUILD_CMD -P $MUST_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			xorg) BUILD_CMD_FINAL="$BUILD_CMD -P $MUST_PKG $XORG_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			mate) BUILD_CMD_FINAL="$BUILD_CMD -P mate mate-extra lxdm $MUST_PKG $XORG_PKG $EXTRA_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			lxde) BUILD_CMD_FINAL="$BUILD_CMD -P lxde lxdm $MUST_PKG $XORG_PKG $EXTRA_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			xfce4) BUILD_CMD_FINAL="$BUILD_CMD -P xfce4 lxdm $MUST_PKG $XORG_PKG $EXTRA_PKG -o venom-$i-$(date +"%Y%m%d").iso";;
			*) echo "ERROR: Currently suport edition is base, xorg, mate, lxde, and xfce4"; exit 1 ;;
		esac
		echo ":: Building '$i' edition..."
		$BUILD_CMD_FINAL || error=1
		unset BUILD_CMD_FINAL
	fi
	if [ "$error" = 1 ]; then
		exit 1
	fi
done
