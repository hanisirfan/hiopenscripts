#!/bin/sh
# Dedicated server basic installations script
# Script By: Muhammad Hanis Irfan Bin Mohd

# To Do: Dump all log like service status to a log file

LINE="-------------------------------------------------"
# Argument 1: Message 1, Argument 2: Message 2, Argument 3: Message 3
DISPLAY_MESSAGE () {
  echo
  echo
  echo
  echo
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
  echo
  echo
  echo
  echo
}

echo "CURRENT TIME = "`date`
echo "HOSTNAME = "`hostname`
echo "USER id = "`whoami`
echo "IP ADDRESS = "`ip a s enp0s3 | grep "inet " | cut -f6 -d" "`

# Update packages
DISPLAY_MESSAGE "Updating Packages"
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
DISPLAY_MESSAGE "Installing Monitoring And Networking Tools"
yum -y install iftop iotop atop htop
yum -y install net-tools
DISPLAY_MESSAGE "Monitoring and networking tools installation completed!"

# Disable and stop firewall daemon
DISPLAY_MESSAGE "Disabling Firewall Daemon"
systemctl disable firewalld
systemctl stop firewalld
DISPLAY_MESSAGE "Firewall Daemon disabled successfully!"

DISPLAY_MESSAGE "SSH Port Change"

# Change SSH Port
CHANGE_SSH_PORT () {
  read -r -p "Port Number (0 - 65535): " PORT

  SSH_CONFIG_FILE="/etc/ssh/sshd_config"
  SSH_PORT_CONFIG_STRING="#Port 22"
  SSH_NEW_PORT_STRING="Port ${PORT}"

  if [[ -n "$PORT" ]] && [[ "$PORT" -ge 0 ]] && [[ "$PORT" -le 65535 ]] ; then
    # sed -i "s/CONFIG_STRING/NEW_PORT" $CONFIG_FILE
    sed -i "s/$SSH_PORT_CONFIG_STRING/$SSH_NEW_PORT_STRING/" $SSH_CONFIG_FILE
    DISPLAY_MESSAGE "SSH port changed successfully!"
  else
    echo "Unknow input given! Please retry.."
    CHANGE_SSH_PORT
  fi
}

ASK_CHANGE_SSH_PORT () {
  read -r -p "Did you want to change the SSH port? (y/n): " yn
    case $yn in
        [Yy]* ) CHANGE_SSH_PORT; break;;
        [Nn]* ) echo "Skipping SSH port change.";;
        * ) echo "Unknown input!."; ASK_CHANGE_SSH_PORT;;
    esac
}

ASK_CHANGE_SSH_PORT

# Disable SELinux
DISPLAY_MESSAGE "Disabling SELinux"

SELINUX_CONFIG_FILE="/etc/selinux/config"
SELINUX_CONFIG_STRING="SELINUX=enforcing"
SELINUX_NEW_STRING="SELINUX=disabled"

sed -i "s/$SELINUX_CONFIG_STRING/$SELINUX_NEW_STRING/" $SELINUX_CONFIG_FILE

DISPLAY_MESSAGE "SELinux disabled successfully!"

# Disable and remove Network Manager
DISPLAY_MESSAGE "Disabling And Removing NetworkManager"

systemctl status NetworkManager
systemctl disable NetworkManager
systemctl status NetworkManager
yum remove NetworkManager

DISPLAY_MESSAGE "NetworkManager disabled and removed successfully!"

DISPLAY_MESSAGE "SELinux disabled successfully!"

DISPLAY_MESSAGE "Please run sestatus command after this server reboots to check whether SELinux is still enforced."

# Reboot the server in 10 seconds.
DISPLAY_MESSAGE "Rebooting the server in 10 seconds!"

# Delays 10 seconds
sleep 10
shutdown -r now

# Dump port number etc in the same log file.