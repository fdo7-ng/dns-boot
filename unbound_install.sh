#!/bin/bash

export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

# Run updates
sudo apt-get update || exit 1
sudo apt-get upgrade -y || exit 1

# Disable systemd-resolved
sudo systemctl stop systemd-resolved.service || exit 1
sudo systemctl disable systemd-resolved.service || exit 1

# Use the Azure DNS server
sudo rm /etc/resolv.conf
sudo echo "nameserver 168.63.129.16" > /tmp/resolv.conf || exit 1
sudo mv /tmp/resolv.conf /etc/resolv.conf || exit 1

# Add the hostname to /etc/hosts to prevent warnings about resolution
sudo cat /etc/hosts | sed '/127.0.0.1/ s/$/ ${hostname}/' > /tmp/hosts || exit 1
sudo mv /tmp/hosts /etc/hosts || exit 1

# Install unbound
sudo apt-get install -y unbound || exit 1

# Enable and start unbound (the last restart added just in case systemd already started it)
sudo systemctl enable unbound || exit 1
sudo systemctl start unbound || exit 1
sudo systemctl restart unbound || exit 1

# Only use unbound for DNS resolution going forward
sudo rm /etc/resolv.conf
sudo echo "nameserver 127.0.0.1" > /tmp/resolv.conf || exit 1
sudo mv /tmp/resolv.conf /etc/resolv.conf || exit 1

exit 0