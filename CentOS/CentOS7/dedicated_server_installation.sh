#!/usr/bin/env bash

###############################################################################################
# Dedicated server basic installations and configurations Bash script
# Script By: Muhammad Hanis Irfan Bin Mohd
# Interactive Menu based on: https://gist.github.com/shinokada/9d54c820b127d0b771c3d87a157fc99d
###############################################################################################

### Message and logs ###
CURRENT_DATE () {
    echo `date +%Y-%m-%d.%H:%M:%S`
}

ADD_TO_LOG () {
  echo "[$(date +%y/%m/%d_%H:%M:%S)] ${1}" >> ./dedicated_server_installation.log
}

# Argument 1: Message 1, Argument 2: Message 2, Argument 3: Message 3
DISPLAY_MESSAGE () {
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
  sleep 1
}

### Colors ###
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

### Color Functions ###
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }

fn_goodafternoon() { echo; echo "Good afternoon."; }
fn_goodmorning() { echo; echo "Good morning."; }
fn_bye() { echo "Good bye!"; exit 0; }
fn_fail() { echo "Wrong option!" exit 1; }

sub-submenu() {
    echo -ne "
$(yellowprint 'SUB-SUBMENU')
$(greenprint '1)') GOOD MORNING
$(greenprint '2)') GOOD AFTERNOON
$(blueprint '3)') Go Back to SUBMENU
$(magentaprint '4)') Go Back to MAIN MENU
$(redprint '0)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        fn_goodmorning
        sub-submenu
        ;;
    2)
        fn_goodafternoon
        sub-submenu
        ;;
    3)
        submenu
        ;;
    4)
        mainmenu
        ;;
    0)
        fn_bye
        ;;
    *)
        fn_fail
        ;;
    esac
}

submenu() {
    echo -ne "
$(blueprint 'CMD1 SUBMENU')
$(greenprint '1)') SUBCMD1
$(magentaprint '2)') Go Back to Main Menu
$(redprint '0)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        sub-submenu
        submenu
        ;;
    2)
        menu
        ;;
    0)
        fn_bye
        ;;
    *)
        fn_fail
        ;;
    esac
}

updateinstallpackages() {
    # Update packages
    DISPLAY_MESSAGE "Updating Packages"
    yum -y update
    DISPLAY_MESSAGE "Packages update completed!"
    ADD_TO_LOG "Packages update completed!"

    # Install nano
    DISPLAY_MESSAGE "Installing Nano"
    yum -y install nano
    DISPLAY_MESSAGE "Nano installation completed!"
    ADD_TO_LOG "Nano installation completed!"

    # Install EPEL
    DISPLAY_MESSAGE "Installing EPEL"
    yum search epel
    yum -y install epel-release.noarch
    DISPLAY_MESSAGE "EPEL installation completed!"
    ADD_TO_LOG "EPEL installation completed!"

    # Install Screen
    DISPLAY_MESSAGE "Installing Screen"
    yum -y install wget screen
    DISPLAY_MESSAGE "Screen installation completed!"
    ADD_TO_LOG "Screen installation completed!"

    # Install networking tools
    DISPLAY_MESSAGE "Installing Monitoring And Networking Tools"
    yum -y install iftop iotop atop htop
    yum -y install net-tools
    DISPLAY_MESSAGE "Monitoring and networking tools installation completed!"
    ADD_TO_LOG "Monitoring and networking tools installation completed!"

    DISPLAY_MESSAGE "Update And Install Necessary Packages completed!"
}

disablestopfirewalld() {
    # Disable and stop firewall daemon
    DISPLAY_MESSAGE "Disabling Firewall Daemon"
    systemctl disable firewalld
    systemctl stop firewalld
    DISPLAY_MESSAGE "Firewall Daemon disabled successfully!"
    ADD_TO_LOG "Firewall Daemon disabled successfully!"
}

disableselinux() {
    # Disable SELinux
    DISPLAY_MESSAGE "Disabling SELinux"
    SELINUX_CONFIG_FILE="/etc/selinux/config"
    SELINUX_CONFIG_STRING="SELINUX=enforcing"
    SELINUX_NEW_STRING="SELINUX=disabled"

    sed -i "s/$SELINUX_CONFIG_STRING/$SELINUX_NEW_STRING/" $SELINUX_CONFIG_FILE

    DISPLAY_MESSAGE "SELinux disabled successfully!"
    ADD_TO_LOG "SELinux disabled successfully!"
}

disableremovenetworkmanager() {
    # Disable and remove Network Manager
    DISPLAY_MESSAGE "Disabling And Removing NetworkManager"
    systemctl disable NetworkManager
    yum remove NetworkManager -y
}

changesshport () {
    DISPLAY_MESSAGE "Change SSH Port"
    read -r -p "Port Number (0 - 65535): " PORT

    sshconfigfile="/etc/ssh/sshd_config"
    sshportconfigstring="#Port 22"
    sshnewportstring="Port ${PORT}"

    if [[ -n "$PORT" ]] && [[ "$PORT" -ge 0 ]] && [[ "$PORT" -le 65535 ]] ; then
        # sed -i "s/CONFIG_STRING/NEW_PORT" $CONFIG_FILE
        sed -i "s/$sshportconfigstring/$sshnewportstring/" $sshconfigfile
        DISPLAY_MESSAGE "SSH port changed successfully!"
        ADD_TO_LOG "SSH port changed successfully!"
        ADD_TO_LOG "New SSH Port: ${PORT}"
        systemctl restart sshd
    else
        echo "Unknow input given! Please retry.."
        changesshport
    fi
}

addadditionalip() {

}

changerootpassword() {
    DISPLAY_MESSAGE "Change Root User Password"
    passwd root
}

mainmenu() {
    echo -ne "
$(greenprint 'Dedicated server basic installations and configurations Bash script')
$(greenprint 'Script By: Muhammad Hanis Irfan Bin Mohd')
$(magentaprint 'MAIN MENU')
$(greenprint '1)') Update And Install Necessary Packages
$(greenprint '2)') Disable And Stop Firewall Daemon
$(greenprint '3)') Disable SELinux
$(greenprint '4)') Disable And Remove NetworkManager
$(greenprint '5)') Change SSH Port
$(greenprint '6)') Add Additional IP
$(greenprint '7)') Change Root User Password
$(greenprint '8)') Reboot Server Now
$(redprint '0)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        updateinstallpackages
        mainmenu
        ;;
    2)
        disablestopfirewalld
        mainmenu
        ;;
    3)
        disableselinux
        mainmenu
        ;;
    4)
        disableremovenetworkmanager
        mainmenu
        ;;
    5)
        changesshport
        mainmenu
        ;;
    6)
        addadditionalip
        mainmenu
        ;;
    7)
        changerootpassword
        mainmenu
        ;;
    8)
        DISPLAY_MESSAGE "Rebooting the server now!"
        ADD_TO_LOG "Rebooting the server now!"
        shutdown -r now
        ;;
    0)
        fn_bye
        ;;
    *)
        fn_fail
        ;;
    esac
}

mainmenu