#!/bin/sh

echo "cat punk-logo.txt"
echo ""
echo ""
echo "******** NETWORK-SETUP *******"
echo "Setting hostname: punktube ..."
echo "punktube" > /etc/hostname


echo "Configuring /etc/hosts file ..."
echo "--------------------------------"
echo "::1             localhost ipv6-localhost ipv6-loopback" >> /etc/hosts
echo "fe00::0         ipv6-localnet" >> /etc/hosts
echo "ff00::0         ipv6-mcastprefix" >> /etc/hosts
echo "ff02::1         ipv6-allnodes" >> /etc/hosts
echo "ff02::2         ipv6-allrouters" >> /etc/hosts
echo "ff02::3         ipv6-allhosts" >> /etc/hosts

echo "Configuring DNS..."
echo "--------------------------------"
echo "auto lo" >> /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet6 auto" >> /etc/network/interfaces
echo "iface eth0 inet dhcp" >> /etc/network/interfaces

echo "Restarting networking service..."
/etc/init.d/networking restart

echo "Obtaining IP address..."
ip_address=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
echo "Obtained IP address: $ip_address"

echo "Installing iputils for traceroute..."
apk add iputils

echo "******** NETWORK-TEST *******"
echo "Performing ping test for 5 sec..."
counter=0
while [ $counter -lt 5 ]
do
  ping -c 4 www.google.com
  if [ $? -eq 0 ]; then
    break
  fi
  counter=$((counter+1))
  sleep 1
done

echo "Performing IPv6 traceroute for 5 sec..."
counter=0
while [ $counter -lt 5 ]
do
  traceroute6 -m 20 ipv6.google.com
  if [ $? -eq 0 ]; then
    break
  fi
  counter=$((counter+1))
  sleep 1
done

echo "cat punk-logo.txt"
echo ""
echo ""
sleep 10

echo "Setting umask to ${UMASK}"
umask ${UMASK}
echo "Creating download directory (${DOWNLOAD_DIR}), state directory (${STATE_DIR}), and temp dir (${TEMP_DIR})"
mkdir -p "${DOWNLOAD_DIR}" "${STATE_DIR}" "${TEMP_DIR}"

if [ `id -u` -eq 0 ] && [ `id -g` -eq 0 ]; then
    if [ "${UID}" -eq 0 ]; then
        echo "Warning: it is not recommended to run as root user, please check your setting of the UID environment variable"
    fi
    echo "Changing ownership of download and state directories to ${UID}:${GID}"
    chown -R "${UID}":"${GID}" /app "${DOWNLOAD_DIR}" "${STATE_DIR}" "${TEMP_DIR}"
    echo "Running MeTube as user ${UID}:${GID}"
    su-exec "${UID}":"${GID}" python3 app/main.py
else
    echo "User set by docker; running MeTube as `id -u`:`id -g`"
    python3 app/main.py
fi
