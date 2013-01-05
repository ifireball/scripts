#!/bin/bash
# mk_vb_tap.bash
#   This script generates a tapX tun/tap interface for use with VirtuaBox
#   virtual machines, and joins it to the br0 bridge.
#
# Parameters:
#   The script accepts one optional parameter - the name of the user who will
#   own the interface and would subsequently run the VM, if the parameter isn't
#   specified, SUDO_USER will be used
#
# Output:
#   The script will output the name of the created interface
#
# Requirements
#   This script needs to be run as root (e.g. using sudo), to enable members of
#   the uml-net group to use this script, add the following line to the sudoers
#   file:
#   %uml-net ALL=(root) NOPASSWD: /usr/local/sbin/mk_vb_tap.bash ""

die() {
	echo "$@" >&2
	exit 1
}

[[ "$UID" -eq 0 ]] || die "This script needs to be run with root priveledges"

if [[ $# -eq 1 ]]; then
	IF_OWNER="$1"
elif [[ "$SUDO_USER" != "" ]]; then
	IF_OWNER="$SUDO_USER"
else
	echo "Usage:"
	echo "  $0 <username>"
	echo "Generate a tun/tap interface owned by the specifed user"
	exit 1
fi

# Static configuration parameters
TUNCTL=/usr/sbin/tunctl
IFCONFIG=/sbin/ifconfig
BRCTL=/usr/sbin/brctl

BR_NAME=br0

# Crete the interface
IF_NAME="$($TUNCTL -b -u "$IF_OWNER")" || 
	die "Failed to create the tun/tap interface"
# Bring it up
$IFCONFIG "$IF_NAME" up ||
	die "Failed to bring up the tun/tap interface"
# Join it to the bridge
$BRCTL addif "$BR_NAME" "$IF_NAME" ||
	die "Failed to add the tun/tap interface to the bridge"

# Output the name of the generated interface, we're all done
echo "$IF_NAME"
exit 0
