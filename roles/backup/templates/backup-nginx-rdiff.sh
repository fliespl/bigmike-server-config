#!/bin/bash

nice /usr/bin/rdiff-backup --remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s rdiff-backup --server" -v3 \
    --include /home/flies \
    --exclude "**" backup@78.11.99.66::/ /var/backups/BigMike/rdiff



nice rdiff-backup --no-acls --preserve-numerical-ids --remote-schema "ssh -i ~/.ssh/backup.priv -C -p22222 %s rdiff-backup --server" -v3 /var/www/accounts/dobrzan backup@78.11.99.66::/var/backups/BigMike/nginx-rdiff/dobrzan