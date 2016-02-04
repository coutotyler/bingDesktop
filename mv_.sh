#!/bin/bash
#

show_help() {
	cat << EOF
Remove spaces from filenames

Usage:
$0 <filename>
EOF
}

main() {
file="$@"
mv "$file" ${file// /_}
}

while [[ $# > 0 ]]; do
	arg="$1"
	case $arg in
		-h|--help)
			show_help
			exit
			;;
		*)
			main $@
			exit
			;;
	esac
	shift
done

if [ $0 != "-bash" ]; then
 	show_help
fi

