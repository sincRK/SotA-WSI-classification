#!/bin/bash

copy_from_manifest() {
    local manifest="$1"
    local target_dir="$2"

    if [ -z "$manifest" ] || [ -z "$target_dir" ]; then
        echo "Usage: copy_from_manifest <manifest.csv> <target_directory>"
        return 1
    fi

    if [ ! -f "$manifest" ]; then
        echo "Error: Manifest '$manifest' not found."
        return 2
    fi

    local manifest_dir
    manifest_dir="$(cd "$(dirname "$manifest")" && pwd)"

    mkdir -p "$target_dir"

    tail -n +2 "$manifest" | while IFS=',' read -r target_filename original_path; do

        # Absolute Pfadangabe basierend auf Manifest-Verzeichnis
        local abs_source="$manifest_dir/$original_path"

        if [ ! -f "$abs_source" ]; then
            echo "Warning: File not found: $abs_source"
            continue
        fi

        cp "$abs_source" "$target_dir/$target_filename"
    done

    echo "Copy completed to: $target_dir"
}

# move data to $TMPDIR
HISTAI=/pfs/10/project/bw16k010/benchmark/histai
COBRA=/pfs/10/project/bw16k010/benchmark/cobra/packages
PP=/pfs/10/project/bw16k010/benchmark/pp
# for histai
copy_from_manifest ${HISTAI}/manifest.csv ${TMPDIR}/histai/data
# for cobra
copy_from_manifest ${COBRA}/manifest.csv ${TMPDIR}/cobra/data
# for pp
copy_from_manifest ${PP}/manifest.csv ${TMPDIR}/pp/data
# for hf_bench_models
cp -r /pfs/10/project/bw16k010/benchmark/hf_bench_models/ ${TMPDIR}/hf_bench_models/
