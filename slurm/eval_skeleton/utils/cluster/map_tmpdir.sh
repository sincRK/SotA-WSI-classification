#!/bin/bash

# Usage: ./replace_tmpdir.sh BASE_DIR REPLACE_VALUE
BASE_DIR=$1
REPLACE=$2

if [ -z "$BASE_DIR" ] || [ -z "$REPLACE" ]; then
    echo "Usage: $0 <BASE_DIR> <REPLACE_VALUE>"
    echo "  BASE_DIR: Base directory to search for embeddings_paths.yaml files"
    echo "  REPLACE_VALUE: Value to replace TMPDIR placeholders with"
    exit 1
fi

if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Directory '$BASE_DIR' does not exist"
    exit 1
fi

# Find all *embeddings_paths.yaml files
embeddings_paths=$(find "${BASE_DIR}" -type f -wholename "${BASE_DIR}/**/configs/*embeddings_paths.yaml")

if [ -z "$embeddings_paths" ]; then
    echo "No *embeddings_paths.yaml files found matching pattern: ${BASE_DIR}/**/configs/*embeddings_paths.yaml"
    exit 0
fi

# Convert to array for counting
embeddings_array=($embeddings_paths)
total_files=${#embeddings_array[@]}

echo "Found $total_files embeddings_paths.yaml files"
echo "Replacing TMPDIR with: $REPLACE"
echo "----------------------------------------"

# Process each file
processed=0
for file in $embeddings_paths; do
    echo "Processing: $file"

    # Check if file contains TMPDIR before attempting replacement
    if grep -q "TMPDIR" "$file"; then
        # Create backup
        cp "$file" "$file.backup"
        echo "  Created backup: $file.backup"

        # Replace TMPDIR with the specified value
        sed -i "s|TMPDIR|$REPLACE|g" "$file"

        # Count replacements made
        replacements=$(grep -c "$REPLACE" "$file")
        echo "  Made $replacements replacements"

        processed=$((processed + 1))
    else
        echo "  No TMPDIR found in file, skipping"
    fi
    echo
done

echo "----------------------------------------"
echo "Processing complete!"
echo "Files processed: $processed / $total_files"
echo "Backups created with .backup extension"

# Optional: Show summary of what was replaced
echo
echo "Summary of replacements:"
for file in $embeddings_paths; do
    if [ -f "$file.backup" ]; then
        echo "  $file:"
        diff "$file.backup" "$file" | grep "^>" | head -3
    fi
done
