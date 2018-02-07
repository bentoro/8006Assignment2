$sport=(80 22)

for i in "${sport[@]}"
do
	:
	hping3 $1 -S -p $i -c 1 >> output
	echo $?
done
