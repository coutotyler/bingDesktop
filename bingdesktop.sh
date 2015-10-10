#!/bin/bash
#

fileName=$(echo "wallpaper_"$(date --rfc-3339 seconds)".jpg" | sed -e "s/ /T/g")
saveDir="/home/tyler/Pictures/wellpaper/"
timeOut=60 #seconds
debug="/dev/null" 
force=0

show_help() {
	cat << EOF
Download daily image from bing and set it as the desktop background.

Usage:
	$0
Options:
	-h --help    --> Show this help
	-d --debug   --> Show debugging output
	-f --force   --> Force download and setting of file
	-a --archive --> Archive this month's pictures 
EOF
}

main() {
	if [[ $force == 0 ]]; then check_current; fi
	if [ ! -d $saveDir ]; then mkdir -p $saveDir; fi
	setup_dbus
	check_connection
	download_and_set
}
	
setup_dbus() {
	PID=$(pgrep gnome-session)
	dbus=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ | cut -d= -f2-)
	export DBUS_SESSION_BUS_ADDRESS=$dbus
}
	
check_connection() {
	startTime=$SECONDS
	until ping -q -c 1 "www.bing.com" > $debug 2>&1; do 
		if [[ $(($SECONDS - $startTime)) -ge $timeOut ]]; then
			logger -i -t bingdesktop -p syslog.err "Can't access www.bing.com"
			exit 1
		fi
	done
}
	
download_and_set() {
	if wget -t 20 --waitretry=1 --retry-connrefused "www.bing.com"$(wget -qO- www.bing.com | grep -o "url:'.*[.]jpg',id" | cut -d"'" -f2 ) -O $saveDir$fileName > $debug 2>&1; then
		gsettings set org.gnome.desktop.background picture-uri "file://$saveDir$fileName" 
	else
		rm $saveDir$fileName
		logger -i -t bingdesktop -p syslog.err 'Download failed' 
		exit 1
	fi
}

check_current() {
	last=`ls -1 $saveDir | tail -n 1 | sed 's/wallpaper_//' | sed 's/T.*//'`
	if [[ $last == `date +%F` ]]; then 
		echo "Already downloaded today's image. Exiting." > $debug
		exit
	fi
}

archive() {
	files=$(ls -1 "$saveDir"*.jpg)
	i=0
	arDir="$saveDir$(date +%B)-$(date +%g)"
	mkdir $arDir
	for x in $files; do
		y=$(echo $x | sed 's/wallpaper_//' | sed 's/T.*//' | cut -d '-' -f2)
		if [[ $y == `date +%m` ]]; then 
			arFiles[$i]=$x
			i=$((i+1))
		fi
	done
	for x in ${arFiles[*]}; do
		mv $x $arDir
	done
	tar cjf "$arDir".tar.bz2 $arDir 2>/dev/null
}

# Parse options
#
while [[ $# -ge 1 ]]; do
	key="$1"
	case $key in
		-h|--help)
			show_help
			exit
			;; 
		-d|--debug)
			debug=`tty`
			main
			;;
		-f|--force)
			force=1
			main
			;;
		-a|--archive)
			archive
			exit
			;;
		*)
			show_help
			exit
			;;
	esac
	shift
done
