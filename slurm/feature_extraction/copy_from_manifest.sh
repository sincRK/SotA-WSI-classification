#!/bin/bash

# Usage: 
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

echo "Manifest dir ${manifest_dir}"

tail -n +2 "$manifest" | while IFS=',' read -r target_filename original_path; do

    original_path_abs=$(realpath "$original_path")
    overlap=""

    IFS='/' read -r -a parts1 <<< "$manifest_dir"
    IFS='/' read -r -a parts2 <<< "$original_path_abs"
    for ((i=0; i<${#parts1[@]} && i<${#parts2[@]}; i++)); do
    if [[ "${parts1[i]}" == "${parts2[i]}" ]]; then
            overlap="${overlap}/${parts1[i]}"
        else
            break
        fi
    done

    # Remove double slashes if any
    overlap=$(echo "$overlap" | sed 's#//*#/#g')

    echo "Overlap ${overlap}"

    if [[ -n "$overlap" ]]; then
        # Absolute Pfadangabe basierend auf Manifest-Verzeichnis
        overlap_len=${#overlap}
        joined="${manifest_dir}${original_path_abs:$overlap_len}"
    else
        joined="${manifest_dir}/${original_path_abs}"
    fi

    if [ ! -f "$joined" ]; then
        echo "Warning: File not found: $joined"
        continue
    fi

    cp "$joined" "$target_dir/$target_filename"
done

echo "Copy completed to: $target_dir"
