#!/bin/bash

source configs/experiments.conf

BASE_DIR=$1

IFS=',' read -r -a MAG_ARR <<< "$MAG"
IFS=',' read -r -a PATCH_SIZE_ARR <<< "$PATCH_SIZE"
IFS=',' read -r -a DATASET_ARR <<< "$DATASET"
IFS=',' read -r -a ENCODER_ARR <<< "$ENCODER"

# Create all possible combinations of folders
for dataset in "${DATASET_ARR[@]}"; do
    # Create configs folder for each dataset
    mkdir -p "${BASE_DIR}/${dataset}/configs"

    for mag in "${MAG_ARR[@]}"; do
        for patch_size in "${PATCH_SIZE_ARR[@]}"; do
            for encoder in "${ENCODER_ARR[@]}"; do
                # Create folder structure
                folder_path="${BASE_DIR}/${dataset}/${mag}_${patch_size}px_0px_overlap/${encoder}"
                mkdir -p "$folder_path"

                # Create empty eval.sh
                touch "${folder_path}/eval.sh"
                # Make it executable
                chmod +x "${folder_path}/eval.sh"
            done
        done
    done
done
