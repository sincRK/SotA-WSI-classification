#!/bin/bash

set -euo pipefail

TARGET_DIR="${1:?usage: $0 <target_dir> <filelist.json>}"
FILELIST="${2:?}"

BUCKET="s3://cobra-pathology"

sudo mkdir -p "$TARGET_DIR"

jq -c '.Contents[] | {Key: .Key, Size: .Size}' "$FILELIST" | while IFS= read -r entry; do
  filepath=$(jq -r '.Key' <<< "$entry")
  filesize_s3=$(jq -r '.Size' <<< "$entry")
  [[ -z "$filepath" ]] && continue

  local_path="$TARGET_DIR/$filepath"
  sudo mkdir -p "$(dirname "$local_path")"

  if [[ -f "$local_path" ]]; then
    filesize_local=$(sudo stat -c%s "$local_path" || echo 0)
    if [[ "$filesize_local" -eq "$filesize_s3" ]]; then
      echo "[*] $filepath vorhanden, überspringe."
      continue
    fi
  fi

  echo "[+] Lade $filepath"
  sudo aws s3 cp --no-sign-request "$BUCKET/$filepath" "$local_path"
done


