#!/bin/sh
#
# Copyright (c) 2011 Ed Schouten <ed@kumina.nl>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

# create-vm.sh: Create a virtual machine using libvirt/KVM

if test $# -lt 10
then
	echo "usage: $0 name nproc ram_mb [disk_volgrp|img_dir] disk_gb [-|disk_splitsize] disk_image [-|vnc_port] [-|vnc_secret] bridge_dev [macaddress]" >&2
	exit 1
fi

NAME=$1
NPROC=$2
RAM_MB=$3
DISK_VOLGRP=$4
DISK_GB=$5
DISK_SPLITSIZE=$6
DISK_IMAGE=$7
VNC_PORT=$8
VNC_SECRET=$9
BRIDGE_DEV=${10}
MACADDRESS=${11}

set -e -x

CREATED=`date -R`

# Create the disk.
I=0
while test $DISK_GB -gt 0
do
	if test $DISK_SPLITSIZE != '-' && test $DISK_GB -gt $DISK_SPLITSIZE
	then
		SLICE=$DISK_SPLITSIZE
	else
		SLICE=$DISK_GB
	fi
	DISKDEV_VM="vd`echo abcdefghijklmnopqrstuvwxyz | cut -b $(($I + 1))`"
	if test -d $DISK_VOLGRP
	then
		# Use qcow2
		DISKDEV_HOST="$DISK_VOLGRP/$NAME-disk$I"
		DISK_CONFIG="$DISK_CONFIG
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='$DISKDEV_HOST'/>
      <target dev='$DISKDEV_VM' bus='virtio'/>
    </disk>"
		qemu-img create -f qcow2 -o cluster_size=2M,preallocation=metadata $DISKDEV_HOST ${SLICE}G
	else
		# Use logical volume
		DISKDEV_HOST="/dev/$DISK_VOLGRP/$NAME-disk$I"
		DISK_CONFIG="$DISK_CONFIG
    <disk type='block' device='disk'>
      <source dev='$DISKDEV_HOST'/>
      <target dev='$DISKDEV_VM' bus='virtio'/>
      <alias name='virtio-disk0'/>
    </disk>"
		lvcreate -L ${SLICE}G -n $NAME-disk$I $DISK_VOLGRP
		dd if=/dev/zero of=$DISKDEV_HOST bs=1M count=1000
	fi

	DISK_GB=$(($DISK_GB - $SLICE))
	I=$(($I + 1))
done

# Generate VNC password if needed.
if test $VNC_PORT = '-'
then
	GRAPHICS_CONFIG="autoport='yes'"
else
	GRAPHICS_CONFIG="autoport='no' port='$VNC_PORT'"
fi
test $VNC_SECRET = '-' || GRAPHICS_CONFIG="$GRAPHICS_CONFIG passwd='$VNC_SECRET'"

if ! test -d $DISK_VOLGRP
then
	# We want an initial installation PXE thingy.
	DD="dd of=/dev/$DISK_VOLGRP/$NAME-disk0 bs=1M"
	if test $DISK_IMAGE = '-'
	then
		DISK_IMAGE=http://debian.kumina.nl/d-i/squeeze/kumihatch-kvm-initial.raw
	fi
	case $DISK_IMAGE in
	ftp://*|http://*|https://*)
		wget -O - $DISK_IMAGE | $DD
		;;
	*)
		$DD if=$DISK_IMAGE
		;;
	esac
fi

if [ -n ${MACADDRESS} ]; then
	MAC_CONFIG="      <mac address='${MACADDRESS}'/>"
fi

# Create the configuration for libvirt.
virsh define /dev/stdin << EOF
<domain type='<%= hypervisor %>' xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
  <name>$NAME</name>
  <description>Created on: $CREATED</description>
  <memory>$(($RAM_MB * 1024))</memory>
  <currentMemory>$(($RAM_MB * 1024))</currentMemory>
  <vcpu>$NPROC</vcpu>
  <os>
    <type arch='x86_64' machine='pc-0.12'>hvm</type>
    <boot dev='network'/>
    <boot dev='hd'/>
    <boot dev='cdrom'/>
  </os>
  <features>
    <acpi/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot><%= on_reboot %></on_reboot>
  <on_crash><%= on_crash %></on_crash>
  <devices>
    <emulator>/usr/bin/<%= hypervisor %></emulator>
$DISK_CONFIG
    <interface type='bridge'>
$MAC_CONFIG
      <source bridge='$BRIDGE_DEV'/>
      <target dev="${NAME}_eth0"/>
      <model type='virtio'/>
    </interface>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' listen='0.0.0.0' $GRAPHICS_CONFIG/>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
    </video>
  </devices>
</domain>
EOF

# Systems should autostart.
virsh autostart $NAME
