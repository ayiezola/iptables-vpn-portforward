#!/bin/bash
echo "====================================="
echo "Iptables script by noyes@jomgegar.com"
echo "version 1.0 2017"
echo "====================================="
iptables="/sbin/iptables"
iptables_save="/sbin/iptables-save"
IP=$(wget -qO- ipv4.icanhazip.com)
echo ""
echo "	What do you want to do? :"
echo "	1) Backup current iptables?"
echo "	2) Reset iptables?"
echo " 	3) Add new iptables rules?"
echo "	4) Exit"
read -p "Select an option [1-4]: " option
case $option in
	1)
	echo "Do you want to backup your current iptables?"
	read backup
		if [ $backup =  "y" ]; then
			$iptables_save > /etc/iptables.ori
			echo "Done. Your iptables file available at /etc/iptables.ori"
		else [ $backup = "n"  ]
			exit 0
		fi
	;;	
	2) 
	echo "Done reset your iptables!!"
	$iptables -F
	for i in $(/sbin/iptables -t nat --line-numbers -L | grep ^[0-9] | awk '{ print $1 }' | tac );
	do $iptables -t nat -D PREROUTING $i; 
	done
	;;
	3)
	echo "Before add new iptables rules, please enter the following value "
	echo "Enter your port to listen"
	read port
	echo "Your VPS IP is :" $IP
	echo "Please put your VPN IP Address :"
	read vpn_ip
	echo ""
	echo "=============================================="
	echo "Your settings : "
	echo "Your VPS IP : " $IP
	echo "Your VPN IP : " $vpn_ip
	echo "Your listening port is : " $port
	echo "Your iptables backup file is /etc/iptables.bak"
	echo "=============================================="
	echo ""
	read -n1 -r -p "Press any key to continue..."

	$iptables -A INPUT -p tcp --dport $port -j ACCEPT
	$iptables -A INPUT -p udp --dport $port -j ACCEPT
	$iptables -A FORWARD -d $vpn_ip -i eth0 -p tcp -m tcp --dport $port -j ACCEPT
	$iptables -A FORWARD -d $vpn_ip -i eth0 -p udp -m udp --dport $port -j ACCEPT
	$iptables -t nat -A PREROUTING -d $IP -p tcp -m tcp --dport $port -j DNAT --to-destination $vpn_ip
	$iptables -t nat -A PREROUTING -d $IP -p udp -m udp --dport $port -j DNAT --to-destination $vpn_ip

	$iptables_save
	;;
	4) 
	echo "Done"
esac
