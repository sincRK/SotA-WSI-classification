#!/bin/bash
D1=$1

# Create directories if they don't exist
for mag in 20x_512px_0px_overlap 20x_256px_0px_overlap 10x_512px_0px_overlap 10x_256px_0px_overlap; do
    for feat in slide_features_titan slide_features_prism slide_features_feather; do
        mkdir -p "${TMPDIR}/${D1}/${mag}/${feat}"
    done
done

# Function to safely link files, ignoring "file exists" errors
safe_ln_files() {
    src_dir="$1"
    dst_dir="$2"
    for f in "${src_dir}"/*; do
        [ -f "$f" ] && ln -s "$f" "${dst_dir}/$(basename "$f")" 2>/dev/null || true
    done
}

# Link files from cobra_features
for mag in 20x_512px_0px_overlap 20x_256px_0px_overlap 10x_512px_0px_overlap 10x_256px_0px_overlap; do
    for feat in slide_features_titan slide_features_prism slide_features_feather; do
        safe_ln_files "${TMPDIR}/cobra_features/${mag}/${feat}" "${TMPDIR}/${D1}/${mag}/${feat}"
    done
done

# Link files from pp_features
for mag in 20x_512px_0px_overlap 20x_256px_0px_overlap 10x_512px_0px_overlap 10x_256px_0px_overlap; do
    for feat in slide_features_titan slide_features_prism slide_features_feather; do
        safe_ln_files "${TMPDIR}/pp_features/${mag}/${feat}" "${TMPDIR}/${D1}/${mag}/${feat}"
    done
done
