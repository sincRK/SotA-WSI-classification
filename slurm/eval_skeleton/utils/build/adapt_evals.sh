#!/bin/bash

# Find all eval.sh files in eval_skeleton and adapt their variables:
# -MAG
# -PATCH_SIZE
# -ENCODER
# -DATASET

# the eval tree is built as:
# BASE_DIR/DATASET/MAG_PATCH_SIZEpx_0px_overlap/ENCODER/eval.sh

BASE_DIR=$1

echo "Adapting eval.sh files in $BASE_DIR"

# Find all eval.sh files
find $BASE_DIR -type f -name "eval.sh" | while read -r file; do
    echo "Processing $file"

    # Extract variables from the path
    DATASET=$(echo $file | cut -d '/' -f 5)
    MAG=$(echo $file | cut -d '/' -f 6 | cut -d'_' -f 1)
    PATCH_SIZE=$(echo $file | cut -d '/' -f 6 | cut -d'_' -f 2 | sed 's/px//g')
    ENCODER=$(echo $file | cut -d '/' -f 7)

    echo "Extracted variables: DATASET=$DATASET, MAG=$MAG, PATCH_SIZE=$PATCH_SIZE, ENCODER=$ENCODER"

    # Use sed to replace the variables in the eval.sh file
    sed -i "s/^MAG=.*/MAG=${MAG}/" $file
    sed -i "s/^PATCH_SIZE=.*/PATCH_SIZE=${PATCH_SIZE}/" $file
    sed -i "s/^DATASET=.*/DATASET=${DATASET}/" $file
    sed -i "s/^ENCODER=.*/ENCODER=${ENCODER}/" $file
done
