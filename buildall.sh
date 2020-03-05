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

MUST_PKG="linux wpa_supplicant os-prober grub"                   # must have pkg in the iso
XORG_PKG="xorg xorg-video-drivers xf86-input-libinput"           # xorg stuff in the iso
EXTRA_PKG="$(grep -v ^# pkglist | tr '\n' ' ')"                  # extra stuff in the iso, read from 'pkglist' file in current dir

PKG_DIR="/mnt/data/venom/packages-dev/"                          # prebuilt pkg path in host
SRC_DIR="/mnt/data/venom/sources/"                               # source path in host

# cmd used by 'mkiso' script
BUILD_CMD="sudo ./build -pkgdir $PKG_DIR -srcdir $SRC_DIR"

[ -f output/venom-rootfs.txz ] && {
	VENOMSRCOPT="output/venom-rootfs.txz"
}

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
	EDITION="base xorg lxde lxqt mate xfce4"
fi

for i in $EDITION; do
	if [ -f output/venom-$i-$(date +"%Y%m%d").iso ]; then
		echo ":: Skipping venom-$i-$(date +"%Y%m%d").iso"
	else
		OUTPUT=venom-$i-$(date +"%Y%m%d")
		ISOOPT="-iso"
		case $i in
			base)   PKGS="-pkg $MUST_PKG";;
			xorg)   PKGS="-pkg $MUST_PKG $XORG_PKG";;
			mate)   PKGS="-pkg $MUST_PKG $XORG_PKG $EXTRA_PKG mate mate-extra lxdm";;
			lxde)   PKGS="-pkg $MUST_PKG $XORG_PKG $EXTRA_PKG lxde lxdm";;
			lxqt)   PKGS="-pkg $MUST_PKG $XORG_PKG $EXTRA_PKG openbox lxqt oxygen-icons5 lxdm";;
			xfce4)  PKGS="-pkg $MUST_PKG $XORG_PKG $EXTRA_PKG xfce4 lxdm";;
			rootfs) PKGS="" ISOOPT="" OUTPUT="venom-rootfs";;
			*)      echo "ERROR: Currently suport flavors is rootfs, base, xorg, mate, lxde, and xfce4"; exit 1 ;;
		esac
		echo "build command: $BUILD_CMD $PKGS $ISOOPT -output $OUTPUT $VENOMSRCOPT"
		sleep 3
		echo ":: Building '$i' flavor..."
		$BUILD_CMD $PKGS $ISOOPT -output $OUTPUT $VENOMSRCOPT || exit 1
	fi
done

exit 0
