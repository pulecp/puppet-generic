#!/bin/sh
iface="$1"
if [ -z "$iface" ]; then
	>&2
	echo "Sets interface aliases according to /etc/network/aliases"
	echo "Usage: $0 interface [interface ..]"
	echo "  or:  $0 -a"
	exit 1
fi

if [ x$iface = x-a ]; then
	interfaces=`awk '$1 == "iface" { print $2 }' /etc/network/interfaces`
else
	interfaces="$*"
fi

for iface in $interfaces; do
	# only refresh aliases if the interface is (supposed to be) up
	if grep -q "${iface}=${iface}" /etc/network/run/ifstate; then
		# create a list of intended aliases (strip comments and empty lines first)
		aliasfile=`mktemp`
		sed -e 's/#.*//' -e 's/[ ^I]*$//' -e '/^$/ d' /etc/network/aliases | awk '$1 == "'$iface'" {print $2}'  | sort -n >$aliasfile

		# create a list of live aliases
		# skip the first for now because that's the 'main' IP address
		# better is to look in /etc/network/interfaces what's supposed to be the main IP
		aliaslive=`mktemp`
		ip addr show dev ${iface} | awk '$1=="inet" { print $2 }' | tail -n +2 | sort -n >$aliaslive

		diff -i $aliaslive $aliasfile | grep '^[<>]' | while read action ip; do
			# remove alias on interface if the IP is a live alias but is not in the aliases file
			if [ $action = '<' ]; then
				ip addr del ${ip} dev ${iface}
			# ..otherwise add it
			else
				ip addr add ${ip} dev ${iface}
			fi
		done

		# cleanup
		rm -f $aliasfile
		rm -f $aliaslive
	fi
done
