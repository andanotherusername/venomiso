#!/bin/bash

#
# This script is executed inside initramfs using chroot to live environment
#

USER=venom
PASSWORD=venom

useradd -m -G users,wheel,audio,video -s /bin/bash $USER
passwd -d $USER &>/dev/null
passwd -d root &>/dev/null

echo "root:root" | chpasswd -c SHA512
echo "$USER:$PASSWORD" | chpasswd -c SHA512

#chmod -R 775 /home/$USER/.config

sed 's/#\(en_US\.UTF-8\)/\1/' -i /etc/locales
genlocales &>/dev/null

# Enable sudo permission by default.
if [ -f /etc/sudoers ]; then
    echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

if [ -d /etc/polkit-1 ]; then
    cat > /etc/polkit-1/rules.d/venom-live.rules <<_EOF
polkit.addAdminRule(function(action, subject) {
    return ["unix-group:wheel"];
});
polkit.addRule(function(action, subject) {
    if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
_EOF
fi

mkdir -p /var/lib/lxdm/
cat > /var/lib/lxdm/lxdm.conf <<_EOF
[base]
last_session=__default__
last_lang=
_EOF

#sed -i "s/--noclear/--noclear -a $USER/" /etc/inittab

if [ $(type -p startxfce4) ]; then
	SSN=$(type -p startxfce4)
elif [ $(type -p mate-session) ]; then
	SSN=$(type -p mate-session)
elif [ $(type -p startlxde) ]; then
	SSN=$(type -p startlxde)
elif [ $(type -p startkde) ]; then
	SSN=$(type -p startkde)
fi

if [ -x $(type -p lxdm) ]; then
	sed -e "s,.*session.*=.*,session=$SSN," -i /etc/lxdm/lxdm.conf
	sed -e "s,.*autologin.*=.*,autologin=$USER," -i /etc/lxdm/lxdm.conf
	#sed "s,#bg=/usr/share/backgrounds/default.png,bg=/usr/share/backgrounds/venom1.jpg," -i /etc/lxdm/lxdm.conf
elif [ -x $(type -p lightdm) ]; then
	# autologin user
	sed -i "s/#autologin-user=/autologin-user=$USER/" /etc/lightdm/lightdm.conf
	sed -i "s/#autologin-session=/autologin-session=mate/" /etc/lightdm/lightdm.conf

	# theme and background
	#sed -i "s:#background=:background=/usr/share/backgrounds/venom1.jpg:" /etc/lightdm/lightdm-gtk-greeter.conf
	sed -i "s:#theme-name=:theme-name=Arc-Darker:" /etc/lightdm/lightdm-gtk-greeter.conf
	sed -i "s:#icon-theme-name=:icon-theme-name=Papirus-Dark:" /etc/lightdm/lightdm-gtk-greeter.conf
fi

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
