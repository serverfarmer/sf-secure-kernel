#!/bin/sh
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.install


disable_file() {
	file=$1
	if [ -f $file ]; then
		mv -f $file $file.disabled
	fi
}


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



if [ "$OSTYPE" != "debian" ]; then
	echo "delaying secure kernel configuration until system reboot"
else
	echo "setting up secure kernel configuration"
	sysctl -qp $base/sysctl/base.conf

	if [ ! -f /etc/X11/xinit/xinitrc ]; then
		echo "disabling sysrq (not needed on servers)"
		sysctl -qp $base/sysctl/sysrq.conf
	fi
fi

echo "making new kernel configuration persistent"
if [ -d /etc/sysctl.d ]; then

	# transitional code
	remove_link /etc/sysctl.d/farmer-base.conf
	remove_link /etc/sysctl.d/farmer-ipv6.conf
	remove_link /etc/sysctl.d/farmer-sysrq.conf

	# install new configuration sets
	install_copy $base/sysctl/base.conf /etc/sysctl.d/farmer-base.conf
	install_copy $base/sysctl/network.conf /etc/sysctl.d/farmer-network.conf

	# disable conflicting Ubuntu default
	disable_file /etc/sysctl.d/10-kernel-hardening.conf
	disable_file /etc/sysctl.d/10-ptrace.conf

	# disable sysrq on text-only hosts
	if [ ! -f /etc/X11/xinit/xinitrc ]; then
		install_copy $base/sysctl/sysrq.conf /etc/sysctl.d/farmer-sysrq.conf
		disable_file /etc/sysctl.d/10-magic-sysrq.conf
	fi
fi
