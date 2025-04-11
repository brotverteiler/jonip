#2)	Netzwerk Konfigurationsupdater
#	- Das Skript soll den User zuerst fragen, ob eine manuelle IP-Adresse gesetzt werden soll, oder sie via DHCP bezogen werden soll.
#	- Falls manuell gewählCt wird, soll nach einer IP-Adresse, Netzwerkmaske, Gateway und DNS gefragt werden.
#	- Am Ende soll die neue Netzwerkkonfiguration ausgegeben werden.

#!/bin/bash
while true; do
exit_directly=false
skip_menu_prompt=false

echo ""
echo "What do you want?"
echo "1 Static IP"
echo "2 Dynamic IP"
echo "3 Show current IP Settings"
echo "4 Exit"

echo ""
read -p "Choose ur number: " choice

case $choice in

  #STATIC IP
  #---------------------------------
  1)
  clear

  #Current IP Settings
    echo "Current IP Settings:"
    echo "--------------------"
    IP=$(ip addr show | grep inet | grep -v inet6 | awk 'NR==2 {print $2}')  
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    DNS=$(resolvectl status | grep 'DNS Servers' | awk '{print $3}')
    echo "IP-Adres/Subnet: $IP"
    echo "Gateway: $GATEWAY"
    echo "DNS: $DNS"
  #---------------------
    echo ""
        > /etc/netplan/50-cloud-init.yaml
    
    read -p "Use current IP as static? (y/n): " use_current

if [[ "$use_current" == "y" || "$use_current" == "Y" ]]; then
    echo "Setting IP..."
    > /etc/netplan/50-cloud-init.yaml
    echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - $IP
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
          addresses: [$DNS]" > /etc/netplan/50-cloud-init.yaml

    sleep 1
    sudo netplan apply
    echo ""
    echo "New Netplan:"
    echo "----------------------------"
    sudo netplan get
    echo ""
else

    read -p "What IP would you like to use? " IP

    read -p "Which Subnet would you like to use? (press enter for default (24)) " subnet
    
    if [ -z "$subnet" ]; then
      subnet=24
      echo "Subnet $subnet"
    else 
      while ! [[ "$subnet" =~ ^[0-9]+$ ]] || (( subnet < 1 || subnet > 32 )); do 
      echo "The Subnet is Invalid, this is because it is invalid. Please retry with a valid, and not invalid subnet. For example: 24 is a Valid subnet, 2000 is an invalid subnet. Thank you very much for using a valid subnet."
      read subnet
      done
    fi

    

    read -p "Which Gateaway would you like to use (1 for setting currently used)? " Gateaway
    
    read -p "Which DNS would you like to use? " dnsSRV
    
    echo ""
    echo "Please make sure everthying is correct before starting the change"

    read -p "Want to continue? (y/n) " antwort

    if [[ "$antwort" == "y" || "$antwort" == "Y" ]]; then
        echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - $IP/$subnet
      routes:
        - to: default
          via: $Gateaway
      nameservers:
          addresses: [$dnsSRV]" > /etc/netplan/50-cloud-init.yaml
   sleep 1
   sudo netplan apply
   echo ""
  echo "New Netplan"
  echo "-----------"
  echo ""
   sudo netplan get
   echo ""
    else
        exit
    fi
    fi
    ;;

  #DYNAMIC IP
  #---------------------------------------
  2) 
  clear
    echo "Set Dynamic IP"
    echo "--------------"
    echo ""
  read -p "Want to continue? (y/n) " antwort

    if [[ "$antwort" == "y" || "$antwort" == "Y" ]]; then
        echo "Dynamic IP is configuring..."
        echo "network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true" > /etc/netplan/50-cloud-init.yaml
	sleep 1
	sudo netplan apply
    else
      exit
    fi
	sudo netplan apply
  echo ""
  echo "New Netplan"
  echo "-----------"
  echo ""
  sudo netplan get
  echo "" 
    ;;
  
  #INFO
  #-----------------------
  3)
    clear
    echo ""
    echo "What would you like to see?"
    echo "1 See netplan"
    echo "2 See IP Adress"
    
    echo ""
    read -p "Choose ur number: " info

    case $info in
    1)
        echo ""
        clear
        netplan=$(cat /etc/netplan/50-cloud-init.yaml)
        if [[ -z "$netplan" ]]; then
            echo "Netplan file is empty"
            echo ""
        else 
        echo ""
        echo "Netplan"
        echo "-------"
        echo ""
            sudo netplan get
            echo ""
        fi
    ;;
  2)
  clear
      echo "Current IP Settings:"
      echo "--------------------"
      echo ""
      IP=$(ip addr show | grep inet | grep -v inet6 | awk 'NR==2 {print $2}')  
      GATEWAY=$(ip route | grep default | awk '{print $3}')
      DNS=$(resolvectl status | grep 'DNS Servers' | awk '{print $3}')
      echo "IP-Adres/Subnet: $IP"
      echo "Gateway: $GATEWAY"
      echo "DNS: $DNS"
      echo ""
    esac
  ;;

  #EXIT 
  #---------------------------
  4)
  exit_directly=true
  clear
  break
  ;;

  #DEFAULT
  #----------------------------
  *)
    echo "wrong input"
    echo ""
    sleep 1
    clear
    skip_menu_prompt=true
	;;
    


esac
if [ "$exit_directly" != true ] && [ "$skip_menu_prompt" != true ]; then
  echo ""
  read -p "Press 'q' to leave or 'enter' to go back to main menu. " exit_choice
  if [[ "$exit_choice" == "q" || "$exit_choice" == "Q" ]]; then
    break
  else 
    clear
  fi
fi

done
