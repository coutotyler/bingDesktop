#!/bin/bash

case $1 in 
	-h|--help) 
		cat << EOF
Usage:
scpdiff <localfile> <remotefile>   <-- Compare two files
scpdiff <localfile> <remoteserver> <-- Compare two files with the same path

eg. 
scpdiff /path/to/my/file myserver:/different/path/to/file
scpdiff /path/to/my/file myserver
scpdiff file server
EOF
		exit
	;;
esac

case $1 in 
	/*)		# The first argument is a fully qualified path
		localfile=${1##*/}
		localpath=${1%/*}/
	;;
	*)	# The first argument is a relative file path
		a=./$1
		localfile=${a##*/}
		localpath=$(pwd)/${a%/*}/
	;;
esac
case $2 in
	*:*)	# The second argument contains a file path
		remotefile=${2##*/}
		tmp=${2##*:} 
		remotepath=${tmp%/*}/
		remoteserver=${2%%:*}
		;;
	*)	# The second argument is just a server name
		remotefile=$localfile
		remotepath=$localpath
		remoteserver=$2
		;;
esac

# Test local file
[[ -a $localpath$localfile ]] || { echo "Error: can't open local file"; exit 1; }

# Copy remote file
scp $remoteserver:$remotepath$remotefile /tmp/$remoteserver.$remotefile > /dev/null 2>&1 || { echo 'Error: scp failed'; exit 1; }

# Store modification time
openModTime=$(stat -c %Y /tmp/$remoteserver.$remotefile)

# Diff files
vimdiff $localpath$localfile /tmp/$remoteserver.$remotefile

# Copy file to remote server if it was modified 
closeModTime=$(stat -c %Y /tmp/$remoteserver.$remotefile)
if [[ $closeModTime != $openModTime ]]; then # copy file to remote machine
	scp /tmp/$remoteserver.$remotefile $remoteserver:$remotepath$remotefile > /dev/null 2>&1 || { echo 'Error: remote update failed'; exit 1; }
fi

# Clean up
rm -f /tmp/$remoteserver.$remotefile || { echo "Error: rm file /tmp/$remoteserver.$remotefile failed"; exit 1; }
