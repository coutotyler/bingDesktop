#!/bin/bash

# ToDo: 
# Add a revert option: Reverts to the previous day's image (If you don't
# like today's)
# Check the timestamp of the current picture. If it's from today, exit. 

#export DISPLAY=:0

fileName=$(echo "wallpaper_"$(date --rfc-3339 seconds)".jpg" | sed -e "s/ /T/g")
saveDir="/home/tyler/Pictures/wallpaper/"
logFile="bingDesktop.log"
logDir="/home/tyler/Documents/logs/"
timeOut=120

if [ ! -d $saveDir ]; then
	mkdir -p $saveDir
fi

if [ ! -d $logDir ]; then
	mkdir -p $logDir
fi

#if [ ! -a $logDir$logFile ]; then
#	touch $logDir$logFile
#fi

# Setup DBUS environment variables
PID=$(pgrep gnome-session)
dbus=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ | cut -d= -f2-)
export DBUS_SESSION_BUS_ADDRESS=$dbus

# Check network connection
startTime=$SECONDS
until ping -q -c 1 "www.bing.com" >> $logDir$logFile 2>&1; do 
	if [[ $(($SECONDS - $startTime)) -ge $timeOut ]]; then
		echo "Can't access www.bing.com"
		exit 1
	fi
done

# Download picture and set background
if wget -t 20 --waitretry=1 --retry-connrefused "www.bing.com"$(wget -qO- www.bing.com | grep -o "url:'.*[.]jpg',id" | cut -d"'" -f2 ) -O /home/tyler/Pictures/wallpaper/"$fileName" 2>>$logDir$logFile; then
	gsettings set org.gnome.desktop.background picture-uri "file://$saveDir$fileName" 2>>$logDir$logFile
else
	rm $saveDir$fileName
	echo 'Download failed.' 
fi
