#!/bin/bash
#

show_help() {
	cat << EOF
Do stuff in an infinite loop. <ctrl>-c to exit.

Usage:
$( basename $0 ) '<commands>'
EOF
}

main() {
	commands=$1
	while true; do 
		eval $commands
		[[ $? > 128 ]] && break
	done
}

while [[ $# > 0 ]]; do
	arg="$1"
	case $arg in
		-h|--help)
			show_help
			exit
			;;
		*)
			main "$arg"
	esac
	shift
done

if [ $0 != "-bash" ]; then
 main
fi

