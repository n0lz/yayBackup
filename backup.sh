#!/bin/bash
#
# Author: ngrundmann
# Version: 0.1.1
#

DEST_PROTOCOL=""				#which transfer type to use e.g.scp
DEST_USER=""					#remote backup user
DEST_SERVER=""					#remote host
DEST_DIR=""					#remote backup folder

DIR_BACKUP=""					#which folders should be backuped. seperated by spaces

GPG_ALGO="AES256"				#algorithm for encryption e.g. aes-256
GPG_PASSPHRASE=""				#passphrase for encryption

BU_SIZE="5000"					#size of single backup containers in MB

DIR_TMP=/tmp/duplicity				#temp directory
DIR_SCRIPT=/root/bin				#script diretcory
DIR_LOG=/var/log/duplicity			#log directory

### DON'T CHANGE ANYTHING DOWN HERE ###

PASSPHRASE=$GPG_PASSPHRASE
export PASSPHRASE

case $1 in
	full)
		for BU_DIR in $DIR_BACKUP
		do
			duplicity full --gpg-options "--cipher-algo $GPG_ALGO" --volsize $BU_SIZE --ssh-options="-oIdentityFile=/root/.ssh/ssh_login_backup"  $BU_DIR $DEST_PROTOCOL://$DEST_USER@$DEST_SERVER/$DEST_DIR$BU_DIR >> $DIR_LOG$BU_DIR.log
		done
		;;

	incr*)
		for BU_DIR in $DIR_BACKUP
                do
			duplicity incr --gpg-options "--cipher-algo $GPG_ALGO" --volsize $BU_SIZE --ssh-options="-oIdentityFile=/root/.ssh/ssh_login_backup" $BU_DIR $DEST_PROTOCOL://$DEST_USER@$DEST_SERVER/$DEST_DIR$BU_DIR >> $DIR_LOG$BU_DIR.log
		done
		;;

	remove)
		for BU_DIR in $DIR_BACKUP
                do
			duplicity remove-all-but-n-full 3 --force --ssh-options="-oIdentityFile=/root/.ssh/ssh_login_backup" $DEST_PROTOCOL://$DEST_USER@$DEST_SERVER/$DEST_DIR$BU_DIR >> $DIR_LOG$BU_DIR.log
		done
		;;

	status)
		for BU_DIR in $DIR_BACKUP
                do
			duplicity collection-status --ssh-options="-oIdentityFile=/root/.ssh/ssh_login_backup" $DEST_PROTOCOL://$DEST_USER@$DEST_SERVER/$DEST_DIR$BU_DIR
		done
		;;

	cleanup)
		for BU_DIR in $DIR_BACKUP
                do
                        duplicity cleanup --force --ssh-options="-oIdentityFile=/root/.ssh/ssh_login_backup" $DEST_PROTOCOL://$DEST_USER@$DEST_SERVER/$DEST_DIR$BU_DIR
                done
                ;;

	*)
		echo "Usage: $SCRIPTNAME {full|incr|remove|status|cleanup}" >&2
		;;

esac

exit 0
