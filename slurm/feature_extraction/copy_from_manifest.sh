#!/bin/bash

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

manifest_dir="$(cd "$(dirname "$manifest")" && pwd)"

mkdir -p "$target_dir"

overlap=""
tail -n +2 "$manifest" | while IFS=',' read -r target_filename original_path; do

    IFS='/' read -r -a parts1 <<< "$manifest_dir"
    IFS='/' read -r -a parts2 <<< "$original_path"
    if [[ -z "$overlap" ]]; then
        for ((i=0; i<${#parts1[@]}; i++)); do
            slice1="${parts1[@]:i}"
            slice1_join=$(IFS=/; echo "${slice1[*]}")

            if [[ "$original_path" == "$slice1_join"* ]]; then
                overlap="$slice1_join"
                break
            fi
        done
    fi

    if [[ -n "$overlap" ]]; then
        # Absolute Pfadangabe basierend auf Manifest-Verzeichnis
        overlap_len=${#overlap}
        joined="${manifest_dir}${original_path:$overlap_len}"
    else
        joined="${manifest_dir}/${original_path}"
    fi

    if [ ! -f "$joined" ]; then
        echo "Warning: File not found: $joined"
        continue
    fi

    cp "$joined" "$target_dir/$target_filename"
done

echo "Copy completed to: $target_dir"
