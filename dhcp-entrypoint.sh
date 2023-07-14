#!/bin/sh
echo "Setting hostname..."
echo "punktube" > /etc/hostname

echo "Configuring /etc/hosts file..."
echo "::1             localhost ipv6-localhost ipv6-loopback" >> /etc/hosts
echo "fe00::0         ipv6-localnet" >> /etc/hosts
echo "ff00::0         ipv6-mcastprefix" >> /etc/hosts
echo "ff02::1         ipv6-allnodes" >> /etc/hosts
echo "ff02::2         ipv6-allrouters" >> /etc/hosts
echo "ff02::3         ipv6-allhosts" >> /etc/hosts

echo "Configuring DNS..."
echo "auto lo" >> /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet6 auto" >> /etc/network/interfaces
echo "iface eth0 inet dhcp" >> /etc/network/interfaces

echo "Restarting networking service..."
/etc/init.d/networking restart

echo "Performing ping test..."
ping -c 4 www.google.com

echo "Installing iputils for traceroute..."
apk add iputils

echo "Performing IPv6 traceroute..."
traceroute6 ipv6.google.com

echo "Executing the specified command..."
exec "$@"
