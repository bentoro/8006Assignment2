IP = /sbin/iptables

FWNAME
FWLOCATION
INTERNALNET
FWIP="192.168.10.2"


TCP_DROP=($FWIP 23 32768:32775 137:139 111 515)
UDP_DROP=(32768:32775 137:139 111 515)
ICMP_DROP=(32768:32775 137:139 111 515)

BLOCK_IP=(192.168.0.0/24)
TCP_ALLOW
UDP_ALLOW
ICMP_ALLOW

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

	#set minimum delay and ftp data to maximum throughput
	$IP -A PREROUTING -t mangle -p tcp --sport ssh -j TOS --set-tos Minimize-Delay
	$ip -A PREROUTING -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
	$ip -A PREROUTING -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput
	$IP -A OUTPUT -t mangle -p tcp --sport ssh -j TOS --set-tos Minimize-Delay
	$ip -A OUTPUT -t mangle -p tcp --sport ftp -j TOS --set-tos Minimize-Delay
	$ip -A OUTPUT -t mangle -p tcp --sport ftp-data -j TOS --set-tos Maximize-Throughput

    #block all incoming syns
    $IP -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
    #block all incoming syn fin packets
    $IP -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP

    for i in "${TCP_DROP[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j DROP
    done

   for i in "${UDP_DROP[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j DROP
    done

   for i in "${ICMP_DROP[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j DROP
    done

   for i in "${TCP_ALLOW[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j ACCEPT
    done

   for i in "${TCP_ALLOW[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j ACCEPT
    done

   for i in "${UDP_ALLOW[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j ACCEPT
    done

   for i in "${ICMP_ALLOW[@]}"
    do
        :
        $IP -A FORWARD -p tcp -m tcp --sport $i -j ACCEPT
    done
}
Firewall(){

        #Setup standalone firewall with ifconfig
        localIP="192.168.0.15"

        ifconfig enp3s2 192.168.10.1 up
        echo "1" >/proc/sys/net/ipv4/ip_forward
        route add -net 192.168.0.0 netmask 255.255.255.0 gw $localIP
        route add -net 192.168.10.0/24 gw 192.168.10.1
        Cleanup
        SetDefaults
        SetFilters
}
Workstation(){
        #firewall
        ifconfig eno1 down
        ifconfig enp3s2 192.168.10.2 up
        route add default gw 192.168.10.1
}
    if [ "$#" -ne 1 ]; then
        echo "Options workstation/firewall"
        exit 1
    fi
    case $1 in
        "workstation") workstation ;;
        "firewall") firewall
    esac
