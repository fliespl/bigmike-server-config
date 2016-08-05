#!/bin/bash

UNIX_TIMESTAMP=$(date +"%s")
TIMESTAMP=$(date +"%F")
BACKUP="/var/backups/gitlab"
BACKUPDIR="$BACKUP/$TIMESTAMP"
AGE=7

mkdir -p "$BACKUPDIR"

if [ ! -d $BACKUPDIR ]; then
	echo "Backup destination folder: $BACKUPDIR does not exist."; echo
	exit 1
fi

/opt/gitlab/bin/gitlab-rake gitlab:backup:create CRON=1

if test $? -ne 0
then
	echo "Gitlab didn't create backup file not created." >&2
	exit 1
fi

# normal backup
FILE=`ls -t /var/opt/gitlab/backups/*_gitlab_backup.tar | head -1`
cp $FILE $BACKUPDIR/$(basename $FILE)

# config backup
sudo sh -c 'umask 0077; tar -cf ${BACKUPDIR}/etc-gitlab.tar -C / etc/gitlab'

# ssh backup
sudo sh -c 'umask 0077; tar -cf ${BACKUPDIR}/etc-ssh.tar -C / etc/ssh'

# gitlab ssh backup
sudo sh -c 'umask 0077; tar -cf ${BACKUPDIR}/gitlab-ssh.tar -C / var/opt/gitlab/.ssh'

tar -zcf $BACKUPDIR.tar.gz -C $BACKUP $TIMESTAMP
if test $? -ne 0
then
	echo "Backup file not created." >&2
	exit 1
fi

rm -rf $BACKUPDIR

find $BACKUP -mindepth 1 -maxdepth 1 -ctime +$AGE -exec echo "removing: "{} \; -exec rm -rf {} \;

ncftpput -V -t 3600 -u "backup" -p "backup123" home.codeone.pl /BigMike/gitlab $BACKUPDIR.tar.gz
rsync --ignore-existing $BACKUPDIR.tar.gz backups@chuck.net-labs.pl:~/backup/bigmike/gitlab/

exit 0
