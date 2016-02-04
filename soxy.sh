#!/bin/bash
#

show_help() {
	echo << EOF
Set up netowrk proxy using ssh

Usage: 
	$0  			--> set up network proxy
	$0 stop		--> stop network proxy
Options: 
	s|stop|-s|--stop	--> stop network proxy
	-h|--help					--> show this help
EOF
}

PORT=49152
HOST=machindo

main() {
	stop_tunnel
	find_port
	start_tunnel
	set_proxy_$(uname)
	print_proxy_settings_$(uname)
}

find_port() {
	while netstat -tln | grep $PORT; do
		PORT=$(($PORT + 1))
	done
}

start_tunnel() { 
	ssh -f -N -D $PORT $HOST || { echo "Problem starting tunnel"; exit; }
}

stop_tunnel() {
	PID=`pgrep -f "ssh -f -N -D"`
	if [[ $PID != '' ]]; then 
		kill $PID || { echo "Problem stopping tunnel"; exit; }
	fi
}

set_proxy_Linux() {
	gsettings set org.gnome.system.proxy.socks host localhost
	gsettings set org.gnome.system.proxy.socks port $PORT
	gsettings set org.gnome.system.proxy mode 'manual'
}

set_proxy_Darwin() {
	networksetup -setwebproxy Wi-Fi localhost $PORT
	networksetup -setwebproxystate Wi-Fi on
}

unset_proxy_Linux() {
	gsettings set org.gnome.system.proxy mode 'none' 
}

unset_proxy_Darwin() {
	networksetup -setwebproxystate Wi-Fi off
}

print_proxy_settings_Linux() {
	echo -n "Proxy mode: "; gsettings get org.gnome.system.proxy mode
	if [ `gsettings get org.gnome.system.proxy mode` == "'manual'" ]; then
		echo -n "Host: "; gsettings get org.gnome.system.proxy.socks host
		echo -n "Port: "; gsettings get org.gnome.system.proxy.socks port
	fi
}

print_proxy_settings_Darwin() {
	networksetup -getwebproxy Wi-Fi
}

# Parse options
#
while [[ $# -ge 1 ]]; do
	key="$1"
	case $key in
		s|stop|-s|--stop)
			unset_proxy_$(uname)
			stop_tunnel
			print_proxy_settings_$(uname)
			exit
			;;
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
