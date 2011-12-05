#!/bin/sh

set -e

if [ "$#" -ne 4 ]
then
	echo "usage: $0 hostname port address1 address2" >&2
	exit 1
fi

HOSTNAME="$1"
PORT="$2"
HOST1="$3"
HOST2="$4"
PID=$$

if nc -zw 15 "$HOST1" "$PORT"
then
	ADDR="$HOST1"
else
	ADDR="$HOST2"
fi

grep -q "^$ADDR $HOSTNAME$" /etc/hosts && exit 0
egrep -v "\b$HOSTNAME\b" /etc/hosts > /etc/hosts.new.$PID
echo "$ADDR $HOSTNAME" >> /etc/hosts.new.$PID
if ! cmp -s /etc/hosts /etc/hosts.new.$PID
then
	echo "$0: $HOSTNAME: updating record to address $ADDR" >&2
fi
mv /etc/hosts.new.$PID /etc/hosts
