#!/bin/bash

# Clear Screen
     clear
     echo "  _____                         _____ _   _______        _              _ " 
     echo " / ____|                       |  __ (_) |__   __|      | |            | |"
     echo "| |     _ __ _____      ___ __ | |__) |     | | ___  ___| |_ _ __   ___| |"
     echo "| |    | '__/ _ \ \ /\ / / '_ \|  ___/ |    | |/ _ \/ __| __| '_ \ / _ \ __|"
     echo "| |____| | | (_) \ V  V /| | | | |   | |    | |  __/\__ \ |_| | | |  __/ |_"
     echo " \_____|_|  \___/ \_/\_/ |_| |_|_|   |_|    |_|\___||___/\__|_| |_|\___|\__|"     
     sleep 1
# Choose OS
    echo ===============================================
    echo "Are you using Linux or Raspberry Pi?"
    choice=3
    echo "1. Linux"
    echo "2. RPI"
    echo -n "1 for Linux 2 for RPI [1 or 2]? "
    while [ $choice -eq 3 ]; do
    read -r choice
    if [ "$choice" -eq 1 ] ; then
# Update or Install?
    echo ===============================================
    echo "Would you like to Update or Install CrownPi?"
    choice=3
    echo "1. Update"
    echo "2. Install"
    echo -n "1 for Update 2 for Install [1 or 2]? "
    while [ $choice -eq 3 ]; do
    read -r choice
# Update 1
    if [ "$choice" -eq 1 ] ; then
    clear
    echo ===============================================
    echo Updating...
    echo ===============================================
# Shutdown crownd
    echo "Shutting down crown client"
    crown-cli stop
    echo ===============================================
# Update crown client
    sudo crown-server-install.sh
    else
# Install A2
    if [ "$choice" -eq 2 ] ; then
# Stop Crown client
    echo ===============================================
    echo "Stopping Crown client"
    sudo crown-cli stop
# Software install
    echo ===============================================
    echo Installing software...
    sudo apt-get install ufw -y
    sudo apt-get install unzip -y
    sudo apt-get install nano -y
    sudo apt-get install p7zip -y
    sudo apt-get install curl -y
    sudo apt install xz-utils -y
    echo "Done"
    echo
# Attempt to create 1GB swap ram
    echo ===============================================
    echo Adding 2GB Swap
    if [ "$(sudo swapon | wc -l)" -lt 2 ]; then
    echo    
    echo "There is no swap defined. Adding 2GB of swap space."
    sudo mkdir -p /var/cache/swap/   
    sudo dd if=/dev/zero of=/var/cache/swap/myswap bs=1M count=2048
    sudo chmod 600 /var/cache/swap/myswap
    sudo mkswap /var/cache/swap/myswap
    sudo swapon /var/cache/swap/myswap
    swap_line="/var/cache/swap/myswap   none    swap    sw  0   0"
    # Add the line only once 
    sudo grep -q -F "$swap_line" /etc/fstab || echo "$swap_line" | sudo tee --append /etc/fstab > /dev/null
    echo "The updated /etc/fstab looks like this:"
    cat /etc/fstab
    fi
# Maintenance scripts
    echo ===============================================
    echo Downloading script...
    sudo curl -o /usr/local/bin/crown-testnet-install.sh https://gitlab.crownplatform.com/crown/crown-core/-/raw/master/scripts/crown-testnet-install.sh
    sudo chmod +x /usr/local/bin/crown-testnet-install.sh
# Boot A open
    echo ===============================================
    echo Would you like to download the snapshot?
    choice=3
    echo "1. Yes"
    echo "2. No"
    echo -n "1 for Yes 2 for No [1 or 2]? "
    while [ $choice -eq 3 ]; do
    read -r choice
# Boot A1
    if [ "$choice" -eq 1 ] ; then
    echo ===============================================
    echo Downloading snapshot
    sudo mkdir /home/testnet/.crown
    sudo wget "https://storage.crownplatform.com/s/7W7CiJJMF9Zkxxx/download" -O "/home/testnet/.crown/snapshot.zip"
    sudo unzip "/home/testnet/.crown/snapshot.zip"
    sudo rm -rf "/home/testnet/.crown/snapshot.zip"
    sudo crown-server-install.sh -c -m -w
    else
# Boot A2
    if [ "$choice" -eq 2 ] ; then
    echo ===============================================
    echo "Skipping snapshot"
    echo ===============================================
    echo "Installing Crown client"
# Client download
    echo "Getting 0.0.0.5 client..."
    sudo mkdir /home/testnet/.crown
    # Create temporary directory
    dir=$(mktemp -d)
    if [ -z "$dir" ]; then
    # Create directory under $HOME if above operation failed
    dir=$HOME/crown-temp
    mkdir -p "$dir"
    fi
    # Change this later to take latest release version.(UPDATE)
    sudo wget "https://github.com/Crowndev/crown/releases/download/0.0.0.5/linux.tar.xz" -O "$dir/linux.tar.xz"
# Install Crown client
    sudo tar -xf "$dir/crown" "$dir/linux.tar.xz"
    sudo cp -f "$dir"/crown/*/bin/* /usr/local/bin/
    sudo cp -f "$dir"/crown/*/lib/* /usr/local/lib/
    sudo rm -rf "$tmp"
    else
    echo "Please make a choice between Yes or No !"
    echo "1. Yes"
    echo "2. No"
    echo -n "1 for Yes 2 for No [1 or 2]? "
    choice=3
    fi
    fi
    done
# Firewall
    echo Setting up firewall...
    sudo ufw allow ssh/tcp
    sudo ufw limit ssh/tcp
    sudo ufw allow 9341/tcp
    sudo ufw allow 9340
# Help scripts
    echo ===============================================
    echo Downloading scripts and other useful tools...
    sudo wget "https://www.dropbox.com/s/gq4vxog7riom739/whatsmyip.sh?dl=0" -O whatsmyip.sh | bash && sudo chmod +x whatsmyip.sh
    echo ===============================================
    echo "Setting up crown.conf"
    cd "$ROOT" || exit
    sudo mkdir -p /home/testnet/.crown
    sudo mv /home/testnet/.crown/crown.conf /home/testnet/.crown/crown.bak
    sudo touch /home/testnet/.crown/crown.conf
    IP=$(curl http://checkip.amazonaws.com/)
    PW=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c32;echo;)
    sudo echo "==========================================================="
    sudo pwd 
    echo 'testnet=1' | sudo tee -a /home/testnet/.crown/crown.conf
    echo 'daemon=1' | sudo tee -a /home/testnet/.crown/crown.conf 
    echo 'staking=0' | sudo tee -a /home/testnet/.crown/crown.conf
    echo 'rpcallowip=127.0.0.1' | sudo tee -a /home/testnet/.crown/crown.conf 
    echo 'rpcuser=crowncoinrpc' | sudo tee -a /home/testnet/.crown/crown.conf 
    echo 'rpcpassword='"$PW" | sudo tee -a /home/testnet/.crown/crown.conf 
    echo 'listen=1' | sudo tee -a /home/testnet/.crown/crown.conf 
    echo 'server=1' | sudo tee -a /home/testnet/.crown/crown.conf 
    echo 'externalip='"$IP" | sudo tee -a /home/testnet/.crown/crown.conf
    echo 'masterode=1' | sudo tee -a /home/testnet/.crown/crown.conf
    echo 'masternodeprivkey=YOURGENKEYHERE' | sudo tee -a /home/testnet/.crown/crown.conf
# Crontab entry
    echo ===============================================
    echo Adding to Crontab
    echo 'MAILTO=""' | sudo tee -a /var/spool/cron/crontabs/home/testnet
    echo '@reboot /usr/local/bin/crownd' | sudo tee -a /var/spool/cron/crontabs/home/testnet
# Zabbix Install
# Zabbix A open
    echo ===============================================
    echo Would you like to install a Zabbix agent?
    choice=3
# Print to stdout
    echo "1. Yes"
    echo "2. No"
    echo -n "1 for Yes 2 for No [1 or 2]? "
# Loop while the variable choice is equal 4
# bash while loop
    while [ $choice -eq 3 ]; do
# read user input
    read -r choice
# bash nested if/else
    if [ "$choice" -eq 1 ] ; then
        echo "You have chosen to install a Zabbix agent"
        sudo wget http://repo.zabbix.com/zabbix/3.4/debian/pool/main/z/zabbix-release/zabbix-release_3.4-1+stretch_all.deb
        sudo dpkg -i zabbix-release_3.4-1+stretch_all.deb
        sudo apt-get update -y
        sudo apt-get install zabbix-agent -y
        echo
        echo Note - Edit zabbix agent configuration file using 'nano /etc/zabbix/zabbix_agentd.conf'
        echo Note - Server=[zabbix server ip] Hostname=[Hostname of Server] EG, Server=192.168.1.10 Hostname=raspberry1
        echo
    else

        if [ "$choice" -eq 2 ] ; then
            echo "Skip Zabbix agent installation"    
        else
            echo "Please make a choice between Yes or No !"
            echo "1. Yes"
            echo "2. No"
            echo -n "1 for Yes 2 for No [1 or 2]? "
            choice=3
        fi
    fi
    done
# NordVPN Install
# VPN A open
    echo ===============================================
    echo Please choose a VPN provider...
    choice=3
# Print to stdout
    echo "1. NordVPN"
    echo "2. VPN Area"
    echo -n "Please choose a VPN [1,2 or 3]? "
# Loop while the variable choice is equal 4
# bash while loop
    while [ $choice -eq 3 ]; do
# read user input
    read -r choice
# bash nested if/else
    if [ "$choice" -eq 1 ] ; then
        echo "You have chosen NordVPN"
        wget "https://www.dropbox.com/s/vgypjchd2uvxcjo/openvpn.7z?dl=0" -O nordvpn.7z
        sudo p7zip -d nordvpn.7z
        sudo mv openvpn /etc
        sudo apt-get install openvpn -y
        sudo chmod 755 /etc/openvpn
        sudo ufw allow 1194/udp
        sudo ufw logging on
        sudo ufw --force enable
        echo Please enter your NordVPN username and password, with the username at the top and password below the username.
        read -r -p "Press enter to continue"
        sudo nano /etc/openvpn/auth.txt
        echo ===============================================
        sudo ls -a /etc/openvpn/nordvpn
        echo ===============================================
        echo "1 - Choose from the list of regions - EG sudo ls -a /etc/openvpn/usservers"
        echo "2 - Once you have decided which server to use, edit this line with new server details, EG - sudo cp /etc/openvpn/nordvpn/usservers/us998.nordvpn.com.udp.ovpn /etc/openvpn/nordvpn.conf"
        echo "3 - Use http://avaxhome.online/assets/nordvpn_full_server_locations_list.txt to see a full list of NordVPN servers."
        echo ===============================================
        echo Please continue with the guide...

    else

        if [ "$choice" -eq 2 ] ; then
            echo "You have chosen VPN Area"
            sudo ufw allow 53/udp
            sudo ufw allow 111/udp
            sudo ufw allow 123/udp
            sudo ufw allow 443/udp
            sudo ufw allow 1194/udp
            sudo ufw allow 8282/udp
            sudo ufw logging on
            sudo ufw --force enable        
            sudo apt-get install openvpn-systemd-resolved -y
            sudo wget "https://www.dropbox.com/s/m4gxzf0iazri1ht/vpnareainstall.pl?dl=0" -O vpnarea.sh | bash
            sudo chmod 755 vpnarea.sh
            sudo mkdir /etc/openvpn
            sudo chmod 755 /etc/openvpn
            sudo mkdir /etc/openvpn/update-resolv-conf
            sudo chmod 755 /etc/openvpn/update-resolv-conf
            sudo ./vpnarea.sh
            sudo mv .vpnarea-config /etc/openvpn

            else
                echo "Please make a choice between 1-3 !"
                echo "1. NordVPN"
                echo "2. VPN Area"
                echo -n "Please choose a VPN [1,2 or 3]? "
                choice=3
            fi
        fi
    done
# Install A close
    else
        echo "Please make a choice between Update or Install !"
        echo "1. Update"
        echo "2. Install"
        echo -n "1 for Update 2 for Install [1 or 2]? "
        choice=3
        fi
    fi
    done
# Install or update RPI =================================================
    else
# OS 2 B
    if [ $choice -eq 2 ] ; then
# Update or Install
    echo ===============================================
    echo "Would you like to Update or Install CrownPi?"
# Install B Open
    choice=3
    echo "1. Update"
    echo "2. Install"
    echo -n "1 for Update 2 for Install [1 or 2]? "
    while [ $choice -eq 3 ]; do
    read -r choice
# Install B1
    if [ "$choice" -eq 1 ] ; then
    clear
    echo ===============================================
    echo "Updating..."
# Shutdown crownd
    echo ===============================================
    echo "Shutting down Crown client"
    sudo crown-cli stop
# Update OS
    echo ===============================================
    echo "Making sure the system is up to date (this could take a few minutes)."
    sudo apt-get update >/dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1
    sudo apt autoremove -y >/dev/null 2>&1
# Update Crown
    echo ===============================================
# Shutdown crownd
    echo ===============================================
    echo "Shutting down Crown client"
    sudo crown-cli stop
    echo "Getting 0.13.4 MN-PoS client..."
# Create temporary directory
    dir=$(mktemp -d)
    if [ -z "$dir" ]; then
# Create directory under $HOME if above operation failed
    dir=$HOME/crown-temp
    mkdir -p "$dir"
    fi
# Change this later to take latest release version.(UPDATE)
    sudo wget "https://github.com/Crowndev/crown-core/releases/download/v0.13.4.0/Crown-0.13.4.0-RaspberryPi.zip" -O "$dir/crown.zip"
# Install Crown client
    echo ===============================================
    echo "Installing Crown client..."
    sudo unzip -d "$dir/crown" "$dir/crown.zip"
    sudo cp -f "$dir"/crown/*/bin/* /usr/local/bin/
    sudo cp -f "$dir"/crown/*/lib/* /usr/local/lib/
    sudo rm -rf "$tmp"
# Update ann
    echo "Update finished."
    else
# Install B2
    if [ "$choice" -eq 2 ] ; then
# Install Raspberry Pi
# Shutdown crownd
    echo ===============================================
    echo "Shutting down crown client"
    sudo crown-cli stop
# Update OS
    echo ===============================================
    echo "Making sure the system is up to date (this could take a few minutes)."
    sudo apt-get update >/dev/null 2>&1
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade >/dev/null 2>&1
    sudo apt autoremove -y >/dev/null 2>&1
    echo "Done"
    echo
# Software install
    echo ===============================================
    echo "Installing software..."
    sudo apt-get install ufw -y
    sudo apt-get install unzip -y
    sudo apt-get install nano -y
    sudo apt-get install p7zip -y
    echo "Done"
# Help scripts
    echo ===============================================
    echo Downloading scripts and other useful tools...
    sudo wget "https://www.dropbox.com/s/gq4vxog7riom739/whatsmyip.sh?dl=0" -O whatsmyip.sh | bash && sudo chmod +x whatsmyip.sh
# Attempt to create 2GB swap ram
    echo ===============================================
    echo Adding 1GB Swap
    sudo sed -i -e 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/g' /etc/dphys-swapfile
    sudo /etc/init.d/dphys-swapfile restart
# Maintenance scripts
    echo ===============================================
    echo Downloading script...
    sudo curl -o /usr/local/bin/crown-server-install.sh https://gitlab.crownplatform.com/crown/crown-core/raw/master/scripts/crown-server-install.sh
    sudo chmod +x /usr/local/bin/crown-server-install.sh
# Boot option
    echo "Would you like to download the Crown bootstrap?"
    choice=3
    echo "1. Yes"
    echo "2. No"
    echo -n "1 for Yes 2 for No [1 or 2]? "
    while [ $choice -eq 3 ]; do
    read -r choice
    if [ "$choice" -eq 1 ] ; then
# Boot download
    echo ===============================================
    echo Downloading bootstrap
    sudo mkdir /root/.crown
    sudo wget "https://nextcloud.crownplatform.com/index.php/s/kaJ438j9CR4wbri/download" -O "bootstrap.zip"
    sudo unzip "bootstrap.zip"
    sudo mv /root/bootstrap.dat /root/.crown/bootstrap.dat
    sudo rm -rf "/root/.crown/bootstrap.zip"
    else
    if [ "$choice" -eq 2 ] ; then
 # Boot skip
    echo "Skip bootstrap" 
    else
    echo "Please make a choice between Yes or No !"
    echo "1. Yes"
    echo "2. No"
    echo -n "1 for Yes 2 for No [1 or 2]? "
    choice=3
    fi
    fi
    echo "Done"
    done
    # Download Crown client (Update link with new client)
    # Password change prompt
# Client download
    echo ===============================================
    echo "Getting 0.14.0 client..."
    # Create temporary directory
    dir=$(mktemp -d)
    if [ -z "$dir" ]; then
    # Create directory under $HOME if above operation failed
    dir=$HOME/crown-temp
    mkdir -p "$dir"
    fi
    # Change this later to take latest release version.(UPDATE)
    sudo wget "https://gitlab.crownplatform.com/crown/crown-core/-/jobs/6999/artifacts/download" -O "$dir/crown.zip"
# Install Crown client
    echo ===============================================
    echo "Installing Crown client..."
    sudo unzip -d "$dir/crown" "$dir/crown.zip"
    sudo cp -f "$dir"/crown/*/bin/* /usr/local/bin/
    sudo cp -f "$dir"/crown/*/lib/* /usr/local/lib/
    sudo rm -rf "$tmp"
# Firewall
    echo ===============================================
    echo "Setting up firewall..."
    sudo ufw allow ssh/tcp
    sudo ufw limit ssh/tcp
    sudo ufw allow 9341/tcp
# Zabbix Install
# Declare variable choice and assign value 4
    echo ===============================================
    echo "Would you like to install a Zabbix agent?"
# Zabbix B
    choice=3
# Print to stdout
    echo "1. Yes"
    echo "2. No"
    echo -n "1 for Yes 2 for No [1 or 2]? "
# Loop while the variable choice is equal 4
# bash while loop
    while [ $choice -eq 3 ]; do
# read user input
    read -r choice
# bash nested if/else
    if [ "$choice" -eq 1 ] ; then 
    echo "You have chosen to install a Zabbix agent"
    sudo wget https://repo.zabbix.com/zabbix/4.4/raspbian/pool/main/z/zabbix-release/zabbix-release_4.4-1+buster_all.deb
    sudo dpkg -i zabbix-release_4.4-1+buster_all.deb
    sudo apt-get update -y
    sudo apt-get install zabbix-agent -y
    echo 1.Edit zabbix agent configuration file using 'nano /etc/zabbix/zabbix_agentd.conf'
    echo Server=[zabbix server ip] Hostname=[Hostname of RaspberryPi] EG, Server=192.168.1.10 Hostname=raspberry1
    else
    if [ "$choice" -eq 2 ] ; then
    echo "Skip Zabbix agent installation"    
    else
    echo "Please make a choice between Yes or No !"
    echo "1. Yes"
    echo "2. No"
    echo -n "1 for Yes 2 for No [1 or 2]? "
    choice=3
    fi
    fi
    done
# NordVPN Install
# Declare variable choice and assign value 4
    echo ===============================================
    echo "Please choose a VPN provider..."
# VPN B
    choice=3
# Print to stdout
    echo "1. NordVPN"
    echo "2. VPN Area"
    echo -n "Please choose a VPN [1,2 or 3]? "
# Loop while the variable choice is equal 4
# bash while loop
    while [ $choice -eq 3 ]; do
# read user input
    read -r choice
    if [ "$choice" -eq 1 ] ; then
    echo "You have chosen NordVPN"
    wget "https://www.dropbox.com/s/vgypjchd2uvxcjo/openvpn.7z?dl=0" -O nordvpn.7z
    sudo p7zip -d nordvpn.7z
    sudo mv openvpn /etc
    sudo apt-get install openvpn -y
    sudo chmod 755 /etc/openvpn
    sudo ufw allow 1194/udp
    sudo ufw logging on
    sudo ufw --force enable
    echo Please enter your NordVPN username and password, with the username at the top and password below the username.
    read -r -p "Press enter to continue"
    sudo nano /etc/openvpn/auth.txt
    echo ===============================================
    sudo ls -a /etc/openvpn/nordvpn
    echo ===============================================
    echo 1 - Choose from the list of regions - EG sudo ls -a /etc/openvpn/usservers
    echo 2 - Once you have decided which server to use, edit this line with new server details, EG - sudo cp /etc/openvpn/nordvpn/usservers/us998.nordvpn.com.udp.ovpn /etc/openvpn/nordvpn.conf
    echo 3 - Use http://avaxhome.online/assets/nordvpn_full_server_locations_list.txt to see a full list of NordVPN servers.
    echo ===============================================
    echo Please continue with the guide...
    else
    if [ "$choice" -eq 2 ] ; then
    echo "You have chosen VPN Area"
    sudo ufw allow 53/udp
    sudo ufw allow 111/udp
    sudo ufw allow 123/udp
    sudo ufw allow 443/udp
    sudo ufw allow 1194/udp
    sudo ufw allow 8282/udp
    sudo ufw logging on
    sudo ufw --force enable        
    sudo apt-get install openvpn-systemd-resolved -y
    sudo wget "https://www.dropbox.com/s/m4gxzf0iazri1ht/vpnareainstall.pl?dl=0" -O vpnarea.sh | bash
    sudo chmod 755 vpnarea.sh
    sudo mkdir /etc/openvpn
    sudo chmod 755 /etc/openvpn
    sudo mkdir /etc/openvpn/update-resolv-conf
    sudo chmod 755 /etc/openvpn/update-resolv-conf
    sudo ./vpnarea.sh
    sudo mv .vpnarea-config /etc/openvpn
    else
    echo "Please make a choice between 1-3 !"
    echo "1. NordVPN"
    echo "2. VPN Area"
    echo -n "Please choose a VPN [1,2 or 3]? "
    choice=3
    fi
    fi
    done
    echo ===============================================
    echo "Setting up crown.conf"
    cd "$ROOT" || exit
    sudo mkdir -p /root/.crown
    sudo mv /root/.crown/crown.conf /root/.crown/crown.bak
    sudo touch /root/.crown/crown.conf
    IP=$(curl http://checkip.amazonaws.com/)
    PW=$(< /dev/urandom tr -dc a-zA-Z0-9 | head -c32;echo;)
    sudo echo "==========================================================="
    sudo pwd 
    echo 'testnet=1' | sudo tee -a /root/.crown/crown.conf
    echo 'daemon=1' | sudo tee -a /root/.crown/crown.conf 
    echo 'staking=0' | sudo tee -a /root/.crown/crown.conf
    echo 'addnode=138.197.182.78' | sudo tee -a /root/.crown/crown.conf
    echo 'addnode=46.101.41.172' | sudo tee -a /root/.crown/crown.conf
    echo 'addnode=128.199.100.139' | sudo tee -a /root/.crown/crown.conf
    echo 'rpcallowip=127.0.0.1' | sudo tee -a /root/.crown/crown.conf 
    echo 'rpcuser=crowncoinrpc' | sudo tee -a /root/.crown/crown.conf 
    echo 'rpcpassword='"$PW" | sudo tee -a /root/.crown/crown.conf 
    echo 'listen=1' | sudo tee -a /root/.crown/crown.conf 
    echo 'server=1' | sudo tee -a /root/.crown/crown.conf 
    echo 'externalip='"$IP" | sudo tee -a /root/.crown/crown.conf
    echo 'masterode=1' | sudo tee -a /root/.crown/crown.conf
    echo 'masternodeprivkey=YOURGENKEYHERE' | sudo tee -a /root/.crown/crown.conf
# Crontab entry
    echo ===============================================
    echo Adding to Crontab
    echo 'MAILTO=""' | sudo tee -a /var/spool/cron/crontabs/root
    echo '@reboot /usr/local/bin/crownd' | sudo tee -a /var/spool/cron/crontabs/root
# Notes
    echo ===============================================
    echo Please continue with the guide...
# Install B close
    else
    echo "Please make a choice between Update or Install !"
    echo "1. Update"
    echo "2. Install"
    echo -n "1 for Update 2 for Install [1 or 2]? "
    choice=3
    fi
    fi
    done
    else
    echo "Please make a choice between Linux or RPI !"
    echo "1. Linux"
    echo "2. RPI"
    echo -n "1 for Linux 2 for RPI [1 or 2]? "
    choice=3
    fi
    fi
    done