#!/usr/bin/env bash
### Main Script
echo "127.0.0.1	kali" >> /etc/hosts
apt-mark hold grub-common grub-pc-bin grub-pc grub2-common grub-customizer
sudo apt update -yq && apt install -y htop
sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -yq && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
sudo apt install -y kali-desktop-xfce
rm -r .cache .config .local
systemctl set-default graphical.target
systemctl enable lightdm
systemctl start lightdm
mv /usr/share/backgrounds/kali-16x9/default default_old
cp /usr/share/backgrounds/kali-16x9/kali-cubism.jpg /usr/share/backgrounds/kali-16x9/default
# Locate the line number of the comment "# Default: DSHELL=/bin/bash"
line_number=$(grep -n "# Default: DSHELL=/bin/bash" /etc/adduser.conf | cut -d':' -f1)
# Append "DSHELL=/bin/zsh" to the line following the comment
sed -i "$((line_number+1))iDSHELL=/bin/zsh" /etc/adduser.conf
# Create user
sudo useradd --create-home LogixBomb
# Set password
echo "LogixBomb:CupCake" | sudo chpasswd
# Create default profile
sudo mkhomedir_helper "LogixBomb"
# Add user to root group
sudo usermod -aG sudo LogixBomb

# Get the current kernel version
current_version=$(uname -r)
# List all installed kernels
all_versions=$(dpkg --list | grep linux-image | awk '{print $2}')
# Loop through all installed kernels
for version in $all_versions; do
  # Remove all kernels except for the current version and the latest one
  if [[ $version != $current_version && $version != $(dpkg --list | grep linux-image | sort -k 3 | tail -n 1 | awk '{print $2}') ]]; then
    echo "Removing old kernel: $version"
    apt-get remove -y $version
  fi
done
# Remove unused packages
apt-get autoremove -y
# Cleanup apt cache
apt-get clean
# Clear any existing rules
iptables -F
# Set default policy to drop all incoming and outgoing traffic
iptables -P INPUT DROP
iptables -P OUTPUT DROP
# Allow incoming HTTP, HTTPS, and VNC traffic
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 6061 -j ACCEPT
# Allow outgoing HTTP, HTTPS, and VNC traffic
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 6061 -j ACCEPT
# Allow loopback traffic (required for some applications)
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# Save the rules to apply them on reboot
iptables-save > /etc/iptables.rules
# Reload the rules to activate them immediately
iptables-restore < /etc/iptables.rules
# Set zsh as the default shell for new users
echo "Set zsh as the default shell for new users"
sudo sed -i 's/DSHELL=\/bin\/bash/DSHELL=\/bin\/zsh/g' /etc/adduser.conf
# Set zsh as the default shell for all existing users
echo "Set zsh as the default shell for all existing users"
for user in $(getent passwd | cut -d: -f1)
do
  sudo usermod -s /bin/zsh $user
done
echo "Done"

#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Update package list and upgrade installed packages
echo "Updating package list and upgrading installed packages..."
apt-get update -y
apt-get upgrade -y

# Clean up package cache
echo "Cleaning up package cache..."
apt-get clean

# Install deborphan if not already installed
if ! dpkg -l deborphan >/dev/null 2>&1; then
    echo "Installing deborphan..."
    apt-get install -y deborphan
fi

# Remove all kernels except the latest
echo "Removing all kernels except the latest..."
latest_kernel=$(uname -r | cut -d- -f1,2)
all_kernels=$(dpkg --list | awk '/linux-image-[0-9]/ {print $2}' | grep -v "$latest_kernel")
if [ -n "$all_kernels" ]; then
    apt-get remove -y --purge $all_kernels
fi

# Remove all orphaned packages
echo "Removing orphaned packages..."
deborphan | xargs -r apt-get -y remove --purge

# Remove deborphan after it runs
echo "Removing deborphan..."
apt-get remove -y --purge deborphan

# Remove unneeded packages and their unused dependencies
echo "Running autoremove to clean up unused dependencies..."
apt-get autoremove -y

# Remove temporary files
echo "Removing temporary files..."
rm -rf /tmp/*
rm -rf /var/tmp/*

# Reset SSH host keys
echo "Resetting SSH host keys..."
rm -f /etc/ssh/ssh_host_*

# Remove user-specific configurations and history files
echo "Removing user-specific configurations and history files..."
for user in $(getent passwd | cut -f1 -d:); do
  user_home=$(getent passwd "${user}" | cut -f6 -d:)
  if [ -d "${user_home}" ]; then
    rm -f "${user_home}"/.bash_history
    rm -f "${user_home}"/.nano_history
    rm -f "${user_home}"/.lesshst
    rm -f "${user_home}"/.mysql_history
    rm -f "${user_home}"/.ssh/authorized_keys
  fi
done

# Clear log files
echo "Clearing log files..."
find /var/log -type f -exec truncate -s 0 {} \;
