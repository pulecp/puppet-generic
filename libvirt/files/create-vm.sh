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

if test $# -ne 7
then
	echo "usage: $0 name nproc ram_mb disk_volgrp disk_gb vnc_port vnc_secret" >&2
	exit 1
fi

NAME=$1
NPROC=$2
RAM_MB=$3
DISK_VOLGRP=$4
DISK_GB=$5
VNC_PORT=$6
VNC_SECRET=$7

set -e -x

CREATED=`date -R`

# Create the disk.
number_of_disks=$(($DISK_GB/125-1))
DISK_CONFIG=""
alfabet="abcdefghij"
for x in `seq 0 $number_of_disks`; do
	lvcreate -L 125G -n ${NAME}-disk${x} ${DISK_VOLGRP}
	xplusone=$(($x+1))
	drive_letter=`echo $alfabet | cut -b $xplusone`
	DISK_CONFIG=$DISK_CONFIG"
    <disk type='block' device='disk'>
      <source dev='/dev/${DISK_VOLGRP}/${NAME}-disk${x}'/>
      <target dev='vd${drive_letter}' bus='virtio'/>
      <alias name='virtio-disk0'/>
    </disk>"
done

# We want an initial installation PXE thingy.
DD="dd of=/dev/${DISK_VOLGRP}/${NAME}-disk0 bs=1M"
if test -f /var/lib/media/initial.raw
then
	$DD if=/var/lib/media/initial.raw
else
	HATCH=http://debian.kumina.nl/d-i/squeeze/kumihatch-kvm-initial.raw
	wget -O - $HATCH | $DD
fi

# Create the configuration for libvirt.
virsh define /dev/stdin <<EOF
<domain type='kvm'>
  <name>${NAME}</name>
  <description>Created on: ${CREATED}</description>
  <memory>$((${RAM_MB} * 1024))</memory>
  <currentMemory>$((${RAM_MB} * 1024))</currentMemory>
  <vcpu>${NPROC}</vcpu>
  <os>
    <type arch='x86_64' machine='pc-0.12'>hvm</type>
    <boot dev='hd'/>
    <boot dev='cdrom'/>
  </os>
  <features>
    <acpi/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>restart</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
${DISK_CONFIG}
    <interface type='bridge'>
      <source bridge='ubr1'/>
      <model type='virtio'/>
    </interface>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='${VNC_PORT}' autoport='no' listen='0.0.0.0' passwd='${VNC_SECRET}'/>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
    </video>
  </devices>
</domain>
EOF

# Systems should autostart.
virsh autostart ${NAME}
