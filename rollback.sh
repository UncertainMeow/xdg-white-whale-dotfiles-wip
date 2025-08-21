#!/usr/bin/env bash

# Roll back changes made by reddit_method_migrate.sh
# Usage: ./rollback.sh <backup_dir>

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <backup_dir>" >&2
    exit 1
fi

BACKUP_DIR="$1"

if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Backup directory not found: $BACKUP_DIR" >&2
    exit 1
fi

echo "Restoring from backup: $BACKUP_DIR"

shopt -s dotglob nullglob
for item in "$BACKUP_DIR"/*; do
    name="$(basename "$item")"
    orig="$HOME/$name"

    if [[ -L "$orig" ]]; then
        dest="$(readlink "$orig")"
        rm "$orig"
        [[ -e "$dest" ]] && rm -rf "$dest"
    elif [[ -e "$orig" ]]; then
        rm -rf "$orig"
    fi

    cp -r "$item" "$orig"
    echo "  Restored $name"

done

echo "Rollback complete."

