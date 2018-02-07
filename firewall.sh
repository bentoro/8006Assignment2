$IP = /sbin/iptables

$FWNAME
$FWLOCATION
$INTERNALNET

$TCP_ALLOW
$UDP_ALLOW
$ICMP_ALLOW

Cleanup(){
    $IP -F

    $IP -X
}

SetDefaults(){
    $IP -P INPUT DROP
    $IP -P OUTPUT DROP
    $IP -P FORWARD DROP
}


