#!/bin/bash

set -euo pipefail

# Argumente
N="${1:?Usage: $0 <n_shards> [target_dir] [filelist.json]}"
TARGET_DIR="${2:-.}"
FILELIST="${3:-./filelist.json}"

# Pfad von Script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check ob download_cobra_single.sh an der richtigen Stelle ist
if [[ ! -f "$SCRIPT_DIR/download_cobra_single.sh" ]]; then
  echo "Fehler: download_cobra_single.sh nicht gefunden im Skriptverzeichnis $SCRIPT_DIR" >&2
  exit 1
fi

# Prüfen
if ! command -v jq &>/dev/null; then
  echo "Fehler: 'jq' ist erforderlich." >&2
  exit 1
fi

if [ ! -f "$FILELIST" ]; then
  echo "Fehler: Datei $FILELIST nicht gefunden." >&2
  exit 1
fi

# Temp-Verzeichnis für Shards
TMPDIR="$(mktemp -d -t cobra_shards_XXXXXXXX)"
echo "[*] Erzeuge Shard-Dateien in: $TMPDIR"

# Einträge zählen
TOTAL=$(jq '.Contents | length' "$FILELIST")
echo "[*] Insgesamt $TOTAL Dateien in $FILELIST"

# Aufteilen in N gleich große Chunks
jq -c ".Contents | to_entries | .[] " "$FILELIST" | split -l $(( (TOTAL + N - 1) / N )) - "$TMPDIR/shard_"

# In Shards gültiges JSON einbauen
for f in "$TMPDIR"/shard_*; do
  jq -s '{Contents: map(.value)}' "$f" > "$f.json"
  rm "$f"
done

# parallele Prozesse starten
PIDS=()
i=0
for shard in "$TMPDIR"/shard_*.json; do
  echo "[*] Starte Shard $i: $shard"
  ${SCRIPT_DIR}/download_cobra_single.sh "$TARGET_DIR" "$shard" > "$TMPDIR/shard_$i.log" 2>&1 &
  PIDS+=($!)
  i=$((i+1))
done

# Warten auf alle Subprozesse
echo "[*] Warte auf alle $N Prozesse..."
FAIL=0
for pid in "${PIDS[@]}"; do
  if ! wait "$pid"; then
    echo "[!] Fehler in Subprozess PID $pid"
    # Spill log zu stdout
    shard_index=$((${#PIDS[@]} - ${#PIDS[@]} + ${pid} % ${#PIDS[@]}))
    echo "[*] Log für Shard $shard_index:"
    cat "$TMPDIR/shard_$shard_index.log"
    cp "$TMPDIR/shard_$shard_index.log" "$TARGET_DIR/shard_$shard_index.log"
    FAIL=1
  fi
done

# Aufräumen
echo "[*] Entferne temporäre Shard-Dateien"
rm -rf "$TMPDIR"

if [ "$FAIL" -eq 0 ]; then
  echo "[✓] Alle Downloads erfolgreich abgeschlossen."
else
  echo "[!] Mindestens ein Subprozess ist fehlgeschlagen."
  exit 1
fi

