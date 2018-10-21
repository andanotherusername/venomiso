#!/bin/bash

USER=venom

chmod -R 775 /etc/skel/.config
mkdir /home/venom

sed -i 's/localhost/venomlive/' /etc/rc.conf

# autologin user
sed -i "s/#autologin-user=/autologin-user=$USER/" /etc/lightdm/lightdm.conf
sed -i "s/#autologin-session=/autologin-session=mate/" /etc/lightdm/lightdm.conf

# theme and background
sed -i "s:#background=:background=/usr/share/backgrounds/venom1.jpg:" /etc/lightdm/lightdm-gtk-greeter.conf
sed -i "s:#theme-name=:theme-name=Arc-Darker:" /etc/lightdm/lightdm-gtk-greeter.conf
sed -i "s:#icon-theme-name=:icon-theme-name=Papirus-Dark:" /etc/lightdm/lightdm-gtk-greeter.conf

sed -i '/DAEMONS=(/,/)/d' /etc/rc.conf

for i in sysklogd dbus lightdm networkmanager bluetooth; do
	if [ -x /etc/rc.d/$i ]; then
		daemon+=($i)
	fi
done

echo "DAEMONS=(${daemon[@]})" >> /etc/rc.conf

