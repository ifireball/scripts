#!/bin/bash
# cloneVM.bash - This script clones the "CentOS" VirtualBox VM, it can be made 
#                to clone other VMs with a very simple configuration change,
#                see below.
#
# Copyright 2007 Barak Korren
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/.
#

# --------------------------- Configuration Variables -------------------------
VBOXMANAGE="/usr/bin/vboxmanage"

# Where to put the VMs, this is the default location for a non-root user
VBBASE="$HOME/.VirtualBox"
VMDIR="$VBBASE/Machines"
VDIDIR="$VBBASE/VDI"

# The name of the VM we're duplicating
ORIGVM="CentOS"
ORIGVDI="$VDIDIR/$ORIGVM.vdi"

# Unless you want to improve my script you 
# needn't change anything below this line
# ------------------------------------------------------------------------------
usage() {
	cat 1>&2 <<EOF
Usage:
  $(basename $0) VMNAME
Creates a new clone of the $ORIGVM VM and names it with he given name.
EOF
	exit 1
}

# Just enough input processing to make it not explode in your face...
[[ $# -ne 1 ]] && usage
NEWVM="$1"
shift

if [[ "$NEWVM" == "$ORIGVM" ]]; then
	echo "New VM name must be different then \"$ORIGVM\"." 1>&2
	usage
fi

NEWVDI="$VDIDIR/$NEWVM.vdi"

# This is how you actually clone the VM:
# 1st you clone the virtual disk
$VBOXMANAGE clonevdi "$ORIGVDI" "$NEWVDI"
# Then you register the new disk with VirtualBox
$VBOXMANAGE registerimage disk "$NEWVDI"
# When you're done with the disk you create a new VM
$VBOXMANAGE createvm -name "$NEWVM" -register
# Finally configure the VM to your liking, including adding the cloned disk
# TODO: Parametrise everything here
$VBOXMANAGE modifyvm "$NEWVM" \
	-ostype "linux26" \
	-memory "256M" \
	-boot1 "disk" -boot2 "dvd" -boot3 "floppy" \
	-hda "$NEWVDI" \
	-nic1 "nat" \
	-audio none 

