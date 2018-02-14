#User configuration section

tcp_allow=(22)
tcp_deny=(32768 32771 32775 137 138 139 111 515 23)


#---------------------------------------------------------------------------
	#
	#    FUNCTION:		External()
	#
  #    DATE:			Feb 15, 2018
  #
  #    DESIGNER:		Benedict Lo & Aing Ragunathan
  #    Programmer:		Benedict Lo & Aing Ragunathan
  #
	#    DESCRIPTION:	This method starts the external tests and saves outputs to file
	#
	#
	#    RETURNS:
	#                	void
	#
	#---------------------------------------------------------------------------
External(){
	#remove old logs
	rm ./output
	printf "External test allowing TCP ports\n"
	for i in "${tcp_allow[@]}"
	do
		:
		hping3 $1 -S -p $i -c 1 >> output
		if [  $? -eq 0 ]; then
		    echo "Port $i on $1 is open and passed the test"
		else
		    echo "Port $i on $1 is closed and failed the test"
		fi
	done

	printf "External test denying TCP ports\n"
	for i in "${tcp_deny[@]}"
	do
		:
		hping3 $1 -S -p $i -c 1 >> output
		if [  $? -eq 0 ]; then
		    echo "Port $i on $1 is closed and passed the test"
		else
		    echo "Port $i on $1 is open and failed the test"
		fi
	done

	icmp=(8)
	printf "External test allowing ICMP ports\n"
	for i in "${icmp[@]}"
	do
		:
		hping3 $1 -S -p $i -1 -c 1 >> output
		if [  $? -eq 0 ]; then
			echo "Port $i on $1 is closed and passed the test"
	else
			echo "Port $i on $1 is open and failed the test"
		fi
	done

	udp=(67)
	printf "External test allowing UDP ports\n"
	for i in "${udp[@]}"
	do
		:
		hping3 $1 -S -p $i -2 -c 1 >> output
		if [  $? -eq 0 ]; then
			echo "Port $i on $1 blocked the udp packet and passed the test"
	else
			echo "Port $i on $1 allowed the udp packet and passed the test"
		fi
	done

	dport=(80)
	printf "External test testing SYN FIN packets\n"
	for i in "${dport[@]}"
	do
		:
		hping3 $1 -SF -p $i -c 1 >> output
		if [  $? -eq 0 ]; then
			echo "Port $i on $1 blocked the SYN FIN packet and passed the test"
	else
			echo "Port $i on $1 allowed the SYN FIN packet and passed the test"
		fi
	done

	printf "External test testing SYN packets\n"
		hping3 $1 -S -p 50000 -c 1 >> output
		if [  $? -eq 0 ]; then
			echo "Port $i on $1 blocked the SYN packet and passed the test"
	else
			echo "Port $i on $1 allowed the SYN packet and passed the test"
		fi

	printf "External test testing fragment packets\n"
		hping3 $1 -S -p 22 -c 1 -f >> output
		if [  $? -eq 0 ]; then
			echo "Port $i on $1 allowed the fragment packet and passed the test"
	else
			echo "Port $i on $1 blocked the fragment packet and failed the test"
		fi

	printf "External test testing fragment packets\n"
	  hping3 $1 -S -p 22 -c 1 -y >> output
		if [  $? -eq 0 ]; then
			echo "Port $i on $1 allowed the fragment packet and failed the test"
	else
			echo "Port $i on $1 blocked the fragment packet and passed the test"
		fi
}
#---------------------------------------------------------------------------
	#
	#    FUNCTION:		Internal()
	#
  #    DATE:			Feb 15, 2018
  #
  #    DESIGNER:		Benedict Lo & Aing Ragunathan
  #    Programmer:		Benedict Lo & Aing Ragunathan
  #
	#    DESCRIPTION:	This method starts the internal tests and saves outputs to file
	#
	#
	#    RETURNS:
	#                	void
	#
	#---------------------------------------------------------------------------
Internal(){
	testport=(22 80 443)
	printf "Internal test testing TCP packets\n"
	for i in "${testport[@]}"
	do
		:
		hping3 $1 -SF -p $i -c 1 >> output
		if [  $? -eq 0 ]; then
			echo "Port $i on $1 is open and allowed the packet through and passed the test"
	else
			echo "Port $i on $1 is closed and blocked the packet through and failed the test"
		fi
	done
}

if [ "$#" -ne 2 ]; then
		echo "./test internal/external [IP]"
		exit 1
fi
case $1 in
		"external") External $2;;
		"internal") Internal $2;;
esac
