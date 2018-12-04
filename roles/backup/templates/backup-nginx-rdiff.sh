#!/bin/bash


nice /usr/bin/rdiff-backup --no-acls --preserve-numerical-ids --remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s sudo rdiff-backup --server" -v3 \
   --include /etc \
   --include /opt --exclude /opt/libreoffice --exclude /opt/phpfarm/src --exclude /opt/phpfarm/inst/sessions \
   --exclude "**" \
    / \
   backup@78.11.99.66::/var/backups/BigMike/fs





nice rdiff-backup --no-acls --preserve-numerical-ids --remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s rdiff-backup --server" -v3 \
    /home \
    --exclude "/home/flies" \
    backup@78.11.99.66::/var/backups/BigMike/fs/home



nice rdiff-backup --no-acls --preserve-numerical-ids --remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s rdiff-backup --server" -v3 \
    --exclude "/home/flies" \
    --exclude "/home/japcok" \
    /home backup@78.11.99.66::/var/backups/BigMike/fs/home