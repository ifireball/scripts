#!/bin/bash
# sysconf-backup.bash - Backup system configuration
#
# Revsion history:
# Date		Author		Revision
# 2011-09-10	Barak Korren	Adapted and generalized from a script on
# 				mailserver

warn () {
	echo "$@" 1>&2
}

die() {
	echo "$@" 1>&2
	exit 1
}

MKDIR=/bin/mkdir
MKTEMP=/bin/mktemp
TAR='/bin/tar'
RM='/bin/rm'
DATE='/bin/date'
CHOWN='/bin/chown'
DPKG=/usr/bin/dpkg
DEBCONF_GET_SELECTIONS=/usr/bin/debconf-get-selections

[[ $UID -eq 0 ]] ||
	die 'This script should be run as root'

BACKUP_USER="ifireball"
BACKUP_BASE="/home/$BACKUP_USER/autosync/misc/backup"
[[ -d "$BACKUP_BASE" ]] ||
	die 'Backup base directory not found'
TEMP_DIR=$($MKTEMP -d) ||
	die 'Faild to create temporary dirctory'
cd $TEMP_DIR ||
	die 'Failed to enter temporary directory'
BACKUP_ARCHIVE=$($DATE "+$HOSTNAME-sysconf-%Y-%m-%d-%H-%M-%S") ||
	die 'Failed to generate backup archive name'

BACKUP_DIR="$BACKUP_ARCHIVE"
$MKDIR "$BACKUP_DIR" ||
	die 'Failed to create backup directory'
BACKUP_FILE="$BACKUP_BASE/$BACKUP_ARCHIVE.tar.bz2"
[[ -x "$BACKUP_FILE" ]] && 
	warn 'Backup file will be overwritten'

$DPKG --get-selections > "$BACKUP_DIR/dpkg-get-selections.lst" ||
	die 'Failed to backup DPKG selections'
$DEBCONF_GET_SELECTIONS > "$BACKUP_DIR/debconf-set-selections.lst" ||
	die 'Failed to backup debconf selections'

$TAR -cjf "$BACKUP_FILE" "$BACKUP_DIR" ||
	die 'Failed to create backup file'
$CHOWN "$BACKUP_USER:$BACKUP_USER" "$BACKUP_FILE" ||
	warn 'Failed to adjust backup file permissions'
$RM -rf $TEMP_DIR ||
	warn 'Failed to clean up temporary data'

exit 0

