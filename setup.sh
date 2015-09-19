#!/bin/bash
#

show_help() {
	cat << EOF
Create links in the scripts directory.
EOF
}

REPO="/home/tyler/Documents/gitRepos/scripts/"
DIR="/home/tyler/Documents/scripts/"

main() {
	for script in `ls $REPO | grep -v setup.sh`; do
		ln -fs $REPO$script $DIR${script%.*} 
	done
}

while [[ $# > 0 ]]; do
	arg="$1"
	case arg in
		-h|--help)
			show_help
			exit
			;;
		*)
			show_help
			exit
			;;
	esac
	shift
done

if [ $0 != "-bash" ]; then
 main
fi

