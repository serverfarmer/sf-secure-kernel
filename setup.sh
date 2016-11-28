#!/bin/sh
. /opt/farm/scripts/init
. /opt/farm/scripts/functions.install


if [ "`uname`" != "Linux" ]; then
	echo "skipping secure kernel setup, unsupported system"
	exit 0
fi

base=/opt/farm/ext/secure-kernel

echo "disabling firewire interfaces"
install_link $base/modprobe/firewire-blacklist.conf /etc/modprobe.d/farmer-firewire-blacklist.conf

echo "setting up secure kernel configuration"
install_link $base/sysctl/base.conf /etc/sysctl.d/farmer-base.conf
sysctl -qp /etc/sysctl.d/farmer-base.conf

install_link $base/sysctl/sysrq.conf /etc/sysctl.d/farmer-sysrq.conf
sysctl -qp /etc/sysctl.d/farmer-sysrq.conf

if [ "`ip -6 route show default`" = "" ]; then
	echo "disabling ipv6"
	install_link $base/sysctl/ipv6.conf /etc/sysctl.d/farmer-ipv6.conf
	sysctl -qp /etc/sysctl.d/farmer-ipv6.conf
fi
