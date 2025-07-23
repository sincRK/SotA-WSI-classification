#!/bin/bash

set -euo pipefail

# Argumente
N="${1:?Usage: $0 <n_shards> [target_dir] [filelist.txt] [username] [hostname] [password]}"
TARGET_DIR="${2:-.}"
FILELIST="${3:-./filelist.txt}"

# No default values for username, hostname, and password
USERNAME="${4:?Username is required}"
HOSTNAME="${5:?Hostname is required}"
PASSWORD="${6:?Password is required}"

# Pfad von Script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if host is reachable
if ! ping -c 1 "$HOSTNAME" &>/dev/null; then
    echo "Error: Host $HOSTNAME is not reachable." >&2
    exit 1
fi

# Check if username@hostname with password is valid
if ! sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no "$USERNAME@$HOSTNAME" "exit" &>/dev/null; then
    echo "Error: Invalid credentials for $USERNAME@$HOSTNAME." >&2
    exit 1
fi

# Check if rsync is installed
if ! command -v rsync &>/dev/null; then
    echo "Error: 'rsync' is required." >&2
    exit 1
fi

# Check if filelist exists
if [ ! -f "$FILELIST" ]; then
    echo "Error: File $FILELIST not found." >&2
    exit 1
fi

# Temp directory for shards
TMPDIR="$(mktemp -d -t parallel_download_XXXXXXXX)"
echo "[*] Creating shard files in: $TMPDIR"

# Check if download_single.sh exists
if [[ ! -f "$SCRIPT_DIR/download_single.sh" ]]; then
    echo "Error: download_single.sh not found in script directory $SCRIPT_DIR" >&2
    exit 1
fi

# Count entries
TOTAL=$(wc -l < "$FILELIST")
echo "[*] Total $TOTAL files in $FILELIST"

# Split into N equal chunks
split -l $(( (TOTAL + N - 1) / N )) "$FILELIST" "$TMPDIR/shard_"

# Process each shard
PIDS=()
i=0
for shard in "$TMPDIR"/shard_*; do
    echo "[*] Starting shard $i: $shard"
    ${SCRIPT_DIR}/download_single.sh "$TARGET_DIR" "$shard" "$USERNAME" "$HOSTNAME" "$PASSWORD" > "$TMPDIR/shard_$i.log" 2>&1 &
    PIDS+=($!)
    i=$((i+1))
done

# Wait for all subprocesses
echo "[*] Waiting for all $N processes..."
FAIL=0
for pid in "${PIDS[@]}"; do
    if ! wait "$pid"; then
        echo "Error: Process $pid failed." >&2
        FAIL=1
    fi
done

if [[ $FAIL -ne 0 ]]; then
    # Spill log to stdout
    echo "[*] Some processes failed. Check logs in $TMPDIR."
    for shard_index in "${!PIDS[@]}"; do
        echo "[*] Log for shard $shard_index:"
        cat "$TMPDIR/shard_$shard_index.log"
        cp "$TMPDIR/shard_$shard_index.log" "$TARGET_DIR/shard_$shard_index.log"
    done
    rm -rf "$TMPDIR"
    echo "[*] Removed temporary shard files."
    exit 1
fi

echo "[*] All processes completed successfully."

# Clean up temporary directory
rm -rf "$TMPDIR"
echo "[*] Removed temporary shard files."
exit 0
