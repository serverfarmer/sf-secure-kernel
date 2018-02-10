#!/bin/sh
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.install


if [ "`uname`" != "Linux" ]; then
	echo "skipping secure kernel setup, unsupported system"
	exit 0
elif [ "$HWTYPE" = "oem" ]; then
	echo "skipping secure kernel setup on oem platform"
	exit 0
elif [ "$HWTYPE" = "container" ] || [ "$HWTYPE" = "lxc" ]; then
	echo "skipping secure kernel setup on container"
	exit 0
fi


base=/opt/farm/ext/secure-kernel


echo "disabling firewire interfaces"
remove_link /etc/modprobe.d/farmer-firewire-blacklist.conf
install_copy $base/modprobe/firewire-blacklist.conf /etc/modprobe.d/farmer-firewire-blacklist.conf


echo "setting up secure kernel configuration"
sysctl -qp $base/sysctl/base.conf

if [ ! -f /etc/X11/xinit/xinitrc ]; then
	echo "disabling sysrq (not needed on servers)"
	sysctl -qp $base/sysctl/sysrq.conf
fi


echo "making new kernel configuration persistent"
if [ -d /etc/sysctl.d ]; then
	remove_link /etc/sysctl.d/farmer-base.conf
	remove_link /etc/sysctl.d/farmer-ipv6.conf
	remove_link /etc/sysctl.d/farmer-sysrq.conf
	install_copy $base/sysctl/base.conf /etc/sysctl.d/farmer-base.conf

	if [ ! -f /etc/X11/xinit/xinitrc ]; then
		install_copy $base/sysctl/sysrq.conf /etc/sysctl.d/farmer-sysrq.conf

		if [ -f /etc/sysctl.d/10-magic-sysrq.conf ]; then
			mv -f /etc/sysctl.d/10-magic-sysrq.conf /etc/sysctl.d/10-magic-sysrq.conf.disabled
		fi
	fi
fi
