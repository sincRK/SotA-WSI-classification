#!/bin/bash
# Usage: copy_matching_h5.sh list_of_files.csv sourcedir destdir [extension]
# Example:
#   bash copy_matching_h5.sh /path/to/list_of_files.csv /path/to/source /path/to/dest tif

set -euo pipefail

if [[ $# -lt 3 || $# -gt 4 ]]; then
    echo "Usage: $0 list_of_files.csv sourcedir destdir [extension]"
    exit 1
fi

LIST_FILE="$1"
SOURCE_DIR="$2"
DEST_DIR="$3"
EXTENSION="${4:-tif}" # Default extension is 'tif'

if [[ ! -f "$LIST_FILE" ]]; then
    echo "ERROR: Cannot find $LIST_FILE"
    exit 1
fi

mkdir -p "$DEST_DIR"

awk -F, -v ext="$EXTENSION" 'NR>1 && $1 ~ ("\\." ext "$") {print $1}' "$LIST_FILE" | \
    xargs -I{} basename {} | \
    sed "s/\.${EXTENSION}$//" | \
    while read -r uuid; do
        src_file="${SOURCE_DIR}/${uuid}_patches.h5"
        if [[ -f "$src_file" ]]; then
            cp "$src_file" "$DEST_DIR/"
        else
            echo "WARNING: $src_file not found."
        fi
    done
