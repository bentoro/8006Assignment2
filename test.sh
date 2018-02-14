ip="192.168.0.11"
tcp_allow=(22)
tcp_deny=(32768 32771 32775 137 138 139 111 515 23)

#remove old logs
rm ./output

for i in "${tcp_allow[@]}"
do
	:
	hping3 $ip -S -p $i -c 1 >> output
	if [  $? -eq 0 ]; then
	    echo "Port $i on $ip is open and passed the test"
	else
	    echo "Port $i on $ip is closed and failed the test"
	fi
done



for i in "${tcp_deny[@]}"
do
	:
	hping3 $ip -S -p $i -c 1 >> output
	if [  $? -eq 0 ]; then
	    echo "Port $i on $ip is open and failed the test"
	else
	    echo "Port $i on $ip is closed and passed the test"
	fi
done


icmp=(8)

for i in "${icmp[@]}"
do
	:
	hping3 $ip -S -p $i -1 -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open and failed the test"
else
		echo "Port $i on $ip is closed and passed the test"
	fi
done

udp=(67)

for i in "${udp[@]}"
do
	:
	hping3 $ip -S -p $i -2 -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open and blocked the udp packet and failed the test"
else
		echo "Port $i on $ip is failed and allowed the udp packet and passed the test"
	fi
done

dport=(80)

for i in "${dport[@]}"
do
	:
	hping3 $ip -SF -p $i -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open and allowed the SYN FIN packet and failed the test"
else
		echo "Port $i on $ip is closed and blocked the SYN FIN packet and passed the test"
	fi
done


	hping3 $ip -S -p 50000 -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open and allowed the SYN packet and failed the test"
else
		echo "Port $i on $ip is closed and blocked the SYN packet and passed the test"
	fi

#fragment flags - set more fragment
pfragment=22
	hping3 $ip -S -p $pfragment -c 1 -f >> output
	if [  $? -eq 0 ]; then
		echo "Port $pfragment on $ip is closed and blocked the fragment packet and passed the test"
else
		echo "Port $pfragment on $ip is open and allowed the fragment packet and failed the test"
	fi

#Don't fragment flags
  hping3 $ip -S -p $pfragment -c 1 -y >> output
	if [  $? -eq 0 ]; then
		echo "Port $pfragment on $ip is closed and blocked the fragment packet and passed the test"
else
		echo "Port $pfragment on $ip is open and allowed the fragment packet and failed the test"
	fi



#USER DEFINED AREA
icmp





