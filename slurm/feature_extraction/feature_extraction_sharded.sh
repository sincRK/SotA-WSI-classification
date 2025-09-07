#!/bin/bash
# feature_extraction_sharded.sh
# Usage: feature_extraction_sharded.sh /path/data /path/output workers n_shards
# Example:
#   bash feature_extraction_sharded.sh ${TMPDIR}/histai/data ${TMPDIR}/histai/output 8 4
#
# This script supports multiple feature extraction tasks after one run with --task all.
# Or seperate runs with --task seg and --task coords.
# Assumptions:
# - All use default patch settings
# Usage:
# wrap this script in for loop over the tasks and patch encoders you want to run.
#
# The output with be a folder called "$PATH_ENCODER" in each shard folder.


set -euo pipefail

DATA_DIR="$1"
OUTPUT_DIR="$2"
WORKERS="$3"
N_SHARDS="$4"
TASK="${5:-all}" # Default task is 'all'
PATCH_ENCODER="${6:-uni_v2}" # Default patch encoder is 'uni_v2'
MAG="${7:-20x}" # Default magnification is '20x'
PATCHSIZE="${8:-512}" # Default patch size is '512'

LIST_FILE="${DATA_DIR}/list_of_files.csv"

if [[ ! -f "$LIST_FILE" ]]; then
    echo "ERROR: Cannot find list_of_files.csv in ${DATA_DIR}"
    exit 1
fi

# Count number of lines excluding header
TOTAL_LINES=$(($(wc -l < "$LIST_FILE") - 1))
if (( TOTAL_LINES <= 0 )); then
    echo "ERROR: list_of_files.csv has no data rows."
    exit 1
fi

# Calculate lines per shard (round up)
LINES_PER_SHARD=$(( (TOTAL_LINES + N_SHARDS - 1) / N_SHARDS ))

# Create shards
mkdir -p "$OUTPUT_DIR"

# Read header separately
HEADER=$(head -n 1 "$LIST_FILE")

tail -n +2 "$LIST_FILE" | split -l "$LINES_PER_SHARD" - "$OUTPUT_DIR/shard_tmp_"

# Determine zero-padding width (e.g., N_SHARDS=12 → width=2)
PAD_WIDTH=${#N_SHARDS}

SHARD_INDEX=0
for shard_file in "$OUTPUT_DIR"/shard_tmp_*; do
    SHARD_DIR="${OUTPUT_DIR}/shard_$(printf "%0${PAD_WIDTH}d" "$SHARD_INDEX")"
    mkdir -p "$SHARD_DIR"

    SHARD_LIST="${SHARD_DIR}/list_of_files.csv"

    # Check if shard file already exists and is non-empty
    # Does not overwrite existing shard files
    if [[ -s "$SHARD_LIST" ]]; then
        echo "Shard list $SHARD_LIST already exists and is non-empty. No overwrite."
    else
        {
            echo "$HEADER"
            cat "$shard_file"
        } > "$SHARD_LIST"
    fi

    (
        #module load devel/miniforge/24.9.2
        #conda activate trident
        python "${TMPDIR}/TRIDENT/run_batch_of_slides.py" \
            --task "$TASK" \
            --max_workers "$WORKERS" \
            --wsi_dir "$DATA_DIR" \
            --custom_list_of_wsis "$SHARD_LIST" \
            --job_dir "$SHARD_DIR" \
            --patch_encoder "$PATCH_ENCODER"
    ) &

    SHARD_INDEX=$((SHARD_INDEX + 1))
done

# Cleanup temp shard split files
rm "$OUTPUT_DIR"/shard_tmp_*

# Wait for all background jobs
wait
echo "All shards completed."
