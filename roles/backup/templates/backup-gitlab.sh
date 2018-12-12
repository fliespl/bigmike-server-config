#!/bin/bash

BACKUP="/var/backups/gitlab"
BACKUPDIR="$BACKUP/tmp"
OUTPUT="$BACKUP/backup.out"

rm -rf "$BACKUPDIR"
mkdir -p "$BACKUPDIR"

if [[ ! -d ${BACKUPDIR} ]]; then
	echo "Backup destination folder: $BACKUPDIR does not exist." >&2
	exit 1
fi

date -R > ${OUTPUT}

/usr/bin/time -f "Took: %E"  bash -c '/opt/gitlab/bin/gitlab-rake gitlab:backup:create >&2' 2>>${OUTPUT}

if test $? -ne 0
then
	echo "Gitlab didn't create backup file not created." >&2
	exit 1
fi


FILE=`ls -t /var/opt/gitlab/backups/*_gitlab_backup.tar | head -1`
cp ${FILE} ${BACKUPDIR}/$(basename $FILE)

OTHER="$BACKUPDIR/other"
mkdir -p ${OTHER}
mkdir -p ${OTHER}/etc
mkdir -p ${OTHER}/var/opt/gitlab
chmod 600 ${OTHER}

cp -R /etc/gitlab ${OTHER}/etc
cp -R /etc/ssh ${OTHER}/etc
cp -R /var/opt/gitlab/.ssh ${OTHER}/var/opt/gitlab

/usr/bin/time -v  bash -c 'rdiff-backup --no-acls --preserve-numerical-ids \
--remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s rdiff-backup --server" -v3 '"${BACKUPDIR}"' \
backup@78.11.99.66::/var/backups/BigMike/gitlab' 2>>${OUTPUT}

if test $? -ne 0
then
	echo -e "Error sending files:\n\n$(cat ${OUTPUT})"
	exit 1
fi

ssh -i ~/.ssh/backup.priv -C -p22222 backup@78.11.99.66 rdiff-backup -v 2 --force --remove-older-than 7B /var/backups/BigMike/gitlab 2>>${OUTPUT}

if test $? -ne 0
then
	echo -e "Error deleting old backups files:\n\n$(cat ${OUTPUT})"
	exit 1
fi

exit 0
