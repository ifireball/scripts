#!/bin/bash
# gvfs-mount-smb-4-shell - Run gvfs-mount to mount smb shares for use in shell
# scripts
#
# Date		Author			Revision
<<<<<<< HEAD
# 2013-01-05	barak.korren@gmail.com	Wrote initial version, tested on Ubuntu
=======
# 2013-01-05	barak.korren@gmail.com	Wrote initial version, tested on Ubunto
>>>>>>> 8f6113bc3228a37d2d75413583eb67d1ddb822c2
# 					12.10
#
die() {
	echo "$@" 1>&2
	exit 1
}


GVFS_MOUNT='/usr/bin/gvfs-mount'
[[ -x "$GVFS_MOUNT" ]] || die "$GVFS_MOUNT not found, is it installed?"

GVFS_FUSE_DIR="/run/user/$USER/gvfs"
[[ -d "$GVFS_FUSE_DIR" ]] || die "$GVFS_FUSE_DIR directory not found, are we inside a GVFS-enabled desktop session?"

if [[ $# -ne 2 ]]; then
	cat <<EOF
Usage: $0 HOSTNAME SHARE
  Mount the given SMB share from the given host using GVFS
EOF
	exit 2
fi

HOST="$1"
SHARE="$2"
SMB_PATH="smb://$HOST/$SHARE"
FUSE_PATH="$GVFS_FUSE_DIR/smb-share:server=$HOST,share=$SHARE"

# Exit if it seems the share is already mounted
[[ -d "$FUSE_PATH" ]] && exit 0

# Actually try to mount the share
$GVFS_MOUNT "$SMB_PATH" || die "Falied to mount share $SMB_PATH"

# Wait until we ca see the share mounted
until [[ -d "$FUSE_PATH" ]]; do
	sleep 2
done
exit 0

