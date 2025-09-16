#!/bin/bash

# Usage: ./batch_eval.sh BASE_DIR BATCH_SIZE
BASE_DIR=$1
BATCH_SIZE=${2:-5}  # Default to 5 if not provided

if [ -z "$BASE_DIR" ]; then
    echo "Usage: $0 <BASE_DIR> [BATCH_SIZE]"
    echo "  BASE_DIR: Directory to search for eval.sh files"
    echo "  BATCH_SIZE: Number of eval.sh scripts to run in parallel (default: 5)"
    exit 1
fi

if [ ! -d "$BASE_DIR" ]; then
    echo "Error: Directory '$BASE_DIR' does not exist"
    exit 1
fi

# Find all eval.sh files
eval_files=$(find "$BASE_DIR" -type f -name "eval.sh")

if [ -z "$eval_files" ]; then
    echo "No eval.sh files found in $BASE_DIR"
    exit 0
fi

# Convert to array for easier processing
eval_array=($eval_files)
total_files=${#eval_array[@]}

echo "Found $total_files eval.sh files"
echo "Running in batches of $BATCH_SIZE"
echo "----------------------------------------"

# Process files in batches
for ((i=0; i<total_files; i+=BATCH_SIZE)); do
    batch_num=$(((i/BATCH_SIZE)+1))
    batch_end=$((i+BATCH_SIZE-1))

    if [ $batch_end -ge $total_files ]; then
        batch_end=$((total_files-1))
    fi

    echo "Starting batch $batch_num (files $((i+1))-$((batch_end+1)))..."

    # Start background processes for this batch
    pids=()
    for ((j=i; j<=batch_end && j<total_files; j++)); do
        eval_file="${eval_array[j]}"
        eval_dir=$(dirname "$eval_file")

        echo "  Starting: $eval_file"

        # Run eval.sh in its directory in the background
        (
            module load devel/miniforge/24.9.2
            conda activate patho_bench
            cd "$eval_dir"
            bash ./eval.sh
        ) &

        pids+=($!)
    done

    # Wait for all processes in this batch to complete
    for pid in "${pids[@]}"; do
        wait $pid
        exit_code=$?
        if [ $exit_code -ne 0 ]; then
            echo "  Warning: Process $pid exited with code $exit_code"
        fi
    done

    echo "Batch $batch_num completed"
    echo "----------------------------------------"
done

echo "All batches completed!"
