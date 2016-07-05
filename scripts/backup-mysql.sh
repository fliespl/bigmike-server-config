#!/bin/bash

TIMESTAMP=$(date +"%F")
BACKUP="/backups"
BACKUPDIR="$BACKUP/$TIMESTAMP"
MYSQL_USER="root"
MYSQL=/usr/bin/mysql
MYSQL_PASSWORD=""
MYSQLDUMP=/usr/bin/mysqldump
AGE=7

mkdir -p "$BACKUPDIR"

if [ ! -d $BACKUPDIR ]; then
	echo "Backup destination folder: $BACKUPDIR does not exist." >&2
	exit 1
fi

if [ -z "`/usr/sbin/service mysql status | grep 'Active: active (running)'`" ] ; then
	echo "HALTED: MySQL does not appear to be running."  >&2
	exit 1
fi

if ! `echo 'exit' | $MYSQL -s --user=$MYSQL_USER -p$MYSQL_PASSWORD` ; then
	echo "HALTED: Supplied mysql username or password appears to be incorrect (not copied here for security, see script)"  >&2
	exit 1
fi

databases=`$MYSQL --user=$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

for db in $databases; do
  # echo "backup started: $db"
  $MYSQLDUMP --force --opt --events --ignore-table=mysql.event --user=$MYSQL_USER -p$MYSQL_PASSWORD --databases $db | gzip > "$BACKUPDIR/$db.gz"
  # echo "backup finished: $db"
done

tar -zcf $BACKUPDIR.tar.gz -C $BACKUP $TIMESTAMP


if test $? -eq 0
then
	# echo "Tar $TIMESTAMP.tar.gz created successfully."
	rm -rf $BACKUPDIR
else
	echo "Backup file not created." >&2
	exit 1
fi

# echo "Cleaning up old backups (older than $AGE days) and temporary files"
find $BACKUP -mindepth 1 -maxdepth 1 -ctime +$AGE -exec rm -rf {} \;

ncftpput -V -u "backup" -p "backup123" home.codeone.pl /BigMike/mysql $BACKUPDIR.tar.gz

if test $? -eq 0
then
#	echo "$TIMESTAMP.tar.gz uploaded successfully."
	rm -rf $BACKUPDIR
else
	echo "Error uploading backup file." >&2
	exit 1
fi

exit 0
