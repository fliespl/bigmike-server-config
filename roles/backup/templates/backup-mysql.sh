#!/bin/bash

BACKUP="/var/backups/mysql"
BACKUPDIR="$BACKUP/tmp"
OUTPUT="$BACKUP/backup.out"

rm -rf "$BACKUPDIR"
mkdir -p "$BACKUPDIR"

if [[ ! -d ${BACKUPDIR} ]]; then
	echo "Backup destination folder: $BACKUPDIR does not exist." >&2
	exit 1
fi

databases=`/usr/bin/mysql --defaults-extra-file=/etc/mysql/debian.cnf -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

date -R > ${OUTPUT}

for db in ${databases}; do
	echo "Backing up database $db" >> ${OUTPUT}
	/usr/bin/time -f "Took: %E"  bash -c '/usr/bin/mysqldump --defaults-extra-file=/etc/mysql/debian.cnf --single-transaction --quick --events '"$db"' | gzip --fast --rsyncable > '"${BACKUPDIR}"'/'"$db"'.sql.gz' 2>>${OUTPUT}
	if test $? -ne 0
	then
		echo -e "Error making backup $db:\n\n$(cat ${OUTPUT})"
		exit 1
	fi
done

/usr/bin/time -v  bash -c 'rdiff-backup --no-acls --preserve-numerical-ids --remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s rdiff-backup --server" -v3 '"${BACKUPDIR}"' backup@78.11.99.66::/var/backups/BigMike/mysql-rdiff' 2>>${OUTPUT}

if test $? -ne 0
then
	echo -e "Error sending files:\n\n$(cat ${OUTPUT})"
	exit 1
fi

exit 0
