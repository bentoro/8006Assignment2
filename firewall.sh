IP="/sbin/iptables"

#FWNAME
#FWLOCATION
#INTERNALNET
FWNIP="192.168.0.4" #IP address of firewall on the network
FWIP="192.168.10.1" #IP address of the firewall within the new network
WORKSTATION="192.168.10.2"  #IP address of workstation using the firewall
INTERFACE="enp3s2"
EXTERNAL_INTERFACE="eno1"

TCP_DROP=(23 32768:32775 137:139 111 515)
UDP_DROP=(32768:32775 137:139 111 515)
ICMP_DROP=(0) #=(32768:32775 137:139 111 515)

BLOCK_IP=(192.168.1.0/24)
TCP_ALLOW=(22 80 443)
UDP_ALLOW=(22 53 67 68)
ICMP_ALLOW=(0 8)


Cleanup(){
	$IP -F
	$IP -X
}

SetDefaults(){
	$IP -P INPUT DROP
	$IP -P OUTPUT DROP
	$IP -P FORWARD DROP
}

SetFilters(){
	#accept fragments
	$IP -A FORWARD -f -j ACCEPT
	#allow stateful add to all for loops
    #dont understand properly
    $IP -A FORWARD -i $INTERFACE -p all -d $BLOCK_IP -j DROP

    #prerouting
#    for i in "${TCP_ALLOW[@]}"
#    do
#        :
#        $IP -t nat -A PREROUTING -p tcp -i $EXTERNAL_INTERFACE --destination-port $i -j DNAT --to-destination $WORKSTATION:$i
#
#    done

#    $IP -t nat -A POSTROUTING -o $EXTERNAL_INTERFACE -m state --state NEW,ESTABLISHED -j SNAT --to-source $FWNIP
    $IP -t nat -A POSTROUTING -j SNAT -s 192.168.10.0/24 -o $EXTERNAL_INTERFACE --to-source $FWNIP

#    $IP -t nat -A PREROUTING -i $EXTERNAL_INTERFACE -m state --state NEW,ESTABLISHED -j DNAT --to-destination $WORKSTATION
    $IP -t nat -A PREROUTING -j DNAT -i $EXTERNAL_INTERFACE --to-destination $WORKSTATION


    #postrounting
#    $IP -t nat -A POSTROUTING -o $EXTERNAL_INTERFACE -j SNAT --to-source $FWNIP

	#set minimum delay and ftp data to maximum throughput
	$IP -A PREROUTING -t mangle -p tcp --sport ssh -j TOS --set-tos Minimize-Delay
	$IP -A PREROUTING -t mangle -p tcp --dport ssh -j TOS --set-tos Minimize-Delay
	$IP -A PREROUTING -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
	$IP -A PREROUTING -t mangle -p tcp --dport ftp -j TOS --set-tos Minimize-Delay
	$IP -A PREROUTING -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput
	$IP -A PREROUTING -t mangle -p tcp --dport ftp-data -j TOS --set-tos Maximize-Throughput
#	$IP -A OUTPUT -t mangle -p tcp --sport ssh -j TOS --set-tos Minimize-Delay
#	$IP -A OUTPUT -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
#	$IP -A OUTPUT -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput

    #block all incoming syns
    $IP -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
    #block all incoming syn fin packets
    $IP -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP

    for i in "${TCP_DROP[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j DROP
        $IP -A FORWARD -p tcp -m tcp --dport $i -j DROP
    done

   for i in "${UDP_DROP[@]}"
    do
        :
        $IP -A FORWARD -p udp -m udp --sport $i -j DROP
        $IP -A FORWARD -p udp -m udp --dport $i -j DROP
    done

   for i in "${ICMP_DROP[@]}"
    do
        :
        $IP -A FORWARD -p icmp -m icmp --icmp-type $i -j DROP
    done

   for i in "${TCP_ALLOW[@]}"
    do
        :
#        $IP -A FORWARD -p tcp -m tcp --dport $i -m state --state NEW,ESTABLISHED -j ACCEPT
#        $IP -A FORWARD -p tcp -m tcp --sport $i -m state --state NEW,ESTABLISHED -j ACCEPT

        $IP -A FORWARD -p tcp -m tcp --sport $i -j ACCEPT
        $IP -A FORWARD -p tcp -m tcp --dport $i -j ACCEPT
        #create a state for established connections
        $IP -A FORWARD -o $INTERFACE -p tcp --sport $i -m conntrack --ctstate \
            NEW,ESTABLISHED -j ACCEPT
        $IP -A FORWARD -o $INTERFACE -p tcp --dport $i -m conntrack --ctstate \
            NEW,ESTABLISHED -j ACCEPT
    done

   for i in "${UDP_ALLOW[@]}"
    do
        :
#        $IP -A FORWARD -p udp -m udp --dport $i -m state --state NEW,ESTABLISHED -j ACCEPT
#        $IP -A FORWARD -p udp -m udp --sport $i -m state --state NEW,ESTABLISHED -j ACCEPT
        $IP -A FORWARD -p udp -m udp --sport $i -j ACCEPT
        $IP -A FORWARD -p udp -m udp --dport $i -j ACCEPT
        $IP -A FORWARD -o $INTERFACE -p tcp --sport $i -m conntrack --ctstate \
            NEW,ESTABLISHED -j ACCEPT
        $IP -A FORWARD -o $INTERFACE -p udp --dport $i -m conntrack --ctstate \
            NEW,ESTABLISHED -j ACCEPT
    done

   for i in "${ICMP_ALLOW[@]}"
    do
        :
        $IP -A FORWARD -p icmp -m icmp --icmp-type $i -j ACCEPT
    done
}
Firewall(){
        #Setup standalone firewall with ifconfig
        ifconfig $INTERFACE 192.168.10.1 up
        echo "1" >/proc/sys/net/ipv4/ip_forward
        #route add -net 192.168.0.0 netmask 255.255.255.0 gw $FWNIP
        route add -net 192.168.0.0 netmask 255.255.255.0 gw 192.168.0.100
        route add -net 192.168.10.0/24 gw 192.168.10.1
}
Workstation(){
        #firewall
        ifconfig $EXTERNAL_INTERFACE down
        ifconfig $INTERFACE 192.168.10.2 up
        route add default gw 192.168.10.1
}
Setup(){
        Cleanup
        SetDefaults
        SetFilters
}
    if [ "$#" -ne 1 ]; then
        echo "Options workstation/firewall"
        exit 1
    fi
    case $1 in
        "workstation") workstation ;;
        "firewall") Firewall ;;
        "setup") Setup ;;
    esac
