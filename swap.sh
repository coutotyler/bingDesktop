#!/bin/bash
#

show_help() {
	cat << EOF
Deal with vim's pesky (but lifesaving) .swp files.

Usage: 
	swap <file> 
Options
	-h --help --> Show this help
EOF
}

main() {
	file=$arg
	vim -n -c ":w $file.rec" -c ":q!" -r $file
	if [ "`diff -q $file $file.rec`" ]; then 
		vimdiff -n $file $file.rec
		echo ".swp and .rec file retained" 
	else
		echo "No difference between current file and recovered file."
		rm .$file.swp $file.rec
	fi
}

exists() {
	file=$arg
	[ -e $file ] || { echo "Can't find file $file"; exit; }
	[ -e .$file.swp ] || { echo "Can't find swap file .$file.swp"; exit; }
}

while [[ $# > 0 ]]; do
	arg="$1"
	case arg in
		-h|--help)
			show_help
			exit
			;;
		*)
			exists arg
			;;
	esac
	shift
done

if [ $0 != "-bash" ]; then
 main arg
fi

