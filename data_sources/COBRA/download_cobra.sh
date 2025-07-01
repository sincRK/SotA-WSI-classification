#!/bin/bash

set -euo pipefail

BUCKET="s3://cobra-pathology"

TARGET_DIR="${1:-.}"
FILELIST="${2:-./filelist.json}"

echo "[*] Zielverzeichnis: $TARGET_DIR"
echo "[*] Dateiliste: $FILELIST"

sudo mkdir -p "$TARGET_DIR"

# Erstelle JSON-Dateiliste falls nicht vorhanden
if [ ! -f "$FILELIST" ]; then
  echo "[*] $FILELIST nicht gefunden. Erzeuge JSON-Dateiliste..."
  aws s3api list-objects-v2 --no-sign-request --bucket cobra-pathology --output json | sudo tee "$FILELIST" > /dev/null
  echo "[*] JSON-Dateiliste erstellt."
fi

echo "[*] Starte Download..."

jq -c '.Contents[] | {Key: .Key, Size: .Size}' "$FILELIST" | while IFS= read -r entry; do
  filepath=$(jq -r '.Key' <<< "$entry")
  filesize_s3=$(jq -r '.Size' <<< "$entry")

  [[ -z "$filepath" ]] && continue

  local_path="$TARGET_DIR/$filepath"
  sudo mkdir -p "$(dirname "$local_path")"

  if [[ -f "$local_path" ]]; then
    filesize_local=$(sudo stat -c%s "$local_path")
    if [[ "$filesize_local" -eq "$filesize_s3" ]]; then
      echo "[*] $filepath existiert lokal und ist vollständig, überspringe."
      continue
    else
      echo "[*] $filepath existiert lokal, aber Größe weicht ab (lokal: $filesize_local, S3: $filesize_s3), lade neu."
    fi
  else
    echo "[+] Lade $filepath"
  fi

  sudo aws s3 cp --no-sign-request "$BUCKET/$filepath" "$local_path"
done

echo "[✓] Download abgeschlossen."

