#!/bin/bash

BACKUP="/var/backups/fs"
BACKUPDIR="$BACKUP/tmp"
OUTPUT="$BACKUP/backup.out"


rm -rf "$BACKUPDIR"
mkdir -p "$BACKUPDIR"

if [[ ! -d ${BACKUPDIR} ]]; then
    echo "Backup destination folder: $BACKUPDIR does not exist." >&2
    exit 1
fi

echo "Started: $(date -R)" > ${OUTPUT}

/usr/bin/time -v  bash -c 'nice /usr/bin/rdiff-backup --no-acls --exclude-sockets --preserve-numerical-ids --remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s sudo rdiff-backup --server" -v3 \
   --include-globbing-filelist "/scripts/rdiff-filelist.txt" \
    / \
   backup@78.11.99.66::/var/backups/BigMike/fs' 2>>${OUTPUT}

if test $? -ne 0
then
    echo -e "Error sending files:\n\n$(cat ${OUTPUT})"
    exit 1
fi


echo "Finished: $(date -R)" >> ${OUTPUT}

exit 0