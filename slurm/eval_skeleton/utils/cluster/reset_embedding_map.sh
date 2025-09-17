#!/bin/bash

# Usage: ./reset_embedding_map.sh BASE_DIR MAP_FILE
# Example: ./reset_embedding_map.sh /path/to/base_dir /path/to/embeddings.yaml

set -e

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 BASE_DIR MAP_FILE"
    exit 1
fi

BASE_DIR="$1"
MAP_FILE="$2"

if [[ ! -d "$BASE_DIR" ]]; then
    echo "Error: BASE_DIR '$BASE_DIR' does not exist or is not a directory."
    exit 1
fi

if [[ ! -f "$MAP_FILE" ]]; then
    echo "Error: MAP_FILE '$MAP_FILE' does not exist or is not a file."
    exit 1
fi

# Find all embeddings_paths.yaml files under BASE_DIR
embeddings_paths=$(find "${BASE_DIR}" -type f -wholename "${BASE_DIR}/**/configs/$(basename $MAP_FILE)")

for file in $embeddings_paths; do
    cp "$MAP_FILE" "$file"
    echo "Copied $MAP_FILE to $file"
done
