tcp=(32768 32771 32775 137 138 139 111 515 23)

for i in "${tcp[@]}"
do
	:
	hping3 $1 -S -p $i -c 1 >> output
	echo $?
	if [  $? -eq 0 ]; then
	    echo "$i passed the test"
	else
	    echo "$i failed the test"
	fi
done

icmp=(8)

for i in "${icmp[@]}"
do
	:
	hping3 $1 -S -p $i -1 -c 1 >> output
	echo $?
	if [  $? -eq 0 ]; then
	    echo "$i passed the icmp test"
	else
	    echo "$i failed the icmp test"
	fi
done

udp=(67)

for i in "${udp[@]}"
do
	:
	hping3 $1 -S -p $i -2 -c 1 >> output
	echo $?
	if [  $? -eq 0 ]; then
	    echo "$i passed the udp test"
	else
	    echo "$i failed the udp test"
	fi
done

dport=(80)

for i in "${dport[@]}"
do
	:
	hping3 $1 -SF -p $i -c 1 >> output
	echo $?
	if [  $? -eq 0 ]; then
	    echo "$i passed the test for SYN FIN"
	else
	    echo "$i failed the test for SYN FIN"
	fi
done


	hping3 $1 -S -p 50000 -c 1 >> output
	echo $?
	if [  $? -eq 0 ]; then
	    echo "$i passed the test for SYN FIN"
	else
	    echo "$i failed the test for SYN FIN"
	fi

#fragment flags - set more fragments
	hping3 $1 -S -p 22 -c 1 -x >> output
	echo $?
	if [  $? -eq 0 ]; then
	    echo "passed the test for fragment testing"
	else
	    echo "failed the test for fragment testing"
	fi

#Don't fragment flags
    hping3 $1 -S -p 22 -c 1 -y >> output
	echo $?
	if [  $? -eq 0 ]; then
	    echo "passed the test for DON'T fragment testing"
	else
	    echo "failed the test for DON'T fragment testing"
	fi
