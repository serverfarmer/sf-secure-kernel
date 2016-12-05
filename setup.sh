#!/bin/sh
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.install


if [ "`uname`" != "Linux" ]; then
	echo "skipping secure kernel setup, unsupported system"
	exit 0
elif [ "$HWTYPE" = "container" ] || [ "$HWTYPE" = "lxc" ]; then
	echo "skipping secure kernel setup on container"
	exit 0
fi


base=/opt/farm/ext/secure-kernel


echo "disabling firewire interfaces"
install_link $base/modprobe/firewire-blacklist.conf /etc/modprobe.d/farmer-firewire-blacklist.conf


echo "setting up secure kernel configuration"
sysctl -qp $base/sysctl/base.conf

IPV6="enabled"
if [ "`ip -6 route show default`" = "" ]; then
	echo "disabling ipv6"
	sysctl -qp $base/sysctl/ipv6.conf
	IPV6="disabled"
fi

if [ ! -f /etc/X11/xinit/xinitrc ]; then
	echo "disabling sysrq (not needed on servers)"
	sysctl -qp $base/sysctl/sysrq.conf
fi


echo "making new kernel configuration persistent"
if [ -d /etc/sysctl.d ]; then
	install_link $base/sysctl/base.conf /etc/sysctl.d/farmer-base.conf

	if [ "$IPV6" != "enabled" ]; then
		install_link $base/sysctl/ipv6.conf /etc/sysctl.d/farmer-ipv6.conf
	fi

	if [ ! -f /etc/X11/xinit/xinitrc ]; then
		install_link $base/sysctl/sysrq.conf /etc/sysctl.d/farmer-sysrq.conf

		if [ -f /etc/sysctl.d/10-magic-sysrq.conf ]; then
			mv -f /etc/sysctl.d/10-magic-sysrq.conf /etc/sysctl.d/10-magic-sysrq.conf.disabled
		fi
	fi
fi
