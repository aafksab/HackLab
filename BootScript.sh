#!/usr/bin/env bash
### Main Script
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
# Install TigerVNC
sudo apt install -y tigervnc-standalone-server tigervnc-common byobu iptables
sudo systemctl daemon-reload
# Install Snapd
sudo apt install -y snapd
sudo systemctl enable snapd.apparmor
sudo systemctl enable snapd
sudo systemctl start snapd
sudo systemctl start snapd.apparmor
sudo snap install novnc
export PATH=$PATH:/snap/bin
sudo apparmor_parser -r /etc/apparmor.d/*snap-confine*
sudo apparmor_parser -r /var/lib/snapd/apparmor/profiles/snap-confine*
sudo apt install -y kali-desktop-live kali-tools-crypto-stego kali-tools-fuzzing kali-tools-top10 kali-linux-default
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
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