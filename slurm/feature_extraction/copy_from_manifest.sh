#!/bin/bash

# Usage: copy_from_manifest.sh /path/manifest.csv /path/target_dir

manifest="$1"
target_dir="$2"

if [ -z "$manifest" ] || [ -z "$target_dir" ]; then
    echo "Usage: copy_from_manifest <manifest.csv> <target_directory>"
    return 1
fi

if [ ! -f "$manifest" ]; then
    echo "Error: Manifest '$manifest' not found."
    return 2
fi

mkdir -p "$target_dir"

tail -n +2 "$manifest" | while IFS=',' read -r target_filename original_path; do

    original_path_abs=$(realpath "$original_path")
    cp "$original_path_abs" "$target_dir/$target_filename"
done

echo "Copy completed to: $target_dir"
