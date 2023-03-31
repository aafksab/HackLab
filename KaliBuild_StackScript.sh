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
sudo apt install -y tigervnc-standalone-server tigervnc-common byobu iptables
sudo systemctl daemon-reload
sudo apt install -y snapd
sudo systemctl enable snapd.apparmor
sudo systemctl enable snapd
sudo systemctl start snapd
sudo systemctl start snapd.apparmor
sudo snap install novnc
export PATH=$PATH:/snap/bin
sudo apparmor_parser -r /etc/apparmor.d/*snap-confine*
sudo apparmor_parser -r /var/lib/snapd/apparmor/profiles/snap-confine*
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
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
# Generate a private key
#openssl genrsa -out key.pem 2048
# Generate a certificate signing request (CSR)
#openssl req -new -key key.pem -out csr.pem
# Generate the self-signed SSL certificate
#openssl x509 -req -days 365 -in csr.pem -signkey key.pem -out self.pem
# Display the details of the self-signed SSL certificate
#openssl x509 -in self.pem -text
# Step 1: Navigate to the systemd system directory
cd /lib/systemd/system/
# Step 2: Create a new service file called tigervncserver.service
sudo tee tigervncserver.service > /dev/null <<EOF
[Unit]
Description=TigerVNC server
[Service]
Type=forking
ExecStartPre=/bin/sh -c '/usr/bin/vncserver -kill %i > /dev/null 2>&1 || :'
ExecStart=/sbin/runuser -l LogixBomb -c "/usr/bin/tigervncserver -SecurityTypes None -autokill no"
ExecStop=/bin/sh -c '/usr/bin/tigervncserver -kill %i > /dev/null 2>&1 || :'
[Install]
WantedBy=multi-user.target
EOF
cd /root
# Step 3: Reload the systemd daemon to pick up the new service file
sudo systemctl daemon-reload
# Step 4: Enable the service to start at boot
sudo systemctl enable tigervncserver.service
# Step 5: Start the service
sudo systemctl start tigervncserver.service
# Step 1: Navigate to the polkit directory
cd /etc/polkit-1/localauthority/50-local.d/
# Step 2: Create a new service file 
sudo tee 45-allow-colord.pkla > /dev/null <<EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF
sudo snap set novnc services.n6082.listen=6061 services.n6082.vnc=localhost:5901