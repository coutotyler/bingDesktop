#!/bin/bash
#

show_help() {
	echo << EOF
help stuff
EOF
}

PORT=49152
HOST=machindo

main() {
	stop_tunnel
	find_port
	start_tunnel
	set_proxy
	print_proxy_settings
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

set_proxy() {
	gsettings set org.gnome.system.proxy.socks host localhost
	gsettings set org.gnome.system.proxy.socks port $PORT
	gsettings set org.gnome.system.proxy mode 'manual'
}

unset_proxy() {
	gsettings set org.gnome.system.proxy mode 'none' 
}

print_proxy_settings() {
	echo -n "Proxy mode: "; gsettings get org.gnome.system.proxy mode
	if [ `gsettings get org.gnome.system.proxy mode` == "'manual'" ]; then
		echo -n "Host: "; gsettings get org.gnome.system.proxy.socks host
		echo -n "Port: "; gsettings get org.gnome.system.proxy.socks port
	fi
}

# Parse options
#
while [[ $# -ge 1 ]]; do
	key="$1"
	
	case $key in
		s|stop|-s|--stop)
			unset_proxy
			stop_tunnel
			print_proxy_settings
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
