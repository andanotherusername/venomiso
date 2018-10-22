#!/bin/bash

USER=venom
PASSWORD=venom

useradd -m -G users,wheel,audio,video -s /bin/bash $USER
passwd -d $USER &>/dev/null
passwd -d root &>/dev/null

echo "root:root" | chpasswd -c SHA512
echo "$USER:$PASSWORD" | chpasswd -c SHA512

chmod -R 775 /home/$USER/.config

# autologin user
sed -i "s/#autologin-user=/autologin-user=$USER/" /etc/lightdm/lightdm.conf
sed -i "s/#autologin-session=/autologin-session=mate/" /etc/lightdm/lightdm.conf

# theme and background
sed -i "s:#background=:background=/usr/share/backgrounds/venom1.jpg:" /etc/lightdm/lightdm-gtk-greeter.conf
sed -i "s:#theme-name=:theme-name=Arc-Darker:" /etc/lightdm/lightdm-gtk-greeter.conf
sed -i "s:#icon-theme-name=:icon-theme-name=Papirus-Dark:" /etc/lightdm/lightdm-gtk-greeter.conf

sed -i 's/localhost/venomlive/' /etc/rc.conf
sed -i '/DAEMONS=(/,/)/d' /etc/rc.conf

if [ -x /etc/rc.d/lxdm ]; then
	DM=lxdm
elif [ -x /etc/rc.d/lightdm ]; then
	DM=lightdm
fi

if [ -x /etc/rc.d/networkmanager ]; then
	NETWORK=networkmanager
elif [ -x /etc/rc.d/network ]; then
	NETWORK=network
fi

for i in sysklogd dbus $DM $NETWORK bluetooth; do
	if [ -x /etc/rc.d/$i ]; then
		daemon+=($i)
	fi
done

echo "DAEMONS=(${daemon[@]})" >> /etc/rc.conf

