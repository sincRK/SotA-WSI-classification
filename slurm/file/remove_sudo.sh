#!/bin/bash
# This script takes a .sh script file as input and removes all appearances of "sudo" from it.

if [ $# -ne 1 ]; then
  echo "Usage: $0 <script_file.sh>"
  exit 1
fi

SCRIPT_FILE="$1"

if [ ! -f "$SCRIPT_FILE" ]; then
  echo "File not found: $SCRIPT_FILE"
  exit 1
fi

# Create a temporary file to store the modified script
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Remove all occurrences of "sudo" from the script
# Also remove the then trailing spaces to keep the script clean
sed -E 's/\bsudo\b[[:space:]]*//g' "$SCRIPT_FILE" | sed 's/[[:space:]]\+$//' > "$TEMP_FILE"

# Replace the original script with the modified one
mv "$TEMP_FILE" "$SCRIPT_FILE"
chmod 755 "$SCRIPT_FILE"

echo "Removed 'sudo' from $SCRIPT_FILE"

