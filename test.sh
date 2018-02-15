ip="192.168.0.3"
tcp_allow=(22 80 443)
tcp_deny=(32768 32771 32775 137 138 139 111 515 23)
udp_allow=(53 67 68)
udp_deny=(32768 32771 32775 137 138 139 111 515 23)
icmp_allow=(0 8)
icmp_deny=(200)

#remove old logs
rm ./output

printf "\n\n\nTesting TCP ALLOW\n"

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

printf "\n\n\nTesting TCP DENY\n"

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

printf "\n\n\nTesting UDP ALLOW\n"

for i in "${udp_allow[@]}"
do
	:
	hping3 $ip -S -p $i -2 -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open udp passed the test"
else
		echo "Port $i on $ip is closed and failed the test"
	fi
done

printf "\n\n\nTesting UDP DENY\n"

for i in "${udp_deny[@]}"
do
	:
	hping3 $ip -S -p $i -2 -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open and failed the test"
else
		echo "Port $i on $ip is closed and passsed the test"
	fi
done


printf "\n\n\nTesting SYN/FIN\n"
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



printf "\n\n\nTesting HIGH PORT\n"
phigh_port=50000
	hping3 $ip -S -p $phigh_port -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $phigh_port on $ip is open and allowed the SYN packet and failed the test"
else
		echo "Port $phigh_port on $ip is closed and blocked the SYN packet and passed the test"
	fi



printf "\n\n\nTesting ICMP ALLOW\n"

for i in "${icmp_allow[@]}"
do
	:
	hping3 $ip -S -p $i -1 -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open and PASSED the test"
else
		echo "Port $i on $ip is closed and failed the test"
	fi
done

printf "\n\n\nTesting ICMP DENY\n"

for i in "${icmp_deny[@]}"
do
	:
	hping3 $ip -S -p $i -1 -c 1 >> output
	if [  $? -eq 0 ]; then
		echo "Port $i on $ip is open and FAILED the test"
else
		echo "Port $i on $ip is closed and PASSED the test"
	fi
done



#fragment flags - set more fragment
printf "\n\n\nTesting FRAGMENTS\n"
pfragment=22
	hping3 $ip -S -p $pfragment -c 1 -f >> output
	if [  $? -eq 0 ]; then
		echo "Port $pfragment on $ip is open and passed the test"
else
		echo "Port $pfragment on $ip is closed and failed the test"
	fi




