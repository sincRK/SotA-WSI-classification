#!/bin/bash

set -euo pipefail

# Argumente "$TARGET_DIR" "$shard" "$USERNAME" "$HOSTNAME" "$PASSWORD"
N="${1:?Usage: $0 [target_dir] [filelist.txt] [username] [hostname] [password]}"
TARGET_DIR="${2:-.}"
FILELIST="${3:?}"

# No default values for username, hostname, and password
USERNAME="${4:?Username is required}"
HOSTNAME="${5:?Hostname is required}"
PASSWORD="${6:?Password is required}"

# Discover common parent directory from filelist
# Get overlap between all lines in filelist
common_parent=$(
    awk -F/ '
        {
            for (i=1; i<=NF; i++) {
                if (i in a) {
                    a[i] = a[i] "/" $i
                } else {
                    a[i] = $i
                }
            }
        }
        END {
            for (i in a) print a[i]
        }
    ' "$FILELIST" | sort | uniq -d | head -n 1
)

# If no common parent found, use current directory
if [[ -z "$common_parent" ]]; then
    common_parent="."
fi

# rsync files from remote host to local target directory
echo "[*] Syncing files from $USERNAME@$HOSTNAME to $TARGET_DIR"

# Create the directory tree from common parent to file in target directory
while IFS= read -r filepath; do
    # Remove the common_parent prefix from filepath to get the relative path
    rel_path="${filepath#$common_parent/}"
    local_path="$TARGET_DIR/$rel_path"
    sudo mkdir -p "$(dirname "$local_path")"
    echo "[+] Syncing $filepath to $local_path"
    sshpass -p "$PASSWORD" rsync -av --no-perms --no-owner --no-group \
        --exclude='*.tmp' --exclude='*.log' \
        "$USERNAME@$HOSTNAME:$filepath" "$local_path"
done < "$FILELIST"
