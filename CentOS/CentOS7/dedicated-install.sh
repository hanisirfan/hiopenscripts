#!/bin/sh
# Dedicated server basic installations script
# Script By: Muhammad Hanis Irfan Bin Mohd

# To Do: Dump all log like service status to a log file

LINE="-------------------------------------------------"
# Argument 1: Message 1, Argument 2: Message 2, Argument 3: Message 3
DISPLAY_MESSAGE () {
  echo $LINE
  if [[ -n "$1" ]]
    then
        echo $1
  fi
  if [[ -n "$2" ]]
    then
        echo $2
  fi
  if [[ -n "$3" ]]
    then
        echo $3
  fi
  echo $LINE
}

# Update packages
DISPLAY_MESSAGE "Updating packages"
yum -y update
DISPLAY_MESSAGE "Packages update completed!"

# Install nano
DISPLAY_MESSAGE "Installing Nano"
yum -y install nano
DISPLAY_MESSAGE "Nano installation completed!"

# Install EPEL
DISPLAY_MESSAGE "Installing EPEL"
yum search epel
yum -y install epel-release.noarch
DISPLAY_MESSAGE "EPEL installation completed!"

# Install Screen
DISPLAY_MESSAGE "Installing Screen"
yum -y install wget screen
DISPLAY_MESSAGE "Screen installation completed!"

# Install networking tools
DISPLAY_MESSAGE "Installing monitoring and networking tools"
yum -y install iftop iotop atop htop
yum -y install net-tools
DISPLAY_MESSAGE "Networking tools installation completed!"

# Disable and stop firewall daemon
DISPLAY_MESSAGE "Disabling Firewall Daemon"
systemctl disable firewalld
systemctl stop firewalld
DISPLAY_MESSAGE "Firewall Daemon disabled successfully!"

DISPLAY_MESSAGE "SSH Port Change"

# Change SSH Port
CHANGE_SSH_PORT () {
  read -p "Port Number (0 - 65535): " PORT
  SSH_CONFIG_FILE="/etc/ssh/sshd_config"
  SSH_PORT_CONFIG_STRING="#Port 22"
  SSH_NEW_PORT_STRING="Port ${PORT}"

  if [[ -n "$PORT" ]] && [[ "$PORT" -ge 0 ]] && [[ "$PORT" -le 65535 ]] ; then
    # sed -i "s/CONFIG_STRING/NEW_PORT" $CONFIG_FILE
    sed -i "s/$SSH_PORT_CONFIG_STRING/$SSH_NEW_PORT_STRING/" $SSH_CONFIG_FILE
  else
    echo "Unknow input given! Please retry.."
    CHANGE_SSH_PORT
  fi
}

read -p "Did you want to change the SSH port? (yes/y) or (no/n): " RESP
if [[ "$RESP" = "y" ]] || [[ "$RESP" = "yes" ]]; then
  CHANGE_SSH_PORT
elif [[ "$RESP" = "n" ]] || [[ "$RESP" = "no" ]]; then
  echo "Skipping SSH port change."
else
  echo "Skipping SSH port change."
fi

# Disable SELinux
# Same method as SSH port change
#nano /etc/selinux/config (disabled)

# Disable and remove Network Manager
# systemctl status NetworkManager
# systemctl disable NetworkManager
# systemctl status NetworkManager
# yum remove NetworkManager

# Reboot the server in 10 seconds.
# Reboot message
# shutdown -r now

# Ask the engineer to run sestatus command to check its status.
# Dump port number etc in the same log file.
# sestatus (check selinux status)