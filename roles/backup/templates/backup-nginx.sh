#!/bin/bash

TIMESTAMP=$(date +"%F")
BACKUP="/var/backups/nginx"
BACKUPDIR="$BACKUP/$TIMESTAMP"
AGE=7

mkdir -p "$BACKUPDIR"

if [[ ! -d ${BACKUPDIR} ]]; then
	echo "Backup destination folder: $BACKUPDIR does not exist."; echo
	exit 1
fi

for dir in /var/www/accounts/*
do
  base=$(basename "$dir")
  tar -zcf "$BACKUPDIR/$base.tar.gz" --warning=no-file-changed --ignore-failed-read --exclude-tag-all=.do-not-backup -C  /var/www/accounts "${base}"

  if test $? -eq 2
  then
    echo "Backup file (${dir}) not created." >&2
  	exit 1
  fi
done

zip -q -s 1024m -r $BACKUPDIR.zip $BACKUPDIR/*
if test $? -eq 0
then
	rm -rf $BACKUPDIR
else
	echo "Backup file not created zip." >&2
	exit 1
fi

# echo "Cleaning up old backups (older than $AGE days) and temporary files"
find $BACKUP -mindepth 1 -maxdepth 1 -ctime +$AGE -exec rm -rf {} \;

rsync $BACKUP/$TIMESTAMP.z* -e "ssh -p 22222 -i ~/.ssh/backup.priv" backup@78.11.99.66:/var/backups/BigMike/nginx/
#ncftpput -V -t 10800 Backup /BigMike/nginx $BACKUP/$TIMESTAMP.z*
#rsync $BACKUP/$TIMESTAMP.z* backups@chuck.net-labs.pl:~/backup/bigmike/nginx/

exit 0
