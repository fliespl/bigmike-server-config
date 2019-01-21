#!/bin/bash

BACKUP="/var/backups/mysql"
BACKUPDIR="$BACKUP/tmp"
OUTPUT="$BACKUP/backup.out"


declare -a excluded_databases=('^machelp_(.*)$')

matchesElement () {
  local e
  for e in "${@:2}"; do [[ "$1" =~ $e ]] && return 1; done
  return 0
}

rm -rf "$BACKUPDIR"
mkdir -p "$BACKUPDIR"

if [[ ! -d ${BACKUPDIR} ]]; then
    echo "Backup destination folder: $BACKUPDIR does not exist." >&2
    exit 1
fi

databases=`/usr/bin/mysql --defaults-extra-file=/etc/mysql/debian.cnf -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema)"`

echo "Started: $(date -R)" > ${OUTPUT}

for db in ${databases}; do
    $(matchesElement "${db}" "${excluded_databases[@]}")

    if test $? -ne 0
    then
        echo "Database ${db} excluded" >> ${OUTPUT}
        continue
    fi

    echo "Backing up database $db" >> ${OUTPUT}
    /usr/bin/time -f "Took: %E"  bash -c 'mydumper -e -B '"$db"' -o '"$BACKUPDIR/$db" 2>>${OUTPUT}

    if test $? -ne 0
    then
        echo -e "Error making backup $db:\n\n$(cat ${OUTPUT})"
        exit 1
    fi
done

/usr/bin/time -v  bash -c 'rdiff-backup --no-acls --preserve-numerical-ids \
--remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s rdiff-backup --server" -v3 '"${BACKUPDIR}"' \
backup@78.11.99.66::/var/backups/BigMike/mysql' 2>>${OUTPUT}

if test $? -ne 0
then
    echo -e "Error sending files:\n\n$(cat ${OUTPUT})"
    exit 1
fi

exit 0
