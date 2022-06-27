#!/usr/bin/env bash

###############################################################################################
# Server basic installations and configurations Bash script
# Script By: Muhammad Hanis Irfan Bin Mohd
# Interactive Menu based on: https://gist.github.com/shinokada/9d54c820b127d0b771c3d87a157fc99d
###############################################################################################

scriptversion=0.1.2
### Message and logs ###
CURRENT_DATE () {
    echo `date +%Y-%m-%d.%H:%M:%S`
}

ADD_TO_LOG () {
  echo "[$(date +%y/%m/%d_%H:%M:%S)] ${1}" >> ./dedicated_server_installation.log
}

# Argument 1: Message 1, Argument 2: Message 2, Argument 3: Message 3
DISPLAY_MESSAGE () {
  echo ""
  echo "----------------------------------------------------------------------------"
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
  echo "----------------------------------------------------------------------------"
  echo ""
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

fn_bye() { echo "Good bye!"; exit 0; }
fn_fail() { echo "Wrong option!" exit 1; }

updateinstallpackages() {
    # Update packages
    DISPLAY_MESSAGE "Updating Packages"
    dnf -y upgrade
    DISPLAY_MESSAGE "Packages update completed!"
    ADD_TO_LOG "Packages update completed!"

    # Install nano
    DISPLAY_MESSAGE "Installing Nano"
    dnf -y install nano
    DISPLAY_MESSAGE "Nano installation completed!"
    ADD_TO_LOG "Nano installation completed!"

    # Install EPEL
    DISPLAY_MESSAGE "Installing EPEL"
    dnf search epel
    dnf -y install epel-release.noarch
    DISPLAY_MESSAGE "EPEL installation completed!"
    ADD_TO_LOG "EPEL installation completed!"

    # Install Screen
    DISPLAY_MESSAGE "Installing Screen"
    dnf -y install wget screen
    DISPLAY_MESSAGE "Screen installation completed!"
    ADD_TO_LOG "Screen installation completed!"

    # Install networking tools
    DISPLAY_MESSAGE "Installing Monitoring And Networking Tools"
    dnf -y install iftop iotop atop htop
    dnf -y install net-tools
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
    dnf remove NetworkManager -y
    ADD_TO_LOG "NetworkManager disabled and removed successfully!"
}

changesshport () {
    # Disable SSH Port
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
    # Add Additional IP
    DISPLAY_MESSAGE "Add Additional IP"
    interfaceconfigfile="/etc/sysconfig/network-scripts/ifcfg-"

    read -r -p "Network Interface: " networkinterface
    interfaceconfigfilefull="${interfaceconfigfile}${networkinterface}"
    if [[ -f "$interfaceconfigfilefull" ]]; then
        # Validating the IP format is gonna be hard so I'll pass. 
        # Just hope that the admin inserted the IP and prefix correctly.
        read -r -p "IP Address (x.x.x.x): " ipaddress
        read -r -p "IP Prefix (1-32): " ipprefix
        for i in {2..15}
            do
                # IPADDR string
                ipaddrstring="IPADDR"
                currentipaddr="${ipaddrstring}${i}"
                case `grep -F "$currentipaddr" "$interfaceconfigfilefull" >/dev/null; echo $?` in
                0)
                    continue
                    ;;
                1)
                    # Add IPADDR string to file
                    ipaddrstringwithipaddress="${currentipaddr}=${ipaddress}"
                    echo "${ipaddrstringwithipaddress}" >> $interfaceconfigfilefull

                        # PREFIX string
                        prefixstring="PREFIX"
                        currentprefix="${prefixstring}${i}"
                        case `grep -F "$currentprefix" "$interfaceconfigfilefull" >/dev/null; echo $?` in
                        0)
                            continue
                            ;;
                        1)
                            # Add PREFIX string to file
                            prefixstringwithprefix="${currentprefix}=${ipprefix}"
                            echo "${prefixstringwithprefix}" >> $interfaceconfigfilefull
                            ADD_TO_LOG "Added a new Additional IP: ${ipaddress}/${ipprefix}"
                            break
                            ;;
                        *)
                            # code if an error occurred
                            ;;
                        esac
                    ;;
                *)
                    # code if an error occurred
                    ;;
                esac

        done
        systemctl restart network
        ip addr show
    else
        DISPLAY_MESSAGE "Interface does not exist!"
        addadditionalip
    fi
}

changerootpassword() {
    # Change Root User Password
    DISPLAY_MESSAGE "Change Root User Password"
    passwd
}

clearhistoryexitssh() {
    DISPLAY_MESSAGE "Current shell history will be deleted and you'll be kicked from the SSH session!"
    sleep 2
    # Delete script log
    shred -u ./dedicated_server_installation.log

    # Delete script
    # Self deleting script based on: https://stackoverflow.com/a/34303677
    shred -u ./dedicated_server_installation.sh

    # Clear Bash command history
    history -cw
    shred -u ~/.bash_history

    # Exit from SSH
    exit
}

mainmenu() {
    echo -ne "
$(greenprint 'Server basic installations and configurations Bash script')
$(greenprint 'Script by: Muhammad Hanis Irfan Bin Mohd Zaid (https://hanisirfan.xyz)')
$(greenprint 'Script version: '${scriptversion}' for AlmaLinux 8')
$(magentaprint '-------------------------------------------------------------------------------')
$(magentaprint 'MAIN MENU')
$(magentaprint '-------------------------------------------------------------------------------')
$(greenprint '1)') Update And Install Necessary Packages
$(redprint '2) Disable And Stop Firewall Daemon (Deprecated)')
$(greenprint '3)') Disable SELinux
$(redprint '4) Disable And Remove NetworkManager (Deprecated)')
$(greenprint '5)') Change SSH Port
$(greenprint '6)') Add Additional IP
$(greenprint '7)') Change Root User Password
$(greenprint '8)') Reboot Server Now
$(redprint '9) Clear History & Exit from SSH')
$(greenprint '0)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        updateinstallpackages
        mainmenu
        ;;
    2)
        #disablestopfirewalld
        DISPLAY_MESSAGE "This feature is deprecated due to the fact that AlmaLinux 8 Non GUI doesn't come with firewalld by default."
        mainmenu
        ;;
    3)
        disableselinux
        mainmenu
        ;;
    4)
        # disableremovenetworkmanager
        DISPLAY_MESSAGE "This feature is deprecated due to the deprecation of network-scripts in AlmaLinux 8 and the replacement of it with NetworkManager." "You can refer to this link: https://www.golinuxcloud.com/unit-network-service-not-found-rhel-8-linux/"
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
    9)
        clearhistoryexitssh
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